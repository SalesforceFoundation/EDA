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
    @description Create N new accounts with billing addresses 
    verify:
        N addresses created
        account address matches address object address
    **********************************************************************************************************/            
    @isTest
    public static void newRecordsWithAddrInfo() {            
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = 
                                                                      UTIL_Describe_API.getBizAccRecTypeID() + ';'));
 
        Integer cAcc = 3;
        list<Account> listAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(cAcc, UTIL_Describe_API.getBizAccRecTypeID());
        for (Account acc : listAcc) {
            acc.BillingStreet = '123 45th';
            acc.BillingCity = 'Seattle';
        }
        Test.startTest();
        insert listAcc;
        Test.stopTest();

        // verify results
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        system.assertEquals(cAcc, mapAccIdAcc.size());
        
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Parent_Account__c, 
        Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cAcc, listAddr.size());
        
        for (Address__c addr : listAddr) {
            Account acc = mapAccIdAcc.get(addr.Parent_Account__c);
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertEquals(true, addr.Default_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Update N organizational accounts with billing addresses 
    verify:
        N addresses created
        account addresses updated
    **********************************************************************************************************/            
    @isTest
    public static void updateRecordsWithAddrInfo() {         
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = 
                                                                            UTIL_Describe_API.getBizAccRecTypeID() + ';'));
 
        // create accounts without addresses
        Integer cAcc = 3;
        list<Account> listAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(cAcc, UTIL_Describe_API.getBizAccRecTypeID());
        insert listAcc;

        // update the accounts' address
        for (Account acc : listAcc) {
            acc.BillingStreet = '123 45th';
            acc.BillingCity = 'Seattle';
        }
        Test.startTest();
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        update listAcc;
        Test.stopTest();

        // verify results
        listAcc = [select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, 
                   Current_Address__c from Account order by Account.Name];
        system.assertEquals(cAcc, listAcc.size());
        
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, 
        Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c 
        order by Parent_Account__r.Name];
        system.assertEquals(cAcc, listAddr.size());
                
        for (Integer i = 0; i < cAcc; i++) {
            Account acc = listAcc[i];
            Address__c addr = listAddr[i];
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertNotEquals(null, acc.BillingStreet);
            system.assertNotEquals(null, acc.BillingCity);
            system.assertEquals(true, addr.Default_Address__c);
            system.assertNotEquals(null, acc.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Update N accounts with address objects 
    verify:
        account addresses updated
        contact addresses not updated
    **********************************************************************************************************/            
    @isTest
    public static void newAddrForAccounts() {           
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = 
                                                                      UTIL_Describe_API.getBizAccRecTypeID() + ';'));
 
        // create accounts without addresses
        list<Account> listAcc = UTIL_UnitTestData_API.getMultipleTestAccounts(3, UTIL_Describe_API.getBizAccRecTypeID());
        insert listAcc;

         // create addresses for the accounts
        List<Address__c> addrs = UTIL_UnitTestData_TEST.getMultipleTestAddresses(listAcc.size());
        for (Integer i = 0; i < listAcc.size(); i++) {
            addrs[i].Parent_Account__c = listAcc[i].Id;
            addrs[i].Default_Address__c = true;
        }
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        insert addrs;
        ADDR_Contact_TEST.turnOnAllAddrTriggers();
        
        // verify results
        listAcc = [select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c 
        from Account order by Account.Name];
        system.assertEquals(3, listAcc.size());
        
        addrs = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Parent_Account__c, 
        Latest_Start_Date__c, Latest_End_Date__c from Address__c order by Parent_Account__r.Name];
        system.assertEquals(3, addrs.size());
        
        for (Integer i = 0; i < listAcc.size(); i++) {
            Account acc = listAcc[i];
            Address__c addr = addrs[i];
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertNotEquals(null, acc.BillingStreet);
            system.assertNotEquals(null, acc.BillingCity);
            system.assertEquals(true, addr.Default_Address__c);
            system.assertEquals(addr.Id, acc.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description Create Accounts when the setting for Address Mgmt is off. 
    verify:
        no Address objects created
        Account addresses set
    **********************************************************************************************************/            
    @isTest
    public static void testDisabledAddr() {        
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Accounts_Addresses_Enabled__c = null));

        List<Account> accs = UTIL_UnitTestData_API.getMultipleTestAccounts(2, UTIL_Describe_API.getAdminAccRecTypeID());
        for (Account acc : accs) {
            acc.BillingStreet = 'new street';
            acc.BillingCity = 'new city';
        }

        // verify Account address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, Current_Address__c from Account]);
        
        for (Account acc : mapAccIdAcc.values()) {
            system.assertEquals(null, acc.Current_Address__c);
        }
        
        // verify no address objects created
        list<Address__c> listAddr = [select Id from Address__c];
        system.assertEquals(0, listAddr.size());
    }
}