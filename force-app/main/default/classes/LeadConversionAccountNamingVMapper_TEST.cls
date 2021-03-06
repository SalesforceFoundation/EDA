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
 * @description Test class for LeadConversionAccountNamingMapper.
 */
@isTest
private with sharing class LeadConversionAccountNamingVMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * LeadConversionAccountNamingMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        LeadConversionAccountNamingMapper LeadConversionAccountNamingMapperInstance = LeadConversionAccountNamingMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            LeadConversionAccountNamingMapper.instance,
            LeadConversionAccountNamingMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            LeadConversionAccountNamingMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * LeadConversionAccountNamingMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        LeadConversionAccountNamingMapper LeadConversionAccountNamingMapperInstance1 = LeadConversionAccountNamingMapper.getInstance();
        LeadConversionAccountNamingMapper LeadConversionAccountNamingMapperInstance2 = LeadConversionAccountNamingMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            LeadConversionAccountNamingMapper.instance,
            LeadConversionAccountNamingMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            LeadConversionAccountNamingMapperInstance1,
            LeadConversionAccountNamingMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            LeadConversionAccountNamingMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test to verify locateRecordTypeService() returns an instance of the RecordTypeService class.
     **************************************************************************************************************************/
    @isTest
    private static void locateRecordTypeServiceValid() {
        LeadConversionAccountNamingVMapper leadConversionAccountNamingMapperInstance = LeadConversionAccountNamingVMapper.getInstance();
        Test.startTest();
        RecordTypeService recordTypeServiceInstance = leadConversionAccountNamingMapperInstance.locateRecordTypeService();
        Test.stopTest();

        System.assertEquals(
            RecordTypeService.getInstance(),
            recordTypeServiceInstance,
            'Should return instance of RecordTypeService class.'
        );
        System.assertEquals(
            true,
            recordTypeServiceInstance != null,
            'Instance of RecordTypeService class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test to verify locateLeadConversionAccountNamingService() returns an instance of the LeadConversionAccountNamingService class.
     **************************************************************************************************************************/
    @isTest
    private static void locateLeadConversionAccountNamingServiceValid() {
        LeadConversionAccountNamingVMapper LeadConversionAccountNamingMapperInstance = LeadConversionAccountNamingVMapper.getInstance();

        Test.startTest();
        LeadConversionAccountNamingService LeadConversionAccountNamingServiceInstance = LeadConversionAccountNamingMapperInstance.locateLeadConversionAccountNamingService();
        Test.stopTest();

        System.assertEquals(
            LeadConversionAccountNamingService.getInstance(),
            LeadConversionAccountNamingServiceInstance,
            'Should return instance of LeadConversionAccountNamingService class.'
        );
        System.assertEquals(
            true,
            LeadConversionAccountNamingServiceInstance != null,
            'Instance of LeadConversionAccountNamingService class should not be null.'
        );
    }

    /*************************************************************************************************************
     * @description Test method to verify getLeadConversionAccountNamingViewModel() returns a DualListboxVModel
     * representing only the active Account Record Types as selected and available options.  It also ensures that
     * all active Record Types are represented as available options regardless of whether they are also in the
     * selected list.
     *************************************************************************************************************/
    @isTest
    private static void getLeadConversionAccountNamingViewModelValid() {
        RecordTypeMapper.instance = new STUB_RecordTypeMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Lead_Converted_Account_RTypes__c = '000000000000000001;000000000000000002')
        );

        LeadConversionAccountNamingVMapper leadConversionAccountNamingMapperInstance = LeadConversionAccountNamingVMapper.getInstance();

        Test.startTest();
        DualListboxVModel dualListboxVModel = leadConversionAccountNamingMapperInstance.getLeadConversionAccountNamingViewModel();
        Test.stopTest();

        System.assertEquals(
            1,
            dualListboxVModel.value.size(),
            'Should only display active account record type as selected value.'
        );
        System.assertEquals(
            '000000000000000001',
            dualListboxVModel.value[0],
            'Should only display active account record type as selected value.'
        );
        System.assertEquals(
            2,
            dualListboxVModel.options.size(),
            'Should only display active account record types as available options.'
        );
        System.assertEquals(
            '000000000000000001',
            dualListboxVModel.options[0].value,
            'Should only display active account record types as available options.'
        );
        System.assertEquals(
            '000000000000000003',
            dualListboxVModel.options[1].value,
            'Should only display active account record types as available options.'
        );
    }

    /**************************************************************************************************************************
     ****************************************************** STUB CLASS *********************************************************
     **************************************************************************************************************************/

    /*************************************************************************************************************
     * @description Stub class to simulate the response from RecordTypeMapper to return a map of Record Type model by Id
     */
    private class STUB_RecordTypeMapper extends RecordTypeMapper {
        public override Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
            Map<Id, RecordTypeModel> recordTypeModelsById = new Map<Id, RecordTypeModel>{
                '000000000000000001' => new RecordTypeModel(
                    '000000000000000001',
                    'Record Type 1',
                    'Record_Type_1',
                    true
                ),
                '000000000000000002' => new RecordTypeModel(
                    '000000000000000002',
                    'Record Type 2',
                    'Record_Type_2',
                    false
                ),
                '000000000000000003' => new RecordTypeModel(
                    '000000000000000003',
                    'Record Type 3',
                    'Record_Type_3',
                    true
                )
            };

            return recordTypeModelsById;
        }
    }
}
