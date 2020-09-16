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

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

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

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

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
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();
        System.assertEquals(MAPR_PrimaryAffiliations.instance, maprPrimaryAfflInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, maprPrimaryAfflInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * MAPR_PrimaryAffiliations class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance1 = MAPR_PrimaryAffiliations.getInstance();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance2 = MAPR_PrimaryAffiliations.getInstance();

        System.assertEquals(MAPR_PrimaryAffiliations.instance, maprPrimaryAfflInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(maprPrimaryAfflInstance1, maprPrimaryAfflInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, maprPrimaryAfflInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelsFromSettings method with 
    * RecordType Name And Primary Field APIs in Settings
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
    * RecordType Name And Primary Field APIs in Settings
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelsFromMappingsTestWithDevNameAndPrimaryFieldAPIs() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeDevNameAndPrimaryFieldAPIs();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();
        Test.startTest();
            List<MODL_PrimaryAfflMapper> primaryAfflModels = maprPrimaryAfflInstance.getModelsFromMappings(primaryAfflMappings);
        Test.stopTest();
 
        System.assertEquals(2, primaryAfflModels.size());

    }
    
    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with 
    * RecordType Name And Primary Field APIs in Settings
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestDevNameAndPrimaryFieldAPI() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeDevNameAndPrimaryFieldAPIs();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();
        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';
        
        System.assert(primaryAfflModel != null);
        System.assertEquals('Business_Organization', primaryAfflModel.getSettingsRecordTypeFieldValue());
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getSettingsContactFieldValue());
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getContactFieldApiName());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), primaryAfflModel.getAccountRecordTypeId());

    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with 
    * RecordType Dev Name And Primary Field Label in Settings
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithFieldLabel() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeDevNameAndPrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();
        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';
        
        System.assert(primaryAfflModel != null);
        System.assertEquals('Business_Organization', primaryAfflModel.getSettingsRecordTypeFieldValue());
        System.assertEquals('Primary Business Organization', primaryAfflModel.getSettingsContactFieldValue());
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getContactFieldApiName());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), primaryAfflModel.getAccountRecordTypeId());

    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with 
    * RecordType Name And Primary Field Label in Settings
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithFieldLabelAndRecTypeName() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeNameAndPrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();
        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';
        
        System.assert(primaryAfflModel != null);
        System.assertEquals('Business Organization', primaryAfflModel.getSettingsRecordTypeFieldValue());
        System.assertEquals('Primary Business Organization', primaryAfflModel.getSettingsContactFieldValue());
        System.assertEquals(prefix + 'Primary_Organization__c', primaryAfflModel.getContactFieldApiName());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), primaryAfflModel.getAccountRecordTypeId());

    }
    
    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with 
    * RecordType Dev Name And inaccurate Primary Field Label in Settings will throw an error
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithInaccurateFieldLabelWithValidationOn() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeNameAndInaccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = new STUB_PrimaryAffiliationValidationOn();

        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true));

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        try{
            Test.startTest();
                MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
            Test.stopTest();
            System.assert(false, 'Always throw an exception when Primary Affl Field is not valid and when Affiliation Record Type is Enforced ');
        } catch (ERR_ExceptionHandler.invalidContactFieldInAffiliationMappingException ex) {
            System.assert(ex.getMessage().contains('Invalid Contact Field in Affiliation Mappings'));
        }   

    } 
    
    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with RecordType Dev Name And Primary Field Label
    * of a different type in Settings throws an error when Affiliation Record Type is enforced
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithTextFieldLabel() {

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business_Organization', Primary_Affl_Field__c = 'Gender'));
        insert mappings;

        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = new STUB_PrimaryAffiliationValidationOn();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        try{
            Test.startTest();
                MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
            Test.stopTest();
            System.assert(false, 'Always throw an exception when Primary Affl Field is not valid and when Affiliation Record Type is Enforced ');
        } catch (ERR_ExceptionHandler.invalidContactFieldInAffiliationMappingException ex) {
            System.assert(ex.getMessage().contains('Invalid Contact Field in Affiliation Mappings'));
        }   
 
    } 

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with inaccurate 
    * RecordType Dev Name And and accurate Primary Field Label in Settings throws an error when record type validation is on
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithInaccurateRecordTypeAndValidationOn() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithInaccurateRecordTypeNameAndAccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = new STUB_PrimaryAffiliationValidationOn();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        try{
            Test.startTest();
                MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
            Test.stopTest();
            System.assert(false, 'Always throw an exception when Primary Affl Field is not valid and when Affiliation Record Type is Enforced ');
        } catch (ERR_ExceptionHandler.invalidRecordTypeInAffiliationMappingException ex) {
            System.assert(ex.getMessage().contains('Invalid RecordType In Affiliation Mappings'));
        }   

    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method will return null with 
    * inaccurate RecordType Dev Name And accurate Primary Field Label in Settings when validation is Off
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithInaccurateRecordTypeAndValidationOff() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithInaccurateRecordTypeNameAndAccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();
        System.assert(primaryAfflModel == null);

    }
    
    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with 
    * Inaccurate RecordType Dev Name And inaccurate Primary Field Label in Settings returns null
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithInaccurateRecordTypeAndFieldWithValidationOff() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithInaccurateRecordTypeNameAndInAccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();
        System.assert(primaryAfflModel == null);

    }
    
    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelFromMapping method with 
    * accurate RecordType Dev Name And inaccurate Primary Field Label in Settings when validation is off
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelFromMappingTestWithAccurateRecordTypeAndInaccurateFieldWithValidationOff() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithRecordTypeNameAndInaccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
            MODL_PrimaryAfflMapper primaryAfflModel = maprPrimaryAfflInstance.getModelFromMapping(primaryAfflMappings[0]);
        Test.stopTest();

        System.assertEquals('Business Organization', primaryAfflModel.getSettingsRecordTypeFieldValue());
        System.assertEquals('Wrong field Label1', primaryAfflModel.getSettingsContactFieldValue());
        System.assertEquals('Wrong field Label1', primaryAfflModel.getContactFieldApiName());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), primaryAfflModel.getAccountRecordTypeId());

    }

    /**************************************************************************************************************************************
    * @description Test method to verify that the getModelsFromSettings method with 
    * duplicate Settings will filter duplicate models 
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelsFromMappingsTestWithDevNameAndPrimaryFieldAPIsWithDuplicates() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

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
    * @description Test method to verify that the getModelFromMapping method with 
    * Inaccurate RecordType Dev Name And accurate Primary Field Label in Settings when validation is off
    ***************************************************************************************************************************************/
    @isTest
    private static void getModelsFromMappingsTestWithInaccurateRecordTypeAndValidationOff() {

        MAPR_PrimaryAffiliations_TEST.insertAfflMappingsWithInaccurateRecordTypeNameAndAccuratePrimaryFieldLables();
        MAPR_PrimaryAffiliations maprPrimaryAfflInstance = MAPR_PrimaryAffiliations.getInstance();

        List<Affl_Mappings__c> primaryAfflMappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();

        Test.startTest();
            List<MODL_PrimaryAfflMapper> primaryAfflModels = maprPrimaryAfflInstance.getModelsFromMappings(primaryAfflMappings);
        Test.stopTest();

        System.assertEquals(0, primaryAfflModels.size());

    }

    /***************************************************************************************************************
    * STUB class which extends MAPR_PrimaryAffiliations, overrides isPrimaryAffiliationValidationOn
    */
    private class STUB_PrimaryAffiliationValidationOn extends MAPR_PrimaryAffiliations {

        @TestVisible
        protected override boolean isPrimaryAffiliationValidationOn() {
            return true;
        }
    }     
}