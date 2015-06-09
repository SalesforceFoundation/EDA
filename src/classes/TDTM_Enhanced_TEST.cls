/*
    Copyright (c) 2014, Salesforce.com Foundation
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
* @date 2015
* @group TDTM
* @description Testing the enhanced TDTM functionality, which applies only to certain records
* depending on their field values. 
*/
@isTest
public with sharing class TDTM_Enhanced_TEST {

	public static testmethod void textField() {
		//Creating three contacts. One of them is not a student, because he doesn't have a university email.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', UniversityEmail__c = 'tt1@fake.edu');
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', UniversityEmail__c = null);
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', UniversityEmail__c = 'tt3@fake.edu');
		Contact[] contacts = new Contact[] {c1, c2, c3};
		insert contacts;
		
		//Creating, but not yet inserting, relationships among the contacts.
		Relationship__c rel12 = new Relationship__c(Contact__c = c1.id, RelatedContact__c = c2.id, Status__c='Active');
        Relationship__c rel13 = new Relationship__c(Contact__c = c1.id, RelatedContact__c = c3.id, Status__c='Active');
        Relationship__c rel23 = new Relationship__c(Contact__c = c2.id, RelatedContact__c = c3.id, Status__c='Active');
              
		//Creating filter condition.
		Trigger_Handler__c relTdtmEntry = [select Filter_Field__c, Filter_Value__c from Trigger_Handler__c 
											where Class__c = 'REL_Relationships_Con_TDTM'];
		relTdtmEntry.Filter_Field__c = 'UniversityEmail__c';
		relTdtmEntry.Filter_Value__c = '';
		update relTdtmEntry;
		
		//Inserting the relationships.
    	Relationship__c[] rels = new Relationship__c[] {rel12, rel13, rel23};
    	insert rels;
    	
    	//Only those that don't involve the student should  have had the reciprocal relationship automatically created.
    	rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(5, rels.size());
	}
}