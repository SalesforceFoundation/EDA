/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group 
* @group-content ../../ApexDocContent/
* @description Test class for MAPR_CON_PreferredEmailFields
*/
@isTest
private class MAPR_CON_PreferredEmailFields_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * MAPR_CON_PreferredEmailFields class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            MAPR_CON_PreferredEmailFields maprConPreferredEmailFieldsInstance = MAPR_CON_PreferredEmailFields.getInstance();
        Test.stopTest();

        System.assertEquals(MAPR_CON_PreferredEmailFields.instance, maprConPreferredEmailFieldsInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, maprConPreferredEmailFieldsInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * MAPR_CON_PreferredEmailFields class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            MAPR_CON_PreferredEmailFields maprConPreferredEmailFieldsInstance1 = MAPR_CON_PreferredEmailFields.getInstance();
            MAPR_CON_PreferredEmailFields maprConPreferredEmailFieldsInstance2 = MAPR_CON_PreferredEmailFields.getInstance();
        Test.stopTest();

        System.assertEquals(MAPR_CON_PreferredEmailFields.instance, maprConPreferredEmailFieldsInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(maprConPreferredEmailFieldsInstance1, maprConPreferredEmailFieldsInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, maprConPreferredEmailFieldsInstance1 != null, 'Instance of service class should not be null.');
    }

    /*********************************************************************************************************************************************
    * @description Test method to verify that the getPreferredEmailSettingsModel returns MODL_PreferredEmailSettings
    **********************************************************************************************************************************************/
    @isTest
    private static void getPreferredEmailSettingsModelNew() {

        Test.startTest();
            MODL_PreferredEmailSettings prefEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        Test.stopTest();

        System.assertEquals(false, prefEmailSettingsModel.preferredEmailFieldModels.isEmpty());
        System.assertEquals(true, String.isNotBlank(prefEmailSettingsModel.alternateEmailPreferredLabel));
        System.assertEquals(true, String.isNotBlank(prefEmailSettingsModel.emailLabel));
        System.assertEquals(false, prefEmailSettingsModel.preferredEmailPicklistLabelByApiName.isEmpty());
        
    }
    
    /*********************************************************************************************************************************************
    * @description Test method to verify that the getPreferredEmailSettingsModel returns cached MODL_PreferredEmailSettings
    **********************************************************************************************************************************************/
    @isTest
    private static void getPreferredEmailSettingsModelExisting() {

        MODL_PreferredEmailSettings prefEmailSettingsModel1 = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        Test.startTest();
            MODL_PreferredEmailSettings prefEmailSettingsModel2 = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        Test.stopTest();

        System.assertEquals(prefEmailSettingsModel1, prefEmailSettingsModel2);
        System.assertEquals(false, prefEmailSettingsModel2.preferredEmailFieldModels.isEmpty());
        System.assertEquals(true, String.isNotBlank(prefEmailSettingsModel2.alternateEmailPreferredLabel));
        System.assertEquals(true, String.isNotBlank(prefEmailSettingsModel2.emailLabel));
        System.assertEquals(false, prefEmailSettingsModel2.preferredEmailPicklistLabelByApiName.isEmpty());

    }
    
    /*********************************************************************************************************************************************
    * @description Test method to verify that the createEmailFieldSettingsModel returns MODL_PreferredEmailSettings
    **********************************************************************************************************************************************/
    @isTest
    private static void createEmailFieldSettingsModel() {

        Test.startTest();
            MODL_PreferredEmailSettings prefEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().createEmailFieldSettingsModel();
        Test.stopTest();

        System.assertEquals(false, prefEmailSettingsModel.preferredEmailFieldModels.isEmpty());
        System.assertEquals(true, String.isNotBlank(prefEmailSettingsModel.alternateEmailPreferredLabel));
        System.assertEquals(true, String.isNotBlank(prefEmailSettingsModel.emailLabel));
        System.assertEquals(false, prefEmailSettingsModel.preferredEmailPicklistLabelByApiName.isEmpty());

    }

    /*************************************************************************************************************************************************************
    * @description  Test method to verify that the getPreferredLabelFromLabel returns a Label when values is contained in preferredEmailPicklistValuesByLabel map
    *************************************************************************************************************************************************************/
    @isTest
    private static void getPreferredLabelFromLabel() {
        Map<String,String> legacyPreferredEmailPicklistValuesByLabel = new Map<String,String> {
                  'University Email' => 'University',
                 'Work Email' => 'Work',
                 'Alternate Email' => 'Alternate'
                };
                    
        Test.startTest();
            String preferredLabel =  MAPR_CON_PreferredEmailFields.getInstance().getPreferredLabelFromLabel('University Email', 
                                                                                                     UTIL_Describe.getpicklistEntriesLabelToAPIMap('Contact', UTIL_Namespace.StrTokenNSPrefix('') + 'Preferred_Email__c'),
                                                                                                    legacyPreferredEmailPicklistValuesByLabel);
        Test.stopTest();
        
        System.assertEquals('University Email', preferredLabel);
    }
    
    /******************************************************************************************************************************************************************
    * @description  Test method to verify that the getPreferredLabelFromLabel returns a Label when values is contained in legacyPreferredEmailPicklistValuesByLabel map
    ******************************************************************************************************************************************************************/
    @isTest
    private static void getPreferredLabelFromLabelLegacy() {
        Map<String, String> preferredEmailPicklistLabelByApiNameCustom = new Map<String, String>{
                'University' => 'University',
                'Work' => 'Work',
                'Alternate' => 'Alternate'
            };
                
         Map<String,String> legacyPreferredEmailPicklistValuesByLabel = new Map<String,String> {
            'University Email' => 'University',
                'Work Email' => 'Work',
                'Alternate Email' => 'Alternate'
             };
                    
        Test.startTest();
            String preferredLabel =  MAPR_CON_PreferredEmailFields.getInstance().getPreferredLabelFromLabel('University Email', 
                                                                                                     preferredEmailPicklistLabelByApiNameCustom,
                                                                                                     legacyPreferredEmailPicklistValuesByLabel);
        Test.stopTest();
        
        System.assertEquals('University', preferredLabel);
    }

    /******************************************************************************************************************************************************************
    * @description  Test method to verify that the getPreferredLabelFromLabel returns a Label when values is are
    * not in either preferredEmailPicklistValuesByLabel or legacyPreferredEmailPicklistValuesByLabel map
    ******************************************************************************************************************************************************************/
    @isTest
    private static void getPreferredLabelFromLabelCustom() {
        Map<String,String> legacyPreferredEmailPicklistValuesByLabel = new Map<String,String> {
            'University Email' => 'University',
                'Work Email' => 'Work',
                'Alternate Email' => 'Alternate'
                };
                    
        Test.startTest();
            String preferredLabel =  MAPR_CON_PreferredEmailFields.getInstance().getPreferredLabelFromLabel('Test Email Field', 
                                                                                                     UTIL_Describe.getpicklistEntriesLabelToAPIMap('Contact', UTIL_Namespace.StrTokenNSPrefix('') + 'Preferred_Email__c'),
                                                                                                    legacyPreferredEmailPicklistValuesByLabel);
        Test.stopTest();
        
        System.assertEquals('Test Email Field', preferredLabel);
    }

    /******************************************************************************************************************************************************************
    * @description Test method to verify that the getPreferredEmailValidationEnabled returns the negated value strored in Custom Settings
    ******************************************************************************************************************************************************************/
    @isTest
    private static void getPreferredEmailValidationEnabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                      (Disable_Preferred_Email_Enforcement__c = true));
        
        Test.startTest();
            Boolean ispreferredEmailValidationEnabled = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailValidationEnabled();
        Test.stopTest();
        
        System.assertEquals(false, ispreferredEmailValidationEnabled);

    }

    /*********************************************************************************************************************************************
    * @description  Test method to verify that the getContactEmailFieldByApiName returns a map of contact Email Field Describess By their API Names
    **********************************************************************************************************************************************/
    @isTest
    private static void getContactEmailFieldByApiName() {

        Test.startTest();
            Map<String, Schema.DescribeFieldResult> contactEmailFieldsByAPIName = MAPR_CON_PreferredEmailFields.getInstance().getContactEmailFieldByApiName();
        Test.stopTest();

        System.assertEquals(false, contactEmailFieldsByAPIName.isEmpty());
        System.assert(contactEmailFieldsByAPIName.get('Email') != null);
    }

    /*********************************************************************************************************************************************
    * @description Test method to verify that the getPreferredEmailPicklistValuesByLabel returns a map of contact Email Fields By their API Names
    **********************************************************************************************************************************************/
    @isTest
    private static void getPreferredEmailPicklistValuesByLabel() {

        Test.startTest();
            Map<String, String> contactEmailFieldsByAPIName = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailPicklistValuesByLabel();
        Test.stopTest();

        System.assertEquals(false, contactEmailFieldsByAPIName.isEmpty());
    }

    /**********************************************************************************************************************************************************
    * @description Test method to verify that the getLegacyPreferredEmailPicklistValuesByLabel returns a map of contact legacy Email Fields By their API Names
    **********************************************************************************************************************************************************/
    @isTest
    private static void getLegacyPreferredEmailPicklistValuesByLabel() {

        Test.startTest();
            Map<String, String> contactEmailFieldsByAPIName = MAPR_CON_PreferredEmailFields.getInstance().getLegacyPreferredEmailPicklistValuesByLabel();
        Test.stopTest();

        System.assertEquals(false, contactEmailFieldsByAPIName.isEmpty());
        System.assertEquals('University', contactEmailFieldsByAPIName.get('University Email'));
        System.assertEquals('Work', contactEmailFieldsByAPIName.get('Work Email'));
        System.assertEquals('Alternate', contactEmailFieldsByAPIName.get('Alternate Email'));
    }

    /**********************************************************************************************************************************************************
    * @description Test method to verify that the getPreferredEmailPicklistLabelByApiName returns a map of contact legacy Email Fields By their API Names
    **********************************************************************************************************************************************************/
    @isTest
    private static void getPreferredEmailPicklistLabelByApiName() {

        Test.startTest();
            Map<String, String> preferredEmailPicklistLabelByApiName = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailPicklistLabelByApiName();
        Test.stopTest();

        System.assertEquals(false, preferredEmailPicklistLabelByApiName.isEmpty());
    }

    /**********************************************************************************************************************************************************
    * @description Test method to verify that the isEDAField() returns true for a EDA field API name
    **********************************************************************************************************************************************************/
    @isTest
    private static void isEDAFieldPositiveTest() {

        Test.startTest();
            Boolean isEDAField = MAPR_CON_PreferredEmailFields.getInstance().isEDAField(UTIL_Namespace.StrTokenNSPrefix('') + 'Preferred_Email__c');
        Test.stopTest();

        System.assertEquals(true, isEDAField);
    }

    /**********************************************************************************************************************************************************
    * @description Test method to verify that the isEDAField() returns false for a standard field API name
    **********************************************************************************************************************************************************/
    @isTest
    private static void isEDAFieldNegativeTest() {

        Test.startTest();
            Boolean isEDAField = MAPR_CON_PreferredEmailFields.getInstance().isEDAField('Email');
        Test.stopTest();

        System.assertEquals(false, isEDAField);
    }

    /**********************************************************************************************************************************************************
    * @description Test method to verify that the getEDAEmailFieldsApiNamesByLabel() returns a map of edaEmailFieldAPINamesByLabels
    **********************************************************************************************************************************************************/
    @isTest
    private static void getEDAEmailFieldsApiNamesByLabelPoitiveTest() {

        Test.startTest();
            Map<String, String> edaEmailFieldAPINamesByLabels = MAPR_CON_PreferredEmailFields.getInstance().getEDAEmailFieldsApiNamesByLabel(UTIL_Describe.getFieldsOfType('Contact', 'EMAIL'));
        Test.stopTest();

        System.assertEquals(false, edaEmailFieldAPINamesByLabels.isEmpty());
    }

    /**********************************************************************************************************************************************************
    * @description Negative test for getEDAEmailFieldsApiNamesByLabel() to ensure the reurned Map is empty when no EDA Email fields are passed
    **********************************************************************************************************************************************************/
    @isTest
    private static void getEDAEmailFieldsApiNamesByLabelNegativeTest() {

        Map<String, Schema.DescribeFieldResult> contactEmailFieldDescribeByEmailAPI = new Map<String, Schema.DescribeFieldResult>();
        contactEmailFieldDescribeByEmailAPI.put('Email', UTIL_Describe.getFieldDescribe('Contact', 'Email'));

        Test.startTest();
            Map<String, String> edaEmailFieldAPINamesByLabels = MAPR_CON_PreferredEmailFields.getInstance().getEDAEmailFieldsApiNamesByLabel(contactEmailFieldDescribeByEmailAPI);
        Test.stopTest();

        System.assertEquals(true, edaEmailFieldAPINamesByLabels.isEmpty());
    }
}