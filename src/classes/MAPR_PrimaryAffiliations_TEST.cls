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
* @group-content ../../ApexDocContent/Contacts.htm
* @description Test class for MAPR_PrimaryAffiliations.cls
*/
@isTest
private class MAPR_PrimaryAffiliations_TEST {

    /**************************************************************************************************************************************
    * @description Inserts Affiliation mappings with RecordTypeDevName and PrimaryAffiliationFieldAPI
    ***************************************************************************************************************************************/
    static void insertAfflMappingsWithRecordTypeDevNameAndPrimaryFieldAPIs() {

        String prefix = UTIL_Namespace.StrTokenNSPrefix('');

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business_Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'HH_Account', Primary_Affl_Field__c =  prefix + 'Primary_Household__c'));
        insert mappings;
    }

    /**************************************************************************************************************************************
    * @description Inserts Affiliation mappings with RecordTypeDevName and PrimaryAffiliationFieldLabels
    ***************************************************************************************************************************************/
    static void insertAfflMappingsWithRecordTypeDevNameAndPrimaryFieldLables() {

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business_Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'HH_Account', Primary_Affl_Field__c = 'Primary Household'));
        insert mappings;
    } 

    /**************************************************************************************************************************************
    * @description Inserts Affiliation mappings with RecordTypeDevName and PrimaryAffiliationFieldAPIs
    ***************************************************************************************************************************************/
    static void insertAfflMappingsWithRecordTypeNameAndPrimaryFieldAPIs() {

        String prefix = UTIL_Namespace.StrTokenNSPrefix('');

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = prefix + 'Primary_Household__c'));
        insert mappings;
    }

    /**************************************************************************************************************************************
    * @description Inserts Affiliation mappings with RecordTypeName and PrimaryAffiliationFieldLabels
    ***************************************************************************************************************************************/
    static void insertAfflMappingsWithRecordTypeNameAndPrimaryFieldLables() {

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
        insert mappings;
    }

    /**************************************************************************************************************************************
    * @description Inserts Affiliation mappings with RecordTypeName and inaccurate PrimaryAffiliationFieldLabels
    ***************************************************************************************************************************************/
    static void insertAfflMappingsWithRecordTypeNameAndInaccuratePrimaryFieldLables() {

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Wrong field Label1'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Wrong field Label2'));
        insert mappings;
    }

    /**************************************************************************************************************************************
    * @description Inserts Affiliation mappings with inaccurate RecordTypeName and accurate PrimaryAffiliationFieldLabels
    ***************************************************************************************************************************************/
    static void insertAfflMappingsWithInaccurateRecordTypeNameAndAccuratePrimaryFieldLables() {

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Org test', Primary_Affl_Field__c = 'Primary Business Organization'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Org Account test', Primary_Affl_Field__c = 'Primary Household'));
        insert mappings;
    }

    /**************************************************************************************************************************************
    * @description Inserts Affiliation mappings with inaccurate RecordTypeName and inaccurate PrimaryAffiliationFieldLabels
    ***************************************************************************************************************************************/
    static void insertAfflMappingsWithInaccurateRecordTypeNameAndInAccuratePrimaryFieldLables() {

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Org test', Primary_Affl_Field__c = 'Primary Business Organization test'));
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Org Account test', Primary_Affl_Field__c = 'Primary Household test'));
        insert mappings;
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * MAPR_PrimaryAffiliations class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();
        Test.stopTest();
        System.assertEquals(MAPR_PrimaryAffiliations.instance, maprPrimaryAfflInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, maprPrimaryAfflInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * MAPR_PrimaryAffiliations class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        
        Test.startTest();
            MAPR_PrimaryAffiliations maprPrimaryAfflInstance1 = MAPR_PrimaryAffiliations.getInstance();
            MAPR_PrimaryAffiliations maprPrimaryAfflInstance2 = MAPR_PrimaryAffiliations.getInstance();
        Test.stopTest();

        System.assertEquals(MAPR_PrimaryAffiliations.instance, maprPrimaryAfflInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(maprPrimaryAfflInstance1, maprPrimaryAfflInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, maprPrimaryAfflInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the isPrimaryAffiliationValidationOn method returns 
    * the value from Custom Settings
    ***************************************************************************************************************************/
    @isTest
    private static void isPrimaryAffiliationValidationOnTrueTest() {

        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true));

        Test.startTest();
            Boolean isValidationOn = MAPR_PrimaryAffiliations.getInstance().isPrimaryAffiliationValidationOn();
        Test.stopTest();

        System.assertEquals(true, isValidationOn);

    }

    /**************************************************************************************************************************
    * @description Test method to verify that the isPrimaryAffiliationValidationOn method returns 
    * the value from Custom Settings
    ***************************************************************************************************************************/
    @isTest
    private static void isPrimaryAffiliationValidationOnFalseTest() {

        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false));
        Test.startTest();
            Boolean isValidationOn = MAPR_PrimaryAffiliations.getInstance().isPrimaryAffiliationValidationOn();
        Test.stopTest();

        System.assertEquals(false, isValidationOn);
    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelsFromSettings method with 
    * Record Type Dev Name And Primary Field APIs in Settings returns models
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelsFromSettingsTestDevNameAndPrimaryFieldAPIs() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeDevNameAndPrimaryFieldAPIs();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        Test.startTest();
            List<MODL_PrimaryAfflMapper> primaryAfflModels = maprPrimaryAfflInstance.getModelsFromSettings();
        Test.stopTest();

        System.assertEquals(2, primaryAfflModels.size());

    }
    
    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelsFromSettings method with 
    * Record Type Dev Name And Primary Field Labels in Settings returns models
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelsFromSettingsTestDevNameAndPrimaryFieldLabels() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeDevNameAndPrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        Test.startTest();
            List<MODL_PrimaryAfflMapper> primaryAfflModels = maprPrimaryAfflInstance.getModelsFromSettings();
        Test.stopTest();

        System.assertEquals(2, primaryAfflModels.size());

    }
    
    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelsFromSettings method with 
    * Record Type Name And Primary Field APIs in Settings returns models
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelsFromSettingsTestWithRecTypeNameAndPrimaryFieldAPIs() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeNameAndPrimaryFieldAPIs();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        Test.startTest();
            List<MODL_PrimaryAfflMapper> primaryAfflModels = maprPrimaryAfflInstance.getModelsFromSettings();
        Test.stopTest();

        System.assertEquals(2, primaryAfflModels.size());

    }
    
    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelsFromSettings method with 
    * Record Type Name And Primary Field Labels in Settings returns models
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelsFromSettingsTestWithRecTypeNameAndPrimaryFieldLabels() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeNameAndPrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        Test.startTest();
            List<MODL_PrimaryAfflMapper> primaryAfflModels = maprPrimaryAfflInstance.getModelsFromSettings();
        Test.stopTest();

        System.assertEquals(2, primaryAfflModels.size());

    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelsFrommappings method with 
    * Record Type Dev Name And Primary Field APIs in Settings returns models
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelsFromMappingsTestWithRecTypeDevNameAndPrimaryFieldAPIs() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeDevNameAndPrimaryFieldAPIs();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();
        Test.startTest();
            List<MODL_PrimaryAfflMapper> primaryAfflModels = maprPrimaryAfflInstance.getModelsFromMappings(primaryAfflMappings);
        Test.stopTest();
 
        System.assertEquals(2, primaryAfflModels.size());

    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelsFromMappings method with 
    * Record Type Dev Name And Primary Field APIs in Settings returns no models
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelsFromMappingsTestNoModelTest() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeNameAndInaccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = new STUB_PrimaryAffiliationValidationOff();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();
        Test.startTest();
            List<MODL_PrimaryAfflMapper> primaryAfflModels = maprPrimaryAfflInstance.getModelsFromMappings(primaryAfflMappings);
        Test.stopTest();
 
        System.assertEquals(true, primaryAfflModels.isEmpty());

    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelsFromSettings method with 
    * duplicate Settings will filter duplicate models 
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelsFromMappingsTestWithDevNameAndPrimaryFieldAPIsWithDuplicates() {

        String prefix = UTIL_Namespace.StrTokenNSPrefix('');

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeDevNameAndPrimaryFieldAPIs();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization duplicate', Account_Record_Type__c = 'Business_Organization', Primary_Affl_Field__c = prefix + 'Primary_Organization__c'));
        insert mappings;
 
        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
            List<MODL_PrimaryAfflMapper> primaryAfflModels = maprPrimaryAfflInstance.getModelsFromMappings(primaryAfflMappings);
        Test.stopTest();

        System.assertEquals(2, primaryAfflModels.size());

    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with valid
    * Record Type Dev Name And valid Primary Field APIs in Settings returns valid Affiliation Mapping model
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestRecTypeDevNameAndPrimaryFieldAPI() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeDevNameAndPrimaryFieldAPIs();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        String prefix = UTIL_Namespace.StrTokenNSPrefix('');

        System.assert(primaryAfflModel != null);
        System.assertEquals(true, primaryAfflModel.getIsValid());
        System.assertEquals('Business_Organization', primaryAfflModel.getSettingsRecordTypeFieldValue());
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getSettingsContactFieldValue());
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getContactFieldApiName());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), primaryAfflModel.getAccountRecordTypeId());
    }
    
    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with valid
    * RecordType Dev Name And valid Primary Field Label in Settings returns valid Affiliation mapping model
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithRecTypeDevNameAndFieldLabel() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeDevNameAndPrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        String prefix = UTIL_Namespace.StrTokenNSPrefix('');

        System.assert(primaryAfflModel != null);
        System.assertEquals(true, primaryAfflModel.getIsValid());
        System.assertEquals('Business_Organization', primaryAfflModel.getSettingsRecordTypeFieldValue());
        System.assertEquals('Primary Business Organization', primaryAfflModel.getSettingsContactFieldValue());
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getContactFieldApiName());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), primaryAfflModel.getAccountRecordTypeId());
    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with 
    * valid Record Type Name And valid Primary Field API in Settings return valid Affiliation mapping model
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithRecTypeNameAndFieldAPI() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeNameAndPrimaryFieldAPIs();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        String prefix = UTIL_Namespace.StrTokenNSPrefix('');

        System.assert(primaryAfflModel != null);
        System.assertEquals(true, primaryAfflModel.getIsValid());
        System.assertEquals('Business Organization', primaryAfflModel.getSettingsRecordTypeFieldValue());
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getSettingsContactFieldValue());
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getContactFieldApiName());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), primaryAfflModel.getAccountRecordTypeId());
    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with 
    * valid RecordType Name And valid Primary Field Label in Settings returns a valid Affiliation mapping model
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithRecTypeNameAndFieldLabel() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeNameAndPrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        String prefix = UTIL_Namespace.StrTokenNSPrefix('');

        System.assert(primaryAfflModel != null);
        System.assertEquals(true, primaryAfflModel.getIsValid());
        System.assertEquals('Business Organization', primaryAfflModel.getSettingsRecordTypeFieldValue());
        System.assertEquals('Primary Business Organization', primaryAfflModel.getSettingsContactFieldValue());
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getContactFieldApiName());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), primaryAfflModel.getAccountRecordTypeId());
    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with accurate
    * Record Type Name And inaccurate Primary Field Label in Settings returns a null value when Record Type Validation is enabled.
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithAccurateRecordTypeAndInaccurateFieldLabelWithValidationOn() {
        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeNameAndInaccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = new STUB_PrimaryAffiliationValidationOn();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
        MODL_PrimaryAfflMapper primAffMapResult = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        System.assertEquals(null, primAffMapResult, 'Affiliation mapping with invalid Contact field should return null value when validation is enabled.');
    } 

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with 
    * accurate RecordType Name And inaccurate Primary Field Label in Settings when validation is off returns null
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithAccurateRecordTypeAndInaccurateFieldLabelWithValidationOff() {
        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeNameAndInaccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = new STUB_PrimaryAffiliationValidationOff();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
        MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        System.assertEquals(null, primaryAfflModel, 'Affiliation mapping with invalid Contact field should return null value when validation is not enabled.');
    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with a valid RecordType Dev Name and valid Primary Field Label
    * in Settings generates a valid affiliation mapping model.
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithTextFieldAsLabelAndValidationOn() {
        String bizAccRecordTypeId = UTIL_Describe_API.getBizAccRecTypeID(); 

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business_Organization', Primary_Affl_Field__c = 'Gender'));
        insert mappings;

        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = new STUB_PrimaryAffiliationValidationOn();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
        MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        String prefix = UTIL_Namespace.StrTokenNSPrefix('');
       
        System.assertEquals(true, primaryAfflModel.getIsValid(), 'Affiliation mapping for valid Contact field and Account record type should be valid.');
        System.assertEquals(bizAccRecordTypeId, primaryAfflModel.getAccountRecordTypeId(), 'Record type for Affiliation mapping should be Business Organization.');
        System.assertEquals(prefix + 'Gender__c', primaryAfflModel.getContactFieldApiName(), 'Contact field API name for Affiliation mapping should be Gender__c.');
        System.assertEquals('Gender', primaryAfflModel.getSettingsContactFieldValue(), 'Contact field name for Affiliation mapping should be Gender.');
        System.assertEquals('Business_Organization', primaryAfflModel.getSettingsRecordTypeFieldValue(), 'Record type name for Affiliation mapping should be Business_Organization.');
    } 

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with a valid RecordType Dev Name an invalid Primary Field API
    * in Settings returns null.
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithLookupFieldAsAPIAndValidationOn() {

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business_Organization', Primary_Affl_Field__c = 'Not a Contact Field'));
        insert mappings;

        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = new STUB_PrimaryAffiliationValidationOn();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
        MODL_PrimaryAfflMapper primAffMapResult = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        System.assertEquals(null, primAffMapResult, 'An invalid Contact field mapping should return null when validation is enabled.');
    } 

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with inaccurate 
    * RecordType Name And and accurate Primary Field Label in Settings generates and invalid model when Record Type validations is enabled.
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithInaccurateRecordTypeAndValidationOn() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithInaccurateRecordTypeNameAndAccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = new STUB_PrimaryAffiliationValidationOn();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        String prefix = UTIL_Namespace.StrTokenNSPrefix('');
        
        System.assertEquals(false, primaryAfflModel.getIsValid(), 'Affiliation mapping model should be invalid for invalid Account Record Type.');
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getContactFieldApiName(), 'Contact field API name for Affiliation mapping model should be Primary_Organization__c.');
        System.assertEquals('Primary Business Organization', primaryAfflModel.getSettingsContactFieldValue(), 'Contact field API name for Affiliation mapping model should be Primary Business Organization.');
        System.assertEquals('Business Org test', primaryAfflModel.getSettingsRecordTypeFieldValue(), 'Record type for Affiliation mapping model should be set as Business org test.');
    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method will return a valid Affiliation mapping model with 
    * inaccurate RecordType Dev Name And accurate Primary Field Label in Settings when validation is Off
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithInaccurateRecordTypeAndValidationOff() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithInaccurateRecordTypeNameAndAccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = new STUB_PrimaryAffiliationValidationOff();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        String prefix = UTIL_Namespace.StrTokenNSPrefix('');

        System.assert(primaryAfflModel != null);
        System.assertEquals(true, primaryAfflModel.getIsValid());
        System.assertEquals('Business Org test', primaryAfflModel.getAccountRecordTypeId());
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getContactFieldApiName());
        System.assertEquals('Primary Business Organization', primaryAfflModel.getSettingsContactFieldValue());
        System.assertEquals('Business Org test', primaryAfflModel.getSettingsRecordTypeFieldValue());
    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with 
    * Inaccurate RecordType Name And inaccurate Primary Field Label in EDA Settings when validation is off returns null
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithInaccurateRecordTypeAndFieldWithValidationOff() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithInaccurateRecordTypeNameAndInAccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = new STUB_PrimaryAffiliationValidationOff();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
        MODL_PrimaryAfflMapper primAffMapResult = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        System.assertEquals(null, primAffMapResult, 'Invalid Contact field and Record Type mappings should return null when validation is not enabled.');
    }

    /***************************************************************************************************************
    * STUB class which extends MAPR_PrimaryAffiliations, overrides isPrimaryAffiliationValidationOn to return true
    ***************************************************************************************************************/
    private class STUB_PrimaryAffiliationValidationOn extends MAPR_PrimaryAffiliations {

        @TestVisible
        protected override boolean isPrimaryAffiliationValidationOn() {
            return true;
        }
    }

    /***************************************************************************************************************
    * STUB class which extends MAPR_PrimaryAffiliations, overrides isPrimaryAffiliationValidationOn to return false
    ***************************************************************************************************************/
    private class STUB_PrimaryAffiliationValidationOff extends MAPR_PrimaryAffiliations {

        @TestVisible
        protected override boolean isPrimaryAffiliationValidationOn() {
            return false;
        }
    }
}