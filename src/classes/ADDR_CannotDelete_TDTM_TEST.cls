/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Tests for ADDR_CannotDelete_TDTM.
*/

@isTest
public with sharing class ADDR_CannotDelete_TDTM_TEST {
    /*********************************************************************************************************
    * @description Retrieves the Business Account record type Id. 
    */
    public static String bizAccRecordTypeId = UTIL_Describe_API.getBizAccRecTypeID(); 

    /*********************************************************************************************************
    * @description Test method to test that when Prevent_Address_Deletion__c is enabled in Hierarchy Settings, and
    * Address has an Account record associated to it, the Address record cannot be deleted.
    */
    @isTest 
    public static void addrCannotDeleteWithAccount() {
        Integer recordCount = 10;
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = bizAccRecordTypeId,
                                                            Prevent_Address_Deletion__c = TRUE));

        UTIL_UnitTestData_TEST.AccsWithAddrs addrsWithChildAccount = UTIL_UnitTestData_TEST.createTestAccsAddrs(recordCount, bizAccRecordTypeId);

        List<Account> returnNewAccounts = addrsWithChildAccount.accs; 
        List<Address__c> returnNewAddresses = addrsWithChildAccount.addrs; 
        System.assertEquals(recordCount, returnNewAddresses.size());

        for (Integer count = 0; count < returnNewAddresses.size(); count++){
            System.assertEquals(returnNewAddresses[count].Id, returnNewAccounts[count].Current_Address__c);
        }
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(returnNewAddresses, false);
        Test.stopTest();

        List<Address__c> returnAddresses = [SELECT Id
                                        FROM Address__c
                                        WHERE Id IN :returnNewAddresses];

        System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
        System.assertEquals(returnNewAddresses.size(), returnAddresses.size());
    }

    @isTest
    public static void addrCannotDeleteWithContact(){
        Integer recordCount = 10;
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Address_Deletion__c = TRUE));

        UTIL_UnitTestData_TEST.ContactsWithAddrs addrsWithChildContact = UTIL_UnitTestData_TEST.createTestContactsAddrs(recordCount);

        List<Contact> returnNewContacts = addrsWithChildContact.contacts; 
        List<Address__c> returnNewAddresses = addrsWithChildContact.addrs; 
        System.assertEquals(recordCount, returnNewAddresses.size());

        for (Integer count = 0; count < returnNewAddresses.size(); count++){
            System.assertEquals(returnNewAddresses[count].Id, returnNewContacts[count].Current_Address__c);
        }
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(returnNewAddresses, false);
        Test.stopTest();

        List<Address__c> returnAddresses = [SELECT Id
                                        FROM Address__c
                                        WHERE Id IN :returnNewAddresses];

        //System.assertEquals(Label.CannotDelete, results[0].errors[0].message);
        System.assertEquals(returnNewAddresses.size(), returnAddresses.size());
        for (Database.DeleteResult result : results){
            System.assertEquals(Label.CannotDelete, result.errors[0].message);
        }
    }

    @isTest
    public static void addrCanDeleteWithAccount(){
        Integer recordCount = 10;
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = bizAccRecordTypeId,
                                                            Prevent_Address_Deletion__c = FALSE));

        UTIL_UnitTestData_TEST.AccsWithAddrs addrsWithChildAccount = UTIL_UnitTestData_TEST.createTestAccsAddrs(recordCount, bizAccRecordTypeId);

        List<Account> returnNewAccounts = addrsWithChildAccount.accs; 
        List<Address__c> returnNewAddresses = addrsWithChildAccount.addrs; 
        System.assertEquals(recordCount, returnNewAddresses.size());

        for (Integer count = 0; count < returnNewAddresses.size(); count++){
            System.assertEquals(returnNewAddresses[count].Id, returnNewAccounts[count].Current_Address__c);
        }
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(returnNewAddresses, false);
        Test.stopTest();

        List<Address__c> returnAddresses = [SELECT Id
                                        FROM Address__c
                                        WHERE Id IN :returnNewAddresses];

        System.assert(returnAddresses.isEmpty());
        for (Database.DeleteResult result : results){
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    @isTest
    public static void addrCanDeleteWithContact(){
        Integer recordCount = 10;
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Prevent_Address_Deletion__c = FALSE));

        UTIL_UnitTestData_TEST.ContactsWithAddrs addrsWithChildContact = UTIL_UnitTestData_TEST.createTestContactsAddrs(recordCount);

        List<Contact> returnNewContacts = addrsWithChildContact.contacts; 
        List<Address__c> returnNewAddresses = addrsWithChildContact.addrs; 
        System.assertEquals(recordCount, returnNewAddresses.size());

        for (Integer count = 0; count < returnNewAddresses.size(); count++){
            System.assertEquals(returnNewAddresses[count].Id, returnNewContacts[count].Current_Address__c);
        }
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(returnNewAddresses, false);
        Test.stopTest();

        List<Address__c> returnAddresses = [SELECT Id
                                        FROM Address__c
                                        WHERE Id IN :returnNewAddresses];

        
        System.assert(returnAddresses.isEmpty());

        for (Database.DeleteResult result : results){
            System.assertEquals(TRUE, result.isSuccess());
        }
        
    }

    @isTest
    public static void addressCanDeleteWithoutChildrenPreventDeleteOn(){
        Integer recordCount = 10;
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = bizAccRecordTypeId,
                                                            Prevent_Address_Deletion__c = TRUE));

        
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, bizAccRecordTypeId);
        insert accounts;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(recordCount);

        for (Integer index = 0; index < recordCount/2; index++){
            addresses[index].Parent_Account__c = accounts[0].Id;
        }

        for (Integer index = recordCount/2; index < recordCount; index++){
            addresses[index].Parent_Contact__c = contacts[0].Id;
        }
        
        insert addresses;
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(addresses, false);
        Test.stopTest();

        List<Address__c> returnAddresses = [SELECT Id
                                        FROM Address__c
                                        WHERE Id IN :addresses];

        System.assert(returnAddresses.isEmpty());

        for (Database.DeleteResult result : results){
            System.assertEquals(TRUE, result.isSuccess());
        }
    }

    @isTest
    public static void addressCanDeleteWithoutChildrenPreventDeleteOff(){
        Integer recordCount = 10;
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                            (Account_Processor__c = bizAccRecordTypeId,
                                                            Prevent_Address_Deletion__c = FALSE));

        
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, bizAccRecordTypeId);
        insert accounts;

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(1);
        insert contacts;

        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(recordCount);

        for (Integer index = 0; index < recordCount/2; index++){
            addresses[index].Parent_Account__c = accounts[0].Id;
        }

        for (Integer index = recordCount/2; index < recordCount; index++){
            addresses[index].Parent_Contact__c = contacts[0].Id;
        }
        
        insert addresses;
        
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(addresses, false);
        Test.stopTest();

        List<Address__c> returnAddresses = [SELECT Id
                                        FROM Address__c
                                        WHERE Id IN :addresses];

        System.assert(returnAddresses.isEmpty());

        for (Database.DeleteResult result : results){
            System.assertEquals(TRUE, result.isSuccess());
        }
    }


}
