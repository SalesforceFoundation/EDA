/*
    Copyright (c) 2009, Salesforce.org
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
 * @date 2021
 * @group Lead Conversion
 * @description Unmanaged functional tests for Lead Conversion Account Name handling
 */

@isTest
private with sharing class LeadConversionAccountNaming_FTST {
    /** Helper method to create the Hierarchy Settings for the tests
     * @param: populateConversionRTs indicates if the Admin and Household RTs should be included
     * for the Lead Conversion
     * @return: returns the orgSettings
     */
    private static hed__Hierarchy_Settings__c createSettings(Boolean populateConversionRTs) {
        hed__Hierarchy_Settings__c orgSettings = hed.UTIL_CustomSettings_API.getOrgSettings();
        if (populateConversionRTs) {
            orgSettings.hed__Lead_Converted_Account_RTypes__c =
                hed.UTIL_Describe_API.getAdminAccRecTypeID() +
                ';' +
                hed.UTIL_Describe_API.getHhAccRecTypeID(); //populate Admin & Household account conversion types
        } else {
            orgSettings.hed__Lead_Converted_Account_RTypes__c = null; //ensure no Account record types for LC
        }
        orgSettings.hed__Admin_Account_Naming_Format__c = '{!{!FirstName}} {!LastName} Administrative Account';
        orgSettings.hed__Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household';
        upsert orgSettings;
        hed.UTIL_CustomSettings_API.getSettingsForTests(orgSettings);
        return orgSettings;
    }

    /**
     * @description T-5026176: Verify that the Lead Conversion Account Naming has no changes with the RT setting disabled
     * (ie, Account Name should be the same as the Lead Company)
     */
    @isTest
    private static void convertLeadVerifySameAccountNameWithoutSettings() {
        hed__Hierarchy_Settings__c orgSettings = createSettings(false);

        Lead testLead = hed.UTIL_UnitTestData_API.getLead();
        testLead.Company = testLead.company + Datetime.now().getTime();
        insert testLead;

        Test.startTest();

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);
        LeadStatus convertedStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        lc.setConvertedStatus(convertedStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Test.stopTest();
        System.assert(lcr.isSuccess()); //Assert conversion succeeded

        //Verify Account Name is the same as the Lead Company
        List<Account> accts = [SELECT Id, Name FROM Account];
        System.assertEquals(1, accts.size(), 'There should be one Account created.');
        System.assertEquals(
            testLead.Company,
            accts[0].Name,
            'The Account should have the same name as the Lead.Company.'
        );
    }

    /**
     * @description T-5026177: Verify that the Lead Conversion Account Naming has no changes with the Record Type
     * setting enabled. (Lead Conversion will create a new Account with the Profile's default Account, so ensure
     * the default is different than the hed__Lead_Converted_Account_RTypes__c setting.)
     */
    @isTest
    private static void convertLeadVerifySameAccountNameWithSettings() {
        //Set Academic Account Record Type as the RT setting since it is not the default Account RT
        hed__Hierarchy_Settings__c orgSettings = createSettings(false);
        orgSettings.hed__Lead_Converted_Account_RTypes__c = hed.UTIL_Describe_API.getAcademicAccRecTypeID();

        //Confirm Academic is not the default RT (default will be used for the new Account during Lead Conversion)
        Schema.DescribeSObjectResult dsr = Schema.SObjectType.Account;
        Map<Id, Schema.RecordTypeInfo> rtMapById = dsr.getRecordTypeInfosById();
        Schema.RecordTypeInfo academicRTInfo = rtMapById.get(hed.UTIL_Describe_API.getAcademicAccRecTypeID());
        System.assertEquals(
            false,
            academicRTInfo.isDefaultRecordTypeMapping(),
            'Academic Account should not be the default Account Record Type'
        );

        //Create a new lead and convert (will create new Account with default RT)
        Lead testLead = hed.UTIL_UnitTestData_API.getLead();
        testLead.Company = 'Test Company ' + Datetime.now().getTime();
        insert testLead;

        Test.startTest();
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);

        LeadStatus convertedStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        lc.setConvertedStatus(convertedStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();
        System.assert(lcr.isSuccess());

        //Verify new Account RT is not Academic and Name is the same as the Lead Company
        List<Account> accts = [SELECT Id, Name, RecordTypeId FROM Account WHERE Name = :testLead.Company];
        System.assertNotEquals(
            hed.UTIL_Describe_API.getAcademicAccRecTypeID(),
            accts[0].RecordTypeId,
            'The new Account should not be the Academic Account RT'
        );
        System.assertEquals(1, accts.size(), 'The Account name should match the Lead.Company and not be updated.');
    }

    /**
     * @description T-5026178: Verify that Lead Conversion Account Naming is honored with the Setting Enabled,
     * and the Record Type Selected (assumes default Account model naming "{LastName} Account" in EDA)
     */
    @isTest
    private static void convertLeadVerifyAcademicAccountNameWithDefaultSettings() {
        //Create settings with Academic Record type set as a Lead Converted type
        hed.UTIL_CustomSettings_API.getSettingsForTests(
            new hed__Hierarchy_Settings__c(
                hed__Account_Processor__c = hed.UTIL_Describe_API.getAdminAccRecTypeID(),
                hed__Household_Account_Naming_Format__c = '{!LastName} Household Account',
                hed__Automatic_Household_Naming__c = true,
                hed__Lead_Converted_Account_RTypes__c = hed.UTIL_Describe_API.getAcademicAccRecTypeID()
            )
        );

        Lead testLead = hed.UTIL_UnitTestData_API.getLead();
        insert testLead;

        Account testAccount = new Account(
            Name = 'Test Account Name',
            RecordTypeId = hed.UTIL_Describe_API.getAcademicAccRecTypeID()
        );
        insert testAccount;

        Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.Id);
        lc.setAccountId(testAccount.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();

        System.assert(lcr.isSuccess());

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account WHERE Id = :testAccount.Id];

        System.assertEquals(testLead.LastName + ' Account', assertAccount.Name);
    }

    /**
     * @description T-5026179: Verify that Lead Conversion Account Naming is honored with the Setting Enabled,
     * and the Record Type Selected (Administrative Account Name Format set)
     */
    @isTest
    private static void convertLeadVerifyAdministrativeAccountNaming() {
        hed__Hierarchy_Settings__c orgSettings = createSettings(true);

        Lead testLead = hed.UTIL_UnitTestData_API.getLead();
        insert testLead;

        Test.startTest();
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);

        LeadStatus convertedStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        lc.setConvertedStatus(convertedStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();
        System.assert(lcr.isSuccess()); //Assert conversion succeeded

        //Verify Account Name follows the setting pattern {!{!FirstName}} {!LastName} Administrative Account
        String acctName = testLead.FirstName + ' ' + testLead.LastName + ' Administrative Account';
        List<Account> accts = [SELECT Id, Name FROM Account WHERE Name = :acctName];
        System.assertEquals(1, accts.size(), 'There should be one Account with the naming pattern.');
    }
}
