/*
    Copyright (c) 2011, Salesforce.org
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
 * @date 2011 (1.x)
 * @group Accounts
 * @group-content ../../ApexDocContent/Accounts.htm
 * @description Tests for ACCT_RenameLeadConvertedAccounts_TDTM.
 */
@isTest
private class ACCT_RenameLeadConvertedAccounts_TEST {
    private static Integer leadCount = 5; // used to determine number of test contact records to create
    /*********************************************************************************************************
     * @description Insert and convert a new Lead with no Lead Conversion record types selected
     * Make sure the Account's name is the Lead Company Name
     */
    @isTest
    private static void convertLeadNoRecordTypes() {
        Lead testLead = new Lead(FirstName = 'First', LastName = 'Last', company = 'Company');
        insert testLead;

        Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Test.stopTest();

        System.assert(lcr.isSuccess());

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];

        System.assertEquals('Company', assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description Insert and convert a new lead with the Administrative Record Type selected
     * Make sure the Account's name is set based on account administrative naming setting.
     */
    @isTest
    private static void convertLeadAdminRecordType() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Automatic_Household_Naming__c = true,
                Lead_Converted_Account_RTypes__c = UTIL_Describe_API.getAdminAccRecTypeID()
            )
        );

        Lead testLead = new Lead(FirstName = 'First', LastName = 'Last', company = 'Company');
        insert testLead;

        Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Test.stopTest();

        System.assert(lcr.isSuccess());

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];

        System.assertEquals(testLead.LastName + ' Administrative Account', assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description Insert and convert a new lead with the Household Record Type selected
     * Make sure the Account's name is set based on account default naming setting.
     */
    @isTest
    private static void convertLeadHHRecordType() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!LastName} Household Account',
                Automatic_Household_Naming__c = true,
                Lead_Converted_Account_RTypes__c = UTIL_Describe_API.getHhAccRecTypeID()
            )
        );

        Lead testLead = new Lead(FirstName = 'First', LastName = 'Last', company = 'Company');
        insert testLead;

        Account testAccount = new Account(
            Name = 'Test Account Name',
            RecordTypeId = UTIL_Describe_API.getHhAccRecTypeID()
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

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];

        System.assertEquals(testLead.LastName + ' Household Account', assertAccount.Name);
    }

    @isTest
    private static void convertLeadDefaultRecordType() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Household_Account_Naming_Format__c = '{!LastName} Household Account',
                Automatic_Household_Naming__c = true,
                Lead_Converted_Account_RTypes__c = UTIL_Describe_API.getAcademicAccRecTypeID()
            )
        );

        Lead testLead = new Lead(FirstName = 'First', LastName = 'Last', company = 'Company');
        insert testLead;

        Account testAccount = new Account(
            Name = 'Test Account Name',
            RecordTypeId = UTIL_Describe_API.getAcademicAccRecTypeID()
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

        Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];

        System.assertEquals(testLead.LastName + ' Account', assertAccount.Name);
    }

    /*********************************************************************************************************
     * @description Insert and convert a specified number of leads to test for bulk, the number
     * to insert can be overriden for unpackaged
     */
    @isTest
    private static void bulkConvertLeadAdminRecordType() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Automatic_Household_Naming__c = true,
                Lead_Converted_Account_RTypes__c = UTIL_Describe_API.getAdminAccRecTypeID()
            )
        );

        List<Lead> leadsToInsert = new List<Lead>();
        for (integer i = 0; i < leadCount; i++) {
            leadsToInsert.add(new Lead(Company = 'Company' + i, lastname = 'Last' + i));
        }

        insert leadsToInsert;

        Test.startTest();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
        list<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        for (Lead theLead : leadsToInsert) {
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(theLead.Id);
            lc.convertedStatus = convertStatus.MasterLabel;
            leadConverts.add(lc);
        }

        Database.LeadConvertResult[] leadConvertResults = Database.convertLead(leadConverts);

        for (Database.LeadConvertResult lcr : leadConvertResults) {
            System.assert(lcr.isSuccess());
        }

        Test.stopTest();
    }
}
