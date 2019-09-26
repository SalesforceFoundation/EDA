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
* @description Test Class for the Install Script for the EDA package.
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
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false); // need to turn off the trigger for this test
        insert cont;

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true); // back on for install script

        Test.startTest();
		//Run the install script
        Test.testInstall(new STG_InstallScript(), null);
        Test.stopTest();

        List<Affl_Mappings__c> mappings = [SELECT Account_Record_Type__c, Primary_Affl_Field__c FROM Affl_Mappings__c];
        System.assertEquals(6, mappings.size());

        List<Trigger_Handler__c> tdtmHandlers = [SELECT Name, Owned_by_Namespace__c FROM Trigger_Handler__c];
        System.assertEquals(TDTM_DefaultConfig.getDefaultRecords().size(), tdtmHandlers.size());

        for (Trigger_Handler__c h : tdtmHandlers) {
            // Verify Owned by namespace field set on first item in list
            System.assertEquals('hed', h.Owned_by_Namespace__c);
        }

        // Verify defaults are set on install
        Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
        System.assertEquals(Label.stgFluent, orgSettings.Default_Contact_Language_Fluency__c);
        
        System.assertEquals(true, orgSettings.Enable_New_Preferred_Phone_Sync__c,
            'Expected the new Preferred Phone sync to be enabled on install.');
        System.assertEquals(false, orgSettings.Disable_Preferred_Phone_Enforcement__c,
            'Expected the Preferred Phone enforcement to be enabled on install.');

        // Making sure the Batch process ran successfully
        Contact cont2 = [SELECT Id, Name, Email, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE Id =: cont.Id];
        System.assertEquals(cont2.AlternateEmail__c, cont2.Email);

        System.assertEquals(false, STG_InstallScript.sendTelemetryDataMethodCalled, 'Did not expect the EDA Telemetry data method to be called on install.');
	}

    @isTest
    public static void tdtmPushWithNamespace() {
        // Testing for push upgrades

        // Make Modifications to store in the database.
        List<Trigger_Handler__c> previousDefaults = TDTM_DefaultConfig.getDefaultRecords();
        for (Trigger_Handler__c h : previousDefaults) {
            h.Trigger_Action__c = null;
        }
        insert previousDefaults;

        Test.startTest();
        //Run the install script as a push upgrade
        Test.testInstall(new STG_InstallScript(), new Version(1,41), true);
        Test.stopTest();

        List<Trigger_Handler__c> tdtmHandlers = [SELECT Name, Owned_by_Namespace__c, Trigger_Action__c FROM Trigger_Handler__c WHERE Owned_by_Namespace__c = 'hed'];

        for (Trigger_Handler__c h : tdtmHandlers) {
            // Verify Owned by namespace field set on first item in list
            System.assertEquals('hed', h.Owned_by_Namespace__c);
            System.assertNotEquals(null, h.Trigger_Action__c); // Should not be null
        }

        System.assertEquals(true, STG_InstallScript.sendTelemetryDataMethodCalled, 'Expected the EDA Telemetry data method to be called on push upgrade.');
    }

    @isTest
    public static void tdtmUpdateWithNamespace() {
        // Testing the special Case when orgs are updated to 1.38 before "Owned by Namespace" field existed on Trigger Handlers

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

        // Verify handlers are not added to the DB
        List<Trigger_Handler__c> initialHandlers = [SELECT Name, Owned_by_Namespace__c FROM Trigger_Handler__c WHERE Owned_by_Namespace__c = 'hed'];
        System.assertEquals(0, initialHandlers.size());

        // Remove Namespace from all records
        List<Trigger_Handler__c> previousDefaults = TDTM_DefaultConfig.getDefaultRecords();
        for (Trigger_Handler__c h : previousDefaults) {
            h.Owned_by_Namespace__c = null;
        }
        insert previousDefaults;

        Test.startTest();
        //Run the install script
        Test.testInstall(new STG_InstallScript(), new Version(1,36), true);
        Test.stopTest();

        // They should now all have the 'hed' as the namespace
        List<Trigger_Handler__c> tdtmHandlers = [SELECT Name, Owned_by_Namespace__c FROM Trigger_Handler__c WHERE Owned_by_Namespace__c = 'hed'];

        System.assertEquals(previousDefaults.size(), tdtmHandlers.size());

        // User handlers should not be touched
        List<Trigger_Handler__c> userHandlers = [SELECT Name, Owned_by_Namespace__c FROM Trigger_Handler__c WHERE Class__c = 'Contact_Update' AND Object__c = 'Contact'];
        System.assertEquals(1, userHandlers.size());
        System.assertEquals(null, userHandlers[0].Owned_by_Namespace__c);
    }

    // Testing a 1.37 and 1.38 Org state upgrade. This is testing a scenario where an org had user managed triggers, prior to the existence of the "Owned by Namespace" field
    @isTest
    public static void tdtmUpdateWithNamespaceUserManaged() {

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

        // Remove Namespace to simulate pre 1.38 status, and user disabled
        List<Trigger_Handler__c> userModifiedDefaults = TDTM_DefaultConfig.getDefaultRecords();
        for (Trigger_Handler__c h:userModifiedDefaults) {
            h.Owned_by_Namespace__c = null;
            h.Active__c = false;
            h.User_Managed__c = true;
        }
        insert userModifiedDefaults;

        //Run the install script
        Test.testInstall(new STG_InstallScript(), new Version(1,37), true);

        List<Trigger_Handler__c> tdtmHandlers = [SELECT Id, Name, Owned_by_Namespace__c, Active__c, User_Managed__c, Class__c FROM Trigger_Handler__c];

        // Verify the number of default records didn't change. We subtract one because the custom non-EDA trigger handler should still exist
        System.assertEquals(TDTM_DefaultConfig.getDefaultRecords().size(), tdtmHandlers.size()-1);

        for (Trigger_Handler__c h : tdtmHandlers) {
            if(h.Class__c != 'Contact_Update') { // exclude custom handler
                System.assertEquals('hed', h.Owned_by_Namespace__c);

                // Verify Admin overrides
                System.assertEquals(false, h.Active__c);
                System.assertEquals(true, h.User_Managed__c);
            }
        }

        Test.startTest();

        //Run the install script
        Test.testInstall(new STG_InstallScript(), new Version(1,38), true);
        Test.stopTest();

        List<Trigger_Handler__c> tdtmHandlers2 = [SELECT Id, Name, Owned_by_Namespace__c, Active__c, User_Managed__c, Class__c FROM Trigger_Handler__c];

        // Verify the number of default records didn't change.
        System.assertEquals(TDTM_DefaultConfig.getDefaultRecords().size(), tdtmHandlers2.size()-1);

        for (Trigger_Handler__c h: tdtmHandlers2) {
            if(h.Class__c != 'Contact_Update') {
                // Verify 'hed' namespace still persists
                System.assertEquals('hed', h.Owned_by_Namespace__c);

                // Verify Admin overrides
                System.assertEquals(false, h.Active__c);
                System.assertEquals(true, h.User_Managed__c);
            } else {
                // Verify custom handler
                System.assertEquals('Contact_Update', h.Class__c);
                System.assertEquals(null, h.Owned_by_Namespace__c);
                System.assertEquals(true, h.Active__c);
                System.assertEquals(false, h.User_Managed__c);
            }
        }
    }

    @isTest
    public static void changeAdminAccAddressParent() {
        //Create 201 accounts of adminRecType
        String adminRecTypeId = UTIL_Describe_API.getAdminAccRecTypeID();
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accs.add(new Account(Name = 'acctest' + i, RecordTypeId = adminRecTypeId));
        }
        insert accs;

        //Create 201 contacts and link them with those accounts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
            contacts.add(new Contact(LastName = 'contest' + i, AccountId = accs[i].Id));
        }
        insert contacts;

        //Create 201 addresses and link them with those accounts
        List<Address__c> addrs = new List<Address__c>();
        for (Integer i = 0; i < 200; i++) {
            addrs.add(new Address__c(Parent_Account__c = accs[i].Id));
        }
        insert addrs;

        //Run script
        Test.startTest();
        STG_InstallScript.reparentAdminAddrs(new Version(1, 14));
        Test.stopTest();

        //Verify addresses are now linked with the contacts
        addrs = [SELECT Parent_Account__c, Parent_Contact__c FROM Address__c WHERE ID IN :addrs];
        for (Address__c addr : addrs) {
            System.assertEquals(null, addr.Parent_Account__c);
            System.assertNotEquals(null, addr.Parent_Contact__c);
        }
    }

    @isTest
    public static void createAdminAccountForContactOnInstall() {

        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

        Contact cont = new Contact(
                FirstName = 'Test',
                LastName = 'User',
                Email = 'usertest@domain.com'
        );

        
        // need to turn off the trigger for this test
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert, true);
        insert cont;
        // back on for install script
		TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.ACCT_IndividualAccounts_TDTM_After_Insert, false);

        Contact contWithoutAccId = [SELECT AccountId FROM Contact WHERE Id = :cont.Id];        
        System.assertEquals(null, contWithoutAccId.AccountId);

        Test.startTest();
        Test.testInstall(new STG_InstallScript(), null);
        Test.stopTest();
        
        //After we run install script, system should populate the AccountId field of the Contact
        Contact contWithAccId = [SELECT AccountId FROM Contact WHERE Id = :cont.Id];
        System.assertNotEquals(null, contWithAccId.AccountId);

    }

    @isTest
    public static void seasonalAddressScheduleOnInstall() {

        Test.startTest();
        Test.testInstall(new STG_InstallScript(), null);
        Test.stopTest();

        //System should create the address schedule job after the installation.
        List<CronTrigger> addressSchedule = [SELECT ID, CronExpression, CronJobDetail.Name, CronJobDetailId, EndTime, NextFireTime, PreviousFireTime, StartTime, State, TimesTriggered FROM CronTrigger
        where CronJobDetail.Name = 'Seasonal Addresses Update'];
        System.assertEquals(1, addressSchedule.size());        
    }

    @isTest
    public static void asyncErrorSchedule() {

        Test.startTest();
        Test.testInstall(new STG_InstallScript(), null);
        Test.stopTest();

        //System should create the error schedule job after the installation. 
        List<CronTrigger> errorSchedule = [SELECT ID, CronExpression, CronJobDetail.Name, CronJobDetailId, EndTime, NextFireTime, PreviousFireTime, StartTime, State, TimesTriggered FROM CronTrigger
        where CronJobDetail.Name = 'HEDA Async Apex Error Processing'];
        System.assertEquals(1, errorSchedule.size());
    }

    @isTest
    public static void deleteOutdatedErrorSchedule() {

        Test.startTest();
        Test.testInstall(new STG_InstallScript(), null);
        Test.stopTest();

        //System should create the error schedule job after the installation.
        List<CronTrigger> errorSchedule = [SELECT ID, CronExpression, CronJobDetail.Name, CronJobDetailId, EndTime, NextFireTime, PreviousFireTime, StartTime, State, TimesTriggered FROM CronTrigger
                                            WHERE CronJobDetail.Name = 'HEDA 90-day-old Error Cleaning'];
        System.assertEquals(1, errorSchedule.size());
    }

    @isTest
    public static void populateAdminRecordTypeSetting() {
        Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
        orgSettings.Administrative_Account_Record_Type__c = '';
        upsert orgSettings;

        Test.startTest();
        //Run the install script for orgs using EDA 1.67
        Test.testInstall(new STG_InstallScript(), new Version(1,67), true);
        Test.stopTest();

        Hierarchy_Settings__c updatedSettings = UTIL_CustomSettingsFacade.getSettings();
        System.assertNotEquals(null, updatedSettings.Administrative_Account_Record_Type__c);
        System.assertNotEquals('', updatedSettings.Administrative_Account_Record_Type__c);
        System.assertEquals(UTIL_Describe_API.getAdminAccRecTypeID(), orgSettings.Administrative_Account_Record_Type__c);
    }

    @isTest
    private static void setDefaultContactLanguageFluencyOnUpgrade() {
        Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
        orgSettings.Default_Contact_Language_Fluency__c = '';
        upsert orgSettings;
        
        Test.startTest();
        // Run the install script for orgs using HEDA 1.74
        Test.testInstall(new STG_InstallScript(), new Version(1,74), true);
        Test.stopTest();

        Hierarchy_Settings__c updatedSettings = UTIL_CustomSettingsFacade.getSettings();
        System.assertEquals(Label.stgFluent, updatedSettings.Default_Contact_Language_Fluency__c);
    }
    
    @isTest
    private static void disablePreferredPhoneOnUpgrade() {
        Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
        orgSettings.Disable_Preferred_Phone_Enforcement__c = False;
        upsert orgSettings;
        
        Test.startTest();
        // Run the install script for orgs using HEDA 1.81
        Test.testInstall(new STG_InstallScript(), new Version(1,81), true);
        Test.stopTest();

        Hierarchy_Settings__c updatedSettings = UTIL_CustomSettingsFacade.getSettings();
        
        System.assertEquals(true, updatedSettings.Disable_Preferred_Phone_Enforcement__c,
            'Expected the Preferred Phone enforcement to be disabled.');
        System.assertEquals(false, updatedSettings.Enable_New_Preferred_Phone_Sync__c, 
            'Expected the new Preferred Phone sync to be disabled.');
    }
}