/*
    Copyright (c) 2017 Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @group Error Handling
* @description Unit tests for ERR_AsyncErrors
*/
@isTest
public class ERR_AsyncErrors_TEST {
    @isTest
    private static void testQueryForErrorsInLastDayIfNotPreviouslyRun() {
        /*
         * Given that there is no 'last run' date/time stored in custom settings
         * And the current date/time is 2016-08-29 08:00:00
         * When I call execute()
         * Then async job records starting from 2016-08-28 08:00:00 should be queried
         */
        AsyncErrorsStub stub = new AsyncErrorsStub();

        stub.currentDateTime = DateTime.newInstanceGmt(2016, 8, 29, 8, 0, 0);

        stub.errorSettingsOrgDefaults = new Hierarchy_Settings__c(
            Async_Error_Check_Last_Run__c = null
        );

        stub.pendingAsyncJobErrors = new List<ERR_AsyncErrors.AsyncApexJobWrapper>();

        stub.execute(null);

        System.assertEquals(
            DateTime.newInstanceGmt(2016, 8, 28, 8, 0, 0),
            stub.pendingAsyncJobErrorsLastRun
        );
    }

    @isTest
    private static void testQueryForErrorsSinceLastRun() {
        /*
         * Given that the date/time 2016-08-28 08:00:00 is stored in custom settings as last run time
         * When I call execute()
         * Then async job records starting from 2016-08-29 08:00:00 should be queried
         */
        AsyncErrorsStub stub = new AsyncErrorsStub();

        stub.currentDateTime = DateTime.newInstanceGmt(2016, 8, 29, 8, 0, 0);

        stub.errorSettingsOrgDefaults = new Hierarchy_Settings__c(
            Async_Error_Check_Last_Run__c = DateTime.newInstanceGmt(
                2016, 8, 29, 8, 0, 0
            )
        );

        stub.pendingAsyncJobErrors = new List<ERR_AsyncErrors.AsyncApexJobWrapper>();

        stub.execute(null);

        System.assertEquals(
            DateTime.newInstanceGmt(2016, 8, 29, 8, 0, 0),
            stub.pendingAsyncJobErrorsLastRun
        );
    }

    @isTest
    private static void testQueriesForErrorsInCurrentNamespace() {
        /*
         * Given that the current namespace is 'hed'
         * When I call execute()
         * Then async job records with namespace 'hed' should be queried
         */
        AsyncErrorsStub stub = new AsyncErrorsStub();

        stub.currentDateTime = DateTime.newInstanceGmt(2016, 8, 29, 8, 0, 0);

        stub.errorSettingsOrgDefaults = new Hierarchy_Settings__c(
            Async_Error_Check_Last_Run__c = null
        );

        stub.currentNamespace = 'hed';

        stub.pendingAsyncJobErrors = new List<ERR_AsyncErrors.AsyncApexJobWrapper>();

        stub.execute(null);

        System.assertEquals(
            'hed',
            stub.pendingAsyncJobErrorsNamespace
        );
    }

    @isTest
    private static void testUpdatesLastRunSetting() {
        /*
         * Given that the current date/time is 2016-08-29 08:00:00
         * When I call execute()
         * Then the 'last run' date/time stored in custom settings should be 2016-08-29 08:00:00
         */
        AsyncErrorsStub stub = new AsyncErrorsStub();

        stub.currentDateTime = DateTime.newInstanceGmt(2016, 8, 29, 8, 0, 0);

        stub.errorSettingsOrgDefaults = new Hierarchy_Settings__c(
            Async_Error_Check_Last_Run__c = null
        );

        stub.pendingAsyncJobErrors = new List<ERR_AsyncErrors.AsyncApexJobWrapper>();

        stub.execute(null);

        System.assertEquals(
            DateTime.newInstanceGmt(2016, 8, 29, 8, 0, 0),
            stub.upsertedErrorSettings.Async_Error_Check_Last_Run__c
        );
    }

