/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @group Address__c
* @group-content ../../ApexDocContent/Address__c.htm
* @description Tests the various trigger context process for ADDR_Addresses_TDTM. It tests both positive 
* and negative scenario where an Address record matches the filter field + filter value and an Address 
* record that does not match the filter field + filter value on the ADDR_Addresses_TDTM trigger handler record.
*/
@isTest	
public class ADDR_Address_TEST {
    /*********************************************************************************************************
    * @description Test setup to create multiple contacts. 
    */
    @testSetup
    static void testSetup() {
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);  
        insert contacts;  
    }
    
    /**********************************************************************************************************
    * @description Test method that specifically verifies the following for beforeInsert:
    * (1) When a new Address record is created and it doesn't match the filter, and Default_Address__c is set 
    * to true, it should populate Latest_Start_Date__c with today's date. 
    * (2) When a new Address record is created and it does match the filter, and Default_Address__c is set 
    * to true, it should not populate Latest_Start_Date__c with today's date. 
    */
    @isTest
    private static void beforeInsertAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                                                                               Contacts_Addresses_Enabled__c = true));
        
        //Retrieves the defaultTDTMConfig
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getDefaultTdtmConfig(); 
        
        List<Contact> contacts = [SELECT Id 
                                  FROM Contact LIMIT 2]; 
        
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2); 
        
        //Add filter on ADDR_Addresses_TDTM triggerHandler
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'ADDR_Addresses_TDTM') {
                token.filterField = 'MailingCity__c';
                token.filterValue = 'Brooklyn';
            }
        }
        
        TDTM_Global_API.setTdtmConfig(tokens);
        
        //Update address records for a positive and negative outcome 
        addresses[0].Parent_Contact__c = contacts[0].Id; 
        addresses[0].Default_Address__c = TRUE; 
        addresses[0].MailingCity__c = 'Boston'; 
        addresses[1].Parent_Contact__c = contacts[1].Id; 
        addresses[1].Default_Address__c = TRUE; 
        addresses[1].MailingCity__c = 'Brooklyn'; 
        
        Test.startTest();
        insert addresses;
        Test.stopTest(); 
        
        
        
        
        //Address 1: Should enter beforeInsert process and populate the Latest_Start_Date__c 
        //Address 2: Should NOT enter beforeInsert process and will NOT populate the Latest_Start_Date__c 
        List<Address__c> returnAddresses = [SELECT Id, MailingCity__c, Latest_Start_Date__c, Default_Address__c
                                            FROM Address__c
                                            WHERE Id IN :addresses];
        System.assertEquals(2, returnAddresses.size());
        
        Map<String, Address__c> cityByAddress = new Map<String, Address__c>(); 
        for (Address__c addr : returnAddresses) {
            cityByAddress.put(addr.MailingCity__c, addr); 
        }
        System.assertEquals(TRUE, cityByAddress.get('Boston').Default_Address__c); 
        System.assertEquals(TRUE, cityByAddress.get('Brooklyn').Default_Address__c);
        System.assertEquals(System.today(), cityByAddress.get('Boston').Latest_Start_Date__c);
        
    }
    
    /**********************************************************************************************************
    * @description Test method that specifically verifies the following for beforeUpdate:
    * (1) When an existing Address record is updated and it doesn't match the filter, and Default_Address__c is set
    * to false, it should populate Latest_End_Date__c with today's date. 
    * (2) When an existing Address record is updated and it doesn't match the filter, and Default_Address__c is set 
    * to true, it should populate Latest_Start_Date__c with today's date. 
    * (3) When an existing Address record is updated and it does match the filter, and Default_Address__c is set 
    * to false, it should not populate Latest_End_Date__c with today's date. 
    * (4) When an existing Address record is updated and it doesn't match the filter, and Default_Address__c is set
    * to true, it should not populate Latest_Start_Date__c with today's date. 
    */
    @isTest
    private static void beforeUpdateAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                                                                               Contacts_Addresses_Enabled__c = true));
        
        //Retrieves the defaultTDTMConfig 
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getDefaultTdtmConfig(); 
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        List<Contact> contacts = contactsAddrs.contacts; 
        List<Address__c> addresses = contactsAddrs.addrs;
        
        //Add filter on ADDR_Addresses_TDTM triggerHandler
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'ADDR_Addresses_TDTM') {
                token.filterField = 'MailingCity__c';
                token.filterValue = 'Brooklyn';
            }
        }
        
        TDTM_Global_API.setTdtmConfig(tokens);
        
        //Update address records for a positive and negative outcome 
        for (Integer i = 0; i < addresses.size(); i++) {
            Address__c addr = addresses[i];
            if (i == 0) {
                addr.Default_Address__c = FALSE; 
            } else if (i == 1) {
                addr.MailingCity__c = 'Brooklyn';
                addr.Default_Address__c = FALSE; 
            } 
        }
        
        update addresses; 
        
        List<Address__c> returnAddresses = [SELECT Id, MailingCity__c, Latest_Start_Date__c, Latest_End_Date__c, Default_Address__c
                                            FROM Address__c 
                                            WHERE Id IN :addresses]; 
        System.assertEquals(2, returnAddresses.size()); 
        
        Map<String, Address__c> cityByAddress = new Map<String, Address__c>(); 
        for (Address__c addr : returnAddresses) {
            cityByAddress.put(addr.MailingCity__c, addr); 
        }
        System.assertEquals(FALSE, cityByAddress.get('City0').Default_Address__c); 
        System.assertEquals(System.today(), cityByAddress.get('City0').Latest_End_Date__c);
        System.assertEquals(FALSE, cityByAddress.get('Brooklyn').Default_Address__c);
        System.assertEquals(NULL, cityByAddress.get('Brooklyn').Latest_End_Date__c);
         
        addresses[1].Default_Address__c = TRUE; 
        
        Test.startTest();
        update addresses; 
        Test.stopTest(); 
        
        List<Address__c> returnFinalAddresses = [SELECT Id, MailingCity__c, Latest_Start_Date__c, Latest_End_Date__c, Default_Address__c
                                                 FROM Address__c 
                                                 WHERE Id IN :addresses]; 
        Map<String, Address__c> finalCityByAddress = new Map<String, Address__c>(); 
        for (Address__c finalAddr : returnFinalAddresses) {
            finalCityByAddress.put(finalAddr.MailingCity__c, finalAddr); 
        }
        System.assertEquals(TRUE, finalCityByAddress.get('Brooklyn').Default_Address__c); 
        System.assertEquals(NULL, finalCityByAddress.get('Brooklyn').Latest_Start_Date__c); 
        System.assertEquals(NULL, finalCityByAddress.get('Brooklyn').Latest_End_Date__c); 

    }
    
    /**********************************************************************************************************
    * @description Test method that specifically verifies the following for beforeUpdate:
    * (1) When an existing Address record is updated and it doesn't match the filter, and Default_Address__c is updated
    * to true, it should populate Latest_Start_Date__c with today's date. 
    * (2) When an existing Address record is updated and it does match the filter, and Default_Address__c is set 
    * to true, it should not populate Latest_Start_Date__c with today's date. 
    */
    @isTest
    private static void beforeUpdateDefaultAddrChanged() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                                                                               Contacts_Addresses_Enabled__c = true));
        
        //Retrieves the defaultTDTMConfig 
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getDefaultTdtmConfig(); 
        
        List<Contact> contacts = [SELECT Id
                                  FROM Contact LIMIT 2]; 
        
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2); 
        addresses[0].Parent_Contact__c = contacts[0].Id; 
        addresses[0].Default_Address__c = False; 
        addresses[0].MailingCity__c = 'Boston'; 
        addresses[1].Parent_Contact__c = contacts[1].Id; 
        addresses[1].Default_Address__c = TRUE; 
        addresses[1].MailingCity__c = 'Brooklyn'; 
        insert addresses; 
        
        //Add filter on ADDR_Addresses_TDTM triggerHandler
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'ADDR_Addresses_TDTM') {
                token.filterField = 'MailingCity__c';
                token.filterValue = 'Brooklyn';
            }
        }
        
        TDTM_Global_API.setTdtmConfig(tokens);
        
        addresses[0].Default_Address__c = TRUE; 
        
        Test.startTest();
        update addresses;
        Test.stopTest(); 
        
        List<Address__c> returnAddresses = [SELECT Id, Latest_Start_Date__c, MailingCity__c
                                            FROM Address__c
                                            WHERE Id IN :addresses]; 
        Map<String, Address__c> cityByAddress = new Map<String, Address__c>(); 
        for (Address__c addr : returnAddresses) {
            cityByAddress.put(addr.MailingCity__c, addr); 
        }
        System.assertEquals(System.today(), cityByAddress.get('Boston').Latest_Start_Date__c); 

    }
    
    /*********************************************************************************************************
    * @description Test method that specifically verifies the following for afterInsert:
    * (1) When a new Address record is created and it doesn't match the filter, and Default_Address__c is set
    * to true, it should populate Current_Address__c and MailingAddress fields on the Parent Contact. 
    * (2) When a new Address record is created and it does match the filter, and Default_Address__c is set to
    * true, it should not populate Current_Address__c and MailingAddress fields on the Parent Contact. 
    */
    @isTest
    private static void afterInsertAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                                                                               Contacts_Addresses_Enabled__c = true));
        
        //Retrieves the defaultTDTMConfig 
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getDefaultTdtmConfig(); 
        
        List<Contact> contacts = [SELECT Id, LastName 
                                  FROM Contact LIMIT 2]; 
        
        List<Address__c> addresses = UTIL_UnitTestData_TEST.getMultipleTestAddresses(2); 
        
        //Add filter on ADDR_Addresses_TDTM triggerHandler
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'ADDR_Addresses_TDTM') {
                token.filterField = 'MailingCity__c';
                token.filterValue = 'Brooklyn';
            }
        }
        
        TDTM_Global_API.setTdtmConfig(tokens);

        addresses[0].Parent_Contact__c = contacts[0].Id; 
        addresses[0].Default_Address__c = TRUE; 
        addresses[1].Parent_Contact__c = contacts[1].Id; 
        addresses[1].Default_Address__c = TRUE; 
        addresses[1].MailingCity__c = 'Brooklyn'; 
        
        Test.startTest();
        insert addresses;
        Test.stopTest(); 
        
        List<Address__c> returnAddresses = [SELECT Id, MailingCity__c, Default_Address__c
                                            FROM Address__c
                                            WHERE Id IN :addresses]; 
        System.assertEquals(2, returnAddresses.size());
        
        Map<String, Address__c> cityByAddress = new Map<String, Address__c>(); 
        for (Address__c addr : returnAddresses) {
            cityByAddress.put(addr.MailingCity__c, addr); 
        }
        System.assertEquals('City0', cityByAddress.get('City0').MailingCity__c); 
        System.assertEquals('Brooklyn', cityByAddress.get('Brooklyn').MailingCity__c); 
     
        //Contact 1: Should populate Current_Address__c and MailingAddress on the Parent Contact
        //Contact 2: Should not populate Current_Address__c and MailingAddress on the Parent Contact
        List<Contact> returnContacts = [SELECT Id, Current_Address__c, MailingAddress, MailingCity
                                           FROM Contact 
                                           WHERE Id IN :contacts];
        System.assertEquals(2, returnContacts.size()); 
        
        Map<String, Contact> cityByContact = new Map<String, Contact>(); 
        for (Contact c : returnContacts) {
            cityByContact.put(c.MailingCity, c); 
        }
        
        System.assertNotEquals(NULL, cityByContact.get('City0').MailingAddress); 
        System.assertEquals(cityByAddress.get('City0').Id, cityByContact.get('City0').Current_Address__c); 
        
        //Tests that the Parent Contact with the associated "Brooklyn" Address record does not get the Parent Contact's 
        //MailingAddress fields and Current_Address__c updated
        if (cityByContact.containsKey('NULL')) {
            System.assertEquals(NULL, cityByContact.get('NULL').Current_Address__c);
            System.assertEquals(NULL, cityByContact.get('NULL').MailingAddress);
        } 
        
    }
    
    /*********************************************************************************************************
    * @description Test method that specifically verifies the following for afterUpdate:
    * (1) When an existing Address record is updated and it doesn't match the filter, Default_Address__c is set
    * to true and MailingStreet__c is changed, the MailingStreet on the Parent Contact should match the MailinStreet__c
    * changed on the Address record. 
    * (2) When an existing Address record is updated and it does match the filter, Default_Address__c is set
    * to true and MailingStreet__c is changed, the MailingStreet on the Parent Contact should not match the MailinStreet__c
    * changed on the Address record.  
    */
    @isTest
    private static void afterUpdateAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                                                                               Contacts_Addresses_Enabled__c = true));
        
        //Retrieves the defaultTDTMConfig 
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getDefaultTdtmConfig(); 
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        List<Contact> contacts = contactsAddrs.contacts; 
        List<Address__c> addresses = contactsAddrs.addrs;
        
        List<Contact> returnContacts = [SELECT Id, Current_Address__c, MailingAddress, MailingCity
                                        FROM Contact 
                                        WHERE Id IN :contacts];
        System.assertEquals(2, returnContacts.size()); 
        
        Map<String, Contact> cityByContact = new Map<String, Contact>(); 
        for (Contact c : returnContacts) {
            cityByContact.put(c.MailingCity, c); 
        }
        System.assertNOTEquals(NULL, cityByContact.get('City0').MailingAddress);     
        System.assertNOTEquals(NULL, cityByContact.get('City0').Current_Address__c);        
       
        //Add filter on ADDR_Addresses_TDTM triggerHandler
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'ADDR_Addresses_TDTM') {
                token.filterField = 'MailingCity__c';
                token.filterValue = 'Brooklyn';
            }
        }
        
        TDTM_Global_API.setTdtmConfig(tokens);
        
        //Update address
        for (Integer i = 0; i < addresses.size(); i++) {
            Address__c addr = addresses[i];
            if (i == 0) {
                addr.MailingStreet__c  = '1 Summer Street'; 
            }
            if (i == 1) {
                addr.MailingCity__c = 'Brooklyn';
                addr.MailingStreet__c  = '1 New Street'; 
            }
        }
        
        Test.startTest(); 
        update addresses; 
        Test.stopTest(); 
        
        //Contact 1: MailingStreet should be updated on the Parent Contact  
        //Contact 2: MailingStreet should not be updated on the Parent Contact  
        List<Contact> returnFinalContacts = [SELECT Id, MailingStreet, MailingCity, Current_Address__c
                                                FROM Contact 
                                                WHERE Id IN :contacts];
        System.assertEquals(2, returnFinalContacts.size()); 
        
        Map<String, Contact> finalCityByContact = new Map<String, Contact>(); 
        for (Contact con : returnFinalContacts) {
            finalCityByContact.put(con.MailingCity, con); 
        }
        System.assertEquals('1 Summer Street', finalCityByContact.get('City0').MailingStreet);
        
        //Tests that the Parent Contact with the associated "Brooklyn" Address record 
        //does not get the Parent Contact's MailingAddress fields and Current_Address__c updated
        if (finalCityByContact.containsKey('NULL')) {
            System.assertNOTEquals('1 New Street', finalCityByContact.get('NULL').MailingStreet);
            System.assertNOTEquals(NULL, finalCityByContact.get('NULL').Current_Address__c);
        }
        
    }
    
    /*********************************************************************************************************
    * @description Test method that specifically verifies the following for afterDelete:
    * (1) When an existing Address record is deleted and it doesn't match the filter, Default_Address__c is set
    * to true, the MailingAddress is cleared. 
    * (2) When an existing Address record is deleted and it does match the filter, Default_Address__c is set
    * to true, the MailingAddress is not cleared. 
    */    
    @isTest
    private static void afterDeleteAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                                                                               Contacts_Addresses_Enabled__c = true));
        
        //Retrieves the defaultTDTMConfig
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getDefaultTdtmConfig(); 
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        List<Contact> contacts = contactsAddrs.contacts; 
        List<Address__c> addresses = contactsAddrs.addrs;
        
        //Update address
        for (Integer i = 0; i < addresses.size(); i++) {
            Address__c addr = addresses[i];
            if (i == 1) {
                addr.MailingCity__c = 'Brooklyn' + i;
            }
        }
         
        update addresses;
        
        Map<String, Address__c> cityByAddress = new Map<String, Address__c>(); 
        for (Address__c addr : addresses) {
            cityByAddress.put(addr.MailingCity__c, addr); 
        }
        
        List<Contact> cons = [SELECT Id, Current_Address__c, MailingCity 
                              FROM Contact 
                              WHERE Id IN :contacts]; 
        System.assertEquals(2, cons.size()); 
        
        Map<String, Contact> cityByContact = new Map<String, Contact>(); 
        for (Contact c : cons) {
            cityByContact.put(c.MailingCity, c); 
        }
        System.assertEquals(cityByAddress.get('City0').Id, cityByContact.get('City0').Current_Address__c);
        System.assertEquals(cityByAddress.get('City0').MailingCity__c, cityByContact.get('City0').MailingCity);
        
        //Add filter on ADDR_Addresses_TDTM triggerHandler
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'ADDR_Addresses_TDTM') {
                token.filterField = 'MailingCity__c';
                token.filterValue = 'Brooklyn1';
            }
        }
        
        TDTM_Global_API.setTdtmConfig(tokens);
        
        Test.startTest();
        delete addresses; 
        Test.stopTest(); 
        
        List<Address__c> returnAddresses = [SELECT Id 
                                            FROM Address__c 
                                            WHERE Id IN :addresses]; 
        System.assertEquals(0, returnAddresses.size()); 
         
        List<Contact> returnCons = [SELECT Id, Current_Address__c, MailingAddress, MailingCity 
                                    FROM Contact 
                                    WHERE Id IN :contacts];
        Map<String, Contact> finalCityByContact = new Map<String, Contact>(); 
        for (Contact con : returnCons) {
            finalCityByContact.put(con.MailingCity, con); 
        }
        if (finalCityByContact.containsKey('NULL')) {
            System.assertNOTEquals(NULL, finalCityByContact.get('NULL').MailingAddress);
            System.assertEquals(NULL, finalCityByContact.get('NULL').Current_Address__c);
        }
 
    }
    
    /*********************************************************************************************************
    * @description Test method that specifically verifies the following for afterDelete:
    * (1) When an existing Address record is deleted with a Parent Account and it doesn't match the filter, Default_Address__c is set
    * to true, the MailingAddress is cleared. 
    * (2) When an existing Address record is deleted with a Parent Account and it does match the filter, Default_Address__c is set
    * to true, the MailingAddress is not cleared. 
    */  
    @isTest
    private static void afterDeleteWithParentAccount() {
        String hhRecordTypeId = UTIL_Describe_API.getHhAccRecTypeID();
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = hhRecordTypeId,
                                                                               Contacts_Addresses_Enabled__c = true,
                                                                               Household_Addresses_RecType__c = hhRecordTypeId,
                                                                               Accounts_Addresses_Enabled__c = hhRecordTypeId));
        
        //Retrieves the defaultTDTMConfig
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getDefaultTdtmConfig(); 
        
        List<Account> accounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(2, hhRecordTypeId);
        insert accounts; 
        
        List<Contact> addContacts = new List<Contact>{
            new Contact (AccountId = accounts[0].Id, LastName = 'Wells'),
            new Contact (AccountId = accounts[1].Id, LastName = 'White')
        };
        insert addContacts; 
        System.debug('TESTClass addContacts -->' + addContacts); 
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        List<Contact> contacts = contactsAddrs.contacts;
        List<Address__c> addresses = contactsAddrs.addrs;
        
        //Update address
        addresses[0].MailingCity__c = 'Boston';
        addresses[0].Default_Address__c = TRUE;
        addresses[0].Parent_Account__c = accounts[0].Id;
        addresses[1].MailingCity__c = 'Brooklyn';
        addresses[1].Default_Address__c = TRUE;
        addresses[1].Parent_Account__c = accounts[1].Id;
        
        update addresses; 
        
        Map<String, Address__c> cityByAddress = new Map<String, Address__c>(); 
        for (Address__c addr : addresses) {
            cityByAddress.put(addr.MailingCity__c, addr); 
        }
        
        System.assertNotEquals(NULL, cityByAddress.get('Brooklyn').Parent_Account__c); 
        System.assertNotEquals(NULL, cityByAddress.get('Boston').Parent_Account__c); 
        
        //Add filter on ADDR_Addresses_TDTM triggerHandler
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'ADDR_Addresses_TDTM') {
                token.filterField = 'MailingCity__c';
                token.filterValue = 'Brooklyn1';
            }
        }
        
        TDTM_Global_API.setTdtmConfig(tokens);
        
        Test.startTest();
        delete addresses; 
        Test.stopTest(); 
        
        List<Address__c> returnAddresses = [SELECT Id 
                                            FROM Address__c 
                                            WHERE Id IN :addresses]; 
        System.assertEquals(0, returnAddresses.size()); 
        
        List<Account> returnAccounts = [SELECT Id, BillingAddress, Current_Address__c, BillingCity
                                        FROM Account
                                        WHERE Id IN :accounts];
        Map<String, Account> cityByAccount = new Map<String, Account>(); 
        for (Account acc : returnAccounts) {
            cityByAccount.put(acc.BillingCity, acc); 
        }
        if (cityByAccount.containsKey('NULL')) {
            System.assertEquals(NULL, cityByAccount.get('NULL').Current_Address__c); 
            System.assertNotEquals(NULL, cityByAccount.get('NULL').BillingAddress); 
        }
        
    }
}