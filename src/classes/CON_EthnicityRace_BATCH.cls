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
* @description Copies data from the Ethnicty Field to the Race Field.
*/
global class CON_EthnicityRace_BATCH implements Database.Batchable<sObject> {

    /*******************************************************************************************************
    * @description start Method for the Database.Batchable interface
    * @param bc the BatchableContext
    * @return database.Querylocator
    ********************************************************************************************************/
	global Database.QueryLocator start(Database.BatchableContext BC) {

		// Get all Contacts that have Ethnicity/Race information that is not "Hispanic or Latino" and not "Not Hispanic or Latino"
		String query = 'SELECT Id, Name, Ethnicity__c, Race__c FROM Contact WHERE Ethnicity__c != \'Hispanic or Latino\' AND Ethnicity__c != \'Not Hispanic or Latino\' AND Ethnicity__c != null';

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		System.debug(scope);

		List<Contact> contacts = (List<Contact> ) scope; //Cast list of contacts
        
        // According to the spec (https://nces.ed.gov/ipeds/Section/collecting_re on 1/13/2017) Ethnicity should only ask if Hispanic or Latino, so the other options will be copied to the Race field. 
        if(contacts.size()>0) {
	        for(Contact c : contacts) {

	        	// If the race field is populated we dont want to override it
	        	if(c.Ethnicity__c != null && c.Race__c == null) {
	        		c.Race__c = c.Ethnicity__c;
	        	}
            }
        }

        update contacts;
	}

	global void finish(Database.BatchableContext BC) {

		// Email Notification
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
							FROM AsyncApexJob WHERE Id =:BC.getJobId()];

		String emailBody = 'The batch Apex job processed ' + a.TotalJobItems +
		' batches with '+ a.NumberOfErrors + ' failures.';

		// Send an email to the Apex job's submitter notifying of job completion.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Ethnicity and Race field backfill: ' + a.Status);
		mail.setPlainTextBody(emailBody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
	}

}