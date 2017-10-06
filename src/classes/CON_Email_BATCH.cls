/*
    Copyright (c) 2017, Salesforce.com Foundation
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation
* @date 2017
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Batch Class to process contacts on HEDA installation
*/
public class CON_Email_BATCH implements Database.Batchable<sObject>,Database.Stateful {
    public List<String> exception_List = new List<String>();
    public Integer recordCount = 0;
	
    String query = 'SELECT Id, Name, Email, Preferred_Email__c '+getCustomFields()+' FROM Contact';

    private InstallContext context;

    public CON_Email_BATCH(InstallContext ic) {
        this.context = ic;
    }

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Contact> contacts = (List<Contact> ) scope; //Cast list of contacts

        // Just run updates because the processing is part of the trigger
        //update contacts;
        Database.SaveResult[] SaveResultList = Database.update(contacts,false); 

        for(integer i =0; i<SaveResultList.size();i++){
            String msg='';
            If(!SaveResultList[i].isSuccess()){
                msg += 'Record Id: ' + contacts.get(i).id + '\n'+' Error: "';        
                for(Database.Error err: SaveResultList[i].getErrors()){  
                    msg += err.getmessage()+'"\n\n';
                } 
            }
            if(msg!='') {
                exception_List.add(msg);
            }
        }

        // Add up records completed
        recordCount += SaveResultList.size();
	}
	
	public void finish(Database.BatchableContext BC) {

        // Email Notification
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];

        // setup parameterized Email body
        String[] params = new String[]{
            String.valueOf(recordCount),
            String.valueOf(exception_List.size())
        };
        String emailBody = String.format(label.stgPreferredEmailBatchEmailBody, params) + '\n\n';
        
        if(exception_List.size() > 0) {
            // Loop through exceptions to include in Batch message
            for(String err : exception_List) {
                emailBody += err + '\n';
            }
        }   

        // Since this batch can be called by a user or the install script, we need to figure
        // out the right address to notify
        String toAddress= a.CreatedBy.Email; // Store user email that stated batch
        if(this.context != null) {
            // Get the user who initiated the install if this is called from the install script
            User u = [Select Id, Email from User where Id =:context.installerID()];  
            toAddress= u.Email; // Store manual user address
        }

        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {toAddress};
        if(toAddress != null) {
            mail.setToAddresses(toAddresses);        
            mail.setSubject(label.stgPreferredEmailBatchEmailSubject + ' ' + a.Status);
            mail.setPlainTextBody(emailBody);

            //Prevent sending email in the unit test
            if(!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }

	}

    // Dynamically build SOQL query to include all custom emails
    private String getCustomFields() {
        Map<String, Schema.DescribeFieldResult> fieldMap = UTIL_Describe.getFieldsOfType('Contact', 'EMAIL');
        String customFieldQuery = '';
        
        for(String fieldName : fieldMap.keySet() ) {
            if ( fieldName != 'Email' ) {
                customFieldQuery += ', ' + fieldName;
            }
        }

        return customFieldQuery;
    }
	
}