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
 * @group-content
 * @description Test class for ContactInfoSettingsController.
 */
@isTest
private with sharing class ContactInfoSettingsController_TEST {
    private static Integer loopCounter = 5;

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
     * @description Test method to verify that the getPreferredContactInfoSettingsVModel method returns a PreferredContactInfoSettingsVModel
     * with selected value matching Hierarchy Settings field when set and a list of active picklist options.
     ***************************************************************************************************************************/
    @isTest
    private static void getPreferredContactInfoSettingsVModelValid() {
        ContactInformationSettingsVMapper.instance = new STUB_ContactInformationSettingsVMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Disable_Preferred_Email_Enforcement__c = false,
                Enable_New_Preferred_Phone_Sync__c = true,
                Disable_Preferred_Phone_Enforcement__c = true,
                Preferred_Phone_Selection__c = 'PhoneField label1'
            )
        );

        Test.startTest();
        PreferredContactInfoSettingsVModel preferredContactInfoSettingsVModel = ContactInfoSettingsController.getPreferredContactInfoSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            true,
            preferredContactInfoSettingsVModel.requirePreferredEmail,
            'Require Preferred Email should be inverse of value set in Hierarchy Settings.'
        );

        System.assertEquals(
            true,
            preferredContactInfoSettingsVModel.enhancedPhoneFunctionality,
            'Enhanced Phone Functionality should match value set in Hierarchy Settings.'
        );

        System.assertEquals(
            false,
            preferredContactInfoSettingsVModel.preferredPhoneEnforcement,
            'Preferred Phone Enforcement should be inverse of value set in Hierarchy Settings.'
        );

        System.assertEquals(
            'PhoneField label1',
            preferredContactInfoSettingsVModel.defaultPreferredPhone.value,
            'Selected Default Preferred Phone should match value set in Hierarchy Settings.'
        );

        System.assertEquals(
            loopCounter,
            preferredContactInfoSettingsVModel.defaultPreferredPhone.options.size(),
            'Should have ' +
            loopCounter +
            ' Default Preferred Phone options to choose from.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getContactLanguageSettingsVModel method throws an exception when an error is
     * encountered.
     ***************************************************************************************************************************/
    @isTest
    private static void getPreferredContactInfoSettingsVModelException() {
        ContactInformationSettingsVMapper.instance = new STUB_ExceptionContactInformationSettingsVMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Disable_Preferred_Email_Enforcement__c = false,
                Enable_New_Preferred_Phone_Sync__c = true,
                Disable_Preferred_Phone_Enforcement__c = true,
                Preferred_Phone_Selection__c = 'PhoneField label1'
            )
        );

        try {
            Test.startTest();
            PreferredContactInfoSettingsVModel preferredContactInfoSettingsVModel = ContactInfoSettingsController.getPreferredContactInfoSettingsVModel();
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
     * ContactLanguageSettingsVModel or PreferredContactInfoSettingsVModel
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

        public override PreferredContactInfoSettingsVModel getPreferredContactInformationSettingsVModel() {
            List<ComboboxValueVModel> preferredPhoneComboboxValueVModelsList = new List<ComboboxValueVModel>();

            for (Integer i = 0; i < loopCounter; i++) {
                preferredPhoneComboboxValueVModelsList.add(
                    new ComboboxValueVModel('PhoneField label' + i, 'PhoneField label' + i)
                );
            }

            ComboboxVModel defaultPreferredPhoneComboboxVModel = new ComboboxVModel(
                'PhoneField label1',
                preferredPhoneComboboxValueVModelsList
            );

            return new PreferredContactInfoSettingsVModel(true, true, false, defaultPreferredPhoneComboboxVModel);
        }
    }

    /*************************************************************************************************************
     * @description Stub class to simulate an error response from ContactInformationSettingsVMapper methods
     */
    private class STUB_ExceptionContactInformationSettingsVMapper extends ContactInformationSettingsVMapper {
        public override ContactLanguageSettingsVModel getContactLanguageSettingsVModel() {
            throw new TestException('Exception encountered!');
        }

        public override PreferredContactInfoSettingsVModel getPreferredContactInformationSettingsVModel() {
            throw new TestException('Exception encountered!');
        }
    }

    /**************************************************************************************
     * @description Custom exception class for testing.
     **************************************************************************************/
    public class TestException extends Exception {
    }
}
