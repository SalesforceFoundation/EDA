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
 * @date 2017
 * @group Error Handling
 * @description Unit tests for ERR_Notifier class
 */
@isTest
private class ERR_Notifier_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ERR_Notifier class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ERR_Notifier notifierService = ERR_Notifier.getInstance();
        Test.stopTest();

        System.assertEquals(
            ERR_Notifier.instance,
            notifierService,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(true, notifierService != null, 'Instance of service class should not be null.');
        System.assertEquals(true, notifierService.sendEmailAsync, 'sendEmailAsync value should be true');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ERR_Notifier class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ERR_Notifier notifierServiceInstance1 = ERR_Notifier.getInstance();

        ERR_Notifier notifierServiceInstance2 = ERR_Notifier.getInstance();
        Test.stopTest();

        System.assertEquals(
            ERR_Notifier.instance,
            notifierServiceInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            notifierServiceInstance1,
            notifierServiceInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(true, notifierServiceInstance1 != null, 'Instance of service class should not be null.');
    }

    /**********************************************************************************************
     * @description Test retrieval of System Administrator Users' Emails
     * verify: Emails of System Administrator Users are retrieved
     */
    @IsTest
    private static void shouldMatchSystemAdminEmailList() {
        ERR_Notifier notifierService = ERR_Notifier.getInstance();
        Test.startTest();
        Set<String> recipientEmails = new Set<String>(
            notifierService.getErrorEmailRecipients(ERR_Notifier.notificationOptions.sysAdmins)
        );
        Test.stopTest();

        Set<String> expectedEmails = getSystemAdminEmails();

        System.assertEquals(expectedEmails.size(), recipientEmails.size(), 'Number of emails should match');
        System.assert(expectedEmails.containsAll(recipientEmails), 'Expected and retrieved emails should be the same');
    }

    /**********************************************************************************************
     * @description Confirm that the method to retrieve Error log record pending notification
     * only retrieve records created in the last 48 hours.
     */
    @IsTest
    private static void shouldOnlyRetrieveRecentErrorLogEntries() {
        ERR_Notifier.MAX_AGE_FOR_ERRORS = Datetime.now().addDays(-3);
        ERR_Notifier.MAX_RECORDS = 100;

        List<Error__c> errors = new List<Error__c>();
        // The oldest error will be 80 days old
        Datetime dt = Datetime.now().addDays(-80).addHours(1);
        // Create one error per day for up to 100 total records.
        for (Integer n = 0; n < 100; n++) {
            errors.add(createError(dt));
            dt = dt.addDays(1);
        }
        insert errors;

        ERR_Notifier notifierService = ERR_Notifier.getInstance();
        Test.startTest();
        List<Error__c> emailErrors = notifierService.getErrorsPendingEmailNotification();
        List<Error__c> chatterErrors = notifierService.getErrorsPendingChatterNotification();
        Test.stopTest();

        System.assertEquals(
            23, //100-80+3
            emailErrors.size(),
            'There should only be 23 errors returned.'
        );
        System.assertEquals(
            23, //100-80+3
            chatterErrors.size(),
            'There should only be 23 chatter errors returned.'
        );
        errors = emailErrors;
        errors.addAll(chatterErrors);
        for (Error__c err : errors) {
            System.assert(
                err.Datetime__c >= ERR_Notifier.MAX_AGE_FOR_ERRORS,
                'All returned errors should be newer than one day'
            );
        }
    }

    /**********************************************************************************************
     * @description Confirm that the method to retrieve Error log record pending notification
     * only retrieve a limited number of records.
     */
    @IsTest
    private static void shouldOnlyRetrieveLimitedErrorLogEntries() {
        ERR_Notifier.MAX_AGE_FOR_ERRORS = Datetime.now().addDays(-3);
        ERR_Notifier.MAX_RECORDS = 10;

        List<Error__c> errors = new List<Error__c>();
        // The oldest error will be 80 days old
        Datetime dt = Datetime.now().addDays(-80).addHours(1);
        // Create one error per day for up to 100 total records.
        for (Integer n = 0; n < 100; n++) {
            errors.add(createError(dt));
            dt = dt.addDays(1);
        }
        insert errors;

        ERR_Notifier notifierService = ERR_Notifier.getInstance();
        Test.startTest();
        List<Error__c> emailErrors = notifierService.getErrorsPendingEmailNotification();
        List<Error__c> chatterErrors = notifierService.getErrorsPendingChatterNotification();
        Test.stopTest();

        System.assertEquals(ERR_Notifier.MAX_RECORDS, emailErrors.size(), 'There should only be ten errors returned.');
        System.assertEquals(
            ERR_Notifier.MAX_RECORDS,
            chatterErrors.size(),
            'There should only be ten chatter errors returned.'
        );
        errors = emailErrors;
        errors.addAll(chatterErrors);
        for (Error__c err : errors) {
            System.assert(
                err.Datetime__c >= ERR_Notifier.MAX_AGE_FOR_ERRORS,
                'All returned errors should be newer than one day'
            );
        }
    }

    /**********************************************************************************************
     * @description Confirm that send error notification process retrieves all errors created
     * that meet the criteria and sends an email for them.
     */
    @IsTest
    private static void shouldSendEmailsToCurrentUser() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Error_Notifications_On__c = true,
                Error_Notifications_To__c = UserInfo.getUserId()
            )
        );

        List<Error__c> errors = new List<Error__c>();
        for (Integer n = 0; n < 100; n++) {
            errors.add(createError(Datetime.now()));
        }
        insert errors;

        ERR_Notifier notifierService = ERR_Notifier.getInstance();
        Test.startTest();
        notifierService.sendErrorNotifications(null);
        Test.stopTest();

        for (Error__c err : getErrors()) {
            System.assert(
                err.Email_Sent__c,
                'All emails pending notification should be marked as having an email sent'
            );
        }
    }

    /**********************************************************************************************
     * @description Confirm that send error notification process retrieves all errors created
     * that meet the criteria and sends an email for them.
     */
    @IsTest
    private static void shouldPostErrorsToChatter() {
        if (!Schema.SObjectType.User.isFeedEnabled()) {
            return;
        }

        SObject chatterGroup = (SObject) System.Type.forName('CollaborationGroup').newInstance();
        chatterGroup.put('Name', 'ChatterTestGroup');
        chatterGroup.put('CollaborationType', 'Private');
        insert chatterGroup;

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Error_Notifications_On__c = true, Error_Notifications_To__c = chatterGroup.Id)
        );

        List<Error__c> errors = new List<Error__c>();
        for (Integer n = 0; n < 100; n++) {
            errors.add(createError(Datetime.now()));
        }
        insert errors;

        ERR_Notifier notifierService = ERR_Notifier.getInstance();
        Test.startTest();
        notifierService.sendErrorNotifications(null);
        Test.stopTest();

        for (Error__c err : getErrors()) {
            System.assert(
                err.Posted_in_Chatter__c,
                'All errors pending notification should be marked as being posted to chatter'
            );
        }
    }

    /**********************************************************************************************
     * @description Confirm that errors are not posted to Chatter if the heap size limit has been reached
     */
    @IsTest
    private static void shouldNotPostErrorsToChatterWithHeapLimit() {
        if (!Schema.SObjectType.User.isFeedEnabled()) {
            return;
        }

        SObject chatterGroup = (SObject) System.Type.forName('CollaborationGroup').newInstance();
        chatterGroup.put('Name', 'ChatterTestGroup');
        chatterGroup.put('CollaborationType', 'Private');
        insert chatterGroup;

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Error_Notifications_On__c = true, Error_Notifications_To__c = chatterGroup.Id)
        );

        List<Error__c> errors = new List<Error__c>();
        for (Integer n = 0; n < 100; n++) {
            errors.add(createError(Datetime.now()));
        }
        insert errors;

        ERR_Notifier notifierService = ERR_Notifier.getInstance();
        Test.startTest();
        ERR_Notifier.MAX_HEAP_LIMIT = Limits.getHeapSize() * 0.1;
        notifierService.sendErrorNotifications(null);
        Test.stopTest();

        for (Error__c err : getErrors()) {
            System.assertEquals(
                false,
                err.Posted_in_Chatter__c,
                'All errors pending notification should NOT have been posted to chatter because over heap size limit'
            );
        }
    }

    /**********************************************************************************************
     * @description Confirm that errors are not emailed if the heap size limit has been reached
     */
    @IsTest
    private static void shouldNotEmailErrorsWithHeapLimit() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Error_Notifications_On__c = true,
                Error_Notifications_To__c = UserInfo.getUserId()
            )
        );

        List<Error__c> errors = new List<Error__c>();
        for (Integer n = 0; n < 100; n++) {
            errors.add(createError(Datetime.now()));
        }
        insert errors;

        ERR_Notifier notifierService = ERR_Notifier.getInstance();
        //Email has to be sent in sync mode so we can force the heap limit
        notifierService.sendEmailAsync = false;
        Test.startTest();
        ERR_Notifier.MAX_HEAP_LIMIT = Limits.getHeapSize() + 1;
        notifierService.sendErrorNotifications(null);
        Test.stopTest();

        for (Error__c err : getErrors()) {
            System.assertEquals(
                false,
                err.Email_Sent__c,
                'All errors pending notification should NOT have been emailed because over heap size limit'
            );
        }
    }

    // Helpers
    ////////////

    /**
     * @description Helper method to retrieve all error records
     */
    private static List<Error__c> getErrors() {
        return [
            SELECT Id, Full_Message__c, Stack_Trace__c, Email_Sent__c, Posted_in_Chatter__c, Context_Type__c
            FROM Error__c
        ];
    }

    /**********************************************************************************************
     * @description Get System Administrator User emails
     * @return Set<String> Emails
     */
    private static Set<String> getSystemAdminEmails() {
        Set<String> result = new Set<String>();

        for (User usr : [
            SELECT Email
            FROM User
            WHERE Profile.Name = :UTIL_Profile.SYSTEM_ADMINISTRATOR AND IsActive = TRUE
        ]) {
            result.add(usr.Email);
        }

        return result;
    }

    /**********************************************************************************************
     * @description Create an instance of an Error__c record
     * @return Error__c instance
     */
    private static Error__c createError(Datetime dt) {
        return new Error__c(
            Error_Type__c = 'TEST',
            Datetime__c = dt,
            Full_Message__c = 'TEST',
            Context_Type__c = 'TEST',
            Stack_Trace__c = 'TEST',
            Record_URL__c = 'https://www.salesforce.com',
            Posted_in_Chatter__c = false,
            Email_Sent__c = false
        );
    }
}
