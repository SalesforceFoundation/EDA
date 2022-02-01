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
 * @date 2022
 * @group Accounts
 * @description Unmanaged functional tests for Account renaming
 */

@isTest
public with sharing class ACCT_NameProcessing_TEST {
    /*********************************************************************************************************
     * @description Insert a new contact and the default account record type is Household
     * Make sure the Account's name is set based on account naming setting for a user in Spanish.
     * Test Scenario: T-3904056
     */
    @isTest
    private static void newContactNewHHAccSpanish() {
        System.runAs(ACCT_IndividualAccounts_TEST.returnUserInSpanish()) {
            Hierarchy_Settings__c edaSettings = new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe.getHhAccRecTypeID(),
                Household_Account_Naming_Format__c = Label.acctNamingOther,
                Automatic_Household_Naming__c = true,
                Household_Other_Name_Setting__c = Label.lastNameHH
            );

            UTIL_CustomSettingsFacade.getSettingsForTests(edaSettings);

            Contact con = UTIL_UnitTestData_API.getContact();
            Test.startTest();
            insert con;
            Test.stopTest();

            Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
            System.assertEquals('Household Account', assertAccount.RecordType.Name);
            System.assertEquals('Domicilio de ' + con.LastName, assertAccount.Name);
        }
    }

    /*********************************************************************************************************
     * @description Insert a new contact and the default account record type is Household
     * Make sure the Account's name is set based on account naming setting for a user in Spanish.
     * Test Scenario: T-3904055
     */
    @isTest
    private static void newContactNewAdminAccSpanish() {
        System.runAs(ACCT_AdministrativeNameRefresh_TEST.returnUserInSpanish()) {
            Hierarchy_Settings__c edaSettings = new Hierarchy_Settings__c(
                Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Administrative_Account_Record_Type__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                Admin_Account_Naming_Format__c = Label.acctNamingOther,
                Admin_Other_Name_Setting__c = Label.lastNameAdminAcc
            );

            UTIL_CustomSettingsFacade.getSettingsForTests(edaSettings);

            Contact con = UTIL_UnitTestData_API.getContact();
            Test.startTest();
            insert con;
            Test.stopTest();

            Account assertAccount = [SELECT Id, RecordType.Name, Name FROM Account LIMIT 1];
            System.assertEquals('Administrative', assertAccount.RecordType.Name);
            System.assertEquals('Cuenta administrativa de ' + con.LastName, assertAccount.Name);
        }
    }
}
