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
* @date 2014
* @group Settings
* @group-content ../../ApexDocContent/Settings.htm
* @description Test Class for the Install Script for the HEDA package.
*/
@isTest
public with sharing class STG_InstallScript_TEST {

	@isTest
	public static void onInstall() {
        Contact cont = new Contact(
            FirstName = 'Joe',
            LastName = 'Test',
            Email = 'joe@domain.com'
        );
        CON_Preferred_TDTM.alreadyRunBefore = true; // need to turn off the trigger for this test
        insert cont;

        CON_Preferred_TDTM.alreadyRunBefore = false; // back on for install script

        Test.startTest();
		//Run the install script
        Test.testInstall(new STG_InstallScript(), null);
        Test.stopTest();

        List<Affl_Mappings__c> mappings = [select Account_Record_Type__c, Primary_Affl_Field__c from Affl_Mappings__c];
        System.assertEquals(6, mappings.size());

        List<Trigger_Handler__c> tdtmHandlers = [select Name, Owned_by_Namespace__c from Trigger_Handler__c];
        System.assertEquals(TDTM_DefaultConfig.getDefaultRecords().size(), tdtmHandlers.size());

        for(Trigger_Handler__c h:tdtmHandlers){
            // Verify Owned by namespace field set on first item in list
            System.assertEquals('hed', h.Owned_by_Namespace__c);
        }

        // Making sure the Batch process ran successfully
        Contact cont2 = [SELECT Id, Name, Email, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE Id =: cont.Id];
        System.assertEquals(cont2.AlternateEmail__c, cont2.Email);
	}

    @isTest
    public static void tdtmPushWithNamespace() {
        // Testing for push upgrades

        // Make Modifications to store in the database.
        List<Trigger_Handler__c> previousDefaults = TDTM_DefaultConfig.getDefaultRecords();
        for(Trigger_Handler__c h:previousDefaults){
            h.Trigger_Action__c = null;
        }
        insert previousDefaults;

        Test.startTest();
        //Run the install script as a push upgrade
        Test.testInstall(new STG_InstallScript(), new Version(1,41), true);
        Test.stopTest();

        List<Trigger_Handler__c> tdtmHandlers = [select Name, Owned_by_Namespace__c, Trigger_Action__c from Trigger_Handler__c WHERE Owned_by_Namespace__c = 'hed'];

        for(Trigger_Handler__c h:tdtmHandlers){
            // Verify Owned by namespace field set on first item in list
            System.assertEquals('hed', h.Owned_by_Namespace__c);
            System.assertNotEquals(null, h.Trigger_Action__c); // Should not be null
        }
    }

    @isTest
    public static void tdtmUpdateWithNamespace() {
        // Testing the special Case when orgs are updated to 1.37 without user managed field

        // Simulate a user adding their own handler, should not need User_Managed__c to be true
        Trigger_Handler__c newHandler = new Trigger_Handler__c(
            Active__c = true,
            Asynchronous__c = false,
            Class__c = 'Contact_Update',
            Load_Order__c = 0.2,
            Object__c = 'Contact',
            Trigger_Action__c = 'BeforeInsert;BeforeUpdate'
        );
        insert newHandler;

        // Remove Namespace from all records
        List<Trigger_Handler__c> previousDefaults = TDTM_DefaultConfig.getDefaultRecords();
        for(Trigger_Handler__c h:previousDefaults){
            h.Owned_by_Namespace__c = null;
        }
        insert previousDefaults;

        Test.startTest();
        //Run the install script
        Test.testInstall(new STG_InstallScript(), new Version(1,36), true);
        Test.stopTest();

        // They should now all have the 'hed' as the namespace
        List<Trigger_Handler__c> tdtmHandlers = [select Name, Owned_by_Namespace__c from Trigger_Handler__c WHERE Owned_by_Namespace__c = 'hed'];

        System.assertEquals(previousDefaults.size(), tdtmHandlers.size());

        // User handlers should not be touched
        List<Trigger_Handler__c> userHandlers = [select Name, Owned_by_Namespace__c from Trigger_Handler__c WHERE Class__c = 'Contact_Update' AND Object__c = 'Contact'];
        System.assertEquals(1, userHandlers.size());
        System.assertEquals(null, userHandlers[0].Owned_by_Namespace__c);

    }

    // Testing a 1.36 and 1.37 Org state. This is testing a scenario where an org had user managed triggers, prior to the existence of the "Owned by Namespace" field
    @isTest
    public static void tdtmUpdateWithNamespaceUserManaged() {

        // Remove Namespace and disable all records
        List<Trigger_Handler__c> previousDefaults = TDTM_DefaultConfig.getDefaultRecords();
        for(Trigger_Handler__c h:previousDefaults){
            h.Owned_by_Namespace__c = null;
        }
        insert previousDefaults;

        // Now that the trigger handlers are added lets simulate them being disabled by an Admin.
        List<Trigger_Handler__c> userModifiedDefaults = [SELECT Id, Name, Owned_by_Namespace__c, Active__c, User_Managed__c FROM Trigger_Handler__c];
        for(Trigger_Handler__c h:userModifiedDefaults){
            h.Active__c = false;
            h.User_Managed__c = true;
        }
        update userModifiedDefaults;

        //Run the install script
        Test.testInstall(new STG_InstallScript(), new Version(1,36), true);

        List<Trigger_Handler__c> tdtmHandlers = [SELECT Id, Name, Owned_by_Namespace__c, Active__c, User_Managed__c FROM Trigger_Handler__c];

        // Verify the number of default records didn't change.
        System.assertEquals(TDTM_DefaultConfig.getDefaultRecords().size(), tdtmHandlers.size());

        for(Trigger_Handler__c h:tdtmHandlers){
            // Unfortunantly the user overwrote them all, so we cannot edit it to add the namespace field
            System.assertEquals('hed', h.Owned_by_Namespace__c);

            // Verify Admin overrides
            System.assertEquals(false, h.Active__c);
            System.assertEquals(true, h.User_Managed__c);
        }

        Test.startTest();

        //Run the install script
        Test.testInstall(new STG_InstallScript(), new Version(1,37), true);
        Test.stopTest();

        List<Trigger_Handler__c> tdtmHandlers2 = [SELECT Id, Name, Owned_by_Namespace__c, Active__c, User_Managed__c FROM Trigger_Handler__c];

        // Verify the number of default records didn't change.
        System.assertEquals(TDTM_DefaultConfig.getDefaultRecords().size(), tdtmHandlers2.size());

        for(Trigger_Handler__c h: tdtmHandlers2){
            // Unfortunantly the user overwrote them all, so we cannot edit it to add the namespace field
            System.assertEquals('hed', h.Owned_by_Namespace__c);

            // Verify Admin overrides
            System.assertEquals(false, h.Active__c);
            System.assertEquals(true, h.User_Managed__c);
        }
    }

    @isTest
    public static void changeAdminAccAddressParent() {
        //Create 201 accounts of adminRecType
        String adminRecTypeId = UTIL_Describe.getAdminAccRecTypeID();
        List<Account> accs = new List<Account>();
        for(Integer i = 0; i < 200; i++) {
            accs.add(new Account(Name = 'acctest' + i, RecordTypeId = adminRecTypeId));
        }
        insert accs;

        //Create 201 contacts and link them with those accounts
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < 200; i++) {
            contacts.add(new Contact(LastName = 'contest' + i, AccountId = accs[i].Id));
        }
        insert contacts;

        //Create 201 addresses and link them with those accounts
        List<Address__c> addrs = new List<Address__c>();
        for(Integer i = 0; i < 200; i++) {
            addrs.add(new Address__c(Parent_Account__c = accs[i].Id));
        }
        insert addrs;

        //Run script
        Test.startTest();
        STG_InstallScript.reparentAdminAddrs(new Version(1, 14));
        Test.stopTest();

        //Verify addresses are now linked with the contacts
        addrs = [select Parent_Account__c, Parent_Contact__c from Address__c where ID IN :addrs];
        for(Address__c addr : addrs) {
            System.assertEquals(null, addr.Parent_Account__c);
            System.assertNotEquals(null, addr.Parent_Contact__c);
        }
    }
}