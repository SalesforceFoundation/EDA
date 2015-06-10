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
public with sharing class TDTM_Filter_TEST {

	// if you only want to run one test in this class, fill in its name here.
    // if you want to run all tests, then use '*'
    private static string strTestOnly = '*';
    
	public static testmethod void emailField() {
		if (strTestOnly != '*' && strTestOnly != 'emailField') return;
		
		insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
		//Creating filter condition.
		insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'UniversityEmail__c',
              Filter_Value__c = null);
		
		//Creating three contacts. One of them is not a student, because he doesn't have a university email.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', UniversityEmail__c = 'tt1@fake.edu');
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', UniversityEmail__c = null);
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', UniversityEmail__c = 'tt3@fake.edu');
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', UniversityEmail__c = '');
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because is a standard lookup field from Contact to Contact.
    	c1.ReportsToId = c2.Id;
    	c2.ReportsToId = c3.Id;
    	c3.ReportsToId = c4.Id;
    	update contacts;
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void textField() {
		if (strTestOnly != '*' && strTestOnly != 'textField') return;
		
		insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
		//Creating filter condition.
		insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'AssistantName',
              Filter_Value__c = 'Anne');
		
		//Creating three contacts. The second one meets the filtering criteria.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', AssistantName = 'Nancy');
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', AssistantName = 'Anne');
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', AssistantName = null);
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', AssistantName = 'John');
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because is a standard lookup field from Contact to Contact.
    	c1.ReportsToId = c2.Id;
    	c2.ReportsToId = c3.Id;
    	c3.ReportsToId = c4.Id;
    	update contacts;
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void checkboxField() {
		if (strTestOnly != '*' && strTestOnly != 'checkboxField') return;
		
		insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
		//Creating filter condition.
		insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'HasOptedOutOfEmail',
              Filter_Value__c = 'true');
		
		//Creating three contacts. The second one meets the filtering criteria.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', HasOptedOutOfEmail = false);
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', HasOptedOutOfEmail = true);
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', HasOptedOutOfEmail = false);
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', HasOptedOutOfEmail = null);
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because is a standard lookup field from Contact to Contact.
    	c1.ReportsToId = c2.Id;
    	c2.ReportsToId = c3.Id;
    	c3.ReportsToId = c4.Id;
    	update contacts;
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void phoneField() {
		if (strTestOnly != '*' && strTestOnly != 'phoneField') return;
		
		insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
		//Creating filter condition.
		insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'MobilePhone',
              Filter_Value__c = '5555-444-3322');
		
		//Creating three contacts. The second one meets the filtering criteria.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', MobilePhone = '5555-333-1111');
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', MobilePhone = '5555-444-3322');
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', MobilePhone = '5555-333-1111');
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', MobilePhone = null);
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because is a standard lookup field from Contact to Contact.
    	c1.ReportsToId = c2.Id;
    	c2.ReportsToId = c3.Id;
    	c3.ReportsToId = c4.Id;
    	update contacts;
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void dateField() {
		if (strTestOnly != '*' && strTestOnly != 'dateField') return;
		
		insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
		//Creating filter condition.
		insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'Birthdate',
              Filter_Value__c = '01/01/1990');
		
		//Creating three contacts. The second one meets the filtering criteria.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', Birthdate = Date.parse('01/01/1989'));
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', Birthdate = Date.parse('01/01/1990'));
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', Birthdate = Date.parse('01/01/1991'));
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', Birthdate = null);
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because is a standard lookup field from Contact to Contact.
    	c1.ReportsToId = c2.Id;
    	c2.ReportsToId = c3.Id;
    	c3.ReportsToId = c4.Id;
    	update contacts;
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void picklistField() {
		if (strTestOnly != '*' && strTestOnly != 'picklistField') return;
		
		insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
		//Creating filter condition.
		insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'Gender__c',
              Filter_Value__c = 'Male');
		
		//Creating three contacts. The second one meets the filtering criteria.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', Gender__c = 'Female');
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', Gender__c = 'Male');
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', Gender__c = 'Female');
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', Gender__c = null);
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because is a standard lookup field from Contact to Contact.
    	c1.ReportsToId = c2.Id;
    	c2.ReportsToId = c3.Id;
    	c3.ReportsToId = c4.Id;
    	update contacts;
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void lookupField() {
		if (strTestOnly != '*' && strTestOnly != 'lookupField') return;
		
		insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
        
        Account acc1 = new Account(Name = 'Acc1'); 
		Account acc2 = new Account(Name = 'Acc2'); 
		insert new Account[] {acc1, acc2};
		                                            
		//Creating filter condition.
		insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'Account',
              Filter_Value__c = acc2.Id);
		
		//Creating three contacts. The second one meets the filtering criteria.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', Account = acc1);
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', Account = acc2);
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', Account = acc1);
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', Account = null);
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because is a standard lookup field from Contact to Contact.
    	c1.ReportsToId = c2.Id;
    	c2.ReportsToId = c3.Id;
    	c3.ReportsToId = c4.Id;
    	update contacts;
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
}