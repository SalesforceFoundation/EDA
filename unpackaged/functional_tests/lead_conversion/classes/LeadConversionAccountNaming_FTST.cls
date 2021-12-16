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


    private static hed__Hierarchy_Settings__c createSettingsNoRecordTypes(){
        hed__Hierarchy_Settings__c orgSettings = hed.UTIL_CustomSettings_API.getOrgSettings();
        orgSettings.hed__Lead_Converted_Account_RTypes__c = null; //ensure no Account record types for LC
        orgSettings.hed__Admin_Account_Naming_Format__c = '{!{!FirstName}} {!LastName} Administrative Account';
        orgSettings.hed__Household_Account_Naming_Format__c = '{!FirstName} {!LastName} Household';
        upsert orgSettings;
        return createSettings(orgSettings);
    } 

    private static hed__Hierarchy_Settings__c createSettings(hed__Hierarchy_Settings__c orgSettings) {
        hed.UTIL_CustomSettings_API.getSettingsForTests(orgSettings);
        return orgSettings;
    }


    /**
     * @description T-5026176: Verify that the Lead Conversion Account Naming has no changes with the setting disabled
     * (ie, Account Name should be the same as the Lead Company)
    */
    @isTest
    private static void insertNewContactWithInactiveChecked() {
        hed__Hierarchy_Settings__c orgSettings = createSettingsNoRecordTypes();
        Lead testLead = hed.UTIL_UnitTestData_API.getLead();
        testLead.Company = testLead.company + Datetime.now().getTime();
        insert testLead;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess()); //Assert conversion succeeded

        //Verify Account Name is the same as the Lead Company
        List<Account> accts = [SELECT Id, Name FROM Account WHERE Name = :testLead.Company];
        System.assertEquals(1, accts.size(), 'There should be one Account with the same name as the Lead.');
    }

    

}
