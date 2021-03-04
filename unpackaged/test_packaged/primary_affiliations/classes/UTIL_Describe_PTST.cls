/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group Utilities
* @description Unmanaged tests for UTIL_Describe used to verify inactive
* Record Types are included in record type mapping.
*/
@isTest
private class UTIL_Describe_PTST {
	/*********************************************************************************************************
    * @description Test Method to verify that UTIL_Describe.populateRecordTypeInfoForSObject() includes the
    * inactive Account Record type in its mapping when Record Type validation is enabled.
    *********************************************************************************************************/
    @isTest
    private static void populateRecordTypeInfoForSObjectInactiveRTValidationOn() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true));

        Test.startTest();
        Util_Describe.populateRecordTypeInfoForSObject('Account');
        Test.stopTest();

        Schema.RecordTypeInfo recTypeInfoByDevName = Util_Describe.getRecordTypeInfoByDeveloperName('Account', 'An_Inactive_Record_Type');
        Schema.RecordTypeInfo recTypeInfoByName = Util_Describe.getRecordTypeInfoByName('Account', 'An Inactive Record Type');
        System.assertEquals(true, recTypeInfoByDevName != null, '\'An Inactive Record Type\' should be included in mapping by developer name.');
        System.assertEquals(true, recTypeInfoByName != null, '\'An Inactive Record Type\' should be included in mapping by label name.');
    }

    /*********************************************************************************************************
    * @description Test Method to verify that UTIL_Describe.getRecordTypeInfoByDeveloperName() includes the
    * inactive Account Record type in its mapping when Record Type validation is enabled.
    *********************************************************************************************************/
    @isTest
    private static void getRecordTypeInfoByDeveloperNameInactiveRTValidationOn() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true));

        Test.startTest();
            Schema.RecordTypeInfo recTypeInfo = Util_Describe.getRecordTypeInfoByDeveloperName('Account', 'An_Inactive_Record_Type');
        Test.stopTest();

        System.assertEquals(true, recTypeInfo != null , '\'An Inactive Record Type\' should be included in mapping by developer name.');
    }

    /*********************************************************************************************************
    * @description Test Method to verify that UTIL_Describe.getRecordTypeInfoByName() includes the
    * inactive Account Record type in its mapping when Record Type validation is enabled.
    *********************************************************************************************************/
    @isTest
    private static void getRecordTypeInfoByNameInactiveRTValidationOn() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true));

        Test.startTest();
            Schema.RecordTypeInfo recTypeInfo = Util_Describe.getRecordTypeInfoByName('Account', 'An Inactive Record Type');
        Test.stopTest();
        System.assertEquals(true, recTypeInfo != null, '\'An Inactive Record Type\' should be included in mapping by label name.');
    }
}