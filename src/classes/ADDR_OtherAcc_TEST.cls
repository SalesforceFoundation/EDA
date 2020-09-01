/*
    Copyright (c) 2016, Salesforce.org
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
* @date 2016
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Tests specific to Address Management on Accounts that are not of 
* of the Household or Administrative types. 
*/

@isTest
public with sharing class ADDR_OtherAcc_TEST {
    
    /*********************************************************************************************************
    @description Insert a new Business Account record with populated billing fields.
    * Verify:
    * - New default Address record is created.
    * - Account's billing fields matches the mailing fields on the newly created default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewAccountWithBillingFields() {            
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = 
                                                                                UTIL_Describe_API.getBizAccRecTypeID() + ';'));

        Integer cAcc = 3;
        list<Account> accList = UTIL_UnitTestData_API.getMultipleTestAccounts(cAcc, UTIL_Describe_API.getBizAccRecTypeID());
        for (Account acc : accList) {
            acc.BillingStreet = '123 45th';
            acc.BillingCity = 'Seattle';
            acc.Billing_County__c = 'Bergen';
        }
        Test.startTest();
        insert accList;
        Test.stopTest();

        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Name, BillingStreet, 
                                                                BillingCity, Billing_County__c, Current_Address__c 
                                                                FROM Account]);
        System.assertEquals(cAcc, accountsById.size());
        
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                        MailingCity__c, MailingCounty__c, Parent_Account__c
                                        FROM Address__c];
        System.assertEquals(cAcc, addrList.size());
        for (Address__c addr : addrList) {
            Account acc = accountsById.get(addr.Parent_Account__c);
            System.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            System.assertEquals(acc.BillingCity, addr.MailingCity__c);
            System.assertEquals(acc.Billing_County__c, addr.MailingCounty__c);
            System.assertEquals(True, addr.Default_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Update existing Business Account's billing fields.
    * Verify:
    * - New default Address record is created.
    * - Account's billing fields matches the mailing fields on the newly created default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void updateExistingAccountBillingFields() {         
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = 
                                                                                UTIL_Describe_API.getBizAccRecTypeID() + ';'));

        Integer numOfAcc = 3;
        List<Account> accList = UTIL_UnitTestData_API.getMultipleTestAccounts(numOfAcc, UTIL_Describe_API.getBizAccRecTypeID());
        insert accList;

        for (Account acc : accList) {
            acc.BillingStreet = '123 45th';
            acc.BillingCity = 'Seattle';
            acc.Billing_County__c = 'Bergen';
        }
        Test.startTest();
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update accList;
        Test.stopTest();

        accList = [SELECT Id, Name, BillingStreet, 
                    BillingCity, Billing_County__c, Current_Address__c 
                    FROM Account];
        System.assertEquals(numOfAcc, accList.size());
        
        List<Address__c> addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                                        MailingCity__c, MailingCounty__c, Parent_Account__c
                                        FROM Address__c];
        System.assertEquals(numOfAcc, addrList.size());
                
        for (Integer i = 0; i < numOfAcc; i++) {
            Account acc = accList[i];
            Address__c addr = addrList[i];
            System.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            System.assertEquals(acc.BillingCity, addr.MailingCity__c);
            System.assertEquals(acc.Billing_County__c, addr.MailingCounty__c);
            System.assertNotEquals(Null, acc.BillingStreet);
            System.assertNotEquals(Null, acc.BillingCity);
            System.assertNotEquals(Null, acc.Current_Address__c);
            System.assertEquals(True, addr.Default_Address__c);
        }
    }

    /*********************************************************************************************************
    @description Insert new default Address on existing Business Account. 
    * Verify:
    * - New default Address record is created.
    * - Account's billing fields are updated to match the mailing fields on the newly created default Address record. 
    **********************************************************************************************************/            
    @isTest
    private static void insertNewDefaultAddressOnExistingAccount() {           
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = 
                                                                                UTIL_Describe_API.getBizAccRecTypeID() + ';'));

        List<Account> accList = UTIL_UnitTestData_API.getMultipleTestAccounts(3, UTIL_Describe_API.getBizAccRecTypeID());
        insert accList;

        List<Address__c> addrList = UTIL_UnitTestData_TEST.getMultipleTestAddresses(accList.size());
        for (Integer i = 0; i < accList.size(); i++) {
            addrList[i].Parent_Account__c = accList[i].Id;
            addrList[i].Default_Address__c = True;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrList;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
        accList = [SELECT Id, Name, BillingStreet, 
                        BillingCity, Billing_County__c, Current_Address__c 
                        FROM Account];
        System.assertEquals(3, accList.size());
        
        addrList = [SELECT Id, Default_Address__c, MailingStreet__c, 
                        MailingCity__c, MailingCounty__c, Parent_Account__c
                        FROM Address__c];
        System.assertEquals(3, addrList.size());
        
        for (Integer i = 0; i < accList.size(); i++) {
            Account acc = accList[i];
            Address__c addr = addrList[i];
            System.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            System.assertEquals(acc.BillingCity, addr.MailingCity__c);
            System.assertEquals(acc.Billing_County__c, addr.MailingCounty__c);
            System.assertNotEquals(Null, acc.BillingStreet);
            System.assertNotEquals(Null, acc.BillingCity);
            System.assertEquals(True, addr.Default_Address__c);
            System.assertEquals(addr.Id, acc.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Insert new Account with billing fields when the setting for Address Mgmt is off. 
    * Verify:
    * - No Address record was created
    * - Account's Current_Address__c is blank. 
    **********************************************************************************************************/            
    @isTest
    private static void testDisabledAddressFeature() {        
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = Null));

        List<Account> accList = UTIL_UnitTestData_API.getMultipleTestAccounts(2, UTIL_Describe.getCustomAdminAccRecTypeID());
        for (Account acc : accList) {
            acc.BillingStreet = 'new street';
            acc.BillingCity = 'new city';
            acc.Billing_County__c = 'new county';
        }
        Test.startTest();
        insert accList; 
        Test.stopTest(); 
        
        Map<Id, Account> accountsById = new Map<Id, Account>([SELECT Id, Current_Address__c 
                                                                FROM Account]);
        for (Account acc : accountsById.values()) {
            System.assertEquals(Null, acc.Current_Address__c);
        }
        
        List<Address__c> addrList = [SELECT Id 
                                        FROM Address__c];
        System.assertEquals(0, addrList.size());
    }
}