    @isTest
    private static void testInsertsErrors() {
        /*
         * Given the following AsyncApexJobWrapper objects are returned from query:
         *   | JobType       | ApexClassName | ApexClassNamespacePrefix | MethodName | CompletedDate       | ExtendedStatus  |
         *   | Future        | TestFuture    | npsp                     | callFuture | 2016-08-29 07:00:00 | Future Error    |
         *   | ScheduledApex | TestScheduled | npsp                     |            | 2016-08-29 07:00:00 | Scheduled Error |
         *   | BatchApex     | TestBatch     | foo                      |            | 2016-08-29 07:00:00 | BatchApex Error |
         *   | Queueable     | TestQueueable |                          |            | 2016-08-29 07:00:00 | Queueable Error |
         * When I call execute()
         * Then the following Error__c objects should be inserted:
         *   | Error_Type__c        | Context_Type__c             | DateTime__c         | Full_Message__c |
         *   | Future method error  | npsp__TestFuture.callFuture | 2016-08-29 07:00:00 | Future Error    |
         *   | Scheduled Apex error | npsp__TestScheduled         | 2016-08-29 07:00:00 | Scheduled Error |
         *   | Batch Apex error     | foo__TestBatch              | 2016-08-29 07:00:00 | BatchApex Error |
         *   | Queueable job error  | TestQueueable               | 2016-08-29 07:00:00 | Queueable Error |
         */
        AsyncErrorsStub stub = new AsyncErrorsStub();

        stub.currentDateTime = DateTime.newInstanceGmt(2016, 8, 29, 8, 0, 0);

        stub.errorSettingsOrgDefaults = new Hierarchy_Settings__c(
            Async_Error_Check_Last_Run__c = null
        );

        DateTime errorDateTime = DateTime.newInstanceGmt(2016, 8, 29, 7, 0, 0);
        stub.pendingAsyncJobErrors = new List<ERR_AsyncErrors.AsyncApexJobWrapper>{
            new ERR_AsyncErrors.AsyncApexJobWrapper(
                'Future', 'TestFuture', 'npsp', 'callFuture', errorDateTime, 'Future Error'
            ),
            new ERR_AsyncErrors.AsyncApexJobWrapper(
                'ScheduledApex', 'TestScheduled', 'npsp', '', errorDateTime, 'Scheduled Error'
            ),
            new ERR_AsyncErrors.AsyncApexJobWrapper(
                'BatchApex', 'TestBatch', 'foo', '', errorDateTime, 'BatchApex Error'
            ),
            new ERR_AsyncErrors.AsyncApexJobWrapper(
                'Queueable', 'TestQueueable', '', '', errorDateTime, 'Queueable Error'
            )
        };

        stub.execute(null);

        Set<Error__c> expectedErrors = new Set<Error__c>{
            new Error__c(
                Error_Type__c = 'Future method error',
                Context_Type__c = 'npsp__TestFuture.callFuture',
                DateTime__c = errorDateTime,
                Full_Message__c = 'Future Error'
            ),
            new Error__c(
                Error_Type__c = 'Scheduled Apex error',
                Context_Type__c = 'npsp__TestScheduled',
                DateTime__c = errorDateTime,
                Full_Message__c = 'Scheduled Error'
            ),
            new Error__c(
                Error_Type__c = 'Batch Apex error',
                Context_Type__c = 'foo__TestBatch',
                DateTime__c = errorDateTime,
                Full_Message__c = 'BatchApex Error'
            ),
            new Error__c(
                Error_Type__c = 'Queueable job error',
                Context_Type__c = 'TestQueueable',
                DateTime__c = errorDateTime,
                Full_Message__c = 'Queueable Error'
            )
        };

        System.assertEquals(
            expectedErrors,
            new Set<Error__c>(stub.insertedErrors)
        );
    }

    @isTest
    private static void testSendsNotifications() {
        /*
         * Given at least one AsyncApexJob error exists
         * When I call execute()
         * Then error notifications should be sent via notifications util
         */
        AsyncErrorsStub stub = new AsyncErrorsStub();

        stub.currentDateTime = DateTime.newInstanceGmt(2016, 8, 29, 8, 0, 0);

        stub.errorSettingsOrgDefaults = new Hierarchy_Settings__c(
            Async_Error_Check_Last_Run__c = null
        );

        DateTime errorDateTime = DateTime.newInstanceGmt(2016, 8, 29, 7, 0, 0);
        stub.pendingAsyncJobErrors = new List<ERR_AsyncErrors.AsyncApexJobWrapper>{
            new ERR_AsyncErrors.AsyncApexJobWrapper(
                'Future', 'TestFuture', 'npsp', 'callFuture', errorDateTime, 'Future Error'
            )
        };

        stub.execute(null);

        System.assert(stub.errorNotificationsSent);
    }


    /**
     * @description This stub class overrides behavior of ERR_AsyncErrors that
     * depends on the runtime environment.
     */
    private class AsyncErrorsStub extends ERR_AsyncErrors {
        public DateTime currentDateTime;
        public String currentNamespace;
        public Hierarchy_Settings__c errorSettingsOrgDefaults;
        public Hierarchy_Settings__c upsertedErrorSettings;
        public List<Error__c> insertedErrors;
        public Boolean errorNotificationsSent = false;
        public DateTime pendingAsyncJobErrorsLastRun;
        public String pendingAsyncJobErrorsNamespace;
        public List<ERR_AsyncErrors.AsyncApexJobWrapper> pendingAsyncJobErrors;
        private override DateTime getCurrentDateTime() {
            return currentDateTime;
        }
        private override String getCurrentNamespace() {
            return currentNamespace;
        }
		private override Hierarchy_Settings__c getErrorSettingsOrgDefaults() {
            return errorSettingsOrgDefaults;
        }
        private override void upsertErrorSettings(Hierarchy_Settings__c errorSettings) {
            upsertedErrorSettings = errorSettings;
        }
        private override void insertErrors(List<Error__c> errors) {
            insertedErrors = errors;
        }
        private override void sendErrorNotifications() {
            errorNotificationsSent = true;
        }
        private override List<ERR_AsyncErrors.AsyncApexJobWrapper> getPendingAsyncJobErrors(DateTime lastRun, String namespace) {
            pendingAsyncJobErrorsLastRun = lastRun;
            pendingAsyncJobErrorsNamespace = namespace;
            return pendingAsyncJobErrors;
        }
    }

}