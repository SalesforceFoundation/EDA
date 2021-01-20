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
* @group-content ../../ApexDocContent/Tests.htm
* @description Test class for AffiliationMappingsHealthCheckVMapper class.
*/
@isTest 
public with sharing class AffiliationMappingsHCVMapper_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AffiliationMappingsHealthCheckVMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
        AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AffiliationMappingsHealthCheckVMapper.instance, AffiliationMappingsHealthCheckVMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, AffiliationMappingsHealthCheckVMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AffiliationMappingsHealthCheckVMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
        AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperInstance1 = 
            AffiliationMappingsHealthCheckVMapper.getInstance();
        AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperInstance2 = 
            AffiliationMappingsHealthCheckVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AffiliationMappingsHealthCheckVMapper.instance, AffiliationMappingsHealthCheckVMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(AffiliationMappingsHealthCheckVMapperInstance1, AffiliationMappingsHealthCheckVMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, AffiliationMappingsHealthCheckVMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test to verify locateRecordTypeService() returns an instance of the RecordTypeService class.
    **************************************************************************************************************************/ 
    @isTest
    private static void locateRecordTypeServiceValid() {
        Test.startTest();
        RecordTypeService recordTypeServiceInstance = AccountModelHealthCheckVMapper.getInstance().locateRecordTypeService();
        Test.stopTest();

        System.assertEquals(RecordTypeService.getInstance(), recordTypeServiceInstance, 'Should return instance of RecordTypeService class.');
        System.assertEquals(true, recordTypeServiceInstance != null, 'Instance of RecordTypeService class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test to verify locateAffiliationMappingsService() returns an instance of the AffiliationMappingsService class.
    **************************************************************************************************************************/ 
    @isTest
    private static void locateAffiliationMappingsServiceValid() {
        Test.startTest();
        AffiliationMappingsService AffiliationMappingsServiceInstance = AffiliationMappingsHealthCheckVMapper.getInstance().locateAffiliationMappingsService();
        Test.stopTest();

        System.assertEquals(AffiliationMappingsService.getInstance(), AffiliationMappingsServiceInstance, 'Should return instance of AffiliationMappingsService class.');
        System.assertEquals(true, AffiliationMappingsServiceInstance != null, 'Instance of AffiliationMappingsService class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test to verify locateLookupFieldService() returns an instance of the LookupFieldService class.
    **************************************************************************************************************************/ 
    @isTest
    private static void locateLookupFieldServiceValid() {
        Test.startTest();
        LookupFieldService LookupFieldServiceInstance = AffiliationMappingsHealthCheckVMapper.getInstance().locateLookupFieldService();
        Test.stopTest();

        System.assertEquals(LookupFieldService.getInstance(), LookupFieldServiceInstance, 'Should return instance of LookupFieldService class.');
        System.assertEquals(true, LookupFieldServiceInstance != null, 'Instance of LookupFieldService class should not be null.');
    }

    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles all
    * passed health checks
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupAllPassed() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsService();
        RecordTypeService.instance = new STUB_RecordTypeService();
        LookupFieldService.instance = new STUB_LookupFieldService();
        PicklistEntryService.instance = new STUB_PicklistEntryServiceRole();

        STUB_AffiliationMappingsHealthCheckVMapperPass AffiliationMappingsHealthCheckVMapperStub =
            new STUB_AffiliationMappingsHealthCheckVMapperPass();
        AffiliationMappingsHealthCheckVMapper.instance = AffiliationMappingsHealthCheckVMapperStub;  

        AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapper =
            AffiliationMappingsHealthCheckVMapper.getInstance();

        Integer numberOfHealthChecks = 3;

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                AffiliationMappingsHealthCheckVMapperStub.getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHealthCheckAffiliationMappings,
            healthCheckGroupVModel.label,
            'Label of returned health check should match expected custom label.'
        );
        System.assertEquals(
            Label.stgHealthCheckStatusPassed,
            healthCheckGroupVModel.status,
            'Status of returned health check should match expected custom label.'
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModel.passedChecks,
            'Number of passed checks of returned health check should match expected custom label.'
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModel.totalChecks,
            'Number of total checks of returned health check should match expected custom label.'
        );
        System.assertEquals(
            0,
            healthCheckGroupVModel.expandedRowsList.size(),
            'No health checks should fail, making expanded rows list size 0.'
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModel.healthCheckItemList[0].healthCheckItemList.size(),
            'Number of health check items of returned health check should match total number of health checks.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles all
    * failed health checks
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupAllFail() {
        AffiliationMappingsService.instance = new STUB_AffiliationMappingsServiceUnfound();
        RecordTypeService.instance = new STUB_RecordTypeServiceNull();

        STUB_AffiliationMappingsHealthCheckVMapperFail AffiliationMappingsHealthCheckVMapperStub =
            new STUB_AffiliationMappingsHealthCheckVMapperFail();

        AffiliationMappingsHealthCheckVMapper.instance = AffiliationMappingsHealthCheckVMapperStub;  

        AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapper =
            AffiliationMappingsHealthCheckVMapper.getInstance();

        Integer numberOfHealthChecks = 3;

        Test.startTest();
            HealthCheckGroupVModel healthCheckGroupVModel =
                AffiliationMappingsHealthCheckVMapper.getHealthCheckGroup();
        Test.stopTest();

        System.assertEquals(
            Label.stgHealthCheckAffiliationMappings,
            healthCheckGroupVModel.label,
            'Label of returned health check should match expected custom label.'
        );
        System.assertEquals(
            Label.stgHealthCheckStatusFailed,
            healthCheckGroupVModel.status,
            'Status of returned health check should match expected custom label.'
        );
        System.assertEquals(
            0,
            healthCheckGroupVModel.passedChecks,
            'Number of passed checks should be 0.'
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModel.totalChecks,
            'Number of total checks of returned health check should match expected custom label.'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.expandedRowsList.size(),
            'All health checks should fail, making expanded rows list size 1.'
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModel.healthCheckItemList[0].healthCheckItemList.size(),
            'Number of health check items of returned health check should match total number of health checks.'
        );
    }

    /*****************************************************************************************
    * @description Test method to verify getValidRecordTypeHealthCheckGroupVModel returns a 
    * HealthCheckGroupVModel with a Passed status when an affiliation mapping is mapped to
    * an Account record type that is valid and active.
    *****************************************************************************************/
    @isTest 
    private static void getValidRecordTypeHealthCheckGroupVModelValid() {
        RecordTypeService.instance = new STUB_RecordTypeService();
        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingsModelsList = new List<AffiliationMappingsModel> {
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                '000000000000000006',
                'Test Primary Field',
                true,
                'Test Status',
                'Test Role'
            )
        };

        Map<Id,RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel> {
            '000000000000000006' => new RecordTypeModel(
                '000000000000000006',
                'Active RecordType Name',
                'activeRTDevName',
                true
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getValidRecordTypeHealthCheckGroupVModel(
                affiliationMappingsModelsList[0],
                recordTypeModelsById
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusPassed,
            1,
            1,
            0,
            1
        );

        AffiliationMappingsHCVMapper_TEST.validateHCItemAssertions(
            healthCheckGroupVModelResult,
            Label.stgHCAfflMapAccRecordTypeTitle,
            'Pass',
            Label.stgHealthCheckStatusPassed,
            String.format(
                Label.stgHCRecordTypeValid, 
                new List<Object> {'Active RecordType Name', 'activeRTDevName'}
            ),
            Label.stgHealthCheckFixNotApplicable,
            0
        );
    }

    /*****************************************************************************************
    * @description Test method to verify getValidRecordTypeHealthCheckGroupVModel returns a 
    * HealthCheckGroupVModel with a Failed status when an affiliation mapping is mapped to
    * an Account record type that is valid, but inactive.
    *****************************************************************************************/
    @isTest 
    private static void getValidRecordTypeHealthCheckGroupVModelInactiveRT() {
        RecordTypeService.instance = new STUB_RecordTypeServiceInactive();
        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingsModelsList = new List<AffiliationMappingsModel> {
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                '000000000000000005',
                'Test Primary Field',
                true,
                'Test Status',
                'Test Role'
            )
        };

        Map<Id,RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel> {
            '000000000000000005' => new RecordTypeModel(
                '000000000000000005',
                'Inactive RecordType Name',
                'inactiveRTDevName',
                false
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getValidRecordTypeHealthCheckGroupVModel(
                affiliationMappingsModelsList[0],
                recordTypeModelsById
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusFailed,
            0,
            1,
            0,
            1
        );

        AffiliationMappingsHCVMapper_TEST.validateHCItemAssertions(
            healthCheckGroupVModelResult,
            Label.stgHCAfflMapAccRecordTypeTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            String.format(
                Label.stgHCRecordTypeInactive, 
                new List<Object> {'Inactive RecordType Name', 'inactiveRTDevName'}
            ),
            String.format(
                Label.stgHCAfflMapAccRecordTypeInactiveFix, 
                new List<Object> {'Inactive RecordType Name', 'inactiveRTDevName'}
            ),
            0
        );  
    }

    /*****************************************************************************************
    * @description Test method to verify getValidRecordTypeHealthCheckGroupVModel returns a 
    * HealthCheckGroupVModel with a Failed status when an affiliation mapping does not match
    * an Account record type specified in the org.
    *****************************************************************************************/
    @isTest 
    private static void getValidRecordTypeHealthCheckGroupVModelNullRT() {
        RecordTypeService.instance = new STUB_RecordTypeServiceNull();
        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingModelsList = new List<AffiliationMappingsModel>{
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                'Non-Existent Record Type Name', // will be converted to matching RT id value
                'Test Primary Field',
                true,
                'Test Status',
                'Test Role'
            )
        };

        Map<Id,RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{
            '000000000000000005' => new RecordTypeModel(
                '000000000000000005',
                'Inactive RecordType Name',
                'inactiveRTDevName',
                false
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getValidRecordTypeHealthCheckGroupVModel(
                affiliationMappingModelsList[0],
                recordTypeModelsById
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusFailed,
            0,
            1,
            0,
            1
        );

        AffiliationMappingsHCVMapper_TEST.validateHCItemAssertions(
            healthCheckGroupVModelResult,
            Label.stgHCAfflMapAccRecordTypeTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            String.format(
                Label.stgHCRecordTypeNotFound, 
                new List<Object>{'Non-Existent Record Type Name'}
            ),
            String.format(
                Label.stgHCAfflMapAccRecordTypeNotFoundFix, 
                new List<Object>{'Non-Existent Record Type Name'}
            ),
            0
        ); 
    }

    /*****************************************************************************************
    * @description Test method to verify getValidRecordTypeHealthCheckGroupVModel returns a 
    * HealthCheckGroupVModel with a Failed status when an affiliation mapping contains a
    * value that is not a Record Type developer name.
    *****************************************************************************************/
    @isTest 
    private static void getValidRecordTypeHealthCheckGroupVModelNonExistentRT() {
        RecordTypeService.instance = new STUB_RecordTypeServiceNull();
        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingModelsList = new List<AffiliationMappingsModel>{
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                'ABCD12345000000000', 
                'Test Primary Field',
                true,
                'Test Status',
                'Test Role'
            )
        };

        Map<Id,RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{
            '000000000000000005' => new RecordTypeModel(
                '000000000000000005',
                'Inactive RecordType Name',
                'inactiveRTDevName',
                false
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getValidRecordTypeHealthCheckGroupVModel(
                affiliationMappingModelsList[0],
                recordTypeModelsById
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusFailed,
            0,
            1,
            0,
            1
        );

        AffiliationMappingsHCVMapper_TEST.validateHCItemAssertions(
            healthCheckGroupVModelResult,
            Label.stgHCAfflMapAccRecordTypeTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            String.format(
                Label.stgHCRecordTypeNotFound, 
                new List<Object>{'ABCD12345000000000'} 
            ),
            String.format(
                Label.stgHCAfflMapAccRecordTypeNotFoundFix, 
                new List<Object>{'ABCD12345000000000'}
            ),
            0
        ); 
    }

    /*****************************************************************************************
    * @description Test method to verify getValidContactPrimaryFieldHealthCheckGroupVModel returns a 
    * HealthCheckGroupVModel with a Passed status when an Primary Affilition field specified
    * in affiliation mappings matches the developer name of a field that corresponds to a  
    * lookup to Account on Contact. 
    *****************************************************************************************/
    @isTest 
    private static void getValidContactPrimaryFieldHealthCheckGroupVModelValidByName() {
        LookupFieldService.instance = new STUB_LookupFieldServiceDevNameMatch();

        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingsModelsList = new List<AffiliationMappingsModel> {
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                'Test Record Type Name', 
                'Valid Contact Lookup Field Name',
                true,
                'Test Status',
                'Test Role'
            )
        };

        Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByName = new Map<String, LookupFieldModel> {
            'Valid Contact Lookup Field Name' => new LookupFieldModel(
                'Valid Contact Lookup Field Name',
                'Valid Contact Lookup Field Label'
            ),

            'Primary Field Name' => new LookupFieldModel(
                'Primary Field Name',
                'Primary Field Label'
            )
        };

        Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByLabel = new Map<String, LookupFieldModel> {
            'Valid Contact Lookup Field Label' => new LookupFieldModel(
                'Valid Contact Lookup Field Name',
                'Valid Contact Lookup Field Label'
            ),


            'Primary Field Label' => new LookupFieldModel(
                'Primary Field Name',
                'Primary Field Label'
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getValidContactPrimaryFieldHealthCheckGroupVModel(
                affiliationMappingsModelsList[0],
                accountlookupFieldOnContactFieldModelByName,
                accountlookupFieldOnContactFieldModelByLabel
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusPassed,
            1,
            1,
            0,
            1
        );

        AffiliationMappingsHCVMapper_TEST.validateHCItemAssertions(
            healthCheckGroupVModelResult,
            Label.stgHCAfflMapContactPrimaryFieldTitle,  
            'Pass',
            Label.stgHealthCheckStatusPassed,
            String.format(
                Label.stgHCAfflMapContactPrimaryFieldValid, 
                new List<Object> {
                    affiliationMappingsModelsList[0].primaryAffiliationField, 
                    affiliationMappingsModelsList[0].accountRecordTypeId}
            ),
            Label.stgHealthCheckFixNotApplicable,
            0
        );
    }

    /*****************************************************************************************
    * @description Test method to verify getValidContactPrimaryFieldHealthCheckGroupVModel returns a 
    * HealthCheckGroupVModel with a Passed status when an Primary Affilition field specified
    * in affiliation mappings matches the label name of a field that corresponds to a  
    * lookup to Account on Contact. 
    *****************************************************************************************/
    @isTest 
    private static void getValidContactPrimaryFieldHealthCheckGroupVModelValidByLabel() {
        LookupFieldService.instance = new STUB_LookupFieldServiceLabelMatch();

        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingsModelsList = new List<AffiliationMappingsModel> {
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                'Test Record Type Name', 
                'Valid Contact Lookup Field Name',
                true,
                'Test Status',
                'Test Role'
            )
        };

        Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByName = new Map<String, LookupFieldModel> {
            'Valid Contact Lookup Field Name' => new LookupFieldModel(
                'Valid Contact Lookup Field Name',
                'Valid Contact Lookup Field Label'
            ),

            'Primary Field Name' => new LookupFieldModel(
                'Primary Field Name',
                'Primary Field Label'
            )
        };

        Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByLabel = new Map<String, LookupFieldModel> {
            'Valid Contact Lookup Field Label' => new LookupFieldModel(
                'Valid Contact Lookup Field Name',
                'Valid Contact Lookup Field Label'
            ),


            'Primary Field Label' => new LookupFieldModel(
                'Primary Field Name',
                'Primary Field Label'
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getValidContactPrimaryFieldHealthCheckGroupVModel(
                affiliationMappingsModelsList[0],
                accountlookupFieldOnContactFieldModelByName,
                accountlookupFieldOnContactFieldModelByLabel
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusPassed,
            1,
            1,
            0,
            1
        );

        AffiliationMappingsHCVMapper_TEST.validateHCItemAssertions(
            healthCheckGroupVModelResult,
            Label.stgHCAfflMapContactPrimaryFieldTitle,  
            'Pass',
            Label.stgHealthCheckStatusPassed,
            String.format(
                Label.stgHCAfflMapContactPrimaryFieldValid, 
                new List<Object> {
                    affiliationMappingsModelsList[0].primaryAffiliationField, 
                    affiliationMappingsModelsList[0].accountRecordTypeId}
            ),
            Label.stgHealthCheckFixNotApplicable,
            0
        );
    }

    /*****************************************************************************************
    * @description Test method to verify getValidContactPrimaryFieldHealthCheckGroupVModel returns a 
    * HealthCheckGroupVModel with a Failed status when mapping specifies a 
    * Primary Affl Field that does not match a field on Contact (by dev name or label name).
    *****************************************************************************************/
    @isTest 
    private static void getValidContactPrimaryFieldHealthCheckGroupVModelNoContactFieldMatch() {
        LookupFieldService.instance = new STUB_LookupFieldServiceNull();

        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingsModelsList = new List<AffiliationMappingsModel> {
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                'Test Record Type Name', 
                'Test Primary Field',
                true,
                'Test Status',
                'Test Role'
            )
        };

        Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByName = new Map<String, LookupFieldModel> {
            'Primary Field Name 1' => new LookupFieldModel(
                'Primary Field Name 1',
                'Primary Field Label 1'
            ),

            'Primary Field Name 2' => new LookupFieldModel(
                'Primary Field Name 2',
                'Primary Field Label 2'
            )
        };

        Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByLabel = new Map<String, LookupFieldModel> {
            'Primary Field Label 1' => new LookupFieldModel(
                'Primary Field Name 1',
                'Primary Field Label 1'
            ),

            'Primary Field Label 2' => new LookupFieldModel(
                'Primary Field Name 2',
                'Primary Field Label 2'
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getValidContactPrimaryFieldHealthCheckGroupVModel(
                affiliationMappingsModelsList[0],
                accountlookupFieldOnContactFieldModelByName,
                accountlookupFieldOnContactFieldModelByLabel
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusFailed,
            0,
            1,
            0,
            1
        );

        AffiliationMappingsHCVMapper_TEST.validateHCItemAssertions(
            healthCheckGroupVModelResult,
            Label.stgHCAfflMapContactPrimaryFieldTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            String.format(
                Label.stgHCAfflMapContactPrimaryFieldInvalid, 
                new List<Object> {affiliationMappingsModelsList[0].primaryAffiliationField}
            ),
            String.format(
                Label.stgHCAfflMapContPrimaryFieldInvalidFix, 
                new List<Object> {affiliationMappingsModelsList[0].primaryAffiliationField}
            ),
            0
        ); 
    }

    /*****************************************************************************************
    * @description Test method to verify getHealthCheckItemVModelForAffiliationMappingsModel 
    * returns a HealthCheckItemVModel with the key set to affiliationMappingsModel.name when
    * there is no Account record type matching the RT specified in the affiliation mapping.
    *****************************************************************************************/
    private static void getHealthCheckItemVModelForAffiliationMappingsModelValidRT() {
        AffiliationMappingsModel affiliationMappingsModel = new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                '000000000000000007',
                'Test Primary Field',
                true,
                'Test Status',
                'Test Role'
            );

            RecordTypeModel recordTypeModel = new RecordTypeModel(
                '000000000000000007',
                'Inactive RecordType Name',
                'inactiveRTDevName',
                true
            );

        AffiliationMappingsHealthCheckVMapper affiliationMappingsHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        Test.startTest();
        HealthCheckItemVModel healthCheckItemVModel = 
            affiliationMappingsHealthCheckVMapperInstance.getHealthCheckItemVModelForAffiliationMappingsModel( 
                affiliationMappingsModel, 
                recordTypeModel
            );
        Test.stopTest();

        List<String> listForSettingsLabel =
            new List<String>{affiliationMappingsModel.name};
        
        String healthCheckItemSetting = String.format(
            Label.stgHCAffiliationMappingSettingHeading,
            listForSettingsLabel
        );
        
        System.assertEquals(recordTypeModel.name, healthCheckItemVModel.key);
        System.assertEquals(healthCheckItemSetting, healthCheckItemVModel.setting);
        System.assertEquals('Pass', healthCheckItemVModel.status);
        System.assertEquals(Label.stgHealthCheckStatusPassed, healthCheckItemVModel.statusLabel);
        System.assertEquals('', healthCheckItemVModel.description);
        System.assertEquals('', healthCheckItemVModel.recommendedFix);
        System.assertEquals(0, healthCheckItemVModel.healthCheckItemList.size());
    }
 
    /*****************************************************************************************
    * @description Test method to verify getValidContactPrimaryFieldHealthCheckGroupVModel returns a 
    * HealthCheckGroupVModel with a Failed status when mapping specifies a 
    * Primary Affl Field is empty.
    *****************************************************************************************/
    @isTest 
    private static void getValidContactPrimaryFieldHealthCheckGroupVModelNullField() {
        LookupFieldService.instance = new STUB_LookupFieldServiceNull();

        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingsModelsList = new List<AffiliationMappingsModel> {
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                'Test Record Type Name', 
                '',
                true,
                'Test Status',
                'Test Role'
            )
        };

        Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByName = new Map<String, LookupFieldModel> {
            'Primary Field Name 1' => new LookupFieldModel(
                'Primary Field Name 1',
                'Primary Field Label 1'
            ),

            'Primary Field Name 2' => new LookupFieldModel(
                'Primary Field Name 2',
                'Primary Field Label 2'
            )
        };

        Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByLabel = new Map<String, LookupFieldModel> {
            'Primary Field Label 1' => new LookupFieldModel(
                'Primary Field Name 1',
                'Primary Field Label 1'
            ),

            'Primary Field Label 2' => new LookupFieldModel(
                'Primary Field Name 2',
                'Primary Field Label 2'
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getValidContactPrimaryFieldHealthCheckGroupVModel(
                affiliationMappingsModelsList[0],
                accountlookupFieldOnContactFieldModelByName,
                accountlookupFieldOnContactFieldModelByLabel
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusFailed,
            0,
            1,
            0,
            1
        );

        AffiliationMappingsHCVMapper_TEST.validateHCItemAssertions(
            healthCheckGroupVModelResult,
            Label.stgHCAfflMapContactPrimaryFieldTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            String.format(
                Label.stgHCAfflMapContactPrimaryFieldInvalid, 
                new List<Object> {affiliationMappingsModelsList[0].primaryAffiliationField}
            ),
            String.format(
                Label.stgHCAfflMapContPrimaryFieldInvalidFix, 
                new List<Object> {affiliationMappingsModelsList[0].primaryAffiliationField}
            ),
            0
        );
    }


    /*****************************************************************************************
    * @description Test method to verify getHealthCheckItemVModelForAffiliationMappingsModel 
    * returns a HealthCheckItemVModel with the key set to affiliationMappingsModel.name when
    * there is no Account record type matching the RT specified in the affiliation mapping.
    *****************************************************************************************/
    private static void getHealthCheckItemVModelForAffiliationMappingsModelNullRT() {
        AffiliationMappingsModel affiliationMappingsModel = new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                '000000000000000007',
                'Test Primary Field',
                true,
                'Test Status',
                'Test Role'
            );

        RecordTypeModel recordTypeModel = null;

        AffiliationMappingsHealthCheckVMapper affiliationMappingsHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        Test.startTest();
        HealthCheckItemVModel healthCheckItemVModel = 
            affiliationMappingsHealthCheckVMapperInstance.getHealthCheckItemVModelForAffiliationMappingsModel( 
                affiliationMappingsModel, 
                recordTypeModel
            );
        Test.stopTest();

        List<String> listForSettingsLabel =
            new List<String>{affiliationMappingsModel.name};
        
        String healthCheckItemSetting = String.format(
            Label.stgHCAffiliationMappingSettingHeading,
            listForSettingsLabel
        );
        
        System.assertEquals(affiliationMappingsModel.name, healthCheckItemVModel.key);
        System.assertEquals(healthCheckItemSetting, healthCheckItemVModel.setting);
        System.assertEquals('Pass', healthCheckItemVModel.status);
        System.assertEquals(Label.stgHealthCheckStatusPassed, healthCheckItemVModel.statusLabel);
        System.assertEquals('', healthCheckItemVModel.description);
        System.assertEquals('', healthCheckItemVModel.recommendedFix);
        System.assertEquals(0, healthCheckItemVModel.healthCheckItemList.size());
    }

    /***************************************************************************
    * @description Test method to verify that
    * getAffiliationMappingsHealthCheckResults returns the expected failed health
    * check
    ***************************************************************************/
    @isTest
    private static void getAffiliationMappingsHealthCheckResultsPass() {

        STUB_AffiliationMappingsService affiliationMappingsServiceStub = 
            new STUB_AffiliationMappingsService();

        STUB_RecordTypeService recordTypeServiceStub = 
            new STUB_RecordTypeService();

        AffiliationMappingsHealthCheckVMapper.instance = 
            new STUB_AffiliationMappingsHealthCheckVMapperSub();
        
        AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperInstance =
            AffiliationMappingsHealthCheckVMapper.getInstance();
        
        AffiliationMappingsModel affiliationMappingsModel =
            affiliationMappingsServiceStub.getAffiliationMappingsModels()[0];

        Map<Id, RecordTypeModel> recordTypeModelsById = 
            recordTypeServiceStub.getModelByIdMapForSObjectType(Account.SObjectType);
        
        Integer numberOfHealthChecks = 3; // TODO: Increment when adding health checks

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            affiliationMappingsHealthCheckVMapperInstance.getAffiliationMappingsHealthCheckResults(
                affiliationMappingsModel,
                recordTypeModelsById,
                new Map<String, LookupFieldModel>(),
                new Map<String, LookupFieldModel>(),
                new Map<String, PicklistEntryModel>(),
                new Map<String, PicklistEntryModel>()
            );
        Test.stopTest();

        System.assertEquals(
            '',
            healthCheckGroupVModelResult.label,
            'Label should equal expected value of blank'
        );
        System.assertEquals(
            '',
            healthCheckGroupVModelResult.status,
            'Status should equal expected value of blank'
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModelResult.passedChecks,
            'Passed checks should equal expected value of ' + numberOfHealthChecks
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModelResult.totalChecks,
            'Total checks should equal expected value of ' + numberOfHealthChecks
        );
        System.assertEquals(
            0,
            healthCheckGroupVModelResult.expandedRowsList.size(),
            'Expanded rows list should have a size of 0'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModelResult.healthCheckItemList.size(),
            'Health Check Item list should have a size of 1'
        );
    }

    /***************************************************************************
    * @description Test method to verify that
    * getAffiliationMappingsHealthCheckResults returns the expected failed health
    * check
    ***************************************************************************/
    @isTest
    private static void getAffiliationMappingsHealthCheckResultsFail() {
        String prefix = UTIL_Namespace.StrTokenNSPrefix('');

        List<Affl_Mappings__c> affiliationMappingsList = new List<Affl_Mappings__c>();
        affiliationMappingsList.add(
            new Affl_Mappings__c(
                Name = 'Test Account', 
                Account_Record_Type__c = 'Test Record Type', 
                Primary_Affl_Field__c = prefix + 'Test_Organization__c'));
        insert affiliationMappingsList;

        STUB_AffiliationMappingsService affiliationMappingsServiceStub = 
            new STUB_AffiliationMappingsService();

        STUB_RecordTypeService recordTypeServiceStub = 
            new STUB_RecordTypeService();

        AffiliationMappingsHealthCheckVMapper.instance = 
            new STUB_AffiliationMappingsHealthCheckVMapperSubFail();
        
        AffiliationMappingsHealthCheckVMapper affiliationMappingsHealthCheckVMapperInstance =
            AffiliationMappingsHealthCheckVMapper.getInstance();
        
        AffiliationMappingsModel affiliationMappingsModel = 
            affiliationMappingsHealthCheckVMapperInstance.locateAffiliationMappingsService().getAffiliationMappingsModels()[0];

        Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>();
        
        Integer numberOfHealthChecks = 3; // TODO: Increment when adding health checks

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            affiliationMappingsHealthCheckVMapperInstance.getAffiliationMappingsHealthCheckResults(
                affiliationMappingsModel,
                recordTypeModelsById,
                new Map<String, LookupFieldModel>(),
                new Map<String, LookupFieldModel>(),
                new Map<String, PicklistEntryModel>(),
                new Map<String, PicklistEntryModel>()
            );
        Test.stopTest();

        System.assertEquals(
            '',
            healthCheckGroupVModelResult.label,
            'Label should equal expected value of blank'
        );
        System.assertEquals(
            '',
            healthCheckGroupVModelResult.status,
            'Status should equal expected value of blank'
        );
        System.assertEquals(
            0,
            healthCheckGroupVModelResult.passedChecks,
            'Passed checks should equal expected value of 0.'
        );
        System.assertEquals(
            numberOfHealthChecks,
            healthCheckGroupVModelResult.totalChecks,
            'Total checks should equal expected value of ' + numberOfHealthChecks
        );
        System.assertEquals(
            1,
            healthCheckGroupVModelResult.expandedRowsList.size(),
            'Expanded rows list should have a size of 1.'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModelResult.healthCheckItemList.size(),
            'Health Check Item list should have a size of 1'
        );
    }



    /*****************************************************************************************
    * @description Test method to verify getActiveExistingRoleHealthCheckGroupVModel returns a 
    * HealthCheckGroupVModel with a Passed status when the Auto Enrollment Role is populated and
    * corresponds to a value in the Role picklist field on Affiliation__c that is active.
    *****************************************************************************************/
    @isTest 
    private static void getActiveExistingRoleHealthCheckGroupVModelValidAndActivePicklistField() {
        PicklistEntryService.instance = new STUB_PicklistEntryServiceValid();

        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingsModelsList = new List<AffiliationMappingsModel> {
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                'Test Record Type Name', 
                '',
                true,
                'Test Status',
                'Test Auto Enrollment Role'
            )
        };

        Map<String, PicklistEntryModel> affiliationRolePicklistEntryModelByName = new Map<String, PicklistEntryModel> {
            'Test Auto Enrollment Role' => new PicklistEntryModel(
                'Test Auto Enrollment Role',
                'Auto Enrollment Role Label',
                true
            ),

            'Auto Enrollment Role Name 2' => new PicklistEntryModel(
                'Auto Enrollment Role Name 2',
                'Auto Enrollment Role Label 2',
                true
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getActiveExistingRoleHealthCheckGroupVModel(
                affiliationMappingsModelsList[0],
                affiliationRolePicklistEntryModelByName
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusPassed,
            1,
            1,
            0,
            1
        );

        AffiliationMappingsHCVMapper_TEST.validateHCItemAssertions(
            healthCheckGroupVModelResult,
            Label.stgHCAfflMapAutoEnrollRoleTitle,
            'Pass',
            Label.stgHealthCheckStatusPassed,
            String.format(
                Label.stgHCAfflMapAutoEnrollRoleValid, 
                new List<Object> {
                    affiliationRolePicklistEntryModelByName.get(affiliationMappingsModelsList[0].autoProgramEnrollmentRole).label, 
                    affiliationRolePicklistEntryModelByName.get(affiliationMappingsModelsList[0].autoProgramEnrollmentRole).name
                }
            ),
            Label.stgHealthCheckFixNotApplicable,
            0
        ); 
    }
    
    /*****************************************************************************************
    * @description Test method to verify getActiveExistingRoleHealthCheckGroupVModel returns a 
    * HealthCheckGroupVModel with a Failed status when the Auto Enrollment Role is populated and
    * corresponds to a value in the Role picklist field on Affiliation__c that is inactive.
    *****************************************************************************************/
    @isTest 
    private static void getActiveExistingRoleHealthCheckGroupVModelValidAndInActivePicklistField() {
        PicklistEntryService.instance = new STUB_PicklistEntryServiceInactive();

        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingsModelsList = new List<AffiliationMappingsModel> {
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                'Test Record Type Name', 
                '',
                true,
                'Test Status',
                'Test Auto Enrollment Role'
            )
        };

        Map<String, PicklistEntryModel> affiliationRolePicklistEntryModelByName = new Map<String, PicklistEntryModel> {
            'Test Auto Enrollment Role' => new PicklistEntryModel(
                'Test Auto Enrollment Role',
                'Auto Enrollment Role Label',
                false
            ),

            'Auto Enrollment Role Name 2' => new PicklistEntryModel(
                'Auto Enrollment Role Name 2',
                'Auto Enrollment Role Label 2',
                true
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getActiveExistingRoleHealthCheckGroupVModel(
                affiliationMappingsModelsList[0],
                affiliationRolePicklistEntryModelByName
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusFailed,
            0,
            1,
            0,
            1
        );

        AffiliationMappingsHCVMapper_TEST.validateHCItemAssertions(
            healthCheckGroupVModelResult,
            Label.stgHCAfflMapAutoEnrollRoleTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            String.format(
                Label.stgHCAfflMapAutoEnrollRoleInactive, 
                new List<Object> {
                    affiliationMappingsModelsList[0].autoProgramEnrollmentRole, 
                    affiliationRolePicklistEntryModelByName.get(affiliationMappingsModelsList[0].autoProgramEnrollmentRole).name
                }
            ),
            String.format(
                Label.stgHCAfflMapAutoEnrollRoleInactiveFix, 
                new List<Object> {
                    affiliationMappingsModelsList[0].autoProgramEnrollmentRole, 
                    affiliationRolePicklistEntryModelByName.get(affiliationMappingsModelsList[0].autoProgramEnrollmentRole).name
                }
            ),
            0
        ); 
    }

    /*****************************************************************************************
    * @description Test method to verify getActiveExistingRoleHealthCheckGroupVModel returns a 
    * HealthCheckGroupVModel with a Failed status when the Auto Enrollment Role is populated and
    * does not correspond to a value in the Role picklist field on Affiliation__c.
    *****************************************************************************************/
    @isTest 
    private static void getActiveExistingRoleHealthCheckGroupVModelInvalidPicklistField() {
        PicklistEntryService.instance = new STUB_PicklistEntryServiceNull();

        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingsModelsList = new List<AffiliationMappingsModel> {
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                'Test Record Type Name', 
                '',
                true,
                'Test Status',
                'Invalid Auto Enrollment Role'
            )
        };

        Map<String, PicklistEntryModel> affiliationRolePicklistEntryModelByName = new Map<String, PicklistEntryModel> {
            'Test Auto Enrollment Role' => new PicklistEntryModel(
                'Test Auto Enrollment Role',
                'Auto Enrollment Role Label',
                true
            ),

            'Auto Enrollment Role Name 2' => new PicklistEntryModel(
                'Auto Enrollment Role Name 2',
                'Auto Enrollment Role Label 2',
                true
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getActiveExistingRoleHealthCheckGroupVModel(
                affiliationMappingsModelsList[0],
                affiliationRolePicklistEntryModelByName
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusFailed,
            0,
            1,
            0,
            1
        );

        AffiliationMappingsHCVMapper_TEST.validateHCItemAssertions(
            healthCheckGroupVModelResult,
            Label.stgHCAfflMapAutoEnrollRoleTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            String.format(
                Label.stgHCAfflMapAutoEnrollRoleNotFound, 
                new List<Object> {affiliationMappingsModelsList[0].autoProgramEnrollmentRole}
            ),
            Label.stgHCAfflMapAutoEnrollRoleNotFoundFix,
            0
        ); 
    }

    /*****************************************************************************************
    * @description Test method to verify getActiveExistingRoleHealthCheckGroupVModel returns an
    * empty HealthCheckGroupVModel with a Passed status when the Auto Enrollment Role is not 
    * populated for an affiliation mapping.
    *****************************************************************************************/
    @isTest 
    private static void getActiveExistingRoleHealthCheckGroupVModelBlankRole() {
        PicklistEntryService.instance = new STUB_PicklistEntryServiceNull();

        AffiliationMappingsHealthCheckVMapper afflMappingHealthCheckVMapperInstance = 
            AffiliationMappingsHealthCheckVMapper.getInstance();

        List<AffiliationMappingsModel> affiliationMappingsModelsList = new List<AffiliationMappingsModel> {
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                'Test Record Type Name', 
                '',
                true,
                'Test Status',
                ''
            )
        };

        Map<String, PicklistEntryModel> affiliationRolePicklistEntryModelByName = new Map<String, PicklistEntryModel> {
            'Test Auto Enrollment Role' => new PicklistEntryModel(
                'Test Auto Enrollment Role',
                'Auto Enrollment Role Label',
                true
            ),

            'Auto Enrollment Role Name 2' => new PicklistEntryModel(
                'Auto Enrollment Role Name 2',
                'Auto Enrollment Role Label 2',
                true
            )
        };

        Test.startTest();
        HealthCheckGroupVModel healthCheckGroupVModelResult = 
            afflMappingHealthCheckVMapperInstance.getActiveExistingRoleHealthCheckGroupVModel(
                affiliationMappingsModelsList[0],
                affiliationRolePicklistEntryModelByName
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateHCGroupAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusPassed,
            0,
            0,
            0,
            0
        );
    }

    /**************************************************************************************
    ********************************* HELPER METHODS **************************************
    **************************************************************************************/

    /**************************************************************************************
    * @description Helper method to validate test assertions for HealthCheckGroup
    **************************************************************************************/ 
    private static void validateHCGroupAssertions(
        HealthCheckGroupVModel healthCheckGroupVModelResult,
        String expectedHealthCheckGroupLabel,
        String expectedHealthCheckGroupStatus,
        Integer expectedPassedChecksCount,
        Integer expectedTotalChecksCount,
        Integer expectedExpandedListSize,
        Integer expectedHealthCheckItemsListSize
    ) {
        System.assertEquals(
            expectedHealthCheckGroupLabel, 
            healthCheckGroupVModelResult.label, 
            'Label should be \'' + expectedHealthCheckGroupLabel + '\'.'
        );

        System.assertEquals(
            expectedHealthCheckGroupStatus, 
            healthCheckGroupVModelResult.status, 
            'Status should be \'' + expectedHealthCheckGroupStatus + '\'.'
        );

        System.assertEquals(
            expectedPassedChecksCount, 
            healthCheckGroupVModelResult.passedChecks, 
            'Passed checks count should be ' + expectedPassedChecksCount + '.'
        );

        System.assertEquals(
            expectedTotalChecksCount, 
            healthCheckGroupVModelResult.totalChecks, 
            'Total checks count should be ' + expectedTotalChecksCount + '.'
        );

        System.assertEquals(
            expectedExpandedListSize, 
            healthCheckGroupVModelResult.expandedRowsList.size(), 
            'ExpandedRows list should have ' + expectedExpandedListSize + ' elements.'
        );

        System.assertEquals(
            expectedHealthCheckItemsListSize, 
            healthCheckGroupVModelResult.healthCheckItemList.size(), 
            'HealthCheckItems list should have ' + expectedHealthCheckItemsListSize + ' elements.'
        );
    }

    /**************************************************************************************
    * @description Helper method to validate test assertions for HealthCheckItem
    **************************************************************************************/ 
    private static void validateHCItemAssertions(
        HealthCheckGroupVModel healthCheckGroupVModelResult,
        String expectedHealthCheckItemSetting,
        String expectedHealthCheckItemStatus,
        String expectedHealthCheckItemStatusLabel,
        String expectedHealthCheckItemDescription,
        String expectedHealthCheckItemFix,
        Integer expectedHealtCheckItemSublistSize
    ) {
        System.assertEquals(
            expectedHealthCheckItemSetting, 
            healthCheckGroupVModelResult.healthCheckItemList[0].setting, 
            'HealthCheckItem setting should be \'' + expectedHealthCheckItemSetting + '\'.'
        );  
        
        System.assertEquals(
            expectedHealthCheckItemStatus, 
            healthCheckGroupVModelResult.healthCheckItemList[0].status, 
            'HealthCheckItem status should be \'' + expectedHealthCheckItemStatus + '\'.'
        ); 

        System.assertEquals(
            expectedHealthCheckItemStatusLabel, 
            healthCheckGroupVModelResult.healthCheckItemList[0].statusLabel, 
            'HealthCheckItem statusLabel should be \'' + expectedHealthCheckItemStatusLabel + '\'.'
        ); 
        
        System.assertEquals(
            expectedHealthCheckItemDescription, 
            healthCheckGroupVModelResult.healthCheckItemList[0].description, 
            'HealthCheckItem statusLabel should be \'' + expectedHealthCheckItemDescription + '\'.'
        ); 

        System.assertEquals(
            expectedHealthCheckItemFix, 
            healthCheckGroupVModelResult.healthCheckItemList[0].recommendedFix, 
            'HealthCheckItem statusLabel should be \'' + expectedHealthCheckItemFix + '\'.'
        ); 

        System.assertEquals(
            expectedHealtCheckItemSublistSize, 
            healthCheckGroupVModelResult.healthCheckItemList[0].healthCheckItemList.size(), 
            'HealthCheckItem statusLabel should be \'' + expectedHealtCheckItemSublistSize + '\'.'
        ); 
    }

    /***************************************************************************
    *********************************STUBS**************************************
    ***************************************************************************/

    /***************************************************************************
    * @description Stub class to simulate the response from
    * AffiliationMappingsHealthCheckVMapper to return a passing result for
    * getAffiliationMappingsHealthCheckResults
    ***************************************************************************/
    private class STUB_AffiliationMappingsHealthCheckVMapperPass extends AffiliationMappingsHealthCheckVMapper {
        private override HealthCheckGroupVModel getValidRecordTypeHealthCheckGroupVModel(
            AffiliationMappingsModel affiliationMappingsModel, 
            Map<Id,RecordTypeModel> recordTypeModelsById
        ) {
            return new HealthCheckGroupVModel(
                'Account RT Health Check', 
                'Pass', 
                1, 
                1, 
                new List<String>(), 
                new List<HealthCheckItemVModel>{
                    new HealthCheckItemVModel(
                        'test key 1', 
                        'test setting', 
                        'Pass', 
                        Label.stgHealthCheckStatusPassed,
                        'test description', 
                        'test fix',
                        new List<HealthCheckItemVModel>()
                    ) 
                }
            );
        }

        private override HealthCheckGroupVModel getValidContactPrimaryFieldHealthCheckGroupVModel(
            AffiliationMappingsModel affiliationMappingsModel,
            Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByName,
            Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByLabel
        ) {
            return new HealthCheckGroupVModel(
                'Contact Primary Field Health Check', 
                'Pass', 
                1, 
                1, 
                new List<String>(), 
                new List<HealthCheckItemVModel>{
                    new HealthCheckItemVModel(
                        'test key 2', 
                        'test setting', 
                        'Pass', 
                        Label.stgHealthCheckStatusPassed,
                        'test description', 
                        'test fix',
                        new List<HealthCheckItemVModel>()
                    ) 
                }
            );
        }

        private override HealthCheckGroupVModel getActiveExistingRoleHealthCheckGroupVModel(
            AffiliationMappingsModel affiliationMappingsModel,
            Map<String, PicklistEntryModel> picklistEntryModelByName
        ) {
            return new HealthCheckGroupVModel(
                'Contact Primary Field Health Check', 
                'Pass', 
                1, 
                1, 
                new List<String>(), 
                new List<HealthCheckItemVModel>{
                    new HealthCheckItemVModel(
                        'test key 2', 
                        'test setting', 
                        'Pass', 
                        Label.stgHealthCheckStatusPassed,
                        'test description', 
                        'test fix',
                        new List<HealthCheckItemVModel>()
                    ) 
                }
            );
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * AffiliationMappingsHealthCheckVMapper to return a failing result for
    * getAffiliationMappingsHealthCheckResults
    ***************************************************************************/
    private class STUB_AffiliationMappingsHealthCheckVMapperFail extends AffiliationMappingsHealthCheckVMapper {
        private override HealthCheckGroupVModel getValidRecordTypeHealthCheckGroupVModel(
            AffiliationMappingsModel affiliationMappingsModel, 
            Map<Id,RecordTypeModel> recordTypeModelsById
        ) {
            return new HealthCheckGroupVModel(
                'Account RT Health Check', 
                'Fail', 
                0, 
                1, 
                new List<String>(), 
                new List<HealthCheckItemVModel>{
                    new HealthCheckItemVModel(
                        'test key 1', 
                        'test setting', 
                        'Fail', 
                        Label.stgHealthCheckStatusFailed,
                        'test description', 
                        'test fix',
                        new List<HealthCheckItemVModel>()
                    ) 
                }
            );
        }

        private override HealthCheckGroupVModel getValidContactPrimaryFieldHealthCheckGroupVModel(
            AffiliationMappingsModel affiliationMappingsModel,
            Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByName,
            Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByLabel
        ) {
            return new HealthCheckGroupVModel(
                'Contact Primary Field Health Check', 
                'Fail', 
                0, 
                1, 
                new List<String>(), 
                new List<HealthCheckItemVModel>{
                    new HealthCheckItemVModel(
                        'test key 2', 
                        'test setting', 
                        'Fail', 
                        Label.stgHealthCheckStatusFailed,
                        'test description', 
                        'test fix',
                        new List<HealthCheckItemVModel>()
                    ) 
                }
            );
        }

        private override HealthCheckGroupVModel getActiveExistingRoleHealthCheckGroupVModel(
            AffiliationMappingsModel affiliationMappingsModel,
            Map<String, PicklistEntryModel> picklistEntryModelByName
        ) {
            return new HealthCheckGroupVModel(
                'Auto Enrollment Role Health Check', 
                'Fail', 
                0, 
                1, 
                new List<String>(), 
                new List<HealthCheckItemVModel>{
                    new HealthCheckItemVModel(
                        'test key 3', 
                        'test setting', 
                        'Fail', 
                        Label.stgHealthCheckStatusFailed,
                        'test description', 
                        'test fix',
                        new List<HealthCheckItemVModel>()
                    ) 
                }
            );
        }

                //TODO: add override for status 

    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * AffiliationMappingsHealthCheckVMapper to control individual health check methods
    * for failure
    ***************************************************************************/
    private class STUB_AffiliationMappingsHealthCheckVMapperSubFail extends AffiliationMappingsHealthCheckVMapper {
        private override HealthCheckGroupVModel getValidRecordTypeHealthCheckGroupVModel(
            AffiliationMappingsModel affiliationMappingModel, 
            Map<Id,RecordTypeModel> recordTypeModelsById
        ) {
            return new HealthCheckGroupVModel(
                'Failed Health Check 1', 
                'Fail', 
                0, 
                1, 
                new List<String>(), 
                new List<HealthCheckItemVModel>()
            );
        }

        private override HealthCheckGroupVModel getActiveExistingRoleHealthCheckGroupVModel(
            AffiliationMappingsModel affiliationMappingsModel,
            Map<String, PicklistEntryModel> picklistEntryModelByName
        ) {
            return new HealthCheckGroupVModel(
                'Failed Health Check 2', 
                'Fail', 
                0, 
                1, 
                new List<String>(), 
                new List<HealthCheckItemVModel>()
            );
        }

                //TODO: add override for status 

    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * AffiliationMappingsHealthCheckVMapper to control individual health check methods
    * for success
    ***************************************************************************/
    private class STUB_AffiliationMappingsHealthCheckVMapperSub extends AffiliationMappingsHealthCheckVMapper {
        private override HealthCheckGroupVModel getValidRecordTypeHealthCheckGroupVModel(
            AffiliationMappingsModel affiliationMappingsModel, 
            Map<Id,RecordTypeModel> recordTypeModelsById
        ) {
            return this.mockCheck(affiliationMappingsModel);
        }

        private override HealthCheckGroupVModel getValidContactPrimaryFieldHealthCheckGroupVModel(
            AffiliationMappingsModel affiliationMappingsModel, 
            Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByName,
            Map<String, LookupFieldModel> accountlookupFieldOnContactFieldModelByLabel
        ) {
            return this.mockCheck(affiliationMappingsModel);
        }

        private override HealthCheckGroupVModel getActiveExistingRoleHealthCheckGroupVModel(
            AffiliationMappingsModel affiliationMappingsModel,
            Map<String, PicklistEntryModel> picklistEntryModelByName
        ) {
            return this.mockCheck(affiliationMappingsModel);
        }
        
        //TODO: add override for status 

        private HealthCheckGroupVModel mockCheck(AffiliationMappingsModel affiliationMappingModel) {
            HealthCheckGroupVModel healthCheckGroupVModel = new HealthCheckGroupVModel(
                '',
                '',
                0,
                0,
                new List<String>(),
                new List<HealthCheckItemVModel>()
            );
    
            HealthCheckItemVModel healthCheckItemVModel =
                new healthCheckItemVModel(
                    'Mock',
                    'MockSetting',
                    'Pass',
                    'MockStatusLabel',
                    'MockDescription',
                    'MockRecommendedFix',
                    new List<HealthCheckItemVModel>()
                );

            healthCheckGroupVModel.totalChecks += 1;

            if(affiliationMappingModel != null) {
                healthCheckGroupVModel.passedChecks += 1;
            }

            if(healthCheckGroupVModel.passedChecks < healthCheckGroupVModel.totalChecks) {
                healthCheckItemVModel.status = 'Fail';
                healthCheckItemVModel.statusLabel = Label.stgHealthCheckStatusFailed;
            }
    
            healthCheckGroupVModel.healthCheckItemList.add(healthCheckItemVModel);
            return healthCheckGroupVModel;
        }
    }

    private class STUB_LookupFieldService extends LookupFieldService {
        public override Map<String, LookupFieldModel> getModelByNameMapForSObjectType(
            SObjectType sObjectType, 
            SObjectType lookupToSObjectType
        ) {
            return new Map<String, LookupFieldModel>{
                'Test_Field__c' => new LookupFieldModel(
                    'Test_Field__c',
                    'Test Field'
                )
            };
        }
    }

    private class STUB_PicklistEntryServiceRole extends PickListEntryService {
        public override Map<String,PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            return new Map<String, PicklistEntryModel>{
                'Test_Role' => new PicklistEntryModel(
                    'Test_Role',
                    'Test Role', 
                    true)
            };
        }
    }

    // TODO: stub picklist Entry Service for Status

    /***************************************************************************
    * @description Stub class to simulate the response from
    * AffiliationMappingsService to return a predetermined set of models.
    ***************************************************************************/
    private class STUB_AffiliationMappingsService extends AffiliationMappingsService {
        public override List<AffiliationMappingsModel> getAffiliationMappingsModels() {
            List<AffiliationMappingsModel> AffiliationMappingsModelList =
                new List<AffiliationMappingsModel>();
            
            AffiliationMappingsModel AffiliationMappingsModel = 
                new AffiliationMappingsModel(
                    'testName',
                    '000000000000000001',
                    'testPrimaryAfflField',
                    true,
                    'testStatus',
                    'testRole'
                );

            AffiliationMappingsModelList.add(AffiliationMappingsModel);

            return AffiliationMappingsModelList;
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * AffiliationMappingsService to return a predetermined set of unfound
    * models.
    ***************************************************************************/
    private class STUB_AffiliationMappingsServiceUnfound extends AffiliationMappingsService {
        public override List<AffiliationMappingsModel> getAffiliationMappingsModels() {
            List<AffiliationMappingsModel> affiliationMappingsModelsList = new List<AffiliationMappingsModel>();

            affiliationMappingsModelsList.add(
                new AffiliationMappingsModel(
                    'unfound name',
                    'unfound accountRecordTypeId',
                    'unfound primaryAffiliationField',
                    true,
                    'unfound autoProgramEnrollmentStatus',
                    'unfound autoProgramEnrollmentRole'
                )
            );

            return affiliationMappingsModelsList;
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * RecordTypeService to return a predetermined set of active models.
    ***************************************************************************/
    private class STUB_RecordTypeService extends RecordTypeService {
        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            Map<Id, RecordTypeModel> recordTypeModelById =
                new Map<Id, RecordTypeModel>();
            
            recordTypeModelById.put('000000000000000001', new RecordTypeModel(
                '000000000000000001',
                'Active RecordType Test Name1',
                'activeRTTestDeveloperName1',
                true
            ));         
                 
            recordTypeModelById.put('000000000000000002', new RecordTypeModel(
                '000000000000000002',
                'Active RecordType Test Name2',
                'activeRTTestDeveloperName2',
                true
            ));         

            recordTypeModelById.put('000000000000000003', new RecordTypeModel(
                '000000000000000003',
                'Active RecordType Test Name3',
                'activeRTTestDeveloperName3',
                true
            ));         
            
            return recordTypeModelById;
        }

        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            return new RecordTypeModel(
                '000000000000000006',
                'Active RecordType Name',
                'activeRTDevName',
                true
            );
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * RecordTypeService to return a predetermined set of inactive models.
    ***************************************************************************/
    private class STUB_RecordTypeServiceInactive extends RecordTypeService {
        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            Map<Id, RecordTypeModel> recordTypeModelById =
                new Map<Id, RecordTypeModel>();
            
            recordTypeModelById.put('000000000000000001', new RecordTypeModel(
                '000000000000000001',
                'Inactive RecordType Test Name1',
                'InactiveRTTestDeveloperName1',
                false
            ));         
                 
            recordTypeModelById.put('000000000000000002', new RecordTypeModel(
                '000000000000000002',
                'Inactive RecordType Test Name2',
                'InactiveRTTestDeveloperName2',
                false
            ));         

            recordTypeModelById.put('000000000000000003', new RecordTypeModel(
                '000000000000000003',
                'Inactive RecordType Test Name3',
                'InactiveRTTestDeveloperName3',
                false
            ));         
            
            return recordTypeModelById;
        }

        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            return new RecordTypeModel(
                '000000000000000005',
                'Inactive RecordType Name',
                'inactiveRTDevName',
                false
            );
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * RecordTypeService to return a null value.
    ***************************************************************************/
    private class STUB_RecordTypeServiceNull extends RecordTypeService {
        public override RecordTypeModel getRecordTypeModelFromMap(String recordTypeId, Map<Id, RecordTypeModel> recordTypeModelById) { 
            return null;
        }

        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            return new Map<Id, RecordTypeModel>{
               '000000000000000009' => new RecordTypeModel(
                                            '000000000000000009',
                                            'random test acct record type',
                                            'randomAcctRT',
                                            true
                                       )
            };
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * LookupFieldService to return a valid lookup field model for a Contact
    * field that is a lookup to Account matching my field dev name.
    ***************************************************************************/
    private class STUB_LookupFieldServiceDevNameMatch extends LookupFieldService {
        public override LookupFieldModel getLookupFieldModelFromNameMap(
            String fieldName, 
            Map<String, LookupFieldModel> lookupFieldModelByName
        ){
            return new LookupFieldModel(
                'Valid Contact Lookup Field Name',
                'Valid Contact Lookup Field Label'
            );
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * LookupFieldService to return a valid lookup field model for a Contact
    * field that is a lookup to Account matching my field label name.
    ***************************************************************************/
    private class STUB_LookupFieldServiceLabelMatch extends LookupFieldService {
        public override LookupFieldModel getLookupFieldModelFromNameMap(
            String fieldName, 
            Map<String, LookupFieldModel> lookupFieldModelByName 
        ){
            return null;
        }
        
        public override LookupFieldModel getLookupFieldModelFromLabelMap(
            String fieldLabel, 
            Map<String, LookupFieldModel> lookupFieldModelByLabel) 
        {
            return new LookupFieldModel(
                'Valid Contact Lookup Field Name',
                'Valid Contact Lookup Field Label'
            );
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from
    * LookupFieldService to return a null value.
    ***************************************************************************/
    private class STUB_LookupFieldServiceNull extends LookupFieldService {
        public override LookupFieldModel getLookupFieldModelFromNameMap(
            String fieldName, 
            Map<String, LookupFieldModel> lookupFieldModelByName) 
        {
            return null;
        }

        public override LookupFieldModel getLookupFieldModelFromLabelMap(
            String fieldLabel, 
            Map<String, LookupFieldModel> lookupFieldModelByLabel) 
        {
            return null;
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from PicklistEntryService
    * to return a PicklistEntryModel for a valid and active picklist value.
    ***************************************************************************/
    private class STUB_PicklistEntryServiceValid extends PicklistEntryService {
        public override Map<String,PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            return new Map<String,PicklistEntryModel>{
                'Test Auto Enrollment Role' => new PicklistEntryModel(
                'Test Auto Enrollment Role',
                'Auto Enrollment Role Label',
                true)
            };
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from PicklistEntryService
    * to return a PicklistEntryModel for a valid, but inactive picklist value.
    ***************************************************************************/
    private class STUB_PicklistEntryServiceInactive extends PicklistEntryService {
        public override Map<String,PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            return new Map<String,PicklistEntryModel>{
                'Test Auto Enrollment Role' => new PicklistEntryModel(
                'Test Auto Enrollment Role',
                'Auto Enrollment Role Label',
                false)
            };
        }
    }

    /***************************************************************************
    * @description Stub class to simulate the response from PicklistEntryService 
    * to return a null value.
    ***************************************************************************/
    private class STUB_PicklistEntryServiceNull extends PicklistEntryService {
        public override Map<String,PicklistEntryModel> getModelsByNameForSObjectField(
            SObjectType sObjectTypeName,
            SObjectField SObjectFieldName
        ) {
            return null;
        }
    }
}
