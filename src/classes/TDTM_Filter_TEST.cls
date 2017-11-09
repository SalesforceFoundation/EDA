/*
    Copyright (c) 2015, Salesforce.org
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
* @date 2015
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description Testing the enhanced TDTM functionality, which applies only to certain records
* depending on their field values. 
*/
@isTest
public with sharing class TDTM_Filter_TEST {
    
    private static ID orgRecTypeID;
    private static ID householdRecTypeID;
    private static ID adminRecTypeID;
    
    public static void recTypesSetup() {
        orgRecTypeID = UTIL_Describe.getBizAccRecTypeID();
        householdRecTypeID = UTIL_Describe.getHhAccRecTypeID();
        adminRecTypeID = UTIL_Describe.getAdminAccRecTypeID();
    } 
    
    public static List<TDTM_Global_API.TdtmToken> setup() {
        insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');
        
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getTdtmConfig();

        
        //Disabling class that creates reciprocal relationships
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_TDTM') {
                token.active = false;
            }
        }
        return tokens;
    }
    
	public static testmethod void emailField() {
        List<TDTM_Global_API.TdtmToken> tokens = setup();
        
		//Creating filter condition
		for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
		        token.filterField = 'UniversityEmail__c';
                token.filterValue = null;
            }
		}
        TDTM_Global_API.setTdtmConfig(tokens, 'hed');
		
		//Creating four contacts. two of them are not students, because they don't have a university email.
		Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', UniversityEmail__c = 'tt1@fake.edu',Preferred_Email__c = 'University');
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', UniversityEmail__c = null);
		Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', UniversityEmail__c = 'tt3@fake.edu',Preferred_Email__c = 'University');
		Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', UniversityEmail__c = '');
		Contact[] contacts = new Contact[] {c1, c2, c3, c4};
		insert contacts;
		
		//Adding lookups among the contacts. Relationships should be automatically created from them.
		//Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
    	c1.ReportsToId = c2.Id;
    	c2.ReportsToId = c3.Id;
    	c3.ReportsToId = c4.Id;
    	Test.startTest();
    	update contacts;
    	Test.stopTest();
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void textField() {
		List<TDTM_Global_API.TdtmToken> tokens = setup();
                                             
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'AssistantName';
                token.filterValue = 'Anne';
            }
        }
		TDTM_Global_API.setTdtmConfig(tokens, 'hed');
		
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
    	Test.startTest();
    	update contacts;
    	Test.stopTest();
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void oneRecordOnly() {
        List<TDTM_Global_API.TdtmToken> tokens = setup();
                                             
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'AssistantName';
                token.filterValue = 'Anne';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens, 'hed');
        
        //Creating two contacts. The second one meets the filtering criteria.
        Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', AssistantName = 'Anne');
        Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', AssistantName = 'Nancy');
        Contact[] contacts = new Contact[] {c1, c2};
        insert contacts;
        
        //Adding lookups among the contacts. Relationships should be automatically created from them.
        //Using the 'ReportsTo' field because it's a standard lookup field from Contact to Contact.
        c1.ReportsToId = c2.Id;
        Test.startTest();
        update c1;
        Test.stopTest();
        
        //Since c1 should be filtered out, not relationship should be created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(0, rels.size());
    }
    
    public static testmethod void InvalidFilterField() {
        List<TDTM_Global_API.TdtmToken> tokens = setup();
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            //Creating filter condition.
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'InvalidField';
                token.filterValue = 'Anne';
            }
            //Disabling THAN_Filter_TDTM, which validates that relationship defined in a Trigger Handler
            //is valid.
            else if(token.className == 'THAN_Filter_TDTM') {
                token.active = false;
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens, 'hed');
        
        //Creating four contacts. The second one meets the filtering criteria.
        Contact c1 = new Contact(FirstName = 'Test', LastName = 'Testerson1', AssistantName = 'Nancy');
        Contact c2 = new Contact(FirstName = 'Test', LastName = 'Testerson2', AssistantName = 'Anne');
        Contact c3 = new Contact(FirstName = 'Test', LastName = 'Testerson3', AssistantName = null);
        Contact c4 = new Contact(FirstName = 'Test', LastName = 'Testerson4', AssistantName = 'John');
        Contact[] contacts = new Contact[] {c1, c2, c3, c4};
        
        try {
            Test.startTest();        
            insert contacts;
            Test.stopTest();
        } catch(Exception ex) {
            // Should throw a validation message, catching the message to the test will still complete
            System.assertEquals(true, ex.getMessage().contains(Label.InvalidFilter));
        }
    }
	
	public static testmethod void checkboxField() {
		List<TDTM_Global_API.TdtmToken> tokens = setup();                                             
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'HasOptedOutOfEmail';
                token.filterValue = 'true';
            }
        }
		TDTM_Global_API.setTdtmConfig(tokens, 'hed');
		
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
    	Test.startTest();
    	update contacts;
    	Test.stopTest();
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void phoneField() {
		List<TDTM_Global_API.TdtmToken> tokens = setup();
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'MobilePhone';
                token.filterValue = '5555-444-3322';
            }
        }
		TDTM_Global_API.setTdtmConfig(tokens, 'hed');
		
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
    	Test.startTest();
    	update contacts;
    	Test.stopTest();
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void dateField() {
		List<TDTM_Global_API.TdtmToken> tokens = setup();
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Birthdate';
                token.filterValue = '01/01/1990';
            }
        }
		TDTM_Global_API.setTdtmConfig(tokens, 'hed');
		
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
    	Test.startTest();
    	update contacts;
    	Test.stopTest();
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void picklistField() {
		List<TDTM_Global_API.TdtmToken> tokens = setup();           
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Gender__c';
                token.filterValue = 'Male';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens, 'hed');
		
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
    	Test.startTest();
    	update contacts;
    	Test.stopTest();
    	
    	//Only those from c1 and c3 should have had a relationship automatically created.
    	Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
    	System.assertEquals(2, rels.size());
	}
	
	public static testmethod void lookupField() {
		List<TDTM_Global_API.TdtmToken> tokens = setup();
        TDTM_Global_API.setTdtmConfig(tokens, 'hed');

        system.assertEquals(new List<TDTM_Global_API.TdtmToken>(), tokens);

        //since we clear the token in setTdtmConfig now, we need to get the new tokens here
        tokens = TDTM_Global_API.getTdtmConfig();
        
        Account acc1 = new Account(Name = 'Acc1'); 
		Account acc2 = new Account(Name = 'Acc2'); 
		insert new Account[] {acc1, acc2};
		UTIL_Debug.debug('****Filter value in test: ' + acc2.Id);
		                                      
		 //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Account.Id';
                token.filterValue = acc2.Id;
            }
        }

        TDTM_Global_API.setTdtmConfig(tokens, 'hed');

		
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
        List<TDTM_Global_API.TdtmToken> tokens = setup();                                             
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Account.Name';
                token.filterValue = 'Acme';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens, 'hed');
        
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
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());
    }
    
    public static testmethod void accountParentField() {
        List<TDTM_Global_API.TdtmToken> tokens = setup();                                             
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Account.Parent.Name';
                token.filterValue = 'top1';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens, 'hed');
        
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
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());
    }

    public static testmethod void recordTypeRelationship() {
        recTypesSetup();
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(), 
                Accounts_Addresses_Enabled__c = orgRecTypeID + ');' + householdRecTypeID + ');'));
                
        List<TDTM_Global_API.TdtmToken> tokens = setup();                                             
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Account.RecordType.Name';
                token.filterValue = 'Business Organization';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens, 'hed');
        
        System.assertNotEquals(null, orgRecTypeID); //Let's make sure the record type exists in the system
            
        Account accFiltered = new Account(Name = 'Acme', RecordTypeId = orgRecTypeID);
        Account accNotFiltered = new Account(Name = 'ABC', RecordTypeId = householdRecTypeID);
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
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());
    }

    public static testmethod void customObject() {
        recTypesSetup();
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(), 
                Accounts_Addresses_Enabled__c = orgRecTypeID + ');' + householdRecTypeID + ');'));
                
        List<TDTM_Global_API.TdtmToken> tokens = setup();
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Current_Address__r.Parent_Account__r.RecordType.Name';
                token.filterValue = 'Business Organization';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens, 'hed');
        
        System.assertNotEquals(null, orgRecTypeID); //Let's make sure the record type exists in the system
            
        Account accFiltered = new Account(Name = 'Acme', RecordTypeId = orgRecTypeID);
        Account accNotFiltered = new Account(Name = 'ABC', RecordTypeId = householdRecTypeID);
        insert new Account[] {accFiltered, accNotFiltered};
        
        Address__c addressFiltered = new Address__c(Parent_Account__c = accFiltered.Id, MailingStreet__c = '123 Main St');
        Address__c addressNotFiltered = new Address__c(Parent_Account__c = accNotFiltered.Id, MailingStreet__c = '123 Main St');
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
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());       
    }
    
    public static testmethod void customObjectTopOfChain() {
        recTypesSetup();
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(), 
                Accounts_Addresses_Enabled__c = orgRecTypeID + ');'));
                
        List<TDTM_Global_API.TdtmToken> tokens = setup();                                      
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Current_Address__r.Parent_Account__r.Name';
                token.filterValue = 'topAcc';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens, 'hed');
        
        Account accFiltered = new Account(Name = 'topAcc', RecordTypeId = orgRecTypeID);
        Account accNotFiltered = new Account(Name = 'ABC', RecordTypeId = orgRecTypeID);
        insert new Account[] {accFiltered, accNotFiltered};
        
        Address__c addressFiltered = new Address__c(Parent_Account__c = accFiltered.Id, MailingStreet__c = '123 Main St');
        Address__c addressNotFiltered = new Address__c(Parent_Account__c = accNotFiltered.Id, MailingStreet__c = '123 Main St');
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
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());     
    }
    
    public static testmethod void customObjectOnlyOneInChain() {
        recTypesSetup();
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(), 
                Accounts_Addresses_Enabled__c = orgRecTypeID + ');'));
                
        List<TDTM_Global_API.TdtmToken> tokens = setup();                   
        //Creating filter condition.
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Current_Address__r.Default_Address__c';
                token.filterValue = 'true';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens, 'hed');
        
        Account topAcc = new Account(Name = 'topAcc', RecordTypeId = orgRecTypeID);
        insert new Account[] {topAcc};
        
        Address__c addressFiltered = new Address__c(Parent_Account__c = topAcc.Id, Default_Address__c = true, MailingStreet__c = '123 Main St');
        Address__c addressNotFiltered = new Address__c(Parent_Account__c = topAcc.Id, Default_Address__c = false, MailingStreet__c = '123 Main St');
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
        Test.startTest();
        update contacts;
        Test.stopTest();
        
        //Only those from c1 and c3 should have had a relationship automatically created.
        Relationship__c[] rels = [select Contact__c, RelatedContact__c from Relationship__c];
        System.assertEquals(2, rels.size());     
    }
}