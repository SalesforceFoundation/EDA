/*
    Copyright (c) 2014, Salesforce.org
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
* @date 2014
* @group ErrorHandling
* @group-content ../../ApexDocContent/ErrorHandling.htm
* @description Notifies specific users or groups by email or Chatter when error occurs.
*/
public class ERR_Notifier {

    public static NotificationOptions notificationOptions = new NotificationOptions();
    
    /*******************************************************************************************************
    * @description Inner class with the 3 types of notification options: user, chatter group, and all system
    *              administrators.
    */
    public class NotificationOptions {
        public final String sysAdmins = 'All Sys Admins';
        public final String user = '005';  //specific user (should be a system admin)
        public final String chatterGroup = '0F9'; //chatter group
    }

    /*******************************************************************************************************
    * @description Sends error notifications to the receivers specified in the settings, if error notifications are enabled, with
    *              all the existing error records that have not been included in previous error notifications.
    * @param context The context that triggered the error notification.
    * @return void
    */
    public static void sendErrorNotifications(String context) {

        Hierarchy_Settings__c errorSettings = UTIL_CustomSettingsFacade.getSettings();
        String errorNotifRecipient = errorSettings.Error_Notifications_To__c;
            
        if (errorSettings.Error_Notifications_On__c == true && errorNotifRecipient != null) {

            //We will post to chatter, if enabled
            if(errorNotifRecipient instanceof id && errorNotifRecipient.startsWith(NotificationOptions.chatterGroup) 
            && Schema.SObjectType.User.isFeedEnabled()) {
                postErrorsToChatter(errorNotifRecipient);
            //We will send email
            } else {
                List<String> sendList = new List<String>();
                if (errorNotifRecipient instanceof id && errorNotifRecipient.startsWith(NotificationOptions.user)) {
                    List<User> useremaillist = new List<User>();
                    useremaillist = [select email from User where id = :errorNotifRecipient and isActive = true];
                    for (User u : useremaillist)
                        sendList.add(u.email);
                } else if(errorNotifRecipient == NotificationOptions.sysAdmins) {
                    list<User> sysadminlist = [select email from User where User.Profile.Name = 'System Administrator' and isActive = true];
                    for (User u : sysadminlist) {
                        sendList.add(u.email);
                    }
                }
                sendEmailNotifications(context, sendList);
            }
        }
    }

    /*******************************************************************************************************
    * @description Sends error email notifications.
    * @param context The context that triggered the error notification
    * @param sendList The list of email addresses to send notifications to.
    * @return void
    */
    private static void sendEmailNotifications(String context, List<String> sendList) {
        if ( !system.isBatch() && !system.isFuture() && Limits.getFutureCalls() < Limits.getLimitFutureCalls() ) {
            //We cannot pass the context, because only primitive types can be passed to future methods.
            sendErrorQueueEmailNotificationFuture(sendList);

        } else if ( system.isFuture() ) {
            sendErrorQueueEmailNotification(context, sendList);
        }

    }

    /*******************************************************************************************************
    * @description Sends error email notifications in a future (asynchronously). It will send an email with all the 
    *              existing error records not already sent in a notification.
    * @param context The context that triggered the error notification.
    * @param sendList The list of email addresses to send notifications to.
    * @return void
    */
    @future
    private static void sendErrorQueueEmailNotificationFuture(List<String> sendList) {
        sendErrorQueueEmailNotification(null, sendList);
    }

    /*******************************************************************************************************
    * @description Sends error email notifications synchronously. It will send an email with all the existing error
    *              records not already sent in a notification.
    * @param context The context that triggered the error notification.
    * @param sendList The list of email addresses to send notifications to.
    * @return void
    */
    private static void sendErrorQueueEmailNotification(String context, List<String> sendList) {
        List<Error__c> errors = [select Id, Error_Type__c, Datetime__c, Full_Message__c, Record_URL__c, Context_Type__c,
                                        Stack_Trace__c from Error__c where Email_Sent__c = false];

        if (!errors.isEmpty() && !sendList.isEmpty()) {
            Messaging.SingleEmailMessage sme = createEmailMessage(context, errors, sendList);

            //Prevent sending email in the unit test
            if(!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{sme});
            }


            for(Error__c error : errors)
                error.Email_Sent__c = true;

            update errors;
        }
    }

    /*******************************************************************************************************
    * @description Creates the email message to send as error notification.
    * @param context The context that triggered the error notification.
    * @param errorList The list of errors to include in the email.
    * @param sendList The list of email recipients.
    * @return 
    */
    private static Messaging.SingleEmailMessage createEmailMessage(String context, List<Error__c> errorList, List<String> sendList) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setReplyTo('donotreply@salesforcefoundation.org');
        mail.setSenderDisplayName('HEDA App');
        mail.setSubject('HEDA Error');
        string bodyString = 'Organization: ' + UserInfo.getOrganizationName() + '(' + UserInfo.getOrganizationId() + ')\n';
        bodyString += 'User: ' + UserInfo.getUserName() + '(' + UserInfo.getUserId() + ')';
        bodyString += '\n\nErrors:';
        Integer i = 1;
        for (Error__c error : errorList){
            bodystring += '\n\n----------\n Error #' + i + ': \n' + getErrorMessageBody(error);
            i++;
        }
        mail.setPlainTextBody(bodyString);
        mail.setToAddresses(sendList); 
        return mail;        
    }

    /*******************************************************************************************************
    * @description Post a message to Chatter with information about all the existing error records that were not already posted.
    * @param chatterGroupId The ID of the Chatter group to post to.
    * @return void
    */
    public static void postErrorsToChatter(String chatterGroupId) {

        if(chatterGroupId instanceof Id) {
            SObject collaborationGroup = Database.query('select Id, Name from CollaborationGroup where id = :chatterGroupId');
            List<Error__c> errors = [select Id, Error_Type__c, Datetime__c, Full_Message__c, Record_URL__c, Context_Type__c,
                                        Stack_Trace__c from Error__c where Posted_in_Chatter__c = false];    

            if (!errors.isEmpty()) {
                List<SObject> postsToInsert = new List<SObject>();
                for(Error__c error : errors) {
                    SObject post = (SObject)System.Type.forName('FeedItem').newInstance();
                    post.put('Title', 'HEDA Error');
                    String body = getErrorMessageBody(error);
                    post.put('Body', body);
                    post.put('ParentId', collaborationGroup.Id);
                    postsToInsert.add(post);
                    error.Posted_in_Chatter__c = true;
                }
                insert postsToInsert;
                update errors; //we don't want to post the same errors again    
            }
        }
    }

    /*******************************************************************************************************
    * @description Creates the body of the error message for a specific error record.
    * @param error The error record to create the message string from.
    * @return String The string representing the error record.
    */
    private static String getErrorMessageBody(Error__c error) {
        String body = '\nError Type: ' + error.Error_Type__c;
        body += '\nError Date: ' + error.Datetime__c;
        body += '\nMessage: "' + error.Full_Message__c + '"';
        if(error.Record_URL__c != null)
            body += '\n' + error.Record_URL__c;
        if(error.Context_Type__c != null)
            body += '\nContext: ' + error.Context_Type__c;
        if(error.Stack_Trace__c != null)
            body += '\n\nStack Trace:\n ' + error.Stack_Trace__c;
        return body;
    }
}