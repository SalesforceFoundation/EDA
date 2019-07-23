/*
    Copyright (c) 2019, Salesforce.org
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
* @date 2019
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Unit tests for Preferred Phone
*/
@isTest
private class CON_PreferredPhone_TEST {
    
    @testSetup
    static void dataSetup() {
        
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Phone_Enforcement__c = False)
        );
        
        // Simulate a user adding their own handler, should not need User_Managed__c to be true
        Trigger_Handler__c newHandler = new Trigger_Handler__c(
            Active__c = true,
            Asynchronous__c = false,
            Class__c = 'CON_PreferredPhone_TDTM',
            Load_Order__c = 0.2,
            Object__c = 'Contact',
            Trigger_Action__c = 'BeforeInsert;BeforeUpdate'
        );
        insert newHandler;
    }
  
  
    /* When Preferred Phone is blank and the count of valued phone fields is one
        update Preferred Phone to label of valued phone and copy the value to 
        standard Phone.
    */
    @isTest 
    static void testSinglePhoneSmartSet() {

        Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            WorkPhone__c = '1234567890'
        );

        Test.startTest();
        insert newCont;
        Test.stopTest();

        Contact newContAfter = [SELECT Id, FirstName, LastName, Name, WorkPhone__c , Phone, PreferredPhone__c FROM Contact];
        
        System.assertEquals(newContAfter.Phone, newContAfter.WorkPhone__c);
        System.assertEquals('Work', newContAfter.PreferredPhone__c);
    }
    
    /* When Standard Phone is not null and Preferred Phone is enforced update Preferred Phone
       to Other and update Other Phone to the value of Standard Phone.
    */
    @isTest 
    static void testUpdatePrefPhoneTOther() {

        Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest'
        );
        insert newCont;
        
        Test.startTest();
            newCont.Phone = '0000000000';
            update newCont;
        Test.stopTest();

        Contact newContAfterList = [SELECT Id, FirstName, LastName, Name, otherPhone , Phone, PreferredPhone__c FROM Contact WHERE Id =: newCont.Id];
        
         
        System.assertEquals('0000000000', newContAfterList.OtherPhone);
        System.assertEquals('Other', newContAfterList.PreferredPhone__c);
    }
    
    /* Clear the value in Standard Phone when the other valued Phone is cleared */
    @isTest 
    static void testClearPhoneValue() {

        Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            Phone = '111111111',
            otherPhone = '0000000000'
        );
        insert newCont;
        
        Contact newContAfter = [SELECT Id, FirstName, LastName, Name, Phone, otherPhone, PreferredPhone__c  FROM Contact where LastName = 'JohnnyTest'];
        Test.startTest();
            newContAfter.otherPhone = '';
            newContAfter.PreferredPhone__c = '';
            update newContAfter;
        Test.stopTest();

        Contact newContAfterList = [SELECT Id, FirstName, LastName, Name, otherPhone , Phone FROM Contact];
        
        
        System.assertEquals(null, newContAfterList.Phone);

    }

    /* Update standard Phone's value to another valued phone's and update Preferred Phone to
    the label of another Phone.  */
    @isTest 
    static void testOnClearOther() {
                 
        Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            WorkPhone__c  = '111111111',
            PreferredPhone__c = 'Work',
            OtherPhone  = '0000000000'
        );
        insert newCont;
        
        Contact newContAfter = [SELECT Id, FirstName, LastName, Name, Phone, otherPhone, WorkPhone__c, PreferredPhone__c  FROM Contact where LastName = 'JohnnyTest'];
        Test.startTest();
            newContAfter.WorkPhone__c = '';
            newContAfter.PreferredPhone__c = '';
            update newContAfter;
        Test.stopTest();

        Contact newContAfterList = [SELECT Id, FirstName, LastName, Name, Phone, PreferredPhone__c  FROM Contact];
                
        System.assertEquals('Other', newContAfterList.PreferredPhone__c);
        System.assertEquals('0000000000', newContAfterList.Phone);

    } 
    
    /*
     Update Preferred Phone to 'Phone (Standard)' when standard Phone's value is not same as 
     any other Phone values and when Preferred Phone is Blank and the Context is batch.
    */

    @isTest 
    static void testBatchPhoneNull() {
         
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Phone_Enforcement__c = True)
            );
        
        Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            Phone  = '111111111',
            OtherPhone  = '0000000000'
        );
        insert newCont;
        
        
        Test.startTest();
            UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Phone_Enforcement__c = False)
            );
            CON_Phone_BATCH batch = new CON_Phone_BATCH(null);
             Database.executeBatch(batch);
        Test.stopTest();

        Contact newContAfterList = [SELECT Id, FirstName, LastName, Name, PreferredPhone__c  FROM Contact];
        
        System.assertEquals('Phone (standard)', newContAfterList.PreferredPhone__c);

    }   
    
    /* 
     Updates Preferred Phone to the label of the Phone field that has a value which is not same as 
     standard phone
    */

    @isTest 
    static void testBatchOther() {
         
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Phone_Enforcement__c = True)
            );
        
        Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            Phone  = '111111111',
            OtherPhone  = '111111111'
        );
        insert newCont;
        
        
        Test.startTest();
            UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Phone_Enforcement__c = False)
            );
            CON_Phone_BATCH batch = new CON_Phone_BATCH(null);
             Database.executeBatch(batch);
        Test.stopTest();

        Contact newContAfterList = [SELECT Id, FirstName, LastName, Name, PreferredPhone__c  FROM Contact];
                
        System.assertEquals('Other', newContAfterList.PreferredPhone__c);
       
    }   
    
    /*  Validation when there are more than one phone fields but not Preferred Phone */
    @isTest 
    static void testErrorPrefBlank() {
        
        try {
            Contact newCont = new Contact(
                FirstName = 'JohnnyTest1',
                LastName = 'JohnnyTest',
                WorkPhone__c  = '111111111',
                OtherPhone  = '0000000000'
        );
            Test.startTest();
            insert newCont;
            
            Test.stopTest();
            
        }catch(Exception error) {
             System.assert(error.getMessage().contains(Label.PreferredPhoneRequiredError));

      } 
        
    } 
   
     /* Validation when Preferred Phone is selected but no other Phone Fields have a value */
    @isTest 
    static void testPrefPhoneNotBlank() {
        
        try {
            Contact newCont = new Contact(
                FirstName = 'JohnnyTest1',
                LastName = 'JohnnyTest',
                PreferredPhone__c  = 'Work'
        );
            Test.startTest();
            insert newCont;
            
            Test.stopTest();
            
        }catch(Exception error) {
             System.assert(error.getMessage().contains(Label.PreferredPhoneMatchNotNull));

      } 
    }     
    /* Validation when Preferred Phone label doesn't match any of the other fields */
    @isTest 
    static void testPrefDiffValue() {
        
        try {
            Contact newCont = new Contact(
                FirstName = 'JohnnyTest1',
                LastName = 'JohnnyTest',
                WorkPhone__c  = '111111111',
                PreferredPhone__c  = 'ForTestingPurposes'
        );
            Test.startTest();
            insert newCont;
            
            Test.stopTest();
            
        }catch(Exception error) {
             System.assert(error.getMessage().contains(Label.PreferredPhoneMatchMustExist));
        }     
    } 
    
    /*
    Update Preferred Phone when Phone Clean Up batch job is run. 
    */
    @isTest 
    static void testBatchWPreferredPhoneSelection() {
         
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Phone_Enforcement__c = True)
            );
            
        
        Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            OtherPhone  = '0000000000',
            homePhone = '111111111'
        );
        insert newCont;
        
        
        Test.startTest();
            UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Phone_Enforcement__c = False)
            );
            UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Preferred_Phone_Selection__c = 'homePhone')
            );    
        
            CON_Phone_BATCH batch = new CON_Phone_BATCH(null);
             Database.executeBatch(batch);
        Test.stopTest();

        Contact newContAfterList = [SELECT Id, FirstName, LastName, Name, Phone, PreferredPhone__c  FROM Contact];
        
        System.assertEquals('Home', newContAfterList.PreferredPhone__c);
        System.assertEquals('111111111', newContAfterList.Phone);

    }   

    /*
    Update Preferred Phone  and Phone when Phone Clean Up batch job is run with no selection done in EDA Settings. 
    */

    @isTest 
    static void testBatchWNoPreferredPhoneSelection() {
         
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Phone_Enforcement__c = True)
            );
            
        
        Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            OtherPhone  = '0000000000',
            homePhone = '111111111'
        );
        insert newCont;
        
        
        Test.startTest();
            UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Phone_Enforcement__c = False)
            );
                
        
            CON_Phone_BATCH batch = new CON_Phone_BATCH(null);
             Database.executeBatch(batch);
        Test.stopTest();

        Contact newContAfterList = [SELECT Id, FirstName, LastName, Name, Phone, PreferredPhone__c  FROM Contact];
        
        System.assert(newContAfterList.PreferredPhone__c != NULL );
        System.assert(newContAfterList.Phone != NULL);

    }  
    
    /*
    Update Preferred Phone and Phone when Phone Clean Up batch job is run with selection done in EDA Settings
    but value null on contact record.
    */

    @isTest 
    static void testBatchWPreferredPhoneSelectionMisMatch() {
         
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Phone_Enforcement__c = True)
            );
            
        
        Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            OtherPhone  = '0000000000',
            MobilePhone  = '0000000000'
        );
        insert newCont;
        
        
        Test.startTest();
            UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Phone_Enforcement__c = False)
            );
                
            UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Preferred_Phone_Selection__c = 'homePhone')
            );
            
            CON_Phone_BATCH batch = new CON_Phone_BATCH(null);
             Database.executeBatch(batch);
        Test.stopTest();

        Contact newContAfterList = [SELECT Id, FirstName, LastName, Name, Phone, PreferredPhone__c  FROM Contact];
        
        System.assert(newContAfterList.PreferredPhone__c != NULL );
        System.assert(newContAfterList.Phone == '0000000000');

    } 
    
    /*
     Copy value of Standard Phone Field to Other when Preferred Phone is Null, Standard Phone is not null and
     all other phones are null.
    */

    @isTest 
    static void testCopyStdPhoneToOther() {
         
               
        Test.startTest();
            Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            Phone  = '0000000000'
        
        );
        
        
        insert newCont;
 
        Test.stopTest();

        Contact newContAfterList = [SELECT Id, FirstName, LastName, Name, otherPhone, PreferredPhone__c  FROM Contact];
        
        System.assertEquals('Other', newContAfterList.PreferredPhone__c);
        System.assert(newContAfterList.otherPhone == '0000000000');

    } 
    
     /* When Standard Phone is not null and Preferred Phone is enforced update Preferred Phone
       to Other and update Other Phone to the value of Standard Phone.
    */
    @isTest 
    static void testUpdatePrefPhoneTOtherBulk() {
        
        List<contact> contactsToInsert = new List<contact>();
        for(Integer i = 0; i < 100; i++) {
            Contact a = new Contact(FirstName='TestAccount' + i, LastName = 'JohnnyTest' + i );
            contactsToInsert.add(a);
        }
        insert contactsToInsert;
    
        Test.startTest();
        for (contact each: contactsToInsert) {
            each.Phone = '0000000000';
        }
            update contactsToInsert;
        Test.stopTest();

        List<contact> newContAfterList = [SELECT Id, FirstName, LastName, Name, otherPhone , Phone, PreferredPhone__c FROM Contact];
        
        for (contact each: newContAfterList) { 
            System.assertEquals('0000000000', each.OtherPhone);
            System.assertEquals('Other', each.PreferredPhone__c);
        }
    }
  
}