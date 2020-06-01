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
private with sharing class TDTM_Filter_TEST {

    private static ID orgRecTypeID;
    private static ID householdRecTypeID;
    private static ID adminRecTypeID;

    private static void recTypesSetup() {
        orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        householdRecTypeID = UTIL_Describe_API.getHhAccRecTypeID();
        adminRecTypeID = UTIL_Describe_API.getAdminAccRecTypeID();
    }

    private static List<TDTM_Global_API.TdtmToken> setup() {
        insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId', Relationship_Type__c = 'TestType');

        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getDefaultTdtmConfig();

        //Disabling class that creates reciprocal relationships
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'REL_Relationships_TDTM') {
                token.active = false;
            }
        }
        return tokens;
    }

    @isTest
    private static void emailField() {
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();

        //Creating filter condition
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'UniversityEmail__c';
                token.filterValue = null;
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        //Creating four contacts. two of them are not students, because they don't have a university email.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.UniversityEmail__c = 'tt1@fake.edu';
        c1.Preferred_Email__c = 'University Email';

        Contact c2 = UTIL_UnitTestData_TEST.getContact();

        Contact c3 = UTIL_UnitTestData_TEST.getContact();
        c3.UniversityEmail__c = 'tt3@fake.edu';
        c3.Preferred_Email__c = 'University Email';

        Contact c4 = UTIL_UnitTestData_TEST.getContact();
        c4.UniversityEmail__c = '';

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

    @isTest
    private static void textField() {
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();

        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'AssistantName';
                token.filterValue = 'Anne';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        //Creating four contacts. The second one meets the filtering criteria.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.AssistantName = 'Nancy';
        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.AssistantName = 'Anne';
        Contact c3 =  UTIL_UnitTestData_TEST.getContact();
        Contact c4 = UTIL_UnitTestData_TEST.getContact();
        c4.AssistantName = 'John';

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

    @isTest
    private static void oneRecordOnly() {
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();
        
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'AssistantName';
                token.filterValue = 'Anne';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        //Creating two contacts. The second one meets the filtering criteria.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.AssistantName = 'Anne';
        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.AssistantName = 'Nancy';

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

    @isTest
    private static void InvalidFilterField() {
        //If we use getDefaultTDTMConfig from setup, then we can't save the token with invalid field. Because the default token in the database still have THAN_Filter_TDTM = Acive. So, we need to call getTDTMConfig, modify the cache directly and save the token.
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getTdtmConfig();
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            //Creating filter condition.
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'InvalidField';
                token.filterValue = 'Anne';
            }
            //Disabling THAN_Filter_TDTM, which validates that relationship defined in a Trigger Handler
            //is valid.
            else if (token.className == 'THAN_Filter_TDTM') {
                token.active = false;
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        //Creating four contacts. The second one meets the filtering criteria.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.AssistantName = 'Nancy';
        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.AssistantName = 'Anne';
        Contact c3 =  UTIL_UnitTestData_TEST.getContact();
        Contact c4 = UTIL_UnitTestData_TEST.getContact();
        c4.AssistantName = 'John';
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

    @isTest
    private static void checkboxField() {
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();                                             
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'HasOptedOutOfEmail';
                token.filterValue = 'true';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        //Creating four contacts. The second one meets the filtering criteria.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.HasOptedOutOfEmail = false;

        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.HasOptedOutOfEmail = true;

        Contact c3 = UTIL_UnitTestData_TEST.getContact();
        c3.HasOptedOutOfEmail = false;

        Contact c4 = UTIL_UnitTestData_TEST.getContact();
        c4.HasOptedOutOfEmail = false; //fyi, null cannot be inserted as the value of a checkbox field

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

    @isTest
    private static void phoneField() {
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'MobilePhone';
                token.filterValue = '5555-444-3322';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        //Creating four contacts. The second one meets the filtering criteria.
        Contact c1 = UTIL_UnitTestData_TEST.getContact(); 
        c1.MobilePhone = '5555-333-1111';

        Contact c2 = UTIL_UnitTestData_TEST.getContact(); 
        c2.MobilePhone = '5555-444-3322';

        Contact c3 = UTIL_UnitTestData_TEST.getContact(); 
        c3.MobilePhone = '5555-333-1111';

        Contact c4 = UTIL_UnitTestData_TEST.getContact();

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

    @isTest
    private static void dateField() {
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Birthdate';
                token.filterValue = '01/01/1990';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        //Creating four contacts. The second one meets the filtering criteria.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.Birthdate = Date.parse('01/01/1989');

        Contact c2 = UTIL_UnitTestData_TEST.getContact(); 
        c2.Birthdate = Date.parse('01/01/1990');

        Contact c3 = UTIL_UnitTestData_TEST.getContact();
        c3.Birthdate = Date.parse('01/01/1991');

        Contact c4 = UTIL_UnitTestData_TEST.getContact();

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

    @isTest
    private static void picklistField() {
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();           
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Gender__c';
                token.filterValue = 'Male';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        //Creating four contacts. The second one meets the filtering criteria.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.Gender__c = 'Female';

        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.Gender__c = 'Male';

        Contact c3 = UTIL_UnitTestData_TEST.getContact();
        c3.Gender__c = 'Female';

        Contact c4 = UTIL_UnitTestData_TEST.getContact();

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

    @isTest
    public static void lookupField() {
        TDTM_Filter_TEST.recTypesSetup();
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();
        TDTM_Global_API.setTdtmConfig(tokens);

        Account acc1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        Account acc2 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, householdRecTypeID)[0];

        insert new Account[] {acc1, acc2};
                      
         //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Account.Id';
                token.filterValue = acc2.Id;
            }
        }

        TDTM_Global_API.setTdtmConfig(tokens, 'hed');

        //Creating four contacts. The second one meets the filtering criteria.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.AccountId = acc1.Id;

        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.AccountId = acc2.Id;

        Contact c3 = UTIL_UnitTestData_TEST.getContact();
        c3.AccountId = acc1.Id;

        Contact c4 =  UTIL_UnitTestData_TEST.getContact();

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
        for (Relationship__c rel : rels) {
            UTIL_Debug.debug('****Contact: ' + rel.Contact__c);
            UTIL_Debug.debug('****Related contact: ' + rel.RelatedContact__c);
        }
        System.assertEquals(2, rels.size());
    }

    @isTest
    private static void relationshipField() {
        TDTM_Filter_TEST.recTypesSetup();
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();                                             
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Account.Name';
                token.filterValue = 'Acme';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        Account accFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        accFiltered.Name = 'Acme';
        Account accNotFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        accNotFiltered.Name = 'ABC';

        insert new Account[] {accFiltered, accNotFiltered};

        //Creating four contacts. two of them are not students, because they don't have a university email.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.AccountId = accNotFiltered.Id;

        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.AccountId = accFiltered.Id;

        Contact c3 = UTIL_UnitTestData_TEST.getContact();
        c3.AccountId = accNotFiltered.Id;

        Contact c4 = UTIL_UnitTestData_TEST.getContact();
        c4.AccountId = accFiltered.Id;
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

    @isTest
    private static void accountParentField() {
        TDTM_Filter_TEST.recTypesSetup();
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();                                             
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Account.Parent.Name';
                token.filterValue = 'top1';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        Account topAccountFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        topAccountFiltered.Name = 'top1';
        Account topAccountNotFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        topAccountNotFiltered.Name = 'top2';

        insert new Account[] {topAccountFiltered, topAccountNotFiltered};

        Account accFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        accFiltered.Name = 'Acme';
        accFiltered.ParentId = topAccountFiltered.Id;
        Account accNotFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        accNotFiltered.Name = 'ABC';
        accNotFiltered.ParentId = topAccountNotFiltered.Id;
        Account accNotFiltered2 =  UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        accNotFiltered2.Name = 'XYC';

        insert new Account[] {accFiltered, accNotFiltered, accNotFiltered2};

        //Creating four contacts. two of them are not students, because they don't have a university email.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.AccountId = accNotFiltered.Id;

        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.AccountId = accFiltered.Id;

        Contact c3 = UTIL_UnitTestData_TEST.getContact();
        c3.AccountId = accNotFiltered2.Id;

        Contact c4 = UTIL_UnitTestData_TEST.getContact();
        c4.AccountId = accFiltered.Id;

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

    @isTest
    private static void recordTypeRelationship() {
        TDTM_Filter_TEST.recTypesSetup();
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(), 
                Accounts_Addresses_Enabled__c = orgRecTypeID + ');' + householdRecTypeID + ');'));

        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();                                             
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Account.RecordType.Name';
                token.filterValue = 'Business Organization';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        System.assertNotEquals(null, orgRecTypeID); //Let's make sure the record type exists in the system

        Account accFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        accFiltered.Name = 'ACME';
        Account accNotFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, householdRecTypeID)[0];
        accFiltered.Name = 'ABC';

        insert new Account[] {accFiltered, accNotFiltered};

        //Creating four contacts. two of them are not students, because they don't have a university email.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.AccountId = accNotFiltered.Id;

        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.AccountId = accFiltered.Id;

        Contact c3 = UTIL_UnitTestData_TEST.getContact();
        c3.AccountId = accNotFiltered.Id;
 
        Contact c4 = UTIL_UnitTestData_TEST.getContact();
        c4.AccountId = accFiltered.Id;

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

    @isTest
    private static void customObject() {
        TDTM_Filter_TEST.recTypesSetup();
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(), 
                Accounts_Addresses_Enabled__c = orgRecTypeID + ');' + householdRecTypeID + ');'));

        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Current_Address__r.Parent_Account__r.RecordType.Name';
                token.filterValue = 'Business Organization';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        System.assertNotEquals(null, orgRecTypeID); //Let's make sure the record type exists in the system

        Account accFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        Account accNotFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, householdRecTypeID)[0];

        insert new Account[] {accFiltered, accNotFiltered};

        Address__c addressFiltered = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        addressFiltered.Parent_Account__c = accFiltered.Id;
        addressFiltered.MailingStreet__c = '123 Main St';

        Address__c addressNotFiltered = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        addressNotFiltered.Parent_Account__c = accNotFiltered.Id; 
        addressNotFiltered.MailingStreet__c = '123 Main St';

        insert new Address__c[] {addressFiltered, addressNotFiltered};

        //Creating four contacts. two of them are not students, because they don't have a university email.

        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.Current_Address__c = addressNotFiltered.Id;

        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.Current_Address__c = addressFiltered.Id;

        Contact c3 =  UTIL_UnitTestData_TEST.getContact();

        Contact c4 = UTIL_UnitTestData_TEST.getContact();
        c4.Current_Address__c = addressFiltered.Id;

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

    @isTest
    private static void customObjectTopOfChain() {
        TDTM_Filter_TEST.recTypesSetup();
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(), 
                Accounts_Addresses_Enabled__c = orgRecTypeID + ');'));

        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();                                      
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Current_Address__r.Parent_Account__r.Name';
                token.filterValue = 'topAcc';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        Account accFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        accFiltered.Name = 'topAcc';
        Account accNotFiltered = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        accNotFiltered.Name = 'ABC';

        insert new Account[] {accFiltered, accNotFiltered};

        Address__c addressFiltered = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0]; 
        addressFiltered.Parent_Account__c = accFiltered.Id;
        addressFiltered.MailingStreet__c = '123 Main St';

        Address__c addressNotFiltered = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0]; 
        addressNotFiltered.Parent_Account__c = accNotFiltered.Id;
        addressNotFiltered.MailingStreet__c = '123 Main St';

        insert new Address__c[] {addressFiltered, addressNotFiltered};

        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.Current_Address__c = addressNotFiltered.Id;

        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.Current_Address__c = addressFiltered.Id;

        Contact c3 =  UTIL_UnitTestData_TEST.getContact();

        Contact c4 = UTIL_UnitTestData_TEST.getContact();
        c4.Current_Address__c = addressFiltered.Id;

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

    @isTest
    private static void customObjectOnlyOneInChain() {
        TDTM_Filter_TEST.recTypesSetup();
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(), 
                Accounts_Addresses_Enabled__c = orgRecTypeID + ');'));

        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();                   
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'REL_Relationships_Con_TDTM') {
                token.filterField = 'Current_Address__r.Default_Address__c';
                token.filterValue = 'true';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        Account topAcc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, orgRecTypeID)[0];
        topAcc.Name = 'topAcc';

        insert topAcc;

        Address__c addressFiltered = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0];
        addressFiltered.Parent_Account__c = topAcc.Id;
        addressFiltered.Default_Address__c = true;
        addressFiltered.MailingStreet__c = '123 Main St';

        Address__c addressNotFiltered = UTIL_UnitTestData_TEST.getMultipleTestAddresses(1)[0]; 
        addressNotFiltered.Parent_Account__c = topAcc.Id;
        addressNotFiltered.Default_Address__c = false;
        addressNotFiltered.MailingStreet__c = '123 Main St';

        insert new Address__c[] {addressFiltered, addressNotFiltered};

        //Creating four contacts. two of them are not students, because they don't have a university email.
        Contact c1 = UTIL_UnitTestData_TEST.getContact();
        c1.Current_Address__c = addressNotFiltered.Id;

        Contact c2 = UTIL_UnitTestData_TEST.getContact();
        c2.Current_Address__c = addressFiltered.Id;

        Contact c3 =  UTIL_UnitTestData_TEST.getContact();

        Contact c4 = UTIL_UnitTestData_TEST.getContact();
        c4.Current_Address__c = addressFiltered.Id;

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

    /*********************************************************************************************************
    * @description Update a contact to meet currency trigger handler filter. Make sure trigger does not run.
    */
    @isTest
    public static void filterCurrencyField() {
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'CON_DoNotContact_TDTM') {
                token.filterField = 'Account.AnnualRevenue';
                token.filterValue = '25';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        insert testContact;

        //Use account because contact has no corrency/number field
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        testAccount.AnnualRevenue = 25;
        update testAccount;

        Test.startTest();
            testContact.Deceased__c = true;
            update testContact;
        Test.stopTest();

        Contact assertContact = [SELECT Id,
                                        Exclude_from_Household_Name__c,
                                        Do_Not_Contact__c
                                FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(false, assertContact.Exclude_from_Household_Name__c);
        System.assertEquals(false, testContact.Do_Not_Contact__c);

    }

    /*********************************************************************************************************
    * @description Update a contact to meet number trigger handler filter. Make sure trigger does not run.
    */
    @isTest
    public static void filterNumberField() {
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Filter_TEST.setup();
        //Creating filter condition.
        for (TDTM_Global_API.TdtmToken token : tokens) {
            if (token.className == 'CON_DoNotContact_TDTM') {
                token.filterField = 'Account.NumberOfEmployees';
                token.filterValue = '25';
            }
        }
        TDTM_Global_API.setTdtmConfig(tokens);

        Contact testContact = UTIL_UnitTestData_TEST.getContact();
        insert testContact;

        //Use account because contact has no corrency/number field
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        testAccount.NumberOfEmployees = 25;
        update testAccount;

        Test.startTest();
            testContact.Deceased__c = true;
            update testContact;
        Test.stopTest();

        Contact assertContact = [SELECT Id,
                Exclude_from_Household_Name__c,
                Do_Not_Contact__c
        FROM Contact WHERE Id = :testContact.Id];

        System.assertEquals(false, assertContact.Exclude_from_Household_Name__c);
        System.assertEquals(false, testContact.Do_Not_Contact__c);

    }

}