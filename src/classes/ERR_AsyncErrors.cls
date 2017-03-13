/*
    Copyright (c) 2016 Salesforce.org
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
* @group ErrorHandling
* @description A recurring job that will detect errors from asynchronous jobs
* and log and send notifications for those errors
*/
public virtual class ERR_AsyncErrors implements Queueable {

    /**
     * @description Query for un-processed AsyncApexJob records that represent
     * failed jobs, creates Error__c log records for those jobs, and then sends
     * notifications for those errors
     */
    public void execute(QueueableContext qc) {
        Hierarchy_Settings__c errorSettings = getErrorSettingsOrgDefaults();
        DateTime lastRun = errorSettings.Async_Error_Check_Last_Run__c;

        // we fetch the *org defaults* custom setting, because we are using the
        // setting as a global variable to keep track of the last time we
        // processed errors (to avoid double processing).  If we queried for
        // the user's copy or profile copy of this setting, then the value
        // stored back to this setting may not be available to this job the
        // next time it runs, since it might run as a different user or
        // profile.

        DateTime now = getCurrentDateTime();

        if (lastRun == null) {
            lastRun = now.addDays(-1);
        }

        errorSettings.Async_Error_Check_Last_Run__c = now;
        upsertErrorSettings(errorSettings);

        // we only want to detect errors for this package's namespace
        String namespace = getCurrentNamespace();

        List<AsyncApexJobWrapper> asyncJobErrors = getPendingAsyncJobErrors(
            lastRun,
            namespace
        );

        List<Error__c> errors = new List<Error__c>();
        for (AsyncApexJobWrapper job : asyncJobErrors) {
            String errorMessage = job.ExtendedStatus;
            String errorType = '';
            if (job.JobType == 'Future') {
                errorType = 'Future method error';
            }
            else if (job.JobType == 'ScheduledApex') {
                errorType = 'Scheduled Apex error';
            }
            else if (job.JobType == 'BatchApex') {
                errorType = 'Batch Apex error';
            }
            else if (job.JobType == 'Queueable') {
                errorType = 'Queueable job error';
            }
            DateTime errorDate = job.CompletedDate;
            String errorContext = '';
            if (!String.isBlank(job.ApexClassNamespacePrefix)) {
                errorContext += job.ApexClassNamespacePrefix + '__';
            }
            errorContext += job.ApexClassName;
            if (job.JobType == 'Future') {
                errorContext += '.' + job.MethodName;
            }

            errors.add(
                new Error__c(
                    Error_Type__c = errorType,
                    Datetime__c = errorDate,
                    Full_Message__c = errorMessage,
                    Context_Type__c = errorContext
                )
            );
        }

        if (!errors.isEmpty()) {
            insertErrors(errors);
            sendErrorNotifications();
        }
    }

    /**
     * @description Get the current DateTime
     */
    @TestVisible
    private virtual DateTime getCurrentDateTime() {
        return DateTime.now();
    }

    @TestVisible
    private virtual String getCurrentNamespace() {
        return UTIL_Namespace.getNamespace();
    }

    /**
     * @description Query for the org default custom settings for Error
     * Settings
     *
     * @return Error_Settings__c
     */
    @TestVisible
    private virtual Hierarchy_Settings__c getErrorSettingsOrgDefaults() {
        return UTIL_CustomSettingsFacade.getSettings();
    }

    /**
     * @description Save the given Hierarchy_Settings__c
     * @param errorSettings
     */
    @TestVisible
    private virtual void upsertErrorSettings(Hierarchy_Settings__c errorSettings) {
        upsert errorSettings;
    }

    /**
     * @description Insert the given list of Error__c objects
     * @param errors The Error__c objects to insert
     */
    @TestVisible
    private virtual void insertErrors(List<Error__c> errors) {
        insert errors;
    }

    /**
     * @description Initiate the sending of error notifications
     */
    @TestVisible
    private virtual void sendErrorNotifications() {
        ERR_Notifier.sendErrorNotifications('');
    }

    /**
     * @description Get a list of AsyncApexJob records that represent jobs that
     * have errors, where the jobs were completed at or after the given lastRun
     * time, and where the associated ApexClass has the given namespace.
     *
     * @param lastRun The DateTime when the list of AsyncApexJobs was last queried/processed
     * @param namespace The namespace of the associated ApexClass of the ApexAsyncJob
     * @return List<AsyncApexJobWrapper>
     */
    @TestVisible
    private virtual List<AsyncApexJobWrapper> getPendingAsyncJobErrors(DateTime lastRun, String namespace) {
        List<AsyncApexJobWrapper> asyncJobErrors = new List<AsyncApexJobWrapper>();

        for (AsyncApexJob job : [
            SELECT
                CompletedDate,
                ExtendedStatus,
                JobItemsProcessed,
                TotalJobItems,
                NumberOfErrors,
                JobType,
                ApexClass.NamespacePrefix,
                ApexClass.Name,
                MethodName
            FROM AsyncApexJob
            WHERE ApexClass.NamespacePrefix = :namespace
            AND JobType IN ('Future', 'ScheduledApex', 'BatchApex', 'Queueable')
            AND (Status = 'Failed' OR NumberOfErrors > 0)
            AND CompletedDate >= :lastRun
        ]) {
            asyncJobErrors.add(new AsyncApexJobWrapper(job));
        }
        return asyncJobErrors;
    }

    /**
     * @description A simple wrapper class around the AsyncApexJob object.
     */
    @TestVisible
    private class AsyncApexJobWrapper {
        public String JobType;
        public String ApexClassName;
        public String ApexClassNamespacePrefix;
        public String MethodName;
        public DateTime CompletedDate;
        public String ExtendedStatus;
        public AsyncApexJobWrapper() {}
        public AsyncApexJobWrapper(
            String JobType,
            String ApexClassName,
            String ApexClassNamespacePrefix,
            String MethodName,
            DateTime CompletedDate,
            String ExtendedStatus
        ) {
            this.JobType = JobType;
            this.ApexClassName = ApexClassName;
            this.ApexClassNamespacePrefix = ApexClassNamespacePrefix;
            this.MethodName = MethodName;
            this.CompletedDate = CompletedDate;
            this.ExtendedStatus = ExtendedStatus;
        }
        public AsyncApexJobWrapper(AsyncApexJob job) {
            this(
                job.JobType,
                job.ApexClass.Name,
                job.ApexClass.NamespacePrefix,
                job.MethodName,
                job.CompletedDate,
                job.ExtendedStatus
            );
        }
    }
}