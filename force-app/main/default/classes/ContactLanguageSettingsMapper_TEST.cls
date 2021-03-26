/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
 * @group
 * @group-content ../../ApexDocContent/Relationships
 * @description Test class for ContactLanguageSettingsMapper.
 */
@isTest
private with sharing class ContactLanguageSettingsMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ContactLanguageSettingsMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ContactLanguageSettingsMapper contactLanguageSettingsMapperInstance = ContactLanguageSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ContactLanguageSettingsMapper.instance,
            contactLanguageSettingsMapperInstance,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true,
            contactLanguageSettingsMapperInstance != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ContactLanguageSettingsMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ContactLanguageSettingsMapper contactLanguageSettingsMapperInstance1 = ContactLanguageSettingsMapper.getInstance();

        ContactLanguageSettingsMapper contactLanguageSettingsMapperInstance2 = ContactLanguageSettingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ContactLanguageSettingsMapper.instance,
            contactLanguageSettingsMapperInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            contactLanguageSettingsMapperInstance1,
            contactLanguageSettingsMapperInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            contactLanguageSettingsMapperInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getContactLanguageSettingsModel method returns a ContactLanguageSettingsModel
     * with the default contact language fluency set to match the value specified in Hierarchy Settings.
     ***************************************************************************************************************************/
    @isTest
    private static void getContactLanguageSettingsModelValid() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Default_Contact_Language_Fluency__c = 'Test Fluency')
        );

        ContactLanguageSettingsMapper contactLanguageSettingsMapperInstance = ContactLanguageSettingsMapper.getInstance();

        Test.startTest();
        ContactLanguageSettingsModel contactLanguageSettingsModel = contactLanguageSettingsMapperInstance.getContactLanguageSettingsModel();
        Test.stopTest();

        System.assertEquals(
            'Test Fluency',
            contactLanguageSettingsModel.defaultContactLanguageFluency,
            'Default fluency should match value in hierarchy settings.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getContactLanguageSettingsModel method returns a ContactLanguageSettingsModel
     * with the default contact language fluency left blank when there is no value specified in Hierarchy Settings.
     ***************************************************************************************************************************/
    @isTest
    private static void getContactLanguageSettingsModelNull() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Default_Contact_Language_Fluency__c = null)
        );

        ContactLanguageSettingsMapper contactLanguageSettingsMapperInstance = ContactLanguageSettingsMapper.getInstance();

        Test.startTest();
        ContactLanguageSettingsModel contactLanguageSettingsModel = contactLanguageSettingsMapperInstance.getContactLanguageSettingsModel();
        Test.stopTest();

        System.assertEquals(
            '""',
            contactLanguageSettingsModel.defaultContactLanguageFluency,
            'Default fluency should be blank when hierarchy settings field is blank.'
        );
    }
}
