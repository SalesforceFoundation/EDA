/*
    Copyright (c) 2021, Salesforce.org
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
 * @date 2021
 * @group Affiliations
 * @group-content ../../ApexDocContent/Affiliations.htm
 * @description Tests specific to Affiliation Management.
 */
@isTest
private class AFFL_MultiRecordTypeMapper_TEST {
    /**
     * @description test to ensure that getPopulatedAffiliationMappings retrieves all mappings with populated Account Record Types
     * and Primary Affiliation fields
     */
    @isTest
    private static void getPopulatedAffiliationMappingsValid() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            false
        );
        AFFL_MultiRecordTypeMapper affiliationMapper = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        List<Affl_Mappings__c> populatedAffiliationMappings = affiliationMapper.getPopulatedAffiliationMappings();
        Test.stopTest();

        System.assertEquals(
            2,
            populatedAffiliationMappings.size(),
            'Only the number of existing affiliation mappings should be retrieved.'
        );
    }

    /**
     * @description test to ensure that getPopulatedAffiliationMappings does not retrieve mappings with empty Account Record Types
     */
    @isTest
    private static void getPopulatedAffiliationMappingsEmptyAccountRecordType() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            false
        );
        AFFL_MultiRecordTypeMapper affiliationMapper = new AFFL_MultiRecordTypeMapper();

        List<Affl_Mappings__c> affiliationMappings = UTIL_CustomSettingsFacade.getAfflMappings();
        affiliationMappings[0].Account_Record_Type__c = null;
        update affiliationMappings;

        Test.startTest();
        List<Affl_Mappings__c> populatedAffiliationMappings = affiliationMapper.getPopulatedAffiliationMappings();
        Test.stopTest();

        System.assertEquals(
            1,
            populatedAffiliationMappings.size(),
            'Affiliation Mappings with empty account record types should not be retrieved.'
        );
    }

    /**
     * @description test to ensure that getPopulatedAffiliationMappings does not retrieve mappings with empty Primary Affiliation Fields
     */
    @isTest
    private static void getPopulatedAffiliationMappingsEmptyPrimaryAffiliationField() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            false
        );
        AFFL_MultiRecordTypeMapper affiliationMapper = new AFFL_MultiRecordTypeMapper();

        List<Affl_Mappings__c> affiliationMappings = UTIL_CustomSettingsFacade.getAfflMappings();
        affiliationMappings[0].Primary_Affl_Field__c = null;
        update affiliationMappings;

        Test.startTest();
        List<Affl_Mappings__c> populatedAffiliationMappings = affiliationMapper.getPopulatedAffiliationMappings();
        Test.stopTest();

        System.assertEquals(
            1,
            populatedAffiliationMappings.size(),
            'Affiliation Mappings with empty primary affiliation fields should not be retrieved.'
        );
    }

    /**
     * @description test to ensure that getRawAccountRecordTypes retrieves all account record type field values
     */
    @isTest
    private static void getRawAccountRecordTypes() {
        List<Affl_Mappings__c> mockedAffiliationMappings = new List<Affl_Mappings__c>{
            new Affl_Mappings__c(Name = 'First', Account_Record_Type__c = 'First Record Type'),
            new Affl_Mappings__c(Name = 'Second', Account_Record_Type__c = 'Second Record Type')
        };
        AFFL_MultiRecordTypeMapper affiliationMapper = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        List<String> rawAccountRecordTypes = affiliationMapper.getRawAccountRecordTypes(mockedAffiliationMappings);
        Test.stopTest();

        System.assertEquals(
            2,
            rawAccountRecordTypes.size(),
            'Only the number of existing affiliation mappings should be retrieved.'
        );
        System.assertEquals(
            true,
            rawAccountRecordTypes.contains('First Record Type'),
            'The first record type should be returned in the list.'
        );
        System.assertEquals(
            true,
            rawAccountRecordTypes.contains('Second Record Type'),
            'The second record type should be returned in the list.'
        );
    }

    /**
     * @description test to ensure that getRawContactFieldsByAccountRecordType retrieves all account record types mapped to primary affiliation fields
     */
    @isTest
    private static void getRawContactFieldsByAccountRecordType() {
        List<Affl_Mappings__c> mockedAffiliationMappings = new List<Affl_Mappings__c>{
            new Affl_Mappings__c(
                Name = 'First',
                Account_Record_Type__c = 'First Record Type',
                Primary_Affl_Field__c = 'First Field'
            ),
            new Affl_Mappings__c(
                Name = 'Second',
                Account_Record_Type__c = 'Second Record Type',
                Primary_Affl_Field__c = 'Second Field'
            )
        };
        AFFL_MultiRecordTypeMapper affiliationMapper = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        Map<String, String> rawContactFieldsByAccountRecordType = affiliationMapper.getRawContactFieldsByAccountRecordType(
            mockedAffiliationMappings
        );
        Test.stopTest();

        System.assertEquals(
            2,
            rawContactFieldsByAccountRecordType.size(),
            'Only the number of existing affiliation mappings should be retrieved.'
        );
        System.assertEquals(
            'First Field',
            rawContactFieldsByAccountRecordType.get('First Record Type'),
            'The first record type should be returned in the map.'
        );
        System.assertEquals(
            'Second Field',
            rawContactFieldsByAccountRecordType.get('Second Record Type'),
            'The second record type should be returned in the map.'
        );
    }

    /**
     * @description test to ensure that getPrimaryAffiliationMappingsByAccountRecordTypeName maps all primary affiliation
     * record type to labels when the Account Record Type is referred to as a label
     */
    @isTest
    private static void getPrimaryAffiliationMappingsByAccountRecordTypeNameLabel() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            false
        );

        Affl_Mappings__c firstMapping = affiliationMappingWrapperList[0].affiliationMapping;
        Affl_Mappings__c secondMapping = affiliationMappingWrapperList[1].affiliationMapping;
        List<Affl_Mappings__c> affiliationMappings = new List<Affl_Mappings__c>{ firstMapping, secondMapping };

        String firstRecordType = affiliationMappingWrapperList[0].getAccountRecordTypeName();
        String secondRecordType = affiliationMappingWrapperList[1].getAccountRecordTypeName();
        List<String> validRawAccountRecordTypesInMappings = new List<String>{ firstRecordType, secondRecordType };

        AFFL_MultiRecordTypeMapper affiliationMapper = new AFFL_MultiRecordTypeMapper();
        Map<String, Schema.RecordTypeInfo> accountRecordTypeInfosByDeveloperName = AFFL_MultiRecordTypeMapper.accountRecordTypeInfosByDeveloperName;

        Test.startTest();
        Map<String, Affl_Mappings__c> primaryAffiliationMappingsByAccountRecordTypeName = affiliationMapper.getPrimaryAffiliationMappingsByAccountRecordTypeName(
            affiliationMappings,
            validRawAccountRecordTypesInMappings,
            accountRecordTypeInfosByDeveloperName
        );
        Test.stopTest();

        System.assertEquals(
            2,
            primaryAffiliationMappingsByAccountRecordTypeName.size(),
            'All Affiliation Mappings should be mapped.'
        );
        System.assertEquals(
            firstMapping,
            primaryAffiliationMappingsByAccountRecordTypeName.get(firstRecordType),
            'The first record type should be appropriately mapped.'
        );
        System.assertEquals(
            secondMapping,
            primaryAffiliationMappingsByAccountRecordTypeName.get(secondRecordType),
            'The second record type should be appropriately mapped.'
        );
    }

    /**
     * @description test to ensure that getPrimaryAffiliationMappingsByAccountRecordTypeName maps all primary affiliation
     * record type to labels when the Account Record Type is referred to as an api name
     */
    @isTest
    private static void getPrimaryAffiliationMappingsByAccountRecordTypeNameApiName() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByDevNameAndLabel(
            false
        );

        Affl_Mappings__c firstMapping = affiliationMappingWrapperList[0].affiliationMapping;
        Affl_Mappings__c secondMapping = affiliationMappingWrapperList[1].affiliationMapping;
        List<Affl_Mappings__c> affiliationMappings = new List<Affl_Mappings__c>{ firstMapping, secondMapping };

        String firstRecordType = affiliationMappingWrapperList[0].getAccountRecordTypeName();
        String secondRecordType = affiliationMappingWrapperList[1].getAccountRecordTypeName();

        String firstRecordTypeDevName = affiliationMappingWrapperList[0].getAccountRecordTypeDeveloperName();
        String secondRecordTypeDevName = affiliationMappingWrapperList[1].getAccountRecordTypeDeveloperName();
        List<String> validRawAccountRecordTypesInMappings = new List<String>{
            firstRecordTypeDevName,
            secondRecordTypeDevName
        };

        AFFL_MultiRecordTypeMapper affiliationMapper = new AFFL_MultiRecordTypeMapper();
        Map<String, Schema.RecordTypeInfo> accountRecordTypeInfosByDeveloperName = AFFL_MultiRecordTypeMapper.accountRecordTypeInfosByDeveloperName;

        Test.startTest();
        Map<String, Affl_Mappings__c> primaryAffiliationMappingsByAccountRecordTypeName = affiliationMapper.getPrimaryAffiliationMappingsByAccountRecordTypeName(
            affiliationMappings,
            validRawAccountRecordTypesInMappings,
            accountRecordTypeInfosByDeveloperName
        );
        Test.stopTest();

        System.assertEquals(
            2,
            primaryAffiliationMappingsByAccountRecordTypeName.size(),
            'All Affiliation Mappings should be mapped.'
        );
        System.assertEquals(
            firstMapping,
            primaryAffiliationMappingsByAccountRecordTypeName.get(firstRecordType),
            'The first record type should be appropriately mapped.'
        );
        System.assertEquals(
            secondMapping,
            primaryAffiliationMappingsByAccountRecordTypeName.get(secondRecordType),
            'The second record type should be appropriately mapped.'
        );
    }

    /**
     * @description test to ensure that getPrimaryAffiliationMappingsByAccountRecordTypeName does not map a primary affiliation
     * record type to a label when the Account Record Type is not a valid Account Record Type
     */
    @isTest
    private static void getPrimaryAffiliationMappingsByAccountRecordTypeNameInvalidAccountRecordType() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            false
        );

        Affl_Mappings__c firstMapping = affiliationMappingWrapperList[0].affiliationMapping;
        Affl_Mappings__c secondMapping = affiliationMappingWrapperList[1].affiliationMapping;
        List<Affl_Mappings__c> affiliationMappings = new List<Affl_Mappings__c>{ firstMapping, secondMapping };

        String firstRecordType = affiliationMappingWrapperList[0].getAccountRecordTypeName();
        String secondRecordType = affiliationMappingWrapperList[1].getAccountRecordTypeName();
        List<String> validRawAccountRecordTypesInMappings = new List<String>{ firstRecordType };

        AFFL_MultiRecordTypeMapper affiliationMapper = new AFFL_MultiRecordTypeMapper();
        Map<String, Schema.RecordTypeInfo> accountRecordTypeInfosByDeveloperName = AFFL_MultiRecordTypeMapper.accountRecordTypeInfosByDeveloperName;

        Test.startTest();
        Map<String, Affl_Mappings__c> primaryAffiliationMappingsByAccountRecordTypeName = affiliationMapper.getPrimaryAffiliationMappingsByAccountRecordTypeName(
            affiliationMappings,
            validRawAccountRecordTypesInMappings,
            accountRecordTypeInfosByDeveloperName
        );
        Test.stopTest();

        System.assertEquals(
            1,
            primaryAffiliationMappingsByAccountRecordTypeName.size(),
            'All Affiliation Mappings should be mapped.'
        );
        System.assertEquals(
            firstMapping,
            primaryAffiliationMappingsByAccountRecordTypeName.get(firstRecordType),
            'The first record type should be appropriately mapped.'
        );
        System.assertEquals(
            null,
            primaryAffiliationMappingsByAccountRecordTypeName.get(secondRecordType),
            'The second record type should not be mapped.'
        );
    }

    // Test getPrimaryAffiliationLookupAPIFromAffiliationType method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getPrimaryAffiliationLookupAPIFromAffiliationTypeTest() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            false
        );
        String bizOrgRecordTypeName = affiliationMappingWrapperList[1].getAccountRecordTypeName();

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
        Test.startTest();
        String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType(
            bizOrgRecordTypeName
        );
        Test.stopTest();

        String bizOrgPrimaryAfflFieldApiName = AffiliationTestSetupFactory_TEST.getBusinessOrganizationFieldApiName();

        System.assertEquals(bizOrgPrimaryAfflFieldApiName, primaryAfflLookupAPIName);
    }

    // Negative test for getPrimaryAffiliationLookupAPIFromAffiliationType method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getPrimaryAffiliationLookupAPIFromAffiliationTypeNegativeTest() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
        Test.startTest();
        String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType(
            'Test Organization xyz'
        );
        Test.stopTest();

        System.assertEquals(null, primaryAfflLookupAPIName);
    }

    // Null test for getPrimaryAffiliationLookupAPIFromAffiliationType method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getPrimaryAffiliationLookupAPIFromAffiliationTypeNullTest() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
        Test.startTest();
        String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPIFromAffiliationType(null);
        Test.stopTest();

        System.assertEquals(null, primaryAfflLookupAPIName);
    }

    // Positive test for getContactFieldFromSettings method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getContactFieldFromSettingsPoitiveTest() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            false
        );
        String bizOrgName = affiliationMappingWrapperList[1].getAccountRecordTypeName();
        String bizOrgContactFieldLabel = AffiliationTestSetupFactory_TEST.getBusinessOrganizationFieldLabel();

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
        Test.startTest();
        String contactFieldFromSettings = afflMapper.getContactFieldFromSettings(bizOrgName);
        Test.stopTest();

        System.assertEquals(bizOrgContactFieldLabel, contactFieldFromSettings);
    }

    // Negative test for getContactFieldFromSettings method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getContactFieldFromSettingsNegativeTest() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
        Test.startTest();
        String contactFieldFromSettings = afflMapper.getContactFieldFromSettings('Test1234');
        Test.stopTest();

        System.assertEquals(null, contactFieldFromSettings);
    }

    // Positive test for getPrimaryAffiliationLookupAPI method of AFFL_MultiRecordTypeMapper using Label name
    @isTest
    private static void getPrimaryAffiliationLookupAPIPoitiveLabelTest() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);
        String bizOrgContactFieldLabel = AffiliationTestSetupFactory_TEST.getBusinessOrganizationFieldLabel();
        String bizOrgContactFieldApiName = AffiliationTestSetupFactory_TEST.getBusinessOrganizationFieldApiName();

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
        Test.startTest();
        String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPI(bizOrgContactFieldLabel);
        Test.stopTest();

        System.assertEquals(bizOrgContactFieldApiName, primaryAfflLookupAPIName);
    }

    // This method tests getValidAccRecordTypesInMappings() of AFFL_MultiRecordTypeMapper class by passing Record Names Labels from affiliation mappings
    @isTest
    private static void testGetValidAccRecordTypesInMappingsMethodwithLabels() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.getAfflMappingWrapperByNameAndLabel();

        affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.populateRecordTypeNamesForWrappers(
            affiliationMappingWrapperList
        );

        List<String> accRecTypeLabelList = new List<String>();
        for (
            AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper affiliationMappingWrapper : affiliationMappingWrapperList
        ) {
            accRecTypeLabelList.add(affiliationMappingWrapper.getAccountRecordTypeName());
        }

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        List<String> matchingRecordTypeList = afflMapper.getValidAccRecordTypesInMappings(accRecTypeLabelList);
        Test.stopTest();

        // Ensure List has all mappings
        System.assertEquals(accRecTypeLabelList.size(), matchingRecordTypeList.size());
    }

    // This method tests getValidAccRecordTypesInMappings() of AFFL_MultiRecordTypeMapper class by passing Record Names list from affiliation mappings
    @isTest
    private static void testGetValidAccRecordTypesInMappingsMethodwithAPIs() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByDevNameAndLabel(
            false
        );

        // Construct a list of Account Record Type Names
        List<String> accRecTypeDevNameList = new List<String>();
        for (
            AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper affiliationMappingWrapper : affiliationMappingWrapperList
        ) {
            accRecTypeDevNameList.add(affiliationMappingWrapper.getAccountRecordTypeDeveloperName());
        }

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
        Test.startTest();
        List<String> matchingRecordTypeList = afflMapper.getValidAccRecordTypesInMappings(accRecTypeDevNameList);
        Test.stopTest();

        // Ensure List has all mappings
        System.assertEquals(affiliationMappingWrapperList.size(), matchingRecordTypeList.size());
    }

    /* This method tests getValidAccRecordTypesInMappings() of AFFL_MultiRecordTypeMapper class by passing
     both Record type Names and Labels list from affiliation mappings */
    @isTest
    private static void testGetValidAccRecordTypesInMappingsMethodwithAPIAndLabels() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndApiName(
            false
        );

        // Construct a list of Account Record Type Names and Labels
        List<String> accRecTypeLabelList = new List<String>();

        for (
            AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper affiliationMappingWrapper : affiliationMappingWrapperList
        ) {
            accRecTypeLabelList.add(affiliationMappingWrapper.getAccountRecordTypeName());
        }

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        List<String> matchingRecordTypeList = afflMapper.getValidAccRecordTypesInMappings(accRecTypeLabelList);
        Test.stopTest();

        // Ensure List has all mappings
        System.assertEquals(affiliationMappingWrapperList.size(), matchingRecordTypeList.size());
    }

    /* This method tests getValidPrimaryAfflFields() of AFFL_MultiRecordTypeMapper class by passing
     both API names for Primary Affiliation Fields */
    @isTest
    private static void testsGetValidPrimaryAfflFields() {
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndApiName(
            false
        );

        List<Affl_Mappings__c> allMappings = [SELECT ID FROM Affl_Mappings__c];
        System.assertEquals(affiliationMappingWrapperList.size(), allMappings.size());

        // Construct a list of primary Affiliation field API Names
        List<String> primaryFieldsList = AffiliationTestSetupFactory_TEST.getContactPrimaryAffiliationFieldApiNames();

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        List<String> validPrimaryFieldList = afflMapper.getValidPrimaryAfflFields(primaryFieldsList);
        Test.stopTest();

        // Ensure List has both mappings
        System.assertEquals(affiliationMappingWrapperList.size(), validPrimaryFieldList.size());
    }

    /* This method tests getValidprimaryAfflFields() of AFFL_MultiRecordTypeMapper class by passing
     labels for Primary Affiliation Fields */
    @isTest
    private static void testsGetValidPrimaryAfflFieldsWithLabels() {
        // Construct a list of primary Affiliation field Labels
        List<String> primaryFieldsList = AffiliationTestSetupFactory_TEST.getContactPrimaryAffiliationFieldLabels();

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        List<String> validPrimaryFieldList = afflMapper.getValidPrimaryAfflFields(primaryFieldsList);
        Test.stopTest();

        // Ensure List has all mappings
        System.assertEquals(primaryFieldsList.size(), validPrimaryFieldList.size());
    }

    /* This method tests getValidPrimaryAfflFields() of AFFL_MultiRecordTypeMapper class by passing
     both label and API names for Primary Affiliation Fields */
    @isTest
    private static void testsGetValidPrimaryAfflFieldsWithLabelsAndAPI() {
        //Note custom setup
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> wrapperList = new List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper>();

        List<String> contactPrimaryAffiliationFieldApiNameList = AffiliationTestSetupFactory_TEST.getContactPrimaryAffiliationFieldApiNames();
        List<String> contactPrimaryAffiliationFieldLabelList = AffiliationTestSetupFactory_TEST.getContactPrimaryAffiliationFieldLabels();
        String bizOrgContactFieldApiName = AffiliationTestSetupFactory_TEST.getBusinessOrganizationFieldApiName();
        String householdContactFieldLabel = AffiliationTestSetupFactory_TEST.getHouseholdFieldLabel();

        wrapperList.add(
            new AffiliationTestSetupFactory_TEST.AfflMappingWrapperByNameAndApiName(
                UTIL_Describe.getCustomHHAccRecTypeID(),
                contactPrimaryAffiliationFieldApiNameList[0]
            )
        );

        wrapperList.add(
            new AffiliationTestSetupFactory_TEST.AfflMappingWrapperByNameAndLabel(
                UTIL_Describe_API.getBizAccRecTypeID(),
                contactPrimaryAffiliationFieldLabelList[1]
            )
        );

        wrapperList = AffiliationTestSetupFactory_TEST.commonSetup(wrapperList, false);
        //Custom setup ended

        List<Affl_Mappings__c> allMappings = [SELECT Id FROM Affl_Mappings__c];
        System.assertEquals(wrapperList.size(), allMappings.size());

        // Construct a list of primary Affiliation field Labels and API names
        List<String> primaryFieldsList = new List<String>();
        primaryFieldsList.add(bizOrgContactFieldApiName);
        primaryFieldsList.add(householdContactFieldLabel);

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();
        Test.startTest();
        List<String> validPrimaryFieldList = afflMapper.getValidPrimaryAfflFields(primaryFieldsList);
        Test.stopTest();

        // Ensure List has all mappings
        System.assertEquals(wrapperList.size(), validPrimaryFieldList.size());
    }

    // Positive test for getPrimaryAffiliationLookupAPI method of AFFL_MultiRecordTypeMapper using API name
    @isTest
    private static void getPrimaryAffiliationLookupAPIPoitiveAPITest() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        String bizOrgContactFieldApiName = AffiliationTestSetupFactory_TEST.getBusinessOrganizationFieldApiName();

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPI(bizOrgContactFieldApiName);
        Test.stopTest();

        System.assertEquals(bizOrgContactFieldApiName, primaryAfflLookupAPIName);
    }

    // Negative test for getPrimaryAffiliationLookupAPI method of AFFL_MultiRecordTypeMapper
    @isTest
    private static void getPrimaryAffiliationLookupAPINegativeTest() {
        AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(false);

        AFFL_MultiRecordTypeMapper afflMapper = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        String primaryAfflLookupAPIName = afflMapper.getPrimaryAffiliationLookupAPI('Test1234');
        Test.stopTest();

        System.assertEquals(null, primaryAfflLookupAPIName);
    }

    /**
     * @description helper class for initialization of tests for needsProgramEnrollment
     */
    private class NeedsProgramEnrollmentValidData {
        public Account accountToTest;
        public Contact contactToTest;
        public Affiliation__c affiliation;

        public NeedsProgramEnrollmentValidData() {
            this.contactToTest = UTIL_UnitTestData_TEST.getUniqueContact(1);
            insert contactToTest;

            Id businessOrganizationRecordTypeId = UTIL_Describe_API.getBizAccRecTypeID();
            this.accountToTest = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, businessOrganizationRecordTypeId)[0];
            insert this.accountToTest;

            this.affiliation = new Affiliation__c(
                Id = UTIL_UnitTestData_TEST.getFakeId(Affiliation__c.SObjectType),
                Account__c = this.accountToTest.Id,
                Contact__c = this.contactToTest.Id,
                Primary__c = true,
                Role__c = AffiliationTestSetupFactory_TEST.PROG_ENROLL_ROLE_STUDENT,
                Status__c = AffiliationTestSetupFactory_TEST.PROG_ENROLL_STATUS_CURRENT
            );
        }
    }

    /**
     * @description Tests needsProgramEnrollment for when a program enrollment should be created using a Record Type
     * developer name and a Contact Field api name
     */
    @isTest
    private static void needsProgramEnrollmentDevNameAndApiName() {
        NeedsProgramEnrollmentValidData testData = new NeedsProgramEnrollmentValidData();
        Formula.recalculateFormulas(new List<Affiliation__c>{ testData.affiliation });

        //Create auto enrollment mapping
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByDevNameAndApiName(
            true
        );
        AFFL_MultiRecordTypeMapper testClass = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        Boolean programEnrollmentNeeded = testClass.needsProgramEnrollment(testData.affiliation);
        Test.stopTest();

        System.assertEquals(
            true,
            programEnrollmentNeeded,
            'A program enrollment should not be needed for the Affiliation.'
        );
    }

    /**
     * @description Tests needsProgramEnrollment for when a program enrollment should be created using a Record Type
     * developer name and a Contact Field label
     */
    @isTest
    private static void needsProgramEnrollmentDevNameAndLabel() {
        NeedsProgramEnrollmentValidData testData = new NeedsProgramEnrollmentValidData();
        Formula.recalculateFormulas(new List<Affiliation__c>{ testData.affiliation });

        //Create auto enrollment mapping
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByDevNameAndLabel(
            true
        );
        AFFL_MultiRecordTypeMapper testClass = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        Boolean programEnrollmentNeeded = testClass.needsProgramEnrollment(testData.affiliation);
        Test.stopTest();

        System.assertEquals(
            true,
            programEnrollmentNeeded,
            'A program enrollment should be needed for the Affiliation.'
        );
    }

    /**
     * @description Tests needsProgramEnrollment for when a program enrollment should be created using a Record Type name
     * and a Contact Field api name
     */
    @isTest
    private static void needsProgramEnrollmentNameAndApiName() {
        NeedsProgramEnrollmentValidData testData = new NeedsProgramEnrollmentValidData();
        Formula.recalculateFormulas(new List<Affiliation__c>{ testData.affiliation });

        //Create auto enrollment mapping
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndApiName(
            true
        );
        AFFL_MultiRecordTypeMapper testClass = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        Boolean programEnrollmentNeeded = testClass.needsProgramEnrollment(testData.affiliation);
        Test.stopTest();

        System.assertEquals(
            true,
            programEnrollmentNeeded,
            'A program enrollment should be needed for the Affiliation.'
        );
    }

    /**
     * @description Tests needsProgramEnrollment for when a program enrollment should be created using a Record Type name
     * and a Contact Field label
     */
    @isTest
    private static void needsProgramEnrollmentNameAndLabel() {
        NeedsProgramEnrollmentValidData testData = new NeedsProgramEnrollmentValidData();
        Formula.recalculateFormulas(new List<Affiliation__c>{ testData.affiliation });

        //Create auto enrollment mapping
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            true
        );
        AFFL_MultiRecordTypeMapper testClass = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        Boolean programEnrollmentNeeded = testClass.needsProgramEnrollment(testData.affiliation);
        Test.stopTest();

        System.assertEquals(
            true,
            programEnrollmentNeeded,
            'A program enrollment should be needed for the Affiliation.'
        );
    }

    /**
     * @description Tests needsProgramEnrollment for when a the affiliation type is null
     */
    @isTest
    private static void needsProgramEnrollmentNullAffiliationType() {
        NeedsProgramEnrollmentValidData testData = new NeedsProgramEnrollmentValidData();

        //Create auto enrollment mapping
        List<AffiliationTestSetupFactory_TEST.AffiliationMappingWrapper> affiliationMappingWrapperList = AffiliationTestSetupFactory_TEST.setupMappingsByNameAndLabel(
            true
        );
        AFFL_MultiRecordTypeMapper testClass = new AFFL_MultiRecordTypeMapper();

        Test.startTest();
        Boolean programEnrollmentNeeded = testClass.needsProgramEnrollment(testData.affiliation);
        Test.stopTest();

        System.assertEquals(
            false,
            programEnrollmentNeeded,
            'A program enrollment should not be needed for the Affiliation when the Affiliation type is null.'
        );
    }
}
