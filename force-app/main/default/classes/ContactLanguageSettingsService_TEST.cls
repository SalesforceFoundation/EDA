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
 * @description Test class for ContactLanguageSettingsService.
 */
@isTest
private with sharing class ContactLanguageSettingsService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ContactLanguageSettingsService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ContactLanguageSettingsService contactLanguageSettingsServiceInstance = ContactLanguageSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            ContactLanguageSettingsService.instance,
            contactLanguageSettingsServiceInstance,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true,
            contactLanguageSettingsServiceInstance != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ContactLanguageSettingsService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ContactLanguageSettingsService contactLanguageSettingsServiceInstance1 = ContactLanguageSettingsService.getInstance();

        ContactLanguageSettingsService contactLanguageSettingsServiceInstance2 = ContactLanguageSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            ContactLanguageSettingsService.instance,
            contactLanguageSettingsServiceInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            contactLanguageSettingsServiceInstance1,
            contactLanguageSettingsServiceInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            contactLanguageSettingsServiceInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateContactLanguageSettingsMapper method returns an instance of
     * ContactLanguageSettingsMapper
     ***************************************************************************************************************************/
    @isTest
    private static void locateContactLanguageSettingsMapperValid() {
        ContactLanguageSettingsService contactLanguageSettingsServiceInstance = ContactLanguageSettingsService.getInstance();

        Test.startTest();
        ContactLanguageSettingsMapper ContactLanguageSettingsMapperInstance = contactLanguageSettingsServiceInstance.locateContactLanguageSettingsMapper();
        Test.stopTest();

        System.assertEquals(
            ContactLanguageSettingsMapper.getInstance(),
            ContactLanguageSettingsMapperInstance,
            'Should return instance of ContactLanguageSettingsMapper class.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getContactLanguageSettingsModel method returns a ContactLanguageSettingsModel
     * with default fluency set to match the value specified in Hierarchy Settings when field is populated.
     ***************************************************************************************************************************/
    @isTest
    private static void getContactLanguageSettingsModelValid() {
        ContactLanguageSettingsMapper.instance = new STUB_ContactLanguageSettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Default_Contact_Language_Fluency__c = 'Test Fluency')
        );

        ContactLanguageSettingsService contactLanguageSettingsServiceInstance = ContactLanguageSettingsService.getInstance();

        Test.startTest();
        ContactLanguageSettingsModel contactLanguageSettingsModel = contactLanguageSettingsServiceInstance.getContactLanguageSettingsModel();
        Test.stopTest();

        System.assertEquals(
            'Test Fluency',
            contactLanguageSettingsModel.defaultContactLanguageFluency,
            'Default fluency should match value set in Hierarchy Settings.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getContactLanguageSettingsModel method returns a ContactLanguageSettingsModel
     * with default fluency left blank when the associated Hierarchy Settings field is empty.
     ***************************************************************************************************************************/
    @isTest
    private static void getContactLanguageSettingsModelEmpty() {
        ContactLanguageSettingsMapper.instance = new STUB_ContactLanguageSettingsMapperEmpty();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Default_Contact_Language_Fluency__c = '')
        );

        ContactLanguageSettingsService contactLanguageSettingsServiceInstance = ContactLanguageSettingsService.getInstance();

        Test.startTest();
        ContactLanguageSettingsModel contactLanguageSettingsModel = contactLanguageSettingsServiceInstance.getContactLanguageSettingsModel();
        Test.stopTest();

        System.assertEquals(
            '""',
            contactLanguageSettingsModel.defaultContactLanguageFluency,
            'Default fluency should should be blank when Hierarchy Settings field is blank.'
        );
    }

    /**************************************************************************************************************************
     ****************************************************** STUB CLASS *********************************************************
     **************************************************************************************************************************/

    /*************************************************************************************************************
     * @description Stub class to simulate the response from ContactLanguageSettingsMapper to return a valid
     * ContactLanguageSettingsModel
     */
    private class STUB_ContactLanguageSettingsMapper extends ContactLanguageSettingsMapper {
        public override ContactLanguageSettingsModel getContactLanguageSettingsModel() {
            return new ContactLanguageSettingsModel('Test Fluency');
        }
    }

    /*************************************************************************************************************
     * @description Stub class to simulate the response from ContactLanguageSettingsMapper to return an empty
     * ContactLanguageSettingsModel
     */
    private class STUB_ContactLanguageSettingsMapperEmpty extends ContactLanguageSettingsMapper {
        public override ContactLanguageSettingsModel getContactLanguageSettingsModel() {
            return new ContactLanguageSettingsModel('');
        }
    }
}
