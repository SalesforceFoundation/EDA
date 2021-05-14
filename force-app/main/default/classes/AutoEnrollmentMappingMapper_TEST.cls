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
 * @group Test
 * @group-content ../../ApexDocContent/Test.htm
 * @description Test class for AutoEnrollmentMappingMapper_TEST.
 */
@isTest
private with sharing class AutoEnrollmentMappingMapper_TEST {
    @testVisible
    private static Integer numberOfRecords = 5;

    /**
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AutoEnrollmentMappingMapper class when one does not already exist.
     */
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AutoEnrollmentMappingMapper autoEnrollmentMappingMapperInstance = AutoEnrollmentMappingMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AutoEnrollmentMappingMapper.instance,
            autoEnrollmentMappingMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            autoEnrollmentMappingMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AutoEnrollmentMappingMapper class when one already exists.
     */
    @isTest
    private static void getInstanceExisting() {
        AutoEnrollmentMappingMapper autoEnrollmentMappingMapperInstance1 = AutoEnrollmentMappingMapper.getInstance();

        Test.startTest();
        AutoEnrollmentMappingMapper autoEnrollmentMappingMapperInstance2 = AutoEnrollmentMappingMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AutoEnrollmentMappingMapper.instance,
            autoEnrollmentMappingMapperInstance2,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            autoEnrollmentMappingMapperInstance1,
            autoEnrollmentMappingMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            autoEnrollmentMappingMapperInstance2 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**
     * @description Test method to verify that the updateAffiliationMappingsFromModelList method updates the affiliation Mappings
     */
    @isTest
    private static void updateAffiliationMappingsFromModelList() {
        AutoEnrollmentMappingMapper autoEnrollmentMappingMapperInstance = AutoEnrollmentMappingMapper.getInstance();

        Map<String, Affl_Mappings__c> affiliationMappingsByName = new Map<String, Affl_Mappings__c>();
        Map<String, AutoEnrollmentMappingModel> autoEnrollmentMappingModelsByNameToUpdate = new Map<String, AutoEnrollmentMappingModel>();

        for (Integer i = 0; i < AutoEnrollmentMappingMapper_TEST.numberOfRecords; i++) {
            Affl_Mappings__c affiliationMapping = new Affl_Mappings__c(
                Name = 'Academic_Program' + i,
                Account_Record_Type__c = 'Academic_Program' + i,
                Primary_Affl_Field__c = 'Primary_Household__c' + i,
                Auto_Program_Enrollment__c = false,
                Auto_Program_Enrollment_Role__c = null,
                Auto_Program_Enrollment_Status__c = null
            );
            affiliationMappingsByName.put(affiliationMapping.Name, affiliationMapping);
        }

        insert affiliationMappingsByName.values();

        for (String mappingName : affiliationMappingsByName.keySet()) {
            Affl_Mappings__c affiliationMapping = affiliationMappingsByName.get(mappingName);
            AutoEnrollmentMappingModel autoEnrollmentMappingModel = new AutoEnrollmentMappingModel(
                affiliationMapping.Name,
                affiliationMapping.Account_Record_Type__c,
                'New Role',
                'New Status',
                true
            );
            autoEnrollmentMappingModelsByNameToUpdate.put(autoEnrollmentMappingModel.name, autoEnrollmentMappingModel);
        }

        Test.startTest();
        List<AutoEnrollmentMappingModel> updatedAutoEnrollmentMappingModels = autoEnrollmentMappingMapperInstance.updateAffiliationMappingsFromModelList(
            autoEnrollmentMappingModelsByNameToUpdate.values()
        );
        Test.stopTest();

        for (AutoEnrollmentMappingModel autoEnrollmentMappingModel : updatedAutoEnrollmentMappingModels) {
            System.assertEquals(
                true,
                autoEnrollmentMappingModel.active,
                'Auto Program Enrollment Model should be active.'
            );
            System.assertEquals(
                'New Role',
                autoEnrollmentMappingModel.role,
                'Auto Program Enrollment Model Role should be set to New Role.'
            );
            System.assertEquals(
                'New Status',
                autoEnrollmentMappingModel.status,
                'Auto Program Enrollment Status should be set to New Status.'
            );

            Affl_Mappings__c affiliationMapping = Affl_Mappings__c.getInstance(autoEnrollmentMappingModel.name);

            System.assertEquals(
                true,
                affiliationMapping.Auto_Program_Enrollment__c,
                'Auto Program Enrollment should be true.'
            );
            System.assertEquals(
                'New Role',
                affiliationMapping.Auto_Program_Enrollment_Role__c,
                'Auto Program Enrollment Role should be set to New Role.'
            );
            System.assertEquals(
                'New Status',
                affiliationMapping.Auto_Program_Enrollment_Status__c,
                'Auto Program Enrollment Status should be set to New Status.'
            );
        }
    }
}
