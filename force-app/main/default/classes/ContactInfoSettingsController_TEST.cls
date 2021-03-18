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
 * @description Test class for ContactInfoSettingsController.
 */
@isTest
private with sharing class ContactInfoSettingsController_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the locateContactInformationSettingsVMapper method returns an instance of
     * ContactInformationSettingsVMapper
     ***************************************************************************************************************************/
    @isTest
    private static void locateContactInformationSettingsVMapperValid() {
        Test.startTest();
        ContactInformationSettingsVMapper ContactInformationSettingsVMapperInstance = ContactInfoSettingsController.locateContactInformationSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            ContactInformationSettingsVMapper.getInstance(),
            ContactInformationSettingsVMapperInstance,
            'Should return instance of ContactInformationSettingsVMapper class.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getContactLanguageSettingsVModel method returns a ContactLanguageSettingsVModel
     * with selected value matching Hierarchy Settings field when set and a list of active picklist options.
     ***************************************************************************************************************************/
    @isTest
    private static void getContactLanguageSettingsVModelValid() {
        ContactInformationSettingsVMapper.instance = new STUB_ContactInformationSettingsVMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Default_Contact_Language_Fluency__c = 'Fluency2')
        );

        Test.startTest();
        ContactLanguageSettingsVModel contactLanguageSettingsVModel = ContactInfoSettingsController.getContactLanguageSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            'Fluency2',
            contactLanguageSettingsVModel.defaultContactLanguageFluency.value,
            'Selected language fluency should match value set in Hierarchy Settings.'
        );

        System.assertEquals(
            3,
            contactLanguageSettingsVModel.defaultContactLanguageFluency.options.size(),
            'Should have 3 picklist options for language fluency.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getContactLanguageSettingsVModel method throws an exception when an error is
     * encountered.
     ***************************************************************************************************************************/
    @isTest
    private static void getContactLanguageSettingsVModelException() {
        ContactInformationSettingsVMapper.instance = new STUB_ExceptionContactInformationSettingsVMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Default_Contact_Language_Fluency__c = '')
        );

        try {
            Test.startTest();
            ContactLanguageSettingsVModel contactLanguageSettingsVModel = ContactInfoSettingsController.getContactLanguageSettingsVModel();
            Test.stopTest();
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw AuraHandledException.');
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUB CLASS *********************************************************
     **************************************************************************************************************************/

    /*************************************************************************************************************
     * @description Stub class to simulate the response from ContactInformationSettingsVMapper to return a valid
     * ContactLanguageSettingsVModel
     */
    private class STUB_ContactInformationSettingsVMapper extends ContactInformationSettingsVMapper {
        public override ContactLanguageSettingsVModel getContactLanguageSettingsVModel() {
            List<ComboboxValueVModel> defaultLanguageFluencyOptionsList = new List<ComboboxValueVModel>{
                new ComboboxValueVModel('Fluency 1', 'Fluency1'),
                new ComboboxValueVModel('Fluency 2', 'Fluency2'),
                new ComboboxValueVModel('Fluency 3', 'Fluency3')
            };

            ComboboxVModel defaultLanguageFluencyComboboxVModel = new ComboboxVModel(
                'Fluency2',
                defaultLanguageFluencyOptionsList
            );

            return new ContactLanguageSettingsVModel(defaultLanguageFluencyComboboxVModel);
        }
    }

    /*************************************************************************************************************
     * @description Stub class to simulate an error response from ContactInformationSettingsVMapper
     */
    private class STUB_ExceptionContactInformationSettingsVMapper extends ContactInformationSettingsVMapper {
        public override ContactLanguageSettingsVModel getContactLanguageSettingsVModel() {
            throw new TestException('Exception encountered!');
        }
    }

    /**************************************************************************************
     * @description Custom exception class for testing.
     **************************************************************************************/
    public class TestException extends Exception {
    }
}
