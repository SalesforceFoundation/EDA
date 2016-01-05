/*
    Copyright (c) 2014, Salesforce.org
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
* @date 2013
* @group Address Management
* @description Tests specific to Address Management. 
*/

@isTest
private with sharing class ADDR_Addresses_TEST {

    /*********************************************************************************************************
    * @description Holds the number of Parent Accounts, Household Administrative, to create in tests.
    */
    static Integer parentAccs = 2;

    /*********************************************************************************************************
    * @description Holds the number of Contacts per Household to create in tests.
    */
    static Integer cCon = 2;    

    /*********************************************************************************************************
    * @description The list of created test Contacts.
    */
    private static list<Contact> listConT;

    /*********************************************************************************************************
    * @description The list of created test Accounts.
    */
    private static list<Account> listAccT; 
    
    /*********************************************************************************************************
    * @description The list of created test Addresses.
    */
    private static list<Address__c> listAddrT;           

    /*********************************************************************************************************
    * @description
    * utility to set up common test data for the Address tests.
    *    - this will create & insert N household Accounts, each with M contacts
    *    - also will create a Default Addresses for each HH Account
    *    - will also setup the default Account Processor to be HH Accounts
    * @param parentAccsT the number of Household Accounts to create
    * @param cConT the number of Contacts to create per Household
    * @return  void
    **********************************************************************************************************/
    private static void createHHTestData(Integer parentAccsT, Integer cConT) {  
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c();
        hs.Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR;
        hs.Organizational_Account_Addresses_Enabled__c = true;
        hs.Household_Adm_Acct_Addresses_Enabled__c = true;
        hs.Reciprocal_Method__c = 'List Settings';
        hs.Simple_Address_Change_Treated_as_Update__c = true;
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
            
        listConT = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(parentAccsT * cConT);
        listAccT = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(parentAccsT, CAO_Constants.HH_ACCOUNT_PROCESSOR);
        insert listAccT;
        
        createTestData(parentAccsT, cConT);
    }
    
    private static void createAdmTestData(Integer parentAccsT, Integer cConT) {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c();
        hs.Account_Processor__c = CAO_Constants.ADM_ACCOUNT_PROCESSOR;
        hs.Organizational_Account_Addresses_Enabled__c = true;
        hs.Household_Adm_Acct_Addresses_Enabled__c = true;
        hs.Reciprocal_Method__c = 'List Settings';
        hs.Simple_Address_Change_Treated_as_Update__c = true;
        hs.Household_Adm_Acct_Addresses_Enabled__c = true;
        UTIL_CustomSettingsFacade.getSettingsForTests(hs);
        
        listConT = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(parentAccsT * cConT);
        listAccT = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(parentAccsT, CAO_Constants.ADM_ACCOUNT_PROCESSOR);
        insert listAccT;
        
        createTestData(parentAccsT, cConT);
    }
    
    private static void createTestData(Integer parentAccsT, Integer cConT) {
        for (Integer i = 0; i < parentAccsT; i++) {
            for (Integer j = 0; j < cConT; j++) {
                listConT[ (i * cConT) + j].AccountId = listAccT[i].Id;
            }
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listConT;        

        initTestAddr(parentAccsT);
        for (Integer i = 0; i < parentAccsT; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = true;
        }
        // clear our triggers recursion prevention since we starting a new test
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        
        // clear our triggers recursion prevention since we are starting a new test
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // start 'em off with new limits!
        Test.startTest();
        
    }

    /*********************************************************************************************************
    * @description Initializes (but not inserts) N new Address objects.
    * @param cAddr the number of Address objects to create
    * @return  void
    **********************************************************************************************************/
    private static void initTestAddr(Integer cAddr) {
        listAddrT = new list<Address__c>();
        for (Integer i = 0; i < cAddr; i++) {
            Address__c addr = new Address__c();
            addr.Address_Type__c = 'Home';
            addr.MailingStreet__c = 'Street' + i;
            addr.MailingCity__c = 'City' + i;
            addr.MailingState__c = 'Washington';
            addr.MailingPostalCode__c = 'Zip' + i;
            addr.MailingCountry__c = 'United States';
            addr.Geolocation__Latitude__s = 47.6097 + i;
            addr.Geolocation__Longitude__s = -122.3331 + i;
            listAddrT.add(addr);            
        }
    }
    
    /*********************************************************************************************************
    * @description Returns whether an Account Billing address matches a Contact Mailing address
    * @return  boolean 
    **********************************************************************************************************/
    private static boolean isMatchAddressAccCon(Account acc, Contact con) {
        UTIL_Debug.debug('****Account in isMatchAddressAccCon: ' + JSON.serializePretty(acc));
        UTIL_Debug.debug('****Contact in isMatchAddressAccCon: ' + JSON.serializePretty(con));
        return (acc.BillingStreet == con.MailingStreet &&          
            acc.BillingCity == con.MailingCity &&          
            acc.BillingState == con.MailingState &&         
            acc.BillingPostalCode == con.MailingPostalCode &&          
            acc.BillingCountry == con.MailingCountry &&
            acc.BillingLatitude == con.MailingLatitude &&
            acc.BillingLongitude == con.MailingLongitude
        );                
    }
        
    /*********************************************************************************************************
    @description
        create N new default Addresses for N Households (with M Contacts)  
    verify:
        N addresses created
        N household billing address fields updated
        M contact Mailing address fields updated
    **********************************************************************************************************/            
    @isTest
    public static void newDefaultAddrHH() {
        createHHTestData(parentAccs, cCon);
        newDefaultAddr();
    }
    
    @isTest
    public static void newDefaultAddrAdm() {
        createAdmTestData(parentAccs, cCon);
        newDefaultAddr();
    }
    
    public static void newDefaultAddr() {
        Test.stopTest();

        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        insert contact w/ address
    verify:
        new default Address created
        contact address lookup updated to new address
        the contact gets the new Address
    **********************************************************************************************************/            
    @isTest
    public static void insertContactWithAddressHH() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR, 
                                      Household_Adm_Acct_Addresses_Enabled__c = true));
        insertContactWithAddress();
    }
    
    @isTest
    public static void insertContactWithAddressAdm() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = CAO_Constants.ADM_ACCOUNT_PROCESSOR, 
                                      Household_Adm_Acct_Addresses_Enabled__c = true));
        insertContactWithAddress();
    }

    public static void insertContactWithAddress() {            
        listConT = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cCon);
        for (Contact con : listConT) {
            con.MailingStreet = 'new street';
            con.MailingCity = 'new city';
        }
        Test.startTest();
        insert listConT;
        Test.stopTest();     

        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }
        
    /*********************************************************************************************************
    @description
        insert contact w/ new address override
    verify:
        new non-default Address created
        contact address lookup updated to new address
        the contact gets the new Address
    **********************************************************************************************************/            
    @isTest
    public static void insertContactWithAddressOverrideHH() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR, 
                                      Household_Adm_Acct_Addresses_Enabled__c = true));
        insertContactWithAddressOverride();
    }
    
    @isTest
    public static void insertContactWithAddressOverrideAdm() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = CAO_Constants.ADM_ACCOUNT_PROCESSOR, 
                                      Household_Adm_Acct_Addresses_Enabled__c = true));
        insertContactWithAddressOverride();
    }
    
    public static void insertContactWithAddressOverride() {                    
        listConT = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cCon);
        Integer i = 1;
        for (Contact con : listConT) {
            con.MailingStreet = 'new street' + i;
            con.MailingCity = 'new city' + i;
            con.is_Address_Override__c = true;
            i++;
        }
        Test.startTest();
        insert listConT;
        Test.stopTest();    

        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(true, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }
        
    /*********************************************************************************************************
    @description
        update existing default Addresses  
    verify:
        household billing address fields updated
        contact Mailing address fields updated
    **********************************************************************************************************/            
    @isTest 
    public static void updateDefaultAddrHH() {
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateDefaultAddr();   
    }
    
    @isTest 
    public static void updateDefaultAddrAdm() {
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateDefaultAddr();
    }
    
    public static void updateDefaultAddr() { 
        // now let's update the Addresses
        for (Integer i = 0; i < parentAccs; i++) {
            Address__c addr = listAddrT[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
        }
        system.assertEquals(false, ADDR_Addresses_TDTM.hasRunAddrTrigger);
        update listAddrT;
        Test.stopTest();
    
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Street'));
            system.assert(con.MailingCity.contains('New City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }
    
    /*********************************************************************************************************
    @description
        delete existing default Addresses  
    verify:
        household billing address fields cleared
        contact Mailing address fields cleared
    **********************************************************************************************************/            
    @isTest
    static void deleteDefaultAddrHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        deleteDefaultAddr();
    }
    
    @isTest
    static void deleteDefaultAddrAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        deleteDefaultAddr();
    }
    
    static void deleteDefaultAddr() {        
        // now let's delete the Addresses
        system.assertEquals(false, ADDR_Addresses_TDTM.hasRunAddrTrigger);
        delete listAddrT;
        Test.stopTest();
    
        // verify that the HH and Contacts' address fields are cleared
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(null, con.MailingStreet);
            system.assertEquals(null, con.MailingCity);
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertEquals(null, con.Current_Address__c);
            system.assertEquals(null, acc.BillingStreet);
            system.assertEquals(null, acc.BillingCity);
        }
    }

    /*********************************************************************************************************
    @description
        delete existing non-default override Addresses  
    verify:
        household billing address fields not changed
        contact Mailing address fields reset to default
    **********************************************************************************************************/            
    @isTest
    static void deleteNonDefaultOverrideAddrHH() {        
        createHHTestData(parentAccs, cCon);
        deleteNonDefaultOverrideAddr();
    }
    
    @isTest
    static void deleteNonDefaultOverrideAddrAdm() {        
        createAdmTestData(parentAccs, cCon);
        deleteNonDefaultOverrideAddr();
    }
    
    static void deleteNonDefaultOverrideAddr() { 
        // create additional addresses
        initTestAddr(parentAccs);
        for (integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'override' + i;
            listAddrT[i].MailingCity__c = 'override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        
        // set the contacts' address overrides
        list<Contact> listCon = new list<Contact>();
        for (integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.Current_Address__c = listAddrT[i].Id;
            con.is_Address_Override__c = true;
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;        
        
        // now let's delete the override Addresses
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        delete listAddrT;
        Test.stopTest();
    
        // verify that the HH and Contacts' address fields the default
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
            system.assert(con.MailingStreet.contains('Street'));
            system.assert(con.MailingCity.contains('City'));            
        }
    }

    /*********************************************************************************************************
    @description
        update existing non-default Addresses  
    verify:
        no change to HH and contact addresses
    **********************************************************************************************************/            
    @isTest
    public static void updateNonDefaultAddrHH() { 
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateNonDefaultAddr();
    }
    
    @isTest
    public static void updateNonDefaultAddrAdm() { 
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateNonDefaultAddr();
    }
    
    public static void updateNonDefaultAddr() {
        // now let's update the Addresses
        for (Integer i = 0; i < parentAccs; i++) {
            Address__c addr = listAddrT[i];
            addr.Default_Address__c = false;
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
        }
        system.assertEquals(false, ADDR_Addresses_TDTM.hasRunAddrTrigger);
        update listAddrT;
        Test.stopTest();
    
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(!con.MailingStreet.contains('New Street'));
            system.assert(!con.MailingCity.contains('New City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        set contact address override  
    verify:
        contact's address matches override
    **********************************************************************************************************/            
    @isTest
    public static void setConAddrOverrideHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        setConAddrOverride();
    }
    
    @isTest
    public static void setConAddrOverrideAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        setConAddrOverride();
    }
    
    public static void setConAddrOverride() {
        // create a new non-default address
        Address__c addrNew = new Address__c();
        addrNew.MailingStreet__c = 'street override';
        addrNew.MailingCity__c = 'city override';
        addrNew.Default_Address__c = false;
        addrNew.Parent_Account__c = listAccT[0].Id;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert addrNew;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // set a contact's address override
        listConT[0].Current_Address__c = addrNew.Id;
        listConT[0].is_Address_Override__c = true;
        update listConT[0];
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
    
        // now let's update the default Addresses
        for (Integer i = 0; i < parentAccs; i++) {
            Address__c addr = listAddrT[i];
            addr.MailingStreet__c = 'New Street' + i;
            addr.MailingCity__c = 'New City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAddrT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.is_Address_Override__c) {
                system.assertEquals(con.Current_Address__c, addrNew.Id);
                system.assertEquals(false, isMatchAddressAccCon(acc, con));
                system.assert(!con.MailingStreet.contains('New Street'));
                system.assert(!con.MailingCity.contains('New City'));               
            } else {
                system.assertEquals(true, isMatchAddressAccCon(acc, con));
                system.assert(con.MailingStreet.contains('New Street'));
                system.assert(con.MailingCity.contains('New City'));
                system.assertEquals(false, con.is_Address_Override__c);
                system.assertNotEquals(null, con.Current_Address__c);
            }
        }
    }

    /*********************************************************************************************************
    @description
        set contact current address, but not override  
    verify:
        contact's address updated, but not override
    **********************************************************************************************************/            
    @isTest
    public static void setConAddrNoOverrideHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        setConAddrNoOverride();
    }
    
    @isTest
    public static void setConAddrNoOverrideAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        setConAddrNoOverride();
    }
    
    public static void setConAddrNoOverride() {
        // create additional addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'not override' + i;
            listAddrT[i].MailingCity__c = 'not override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // set the contacts' address overrides
        list<Contact> listCon = new list<Contact>();
        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.Current_Address__c = listAddrT[i].Id;
            con.is_Address_Override__c = false;
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address, except for the contacts we modified
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, Current_Address__r.Default_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        Integer cNotOverride = 0;
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.MailingStreet.contains('not override') == true) {
                cNotOverride++;
                system.assertEquals(false, isMatchAddressAccCon(acc, con));
                system.assert(con.MailingStreet.contains('not override'));
                system.assert(con.MailingCity.contains('not override'));
                system.assertEquals(false, con.is_Address_Override__c);
                system.assertNotEquals(null, con.Current_Address__c);            
            } else {
                system.assertEquals(true, con.Current_Address__r.Default_Address__c);
                system.assertEquals(true, isMatchAddressAccCon(acc, con));
                system.assert(con.MailingStreet.contains('Street'));
                system.assert(con.MailingCity.contains('City'));
                system.assertEquals(false, con.is_Address_Override__c);
                system.assertNotEquals(null, con.Current_Address__c);
            }
        }
        system.assertEquals(parentAccs, cNotOverride);
    }

    /*********************************************************************************************************
    @description
        insert new default addresses to HH w/ existing default addresses  
    verify:
        contact's && hh address matches new default
        old default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddrHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertNewDefaultAddr();
    }
    
    @isTest
    public static void insertNewDefaultAddrAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertNewDefaultAddr();
    }
    
    public static void insertNewDefaultAddr() {
        // create additional addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = true;
            listAddrT[i].MailingStreet__c = 'New Default Street' + i;
            listAddrT[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
        Test.stopTest();

        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Default Street'));
            system.assert(con.MailingCity.contains('New Default City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(parentAccs * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('New Default Street'));
            system.assertEquals(fNewDefault, addr.Default_Address__c);
            if (fNewDefault) {
               system.assertEquals(system.today(), addr.Latest_Start_Date__c);
               system.assertEquals(null, addr.Latest_End_Date__c);
            } else {
               system.assertEquals(system.today(), addr.Latest_End_Date__c);                
            }
        }        
    }
    
    /*********************************************************************************************************
    @description
        insert new default addresses to HH w/ existing default addresses, and then go back  
    verify:
        contact's && hh address matches original default
        new default addresses no longer marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultAddrAndResetHH() {  
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertNewDefaultAddrAndReset();
    }
    
    @isTest
    public static void insertNewDefaultAddrAndResetAdm() {  
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertNewDefaultAddrAndReset();
    }
    
    public static void insertNewDefaultAddrAndReset() {
        list<Address__c> listAddrOriginal = listAddrT;
        
        // create additional addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = true;
            listAddrT[i].MailingStreet__c = 'New Default Street' + i;
            listAddrT[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // go back to original default addresses
        // added this extra set to test fix where we didn't use the correct default
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrOriginal[i].Default_Address__c = true;
            listAddrOriginal[i].MailingStreet__c = 'Original Default Street' + i;
            listAddrOriginal[i].MailingCity__c = 'Original Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAddrOriginal;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();

        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('Original Default Street'));
            system.assert(con.MailingCity.contains('Original Default City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses got Default cleared.
        // and verify latest start date and latest end date appropriately set.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(parentAccs * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('Original Default Street'));
            system.assertEquals(fNewDefault, addr.Default_Address__c);
            if (fNewDefault) {
               system.assertEquals(system.today(), addr.Latest_Start_Date__c);
               system.assertEquals(null, addr.Latest_End_Date__c);
            } else {
               system.assertEquals(system.today(), addr.Latest_End_Date__c);                
            }
        }        
    }

    /*********************************************************************************************************
    @description
        update contacts' Address Override  
    verify:
        contacts' Mailing address fields updated to the Address Override's fields.
    **********************************************************************************************************/            
    @isTest
    public static void updateAddrOverrideHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateAddrOverride();
    }
    
    @isTest
    public static void updateAddrOverrideAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateAddrOverride();
    }
    
    public static void updateAddrOverride() {
        // create additional addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'override' + i;
            listAddrT[i].MailingCity__c = 'override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // set the contacts' address overrides
        list<Contact> listCon = new list<Contact>();
        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.Current_Address__c = listAddrT[i].Id;
            con.is_Address_Override__c = true;
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.is_Address_Override__c) {
                system.assertNotEquals(null, con.Current_Address__c);
                system.assertEquals(false, isMatchAddressAccCon(acc, con));
                system.assert(con.MailingStreet.contains('override'));
                system.assert(con.MailingCity.contains('override'));               
            } else {
                system.assertEquals(true, isMatchAddressAccCon(acc, con));
                system.assert(con.MailingStreet.contains('Street'));
                system.assert(con.MailingCity.contains('City'));
                system.assertEquals(false, con.is_Address_Override__c);
                system.assertNotEquals(null, con.Current_Address__c);
            }
        }

        // verify address overrides have latest start date and latest end date appropriately set.
        list<Address__c> listAddr = [select Id, Latest_Start_Date__c, Latest_End_Date__c from Address__c where Id in :listAddrT];
        system.assertEquals(parentAccs, listAddr.size());
        for (Address__c addr : listAddr) {
           system.assertEquals(system.today(), addr.Latest_Start_Date__c);
           system.assertEquals(null, addr.Latest_End_Date__c);
        }        
    }
        
    /*********************************************************************************************************
    @description
        clear contacts' Address Override  
    verify:
        contacts' Mailing address fields updated to the HH default address
    **********************************************************************************************************/            
    @isTest
    public static void clearAddrOverrideHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        clearAddrOverride();
    }
    
    @isTest
    public static void clearAddrOverrideAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        clearAddrOverride();
    }
    
    public static void clearAddrOverride() {
        // create additional addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'override' + i;
            listAddrT[i].MailingCity__c = 'override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // set the contacts' address overrides
        list<Contact> listCon = new list<Contact>();
        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.Current_Address__c = listAddrT[i].Id;
            con.is_Address_Override__c = true;
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;

        // now clear out the contacts' address overrides
        for (Contact con : listCon) {
            con.is_Address_Override__c = false;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('Street'));
            system.assert(con.MailingCity.contains('City'));
        }

        // verify address overrides have latest start date and latest end date appropriately set.
        list<Address__c> listAddr = [select Id, Latest_Start_Date__c, Latest_End_Date__c from Address__c where Id in :listAddrT];
        system.assertEquals(parentAccs, listAddr.size());
        for (Address__c addr : listAddr) {
           system.assertEquals(system.today(), addr.Latest_Start_Date__c);
           system.assertEquals(system.today(), addr.Latest_End_Date__c);
        }        
    }

    /*********************************************************************************************************
    @description
        update contacts' mailing address to cause creation of new default Address object  
    verify:
        new Default Address created
        HH and Contacts get new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrNewHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateConAddrNew();
    }
    
    @isTest
    public static void updateConAddrNewAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateConAddrNew();
    }
    
    public static void updateConAddrNew() {
        // modify some of the contact addresses directly
        list<Contact> listCon = new list<Contact>();
        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.MailingStreet = 'Direct Street Edit';
            con.MailingCity = 'Direct City Edit';
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.MailingStreet = 'another Street Edit';
            con.MailingCity = 'another City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.MailingStreet = 'final Street Edit';
            con.MailingCity = 'final City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('final Street Edit'));
            system.assert(con.MailingCity.contains('final City Edit'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        // each set of edits created a new address object 
        system.assertEquals(parentAccs * 4, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('final Street Edit'));
            system.assertEquals(fNewDefault, addr.Default_Address__c);
        }                
    }

    /*********************************************************************************************************
    @description
        update contacts' mailing address and mark it as override, to cause creation of new non-default Address object  
    verify:
        new Address created
        HH sticks with default Address
        contact gets new address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrMarkOverrideHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateConAddrMarkOverride();
    }
    
    @isTest
    public static void updateConAddrMarkOverrideAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateConAddrMarkOverride();
    }
    
    public static void updateConAddrMarkOverride() {
        // modify the contact addresses directly, and set override
        list<Contact> listCon = new list<Contact>();
        for (Integer i = 0; i < parentAccs*cCon; i++) {
            Contact con = listConT[i];
            con.MailingStreet = 'Direct Street Edit';
            con.MailingCity = 'Direct City Edit';
            con.is_Address_Override__c = true;
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts do not share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(false, isMatchAddressAccCon(acc, con));
            system.assertEquals(true, con.MailingStreet.contains('Direct Street Edit'));
            system.assertEquals(true, con.MailingCity.contains('Direct City Edit'));
            system.assertEquals(false, acc.BillingStreet.contains('Direct Street Edit'));
            system.assertEquals(false, acc.BillingCity.contains('Direct City Edit'));
            system.assertEquals(true, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        system.assertEquals(parentAccs * cCon + parentAccs, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean isNewEdit = (addr.MailingStreet__c.contains('Direct Street Edit'));
            system.assertNotEquals(isNewEdit, addr.Default_Address__c);
        }                
    }

    /*********************************************************************************************************
    @description
        update contacts' mailing address to cause an update to default Address object  
    verify:
        existing Default Address updated
        HH and Contacts get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrExistingHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateConAddrExisting();
    }
    
    @isTest
    public static void updateConAddrExistingAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateConAddrExisting();
    }
    
    public static void updateConAddrExisting() {
        // modify some of the contact addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        list<Contact> listCon = new list<Contact>();
        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.MailingStreet = 'Direct Street Edit';
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.MailingState = 'Washington';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.MailingStreet = ' direct street  edit ';  // whitespace and casing should not count as a real edit.
            con.MailingState = 'Oregon';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('direct street  edit'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        system.assertEquals(parentAccs, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assertEquals('direct street  edit', addr.MailingStreet__c);
        }                
    }

    /*********************************************************************************************************
    @description
        update contacts' mailing address with just a case change, to cause an update to default Address object  
    verify:
        existing Default Address updated
        HH and Contacts get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrExistingCaseOnlyHH() {    
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateConAddrExistingCaseOnly();
    }
    
    @isTest
    public static void updateConAddrExistingCaseOnlyAdm() {    
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateConAddrExistingCaseOnly();
    }
    
    public static void updateConAddrExistingCaseOnly() {
        // modify some of the contact addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        list<Contact> listCon = new list<Contact>();
        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.MailingStreet = 'Direct Street Edit';
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.MailingState = 'Washington';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.MailingStreet = ' direct street  edit ';  // whitespace and casing should not count as a real edit.
            con.MailingState = 'Oregon';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;

        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.MailingStreet = ' DIRECT STREET  EDIT ';  // only change casing.
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.equals('DIRECT STREET  EDIT'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        system.assertEquals(parentAccs, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assert(addr.MailingStreet__c.equals('DIRECT STREET  EDIT'));
        }
        
        // now test that changing the case from the account updates all addresses
        for (Integer i = 0; i < parentAccs; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = 'direct street  edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        
        // verify that the HH and Contacts share the same address
        mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.equals('direct street  edit'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        system.assertEquals(parentAccs, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assert(addr.MailingStreet__c.equals('direct street  edit'));
        }                   
    }

    /*********************************************************************************************************
    @description
        update accounts' billing address to cause creation of new default Address object  
    verify:
        new Default Address created
        HH and Contacts get new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAccAddrNewHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateAccAddrNew();
    }
    
    @isTest
    public static void updateAccAddrNewAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateAccAddrNew();
    }
    
    public static void updateAccAddrNew() {
        // modify some of the account addresses directly
        for (Integer i = 0; i < parentAccs; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = 'Direct Street Edit';
            acc.BillingCity = 'Direct City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;

        for (Integer i = 0; i < parentAccs; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = 'another Street Edit';
            acc.BillingCity = 'another City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;

        for (Integer i = 0; i < parentAccs; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = 'final Street Edit';
            acc.BillingCity = 'final City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(acc.BillingStreet.contains('final Street Edit'));
            system.assert(con.MailingStreet.contains('final Street Edit')); 
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
         // verify the previous addresses got Default cleared.
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        // each set of edits created a new address object 
        system.assertEquals(parentAccs * 4, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fNewDefault = (addr.MailingStreet__c.contains('final Street Edit'));
            system.assertEquals(fNewDefault, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        update accounts' billing address to cause an update of the default Address object  
    verify:
        existing Default Address updated
        HH and Contacts get updated Address
    **********************************************************************************************************/            
    @isTest
    public static void updateAccAddrExistingHH() {
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateAccAddrExisting();
    }
    
    @isTest
    public static void updateAccAddrExistingAdm() {
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateAccAddrExisting();
    }
    
    public static void updateAccAddrExisting() {
        // modify some of the account addresses directly
        // NOTE: we only modify 1 field, so it will be treated as an update to an existing address!
        for (Integer i = 0; i < parentAccs; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = 'Direct Street Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;

        for (Integer i = 0; i < parentAccs; i++) {
            Account acc = listAccT[i];
            acc.BillingState = 'Washington';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;

        for (Integer i = 0; i < parentAccs; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = ' direct street  edit ';    // whitespace and casing should not count as real edit.
            acc.BillingState = 'Oregon';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(acc.BillingStreet.contains('direct street  edit'));
            system.assert(con.MailingStreet.contains('direct street  edit')); 
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify that no new address was created
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        system.assertEquals(parentAccs, listAddr.size());
        for (Address__c addr : listAddr) {
            system.assertEquals('direct street  edit', addr.MailingStreet__c);
        }        
    }

    /*********************************************************************************************************
    @description
        create an Address with no Account 
    verify:
        runtime error
    **********************************************************************************************************/            
    @isTest
    public static void newAddrNoAccount() {        
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            system.assertEquals(null, listAddrT[i].Parent_Account__c);
        }
        
        try {
            insert listAddrT;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrHhAdmAccountOnly));
            return;
        }
        system.assert(false); //we shouldn't get here!
    }

    /*********************************************************************************************************
    @description
        insert new seasonal addresses to HH w/ existing default addresses  
    verify:
        contact's && hh address matches new seasonal
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewSeasonalAddrHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertNewSeasonalAddr();
    }
    
    @isTest
    public static void insertNewSeasonalAddrAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertNewSeasonalAddr();
    }
    
    public static void insertNewSeasonalAddr() {
        // create additional addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(-1).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Seasonal Street'));
            system.assert(con.MailingCity.contains('New Seasonal City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(parentAccs * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }
    
    /*********************************************************************************************************
    @description
        insert new seasonal addresses to HH w/ existing default addresses  
    verify:
        contact's && hh address matches new seasonal
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewSeasonalAddrHHWithYear() {
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertNewSeasonalAddrWithYear();
    }
    
    @isTest
    public static void insertNewSeasonalAddrAdmWithYear() {
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertNewSeasonalAddrWithYear();
    }
    
    public static void insertNewSeasonalAddrWithYear() {
        // create additional addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            
            listAddrT[i].Seasonal_Start_Year__c = System.today().addYears(-1).year();
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(-1).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            
            listAddrT[i].Seasonal_End_Year__c = System.today().addYears(1).year();
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Seasonal Street'));
            system.assert(con.MailingCity.contains('New Seasonal City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(parentAccs * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            UTIL_Debug.debug('****Is seasonal: ' + fSeasonal);
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        insert new seasonal addresses, not current, to HH w/ existing default addresses  
    verify:
        contact's && hh address stay with default
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void insertNewSeasonalAddrNotCurrentHH() {
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertNewSeasonalAddrNotCurrent();
    }
    
    @isTest
    public static void insertNewSeasonalAddrNotCurrentAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertNewSeasonalAddrNotCurrent();
    }
    
    public static void insertNewSeasonalAddrNotCurrent() {
        // create additional addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(2).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(!con.MailingStreet.contains('New Seasonal Street'));
            system.assert(!con.MailingCity.contains('New Seasonal City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(parentAccs * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        update seasonal addresses to current, on HH w/ existing default addresses  
    verify:
        contact's && hh address updated to seasonal address
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void updateSeasonalAddrHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateSeasonalAddr();
    }
    
    @isTest
    public static void updateSeasonalAddrAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateSeasonalAddr();
    }
    
    public static void updateSeasonalAddr() {   
        // create additional seasonal addresses not current
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(2).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // now make them current
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(-1).month());
        }
        update listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;                
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Seasonal Street'));
            system.assert(con.MailingCity.contains('New Seasonal City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(parentAccs * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap with eachother  
    verify:
        overlap detected, seasonal addresses don't save
    **********************************************************************************************************/            
    @isTest
    public static void insertSeasonalAddrWithOverlapHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertSeasonalAddrWithOverlap();
    }
    
    @isTest
    public static void insertSeasonalAddrWithOverlapAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertSeasonalAddrWithOverlap();
    }
    
    public static void insertSeasonalAddrWithOverlap() {
        // create additional seasonal addresses not current
        initTestAddr(parentAccs * 2);
        for (Integer i = 0; i < parentAccs * 2; i++) {
            Integer iacc = i < parentAccs ? i : i-parentAccs;
            if (math.mod(i, 2) == 0) {
                listAddrT[i].Parent_Account__c = listAccT[iacc].Id;
                listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
                listAddrT[i].Seasonal_Start_Day__c = '1';
                listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(3).month());
                listAddrT[i].Seasonal_End_Day__c = '28';
            } else {
                listAddrT[i].Parent_Account__c = listAccT[iacc-1].Id;
                listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(-1).month());
                listAddrT[i].Seasonal_Start_Day__c = '1';
                listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(2).month());
                listAddrT[i].Seasonal_End_Day__c = '28';            
            }
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        try {
            insert listAddrT;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrSeasonalOverlap));
            return;
        }
        system.assert(false); //we shouldn't get here!
        
    }

    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap with eachother  
    verify:
        overlap detected
    **********************************************************************************************************/            
    @isTest
    public static void testSeasonalAddrOverlapLogic() {        
        Address__c a1 = new Address__c();
        Address__c a2 = new Address__c();

        // test both increasing ranges, no overlap
        a1.Seasonal_Start_Month__c = '1';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '3';
        a1.Seasonal_End_Day__c = '28';
        a2.Seasonal_Start_Month__c = '4';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '6';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));
        
        // test both increasing ranges, with overlap
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_End_Month__c = '6';
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));
        
        // test one increasing range, one decreasing range, no overlap
        a1.Seasonal_Start_Month__c = '3';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '5';
        a1.Seasonal_End_Day__c = '28';
        a2.Seasonal_Start_Month__c = '11';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));

        // test one increasing range, one decreasing range, with overlap
        a2.Seasonal_Start_Month__c = '11';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '4';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));

        // test both decreasing ranges, always overlap
        a1.Seasonal_Start_Month__c = '9';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '28';
        a2.Seasonal_Start_Month__c = '12';
        a2.Seasonal_Start_Day__c = '1';
        a2.Seasonal_End_Month__c = '3';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));
        
        // test both increasing ranges in the same month, no overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));

        // test both increasing ranges in the same month, with overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '10';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));

        // test one increasing range, one decreasing range in the same month, no overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = '1';
        a2.Seasonal_End_Day__c = '28';
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(false, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));

        // test one increasing range, one decreasing range in the same month, with overlap
        a1.Seasonal_Start_Month__c = '2';
        a1.Seasonal_Start_Day__c = '1';
        a1.Seasonal_End_Month__c = '2';
        a1.Seasonal_End_Day__c = '10';
        a2.Seasonal_Start_Month__c = '2';
        a2.Seasonal_Start_Day__c = '11';
        a2.Seasonal_End_Month__c = '2';
        a2.Seasonal_End_Day__c = '1';
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a1, a2));
        system.assertEquals(true, ADDR_Addresses_TDTM.isSeasonalOverlap(a2, a1));
    }

    /*********************************************************************************************************
    @description
        create multiple seasonal address that overlap existing seasonal addresses  
    verify:
        overlap detected, seasonal addresses don't save
    **********************************************************************************************************/            
    @isTest
    public static void insertSeasonalAddrOverlapExistingHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertSeasonalAddrOverlapExisting();
    }
    
    @isTest
    public static void insertSeasonalAddrOverlapExistingAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertSeasonalAddrOverlapExisting();
    }
    
    public static void insertSeasonalAddrOverlapExisting() {
        // create additional seasonal addresses not current
        initTestAddr(parentAccs);
        Date dtTest = Date.newInstance(system.today().year(), 6, 1);
        
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(dtTest.addMonths(1).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(dtTest.addMonths(3).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        
        // create additional seasonal addresses that overlap existing seasonal addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(dtTest.addMonths(2).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(dtTest.addMonths(4).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        try {
            insert listAddrT;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrSeasonalOverlap));
            return;
        }
        system.assert(false); //we shouldn't get here!
        
    }

    /*********************************************************************************************************
    @description
        create multiple partial seasonal address  
    verify:
        partial seasonal detected, seasonal addresses don't save
    **********************************************************************************************************/            
    @isTest
    public static void insertPartialSeasonalAddrHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertPartialSeasonalAddr();
    }
    
    @isTest
    public static void insertPartialSeasonalAddrAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertPartialSeasonalAddr();
    }
    
    public static void insertPartialSeasonalAddr() {
        // create additional seasonal addresses not current
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_Start_Day__c = '1';
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        try {
            insert listAddrT;
        } catch (Exception ex) {
            system.assert(ex.getMessage().contains(Label.addrSeasonalPartial));
            return;
        }
        system.assert(false); //we shouldn't get here!
        
    }

    /*********************************************************************************************************
    @description
        schedule a seasonal address update 
    verify:
        contact's && hh address matches new seasonal
        old default addresses still marked default
    **********************************************************************************************************/            
    @isTest
    public static void scheduleSeasonalAddrUpdateHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        scheduleSeasonalAddrUpdate();
    }
    
    @isTest
    public static void scheduleSeasonalAddrUpdateAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        scheduleSeasonalAddrUpdate();
    }
    
    public static void scheduleSeasonalAddrUpdate() { 
        // create additional addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].Seasonal_Start_Month__c = string.valueOf(system.today().month());
            listAddrT[i].Seasonal_Start_Day__c = string.valueOf(system.today().day());
            listAddrT[i].Seasonal_End_Month__c = string.valueOf(system.today().addMonths(1).month());
            listAddrT[i].Seasonal_End_Day__c = '28';
            listAddrT[i].MailingStreet__c = 'New Seasonal Street' + i;
            listAddrT[i].MailingCity__c = 'New Seasonal City' + i;
        }
        
        // Hack!  by setting our trigger handler as run,
        // we can insert the new seasonal addresses but not have them processed.
        // this way we can test the scheduled job!
        ADDR_Addresses_TDTM.hasRunAddrTrigger = true;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;

        //Schedule the job just for test coverage purposes. But we still have to manually run the
        //batch, as batch jobs run from a scheduled job don't actually run after stopTest, as described
        //at https://salesforce.stackexchange.com/questions/36806/does-test-stoptest-ensure-a-system-schedule-database-batchable-completes-in-a
        String jobId= System.schedule('Seasonal Addresses Update', '0 15 0 * * ?', new ADDR_Seasonal_SCHED());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals('0 15 0 * * ?', ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assert(String.valueOf(ct.NextFireTime).contains('00:15:00'));
        
        // run the scheduled batch directly
        ADDR_Seasonal_BATCH batch = new ADDR_Seasonal_BATCH();
        //Test.startTest(); already called by createHHTestData() 
        Database.executeBatch(batch);
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Seasonal Street'));
            system.assert(con.MailingCity.contains('New Seasonal City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the previous addresses still are Default
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(parentAccs * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fSeasonal = (addr.MailingStreet__c.contains('New Seasonal Street'));
            system.assertEquals(!fSeasonal, addr.Default_Address__c);
        }        
    }

    /*********************************************************************************************************
    @description
        create N new duplicate Addresses from Account  
    verify:
        duplicates not created
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAccountAddrHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        newDupeAccountAddr();
    }
    
    @isTest
    public static void newDupeAccountAddrAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        newDupeAccountAddr();
    }
    
    public static void newDupeAccountAddr() {
        // create additional addresses thru the account.
        for (Integer i = 0; i < parentAccs; i++) {
            listAccT[i].BillingStreet = listAddrT[i].MailingStreet__c;
            listAccT[i].BillingCity = listAddrT[i].MailingCity__c;
            listAccT[i].BillingState = listAddrT[i].MailingState__c;
            listAccT[i].BillingPostalCode = listAddrT[i].MailingPostalCode__c;
            listAccT[i].BillingCountry = listAddrT[i].MailingCountry__c;
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        Test.stopTest();
        
        // verify that we don't have new Addresses
        list<Address__c> listAddr = [select Id from Address__c];
        system.assertEquals(parentAccs, listAddr.size());
    }

    /*********************************************************************************************************
    @description
        create N new duplicate Addresses from Contact  
    verify:
        duplicates not created
    **********************************************************************************************************/            
    @isTest
    public static void newDupeContactAddrHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        newDupeContactAddr();
    }
    
    @isTest
    public static void newDupeContactAddrAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        newDupeContactAddr();
    }
    
    public static void newDupeContactAddr() {
        // create additional addresses thru the contact.
        for (Integer i = 0; i < parentAccs; i++) {
            for (Integer j = 0; j < cCon; j++) {
                listConT[(i * parentAccs) + j].MailingStreet = listAddrT[i].MailingStreet__c;
                listConT[(i * parentAccs) + j].MailingCity = listAddrT[i].MailingCity__c;
                listConT[(i * parentAccs) + j].MailingState = listAddrT[i].MailingState__c;
                listConT[(i * parentAccs) + j].MailingPostalCode = listAddrT[i].MailingPostalCode__c;
                listConT[(i * parentAccs) + j].MailingCountry = listAddrT[i].MailingCountry__c;
            }
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listConT;
        Test.stopTest();
        
        // verify that we don't have new Addresses
        list<Address__c> listAddr = [select Id from Address__c];
        system.assertEquals(parentAccs, listAddr.size());
    }

    /*********************************************************************************************************
    @description
        create N new duplicate Addresses from Account, with non-default existing  
    verify:
        duplicates not created
        found match becomes Default
    **********************************************************************************************************/            
    @isTest
    public static void newDupeAccountAddrNonDefaultHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        newDupeAccountAddrNonDefault();
    }
    
    @isTest
    public static void newDupeAccountAddrNonDefaultAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        newDupeAccountAddrNonDefault();
    }
    
    public static void newDupeAccountAddrNonDefault() {
         // create additional non-default addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Street' + i;
            listAddrT[i].MailingCity__c = 'New City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
 
        // create additional addresses thru the account.
        for (Integer i = 0; i < parentAccs; i++) {
            listAccT[i].BillingStreet = listAddrT[i].MailingStreet__c;
            listAccT[i].BillingCity = listAddrT[i].MailingCity__c;
            listAccT[i].BillingState = listAddrT[i].MailingState__c;
            listAccT[i].BillingPostalCode = listAddrT[i].MailingPostalCode__c;
            listAccT[i].BillingCountry = listAddrT[i].MailingCountry__c;
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Street'));
            system.assert(con.MailingCity.contains('New City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the new addresses still are Default and we don't have too many
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(parentAccs * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean isNew = (addr.MailingStreet__c.contains('New Street'));
            system.assertEquals(isNew, addr.Default_Address__c);
        }        
 
    }

    /*********************************************************************************************************
    @description
        create N new duplicate Addresses from Contact, with non-default existing  
    verify:
        duplicates not created
        found match becomes Default
    **********************************************************************************************************/            
    @isTest
    public static void newDupeContactAddrNonDefaultHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        newDupeContactAddrNonDefault();
    }
    
    @isTest
    public static void newDupeContactAddrNonDefaultAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        newDupeContactAddrNonDefault();
    }
    
    public static void newDupeContactAddrNonDefault() {
         // create additional non-default addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'New Street' + i;
            listAddrT[i].MailingCity__c = 'New City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
 
        // create additional addresses thru the contact.
        for (Integer i = 0; i < parentAccs; i++) {
            for (Integer j = 0; j < cCon; j++) {
                listConT[(i * parentAccs) + j].MailingStreet = listAddrT[i].MailingStreet__c;
                listConT[(i * parentAccs) + j].MailingCity = listAddrT[i].MailingCity__c;
                listConT[(i * parentAccs) + j].MailingState = listAddrT[i].MailingState__c;
                listConT[(i * parentAccs) + j].MailingPostalCode = listAddrT[i].MailingPostalCode__c;
                listConT[(i * parentAccs) + j].MailingCountry = listAddrT[i].MailingCountry__c;
            }
        }        
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listConT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assert(con.MailingStreet.contains('New Street'));
            system.assert(con.MailingCity.contains('New City'));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
        
        // verify the new addresses still are Default and we don't have too many
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(parentAccs * 2, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean isNew = (addr.MailingStreet__c.contains('New Street'));
            system.assertEquals(isNew, addr.Default_Address__c);
        }        
 
    }

    /*********************************************************************************************************
    @description
        update contacts' mailing address when they have an address override
    verify:
        new non-default Address created
        contact override updated to new address
        only the contact gets the new Address
    **********************************************************************************************************/            
    @isTest
    public static void updateConAddrWithOverrideHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateConAddrWithOverride();
    }
    
    @isTest
    public static void updateConAddrWithOverrideAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateConAddrWithOverride();
    }
        
    public static void updateConAddrWithOverride() {
        // create additional addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = false;
            listAddrT[i].MailingStreet__c = 'override' + i;
            listAddrT[i].MailingCity__c = 'override' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // set the contacts' address overrides
        list<Contact> listCon = new list<Contact>();
        for (Integer i = 0; i < parentAccs; i++) {
            Contact con = listConT[i*parentAccs + i];
            con.Current_Address__c = listAddrT[i].Id;
            con.is_Address_Override__c = true;
            listCon.add(con);
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
 
        // modify some of the contact addresses directly
        for (Contact con : listCon) {
            con.MailingStreet = 'Direct Street Edit';
            con.MailingCity = 'Direct City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listCon;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            if (con.is_Address_Override__c == false) {
                system.assertNotEquals(null, con.Current_Address__c);
                system.assertEquals(true, isMatchAddressAccCon(acc, con));
                system.assert(!con.MailingStreet.contains('Direct Street Edit'));
                system.assert(!con.MailingCity.contains('Direct City Edit'));
                system.assert(!con.MailingStreet.contains('override'));
                system.assert(!con.MailingCity.contains('override'));
            } else {
                system.assertEquals(false, isMatchAddressAccCon(acc, con));
                system.assert(con.MailingStreet.contains('Direct Street Edit'));
                system.assert(con.MailingCity.contains('Direct City Edit'));
                system.assertEquals(true, con.is_Address_Override__c);
                system.assertNotEquals(null, con.Current_Address__c);
            }
        }
 
         // verify the new overrides are not marked default, and that the contact points to them
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, Parent_Account__c from Address__c];
        system.assertEquals(parentAccs * 3, listAddr.size());
        for (Address__c addr : listAddr) {
            boolean fOverride = (addr.MailingStreet__c.contains('Direct Street Edit'));
            if (fOverride) {
                system.assertEquals(false, addr.Default_Address__c);
                boolean isSetOnContact = false;
                for (Contact con : listCon) {
                    if (con.is_Address_Override__c && con.Current_Address__c == addr.Id)
                        isSetOnContact = true;
                }
                system.assertEquals(true, isSetOnContact);
            }
        }                
    }

    /*********************************************************************************************************
    @description
        insert new contacts with no addresses to existing households that have default addresses
    verify:
        new contacts get the default hh address
    **********************************************************************************************************/            
    @isTest
    public static void insertConWithNoAddrToExistingHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertConWithNoAddrToExisting();
    }
    
    @isTest
    public static void insertConWithNoAddrToExistingAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertConWithNoAddrToExisting();
    }
    
    public static void insertConWithNoAddrToExisting() {
        // insert new contacts to the HH without any addresses
        list<Contact> listCon = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listCon[i].AccountId = listAccT[i].Id;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listCon;         
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        insert new contacts with addresses to existing households that have default addresses
    verify:
        all contacts and hh get the new default hh address from the new contacts
    **********************************************************************************************************/            
    @isTest
    public static void insertConWithAddrToExistingHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertConWithAddrToExisting();
    }
    
    @isTest
    public static void insertConWithAddrToExistingAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertConWithAddrToExisting();
    }
    
    public static void insertConWithAddrToExisting() {
        // insert new contacts to the HH with new addresses
        list<Contact> listCon = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listCon[i].AccountId = listAccT[i].Id;
            listCon[i].MailingStreet = 'New Mailing Street' + i;
            listCon[i].MailingCity = 'New Mailing City' + i;
            listCon[i].MailingState = 'California';
            listCon[i].MailingCountry = 'United States';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listCon;         
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
            system.assert(con.MailingStreet.contains('New Mailing Street'));
            system.assert(con.MailingCity.contains('New Mailing City'));
        }
    }

    /*********************************************************************************************************
    @description
        insert new contacts with default addresses to existing households that have default addresses       
        (this is to mimic the behavior of doing New Contact from the HH Account, in which case Salesforce
        brings up the new contact page in edit mode, with the account's billing address copied into the 
        contact's mailing address fields).
    verify:
        no new addresses created
        new contacts point at the default address
    **********************************************************************************************************/            
    @isTest
    public static void insertConWithDefaultAddrToExistingHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertConWithDefaultAddrToExisting();
    }
    
    @isTest
    public static void insertConWithDefaultAddrToExistingAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertConWithDefaultAddrToExisting();
    }

    public static void insertConWithDefaultAddrToExisting() {
        // reload accounts to get their default addresses
        listAccT = [select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account];
        system.assertEquals(parentAccs, listAccT.size());
        
        // insert new contacts to the HH with the current default addresses
        list<Contact> listCon = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listCon[i].AccountId = listAccT[i].Id;
            listCon[i].MailingStreet = listAccT[i].BillingStreet;
            listCon[i].MailingCity = listAccT[i].BillingCity;
            listCon[i].MailingState = listAccT[i].BillingState;
            listCon[i].MailingPostalCode = listAccT[i].BillingPostalCode;
            listCon[i].MailingCountry = listAccT[i].BillingCountry;
            listCon[i].MailingLatitude = listAccT[i].BillingLatitude;
            listCon[i].MailingLongitude = listAccT[i].BillingLongitude;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listCon;         
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * (cCon + 1), listCon.size());
        
        Integer cAddr = [select count() from Address__c];
        system.assertEquals(parentAccs, cAddr);
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        insert contact w/ multiline street address
    verify:
        new default Address created and the street address is broken up into street and street2
        the HH Account gets the new multiline address
    **********************************************************************************************************/            
    @isTest
    public static void insertContactWithMultilineStreetAddressHH() {
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR, 
                                      Household_Adm_Acct_Addresses_Enabled__c = true));
        insertContactWithMultilineStreetAddress(); 
    }
    
    @isTest
    public static void insertContactWithMultilineStreetAddressAdm() {
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR, 
                                      Household_Adm_Acct_Addresses_Enabled__c = true));
        insertContactWithMultilineStreetAddress();
    }
    
    public static void insertContactWithMultilineStreetAddress() {     
        listConT = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cCon);
        for (Contact con : listConT) {
            con.MailingStreet = 'new street\r\nsecond line';
            con.MailingCity = 'new city';
        }
        Test.startTest();
        insert listConT; 
        Test.stopTest();       
        
        // verify the Address objects split street.
        list<Address__c> listAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c from Address__c];
        for (Address__c addr : listAddr) {
            system.assertEquals('new street', addr.MailingStreet__c);
            system.assertEquals('second line', addr.MailingStreet2__c);
            system.assertEquals('new street, second line', addr.Formula_MailingStreetAddress__c);
        }

        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals('new street\r\nsecond line', con.MailingStreet);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        insert new default multiline street addresses to HH w/ existing default addresses  
    verify:
        contact's && hh address matches new default
        street & street2 combined into contact and account single street field
    **********************************************************************************************************/            
    @isTest
    public static void insertNewDefaultMultilineStreetAddrHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        insertNewDefaultMultilineStreetAddr();
    }
    
    @isTest
    public static void insertNewDefaultMultilineStreetAddrAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        insertNewDefaultMultilineStreetAddr();
    }
    
    public static void insertNewDefaultMultilineStreetAddr() {
        // create additional addresses
        initTestAddr(parentAccs);
        for (Integer i = 0; i < parentAccs; i++) {
            listAddrT[i].Parent_Account__c = listAccT[i].Id;
            listAddrT[i].Default_Address__c = true;
            listAddrT[i].MailingStreet__c = 'New Default Street';
            listAddrT[i].MailingStreet2__c = 'Second Line';
            listAddrT[i].MailingCity__c = 'New Default City' + i;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;        
        Test.stopTest();

        // verify that the HH and Contacts share the same address and it's new!
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        system.assertEquals(parentAccs * cCon, listCon.size());
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals('New Default Street\r\nSecond Line', con.MailingStreet);
            system.assertEquals('New Default Street\r\nSecond Line', acc.BillingStreet);
        }
        
    }
    
    /*********************************************************************************************************
    @description
        update accounts' billing address with multiline street address  
    verify:
        new Default Address created
        HH and Contacts get new Address
        new Addresss has multiline street split into Street and Street2 fields
    **********************************************************************************************************/            
    @isTest
    public static void updateAccMultilineStreetAddrHH() {        
        // this creates a default Address for each Account
        createHHTestData(parentAccs, cCon);
        updateAccMultilineStreetAddr();
    }
    
    @isTest
    public static void updateAccMultilineStreetAddrAdm() {        
        // this creates a default Address for each Account
        createAdmTestData(parentAccs, cCon);
        updateAccMultilineStreetAddr();
    }
    
    public static void updateAccMultilineStreetAddr() {
        // modify some of the account addresses directly
        for (Integer i = 0; i < parentAccs; i++) {
            Account acc = listAccT[i];
            acc.BillingStreet = 'Direct Street Edit\r\nSecond Line';
            acc.BillingCity = 'Direct City Edit';
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAccT;
        Test.stopTest();
        
        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals('Direct Street Edit\r\nSecond Line', acc.BillingStreet);
            system.assertEquals('Direct Street Edit\r\nSecond Line', con.MailingStreet);
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
 
        // verify the Address objects split street.
        list<Address__c> listAddr = [select Id, MailingStreet__c, MailingStreet2__c, Formula_MailingStreetAddress__c, Default_Address__c from Address__c];
        for (Address__c addr : listAddr) {
            if (addr.Default_Address__c) {
                system.assertEquals('Direct Street Edit', addr.MailingStreet__c);
                system.assertEquals('Second Line', addr.MailingStreet2__c);
                system.assertEquals('Direct Street Edit, Second Line', addr.Formula_MailingStreetAddress__c);
            }
        }

    }

    /*********************************************************************************************************
    @description
        create N new organizational accounts with billing addresses 
    verify:
        N addresses created
        account address matches address object address
    **********************************************************************************************************/            
    @isTest
    public static void newOrgAccounts() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR,
                Organizational_Account_Addresses_Enabled__c = true
        ));
 
        Integer cAcc = 3;
        list<Account> listAcc = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(cAcc, null);
        for (Account acc : listAcc) {
            acc.BillingStreet = '123 45th';
            acc.BillingCity = 'Seattle';
        }
        Test.startTest();
        insert listAcc;
        Test.stopTest();

        // verify results
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        system.assertEquals(cAcc, mapAccIdAcc.size());
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c];
        system.assertEquals(cAcc, listAddr.size());
        
        for (Address__c addr : listAddr) {
            Account acc = mapAccIdAcc.get(addr.Parent_Account__c);
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertEquals(true, addr.Default_Address__c);
        }
    }

    /*********************************************************************************************************
    @description
        update N organizational accounts with billing addresses 
    verify:
        N addresses created
        account addresses updated
        contact addresses not updated
    **********************************************************************************************************/            
    @isTest
    public static void updateOrgAccounts() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR,
                Organizational_Account_Addresses_Enabled__c = true
        ));
 
        // create accounts without addresses
        Integer cAcc = 3;
        list<Account> listAcc = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(cAcc, null);
        insert listAcc;
        
        // add a contact to each account.
        list<Contact> listCon = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cAcc);
        for (Integer i = 0; i < cAcc; i++) {
            listCon[i].AccountId = listAcc[i].Id;
        }
        insert listCon;

        // update the accounts' address
        for (Account acc : listAcc) {
            acc.BillingStreet = '123 45th';
            acc.BillingCity = 'Seattle';
        }
        Test.startTest();
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        update listAcc;
        Test.stopTest();

        // verify results
        listAcc = [select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry 
                    from Account order by Account.Name];
        system.assertEquals(cAcc, listAcc.size());
        
        list<Address__c> listAddr = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c 
                                    from Address__c order by Parent_Account__r.Name];
        system.assertEquals(cAcc, listAddr.size());
        
        listCon = [select Id, AccountId, Name, Current_Address__c, MailingStreet, MailingCity from Contact order by Account.Name];
        system.assertEquals(cAcc, listCon.size());        
        
        for (Integer i = 0; i < cAcc; i++) {
            Account acc = listAcc[i];
            Address__c addr = listAddr[i];
            Contact con = listCon[i];
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertEquals(true, addr.Default_Address__c);
            system.assertEquals(null, con.Current_Address__c);
            system.assertEquals(null, con.MailingStreet);
            system.assertEquals(null, con.MailingCity);
        }
    }
    
    /*********************************************************************************************************
    @description
        update N organizational accounts with address objects 
    verify:
        account addresses updated
        contact addresses not updated
    **********************************************************************************************************/            
    @isTest
    public static void newAddrForOrgAccounts() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR,
                Organizational_Account_Addresses_Enabled__c = true
        ));
 
        // create accounts without addresses
        Integer cAcc = 3;
        list<Account> listAcc = UTIL_UnitTestData_TEST.CreateMultipleTestAccounts(cAcc, null);
        insert listAcc;
        
        // add a contact to each account.
        list<Contact> listCon = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cAcc);
        for (Integer i = 0; i < cAcc; i++) {
            listCon[i].AccountId = listAcc[i].Id;
        }
        insert listCon;

         // create addresses for the accounts
        initTestAddr(cAcc);
        for (Integer i = 0; i < cAcc; i++) {
            listAddrT[i].Parent_Account__c = listAcc[i].Id;
            listAddrT[i].Default_Address__c = true;
        }
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        insert listAddrT;
        ADDR_Addresses_TDTM.hasRunAddrTrigger = false;
        
        // verify results
        listAcc = [select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account order by Account.Name];
        system.assertEquals(cAcc, listAcc.size());
        listAddrT = [select Id, Default_Address__c, MailingStreet__c, MailingCity__c, Parent_Account__c, Latest_Start_Date__c, Latest_End_Date__c from Address__c order by Parent_Account__r.Name];
        system.assertEquals(cAcc, listAddrT.size());
        listCon = [select Id, AccountId, Name, Current_Address__c, MailingStreet, MailingCity from Contact order by Account.Name];
        system.assertEquals(cAcc, listCon.size());        
        
        for (Integer i = 0; i < cAcc; i++) {
            Account acc = listAcc[i];
            Address__c addr = listAddrT[i];
            Contact con = listCon[i];
            system.assertEquals(acc.BillingStreet, addr.MailingStreet__c);
            system.assertEquals(acc.BillingCity, addr.MailingCity__c);
            system.assertEquals(true, addr.Default_Address__c);
            system.assertEquals(null, con.Current_Address__c);
            system.assertEquals(null, con.MailingStreet);
            system.assertEquals(null, con.MailingCity);
        }
    }

    /*********************************************************************************************************
    @description
        create N contacts with Household Accounts when the setting for Address Mgmt is off. 
    verify:
        no Address objects created
        HH Account addresses set
        Contact addresses set
    **********************************************************************************************************/            
    @isTest
    public static void testDisabledHHAccountAddr() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR,
                Household_Adm_Acct_Addresses_Enabled__c = false
        ));
        testDisabledAccountAddr();
    }
    
    @isTest
    public static void testDisabledAdmAccountAddr() {        
        Hierarchy_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c (
                Account_Processor__c = CAO_Constants.Adm_ACCOUNT_PROCESSOR,
                Household_Adm_Acct_Addresses_Enabled__c = false
        ));
        testDisabledAccountAddr();
    }
    
    public static void testDisabledAccountAddr() {
        listConT = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cCon);
        for (Contact con : listConT) {
            con.MailingStreet = 'new street';
            con.MailingCity = 'new city';
        }
        insert listConT;        

        // verify that the HH and Contacts share the same address
        map<Id, Account> mapAccIdAcc = new map<Id, Account>([select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude from Account]);
        list<Contact> listCon = [select Id, Name, AccountId, is_Address_Override__c, Current_Address__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude from Contact];
        
        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertEquals(null, con.Current_Address__c);
        }
        
        // verify no address objects created
        list<Address__c> listAddr = [select Id from Address__c];
        system.assertEquals(0, listAddr.size());
    }
}