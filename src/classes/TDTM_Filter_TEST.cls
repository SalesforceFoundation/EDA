/*
    Copyright (c) 2015, Salesforce.com Foundation
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
		if (strTestOnly != '*' && strTestOnly != '*') return;
		
		insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
		//Creating filter condition.
		insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'UniversityEmail__c',
              Filter_Value__c = null);
		
		//Creating four contacts. two of them are not students, because they don't have a university email.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', UniversityEmail__c = 'tt1@fake.edu');
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', UniversityEmail__c = null);
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', UniversityEmail__c = 'tt3@fake.edu');
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', UniversityEmail__c = '');
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
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
		
		//Creating four contacts. The second one meets the filtering criteria.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', AssistantName = 'Nancy');
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', AssistantName = 'Anne');
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', AssistantName = null);
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', AssistantName = 'John');
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
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
		
		//Creating four contacts. The second one meets the filtering criteria.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', HasOptedOutOfEmail = false);
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', HasOptedOutOfEmail = true);
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', HasOptedOutOfEmail = false);
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', HasOptedOutOfEmail = false); //fyi, null cannot be inserted as the value of a checkbox field
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
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
		
		//Creating four contacts. The second one meets the filtering criteria.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', MobilePhone = '5555-333-1111');
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', MobilePhone = '5555-444-3322');
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', MobilePhone = '5555-333-1111');
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', MobilePhone = null);
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
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
		
		//Creating four contacts. The second one meets the filtering criteria.
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
		
		//Creating four contacts. The second one meets the filtering criteria.
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
        
		insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete');
              
        Account acc1 = new Account(Name = 'Acc1'); 
		Account acc2 = new Account(Name = 'Acc2'); 
		insert new Account[] {acc1, acc2};
		UTIL_Debug.debug('****Filter value in test: ' + acc2.Id);
		
		//Creating filter condition.
		Trigger_Handler__c handler = [select Filter_Field__c, Filter_Value__c from Trigger_Handler__c where Class__c = 'REL_Relationships_Con_TDTM'];
		handler.Filter_Field__c = 'AccountId'; //We have to append Id because that's what's in the map of fields!
        handler.Filter_Value__c = acc2.Id;
        update handler;
		
		//Creating four contacts. The second one meets the filtering criteria.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', AccountId = acc1.Id);
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', AccountId = acc2.Id);
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', AccountId = acc1.Id);
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4');
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(0, rels.size());
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because is a standard lookup field from Contact to Contact.
    	c1.ReportsToId = c2.Id;
    	c2.ReportsToId = c3.Id;
    	c3.ReportsToId = c4.Id;
    	Test.startTest();
    	update contacts;
    	Test.stopTest();
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	for(Relationship__c rel : rels) {
    		UTIL_Debug.debug('****Contact: ' + rel.Contact__c);
    		UTIL_Debug.debug('****Related contact: ' + rel.RelatedContact__c);
    	}
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void relationshipField() {
        if (strTestOnly != '*' && strTestOnly != 'relationshipField') return;
        
        insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
        //Creating filter condition.
        insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'Account.Name',
              Filter_Value__c = 'Acme');
              
        Account accFiltered = new Account(Name = 'Acme');
        Account accNotFiltered = new Account(Name = 'ABC');
        insert new Account[] {accFiltered, accNotFiltered};
        
        //Creating four contacts. two of them are not students, because they don't have a university email.
        Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', AccountId = accNotFiltered.Id);
        Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', AccountId = accFiltered.Id);
        Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', AccountId = accNotFiltered.Id);
        Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', AccountId = accFiltered.Id);
        Contact[] contacts = new Contact[] {c1, c2, c3, c4};
        insert contacts;
        
        //Adding lookups among the contacts. Relationships should be automatically created from them.
        //Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
        c1.ReportsToId = c2.Id;
        c2.ReportsToId = c3.Id;
        c3.ReportsToId = c4.Id;
        update contacts;
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());
    }
    
    public static testmethod void accountParentField() {
        if (strTestOnly != '*' && strTestOnly != 'accountParentField') return;
        
        insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
        //Creating filter condition.
        insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'Account.Parent.Name',
              Filter_Value__c = 'top1');
              
        Account topAccountFiltered = new Account(Name = 'top1');
        Account topAccountNotFiltered = new Account(Name = 'top2');
        insert new Account[] {topAccountFiltered, topAccountNotFiltered};
              
        Account accFiltered = new Account(Name = 'Acme', ParentId = topAccountFiltered.Id);
        Account accNotFiltered = new Account(Name = 'ABC', ParentId = topAccountNotFiltered.Id);
        Account accNotFiltered2 = new Account(Name = 'XYC');
        insert new Account[] {accFiltered, accNotFiltered, accNotFiltered2};
        
        //Creating four contacts. two of them are not students, because they don't have a university email.
        Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', AccountId = accNotFiltered.Id);
        Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', AccountId = accFiltered.Id);
        Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', AccountId = accNotFiltered2.Id);
        Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', AccountId = accFiltered.Id);
        Contact[] contacts = new Contact[] {c1, c2, c3, c4};
        insert contacts;
        
        //Adding lookups among the contacts. Relationships should be automatically created from them.
        //Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
        c1.ReportsToId = c2.Id;
        c2.ReportsToId = c3.Id;
        c3.ReportsToId = c4.Id;
        update contacts;
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());
    }
    
    public static testmethod void recordTypeRelationship() {
        if (strTestOnly != '*' && strTestOnly != 'recordTypeRelationship') return;
        
        insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
        //Creating filter condition.
        insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'Account.RecordType.Name',
              Filter_Value__c = 'Business Organization');
              
        ID orgRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
        System.assertNotEquals(null, orgRecTypeID); //Let's make sure the record type exists in the system
            
        Account accFiltered = new Account(Name = 'Acme', RecordTypeId = orgRecTypeID);
        Account accNotFiltered = new Account(Name = 'ABC');
        insert new Account[] {accFiltered, accNotFiltered};
        
        //Creating four contacts. two of them are not students, because they don't have a university email.
        Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', AccountId = accNotFiltered.Id);
        Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', AccountId = accFiltered.Id);
        Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', AccountId = accNotFiltered.Id);
        Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', AccountId = accFiltered.Id);
        Contact[] contacts = new Contact[] {c1, c2, c3, c4};
        insert contacts;
        
        //Adding lookups among the contacts. Relationships should be automatically created from them.
        //Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
        c1.ReportsToId = c2.Id;
        c2.ReportsToId = c3.Id;
        c3.ReportsToId = c4.Id;
        update contacts;
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());
    }
    
    public static testmethod void customObject() {
        if (strTestOnly != '*' && strTestOnly != 'customObject') return;
        
        insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
        //Creating filter condition.
        insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'Current_Address__r.Parent_Account__r.RecordType.Name',
              Filter_Value__c = 'Business Organization');
              
        ID orgRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
        System.assertNotEquals(null, orgRecTypeID); //Let's make sure the record type exists in the system
            
        Account accFiltered = new Account(Name = 'Acme', RecordTypeId = orgRecTypeID);
        Account accNotFiltered = new Account(Name = 'ABC');
        insert new Account[] {accFiltered, accNotFiltered};
        
        Address__c addressFiltered = new Address__c(Parent_Account__c = accFiltered.Id);
        Address__c addressNotFiltered = new Address__c(Parent_Account__c = accNotFiltered.Id);
        insert new Address__c[] {addressFiltered, addressNotFiltered};
        
        //Creating four contacts. two of them are not students, because they don't have a university email.
        Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', Current_Address__c = addressNotFiltered.Id);
        Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', Current_Address__c = addressFiltered.Id);
        Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3');
        Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', Current_Address__c = addressFiltered.Id);
        Contact[] contacts = new Contact[] {c1, c2, c3, c4};
        insert contacts;
        
        //Adding lookups among the contacts. Relationships should be automatically created from them.
        //Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
        c1.ReportsToId = c2.Id;
        c2.ReportsToId = c3.Id;
        c3.ReportsToId = c4.Id;
        update contacts;
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());       
    }
    
    public static testmethod void customObjectTopOfChain() {
        if (strTestOnly != '*' && strTestOnly != 'customObjectTopOfChain') return;
        
        insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
        //Creating filter condition.
        insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'Current_Address__r.Parent_Account__r.Name',
              Filter_Value__c = 'topAcc');

        Account accFiltered = new Account(Name = 'topAcc');
        Account accNotFiltered = new Account(Name = 'ABC');
        insert new Account[] {accFiltered, accNotFiltered};
        
        Address__c addressFiltered = new Address__c(Parent_Account__c = accFiltered.Id);
        Address__c addressNotFiltered = new Address__c(Parent_Account__c = accNotFiltered.Id);
        insert new Address__c[] {addressFiltered, addressNotFiltered};
        
        //Creating four contacts. two of them are not students, because they don't have a university email.
        Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', Current_Address__c = addressNotFiltered.Id);
        Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', Current_Address__c = addressFiltered.Id);
        Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3');
        Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', Current_Address__c = addressFiltered.Id);
        Contact[] contacts = new Contact[] {c1, c2, c3, c4};
        insert contacts;
        
        //Adding lookups among the contacts. Relationships should be automatically created from them.
        //Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
        c1.ReportsToId = c2.Id;
        c2.ReportsToId = c3.Id;
        c3.ReportsToId = c4.Id;
        update contacts;
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());     
    }
    
    public static testmethod void customObjectOnlyOneInChain() {
        if (strTestOnly != '*' && strTestOnly != 'customObjectOnlyOneInChain') return;
        
        insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
                                                    
        //Creating filter condition.
        insert new Trigger_Handler__c(Active__c = true, Asynchronous__c = false, 
              Class__c = 'REL_Relationships_Con_TDTM', Load_Order__c = 1, Object__c = 'Contact', 
              Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Filter_Field__c = 'Current_Address__r.Default_Address__c',
              Filter_Value__c = 'true');

        Account topAcc = new Account(Name = 'topAcc');
        insert new Account[] {topAcc};
        
        Address__c addressFiltered = new Address__c(Parent_Account__c = topAcc.Id, Default_Address__c = true);
        Address__c addressNotFiltered = new Address__c(Parent_Account__c = topAcc.Id, Default_Address__c = false);
        insert new Address__c[] {addressFiltered, addressNotFiltered};
        
        //Creating four contacts. two of them are not students, because they don't have a university email.
        Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', Current_Address__c = addressNotFiltered.Id);
        Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', Current_Address__c = addressFiltered.Id);
        Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3');
        Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', Current_Address__c = addressFiltered.Id);
        Contact[] contacts = new Contact[] {c1, c2, c3, c4};
        insert contacts;
        
        //Adding lookups among the contacts. Relationships should be automatically created from them.
        //Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
        c1.ReportsToId = c2.Id;
        c2.ReportsToId = c3.Id;
        c3.ReportsToId = c4.Id;
        update contacts;
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());     
    }
}