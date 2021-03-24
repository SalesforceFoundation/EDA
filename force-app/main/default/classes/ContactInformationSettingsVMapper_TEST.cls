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
 * @description Test class for ContactInformationSettingsVMapper.
 */
@isTest
private with sharing class ContactInformationSettingsVMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * ContactInformationSettingsVMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        ContactInformationSettingsVMapper contactInformationSettingsVMapperInstance = ContactInformationSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ContactInformationSettingsVMapper.instance,
            contactInformationSettingsVMapperInstance,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true,
            contactInformationSettingsVMapperInstance != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * ContactInformationSettingsVMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        ContactInformationSettingsVMapper contactInformationSettingsVMapperInstance1 = ContactInformationSettingsVMapper.getInstance();

        ContactInformationSettingsVMapper contactInformationSettingsVMapperInstance2 = ContactInformationSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            ContactInformationSettingsVMapper.instance,
            contactInformationSettingsVMapperInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            contactInformationSettingsVMapperInstance1,
            contactInformationSettingsVMapperInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            contactInformationSettingsVMapperInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locatePicklistEntryService method returns an instance of
     * PicklistEntryService
     ***************************************************************************************************************************/
    @isTest
    private static void locatePicklistEntryServiceValid() {
        ContactInformationSettingsVMapper contactInformationSettingsVMapperInstance = ContactInformationSettingsVMapper.getInstance();

        Test.startTest();
        PicklistEntryService picklistEntryServiceInstance = contactInformationSettingsVMapperInstance.locatePicklistEntryService();
        Test.stopTest();

        System.assertEquals(
            PicklistEntryService.getInstance(),
            picklistEntryServiceInstance,
            'Should return instance of PicklistEntryService class.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locateContactLanguageSettingsService method returns an instance of
     * ContactLanguageSettingsService
     ***************************************************************************************************************************/
    @isTest
    private static void locateContactLanguageSettingsServiceValid() {
        ContactInformationSettingsVMapper contactInformationSettingsVMapperInstance = ContactInformationSettingsVMapper.getInstance();

        Test.startTest();
        ContactLanguageSettingsService contactLanguageSettingsServiceInstance = contactInformationSettingsVMapperInstance.locateContactLanguageSettingsService();
        Test.stopTest();

        System.assertEquals(
            ContactLanguageSettingsService.getInstance(),
            contactLanguageSettingsServiceInstance,
            'Should return instance of ContactLanguageSettingsService class.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getContactLanguageSettingsVModel method returns a valid ContactLanguageSettingsVModel
     * representing the list of active picklist values available for Contact_Language__c.Fluency__c and the value specified in
     * Hierarchy Settings.
     ***************************************************************************************************************************/
    @isTest
    private static void getContactLanguageSettingsVModelValid() {
        PicklistEntryService.instance = new STUB_PicklistEntryService();
        ContactLanguageSettingsMapper.instance = new STUB_ContactLanguageSettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Default_Contact_Language_Fluency__c = 'Fluency1')
        );
        ContactInformationSettingsVMapper contactInformationSettingsVMapperInstance = ContactInformationSettingsVMapper.getInstance();

        Test.startTest();
        ContactLanguageSettingsVModel contactLanguageSettingsVModel = contactInformationSettingsVMapperInstance.getContactLanguageSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            'Fluency1',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.value,
            'Selected value should match value set in Hierarchy Settings.'
        );
        System.assertEquals(
            2,
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options.size(),
            'Options list should include all active picklist values for contact language fluency.'
        );
        System.assertEquals(
            'Fluency1',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[0].value,
            'Options list should include all active picklist values for contact language fluency.'
        );
        System.assertEquals(
            'Fluency2',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options[1].value,
            'Options list should include all active picklist values for contact language fluency.'
        );
    }

    /**************************************************************************************************************************
     ****************************************************** STUB CLASS *********************************************************
     **************************************************************************************************************************/

    /*************************************************************************************************************
     * @description Stub class to simulate the response from PicklistEntryService to return a map of active
     * PicklistEntryModels by Name
     */
    private class STUB_PicklistEntryService extends PicklistEntryService {
        public override Map<String, PicklistEntryModel> getActivePicklistEntryModelsByName(
            Map<String, PicklistEntryModel> picklistEntryModelsByName
        ) {
            return new Map<String, PicklistEntryModel>{
                'Fluency1' => new PicklistEntryModel('Fluency1', 'Fluency_1', true),
                'Fluency2' => new PicklistEntryModel('Fluency2', 'Fluency_2', true)
            };
        }
    }

    /*************************************************************************************************************
     * @description Stub class to simulate the response from ContactLanguageSettingsMapper to return a valid
     * ContactLanguageSettingsModel
     */
    private class STUB_ContactLanguageSettingsMapper extends ContactLanguageSettingsMapper {
        public override ContactLanguageSettingsModel getContactLanguageSettingsModel() {
            return new ContactLanguageSettingsModel('Fluency1');
        }
    }
}
