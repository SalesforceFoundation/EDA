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
            AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperInstance = AffiliationMappingsHealthCheckVMapper.getInstance();
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
            AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperInstance1 = AffiliationMappingsHealthCheckVMapper.getInstance();
            AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperInstance2 = AffiliationMappingsHealthCheckVMapper.getInstance();
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

    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles all
    * passed health checks
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupAllPassed() {
        AffiliationMappingsService.instance = 
            new STUB_AffiliationMappingsService();
        RecordTypeService.instance =
            new STUB_RecordTypeService();

        AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperStub =
            new STUB_AffiliationMappingsHealthCheckVMapper();
        AffiliationMappingsHealthCheckVMapper.instance = AffiliationMappingsHealthCheckVMapperStub;  

        AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapper =
            AffiliationMappingsHealthCheckVMapper.getInstance();

        Integer numberOfHealthChecks = 1;

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
            1,
            healthCheckGroupVModel.healthCheckItemList.size(),
            'Number of health check items of returned health check should be 1.'
        );
    }

    /***************************************************************************
    * @description Test method to verify that getHealthCheckGroup handles all
    * passed health checks
    ***************************************************************************/
    @isTest
    private static void getHealthCheckGroupAllFail() {
        AffiliationMappingsService.instance = 
            new STUB_AffiliationMappingsServiceUnfound();
        RecordTypeService.instance =
            new STUB_RecordTypeService();

        AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapperStub =
            new STUB_AffiliationMappingsHealthCheckVMapper();

        AffiliationMappingsHealthCheckVMapper.instance = AffiliationMappingsHealthCheckVMapperStub;  

        AffiliationMappingsHealthCheckVMapper AffiliationMappingsHealthCheckVMapper =
            AffiliationMappingsHealthCheckVMapper.getInstance();

        Integer numberOfHealthChecks = 1;

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
            0,
            healthCheckGroupVModel.expandedRowsList.size(),
            'All health checks should fail, making expanded rows list size 0.'
        );
        System.assertEquals(
            1,
            healthCheckGroupVModel.healthCheckItemList.size(),
            'Number of health check items of returned health check should be 1.'
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

        List<AffiliationMappingsModel> affiliationMappingModels = new List<AffiliationMappingsModel>{
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                '000000000000000006',
                'Test Primary Field',
                true,
                'Test Status',
                'Test Role'
            )
        };

        Map<Id,RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{
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
                affiliationMappingModels,
                recordTypeModelsById
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusPassed,
            1,
            1,
            0,
            1,
            Label.stgHCAfflMapAccRecordTypeTitle,
            'Pass',
            Label.stgHealthCheckStatusPassed,
            String.format(
                Label.stgHCRecordTypeValid, 
                new List<Object>{'Active RecordType Name', 'activeRTDevName'}
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

        List<AffiliationMappingsModel> affiliationMappingModels = new List<AffiliationMappingsModel>{
            new AffiliationMappingsModel(
                'Test Affiliation Mapping',
                '000000000000000005',
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
                affiliationMappingModels,
                recordTypeModelsById
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusFailed,
            0,
            1,
            0,
            1,
            Label.stgHCAfflMapAccRecordTypeTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            String.format(
                Label.stgHCRecordTypeInactive, 
                new List<Object>{'Inactive RecordType Name', 'inactiveRTDevName'}
            ),
            String.format(
                Label.stgHCAfflMapAccRecordTypeInactiveFix, 
                new List<Object>{'Inactive RecordType Name', 'inactiveRTDevName'}
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
                'HH_Account', // will be converted to matching RT id value
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
                affiliationMappingModelsList,
                recordTypeModelsById
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusFailed,
            0,
            1,
            0,
            1,
            Label.stgHCAfflMapAccRecordTypeTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            String.format(
                Label.stgHCRecordTypeNotFound, 
                new List<Object>{(String)Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account')?.getRecordTypeId()}
            ),
            String.format(
                Label.stgHCAfflMapAccRecordTypeNotFoundFix, 
                new List<Object>{(String)Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account')?.getRecordTypeId()}
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
                'Not An Account Record Type ID', 
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
                affiliationMappingModelsList,
                recordTypeModelsById
            );
        Test.stopTest();

        AffiliationMappingsHCVMapper_TEST.validateAssertions(
            healthCheckGroupVModelResult,
            Label.stgHealthCheckAffiliationMappings,
            Label.stgHealthCheckStatusFailed,
            0,
            1,
            0,
            1,
            Label.stgHCAfflMapAccRecordTypeTitle,
            'Fail',
            Label.stgHealthCheckStatusFailed,
            String.format(
                Label.stgHCRecordTypeNotFound, 
                new List<Object>{'Not An Account Record Type ID'} 
            ),
            String.format(
                Label.stgHCAfflMapAccRecordTypeNotFoundFix, 
                new List<Object>{'Not An Account Record Type ID'}
            ),
            0
        ); 
    }

    /**************************************************************************************
    ********************************* HELPER METHODS **************************************
    **************************************************************************************/

    private static void validateAssertions(
        HealthCheckGroupVModel healthCheckGroupVModelResult,
        String expectedHealthCheckGroupLabel,
        String expectedHealthCheckGroupStatus,
        Integer expectedPassedChecksCount,
        Integer expectedTotalChecksCount,
        Integer expectedExpandedListSize,
        Integer expectedHealthCheckItemsListSize,
        String expectedHealthCheckItemSetting,
        String expectedHealthCheckItemStatus,
        String expectedHealthCheckItemStatusLabel,
        String expectedHealthCheckItemDescription,
        String expectedHealthCheckItemFix,
        Integer expectedHealtCheckItemSublistSize
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
    * AffiliationMappingsHealthCheckVMapper to control individual health check methods
    * for success or failure
    ***************************************************************************/
    private class STUB_AffiliationMappingsHealthCheckVMapper extends AffiliationMappingsHealthCheckVMapper {
        private override HealthCheckGroupVModel getValidRecordTypeHealthCheckGroupVModel(
            List<AffiliationMappingsModel> affiliationMappingModels, 
            Map<Id,RecordTypeModel> recordTypeModelsById
        ) {
            return this.mockCheck(affiliationMappingModels);
        }
        
        private HealthCheckGroupVModel mockCheck(List<AffiliationMappingsModel> affiliationMappingModels) {
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

            if(affiliationMappingModels != null) {
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
            return null;
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
    }
}
