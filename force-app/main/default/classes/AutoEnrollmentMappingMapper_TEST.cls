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
     * @description Test method to verify that the updateAffiliationMappings method updates the affiliation Mappings
     */
    @isTest
    private static void updateAffiliationMappingFromModel() {
        Affl_Mappings__c afflMapping = new Affl_Mappings__c(
            Name = 'Academic_Program',
            Account_Record_Type__c = 'Academic_Program',
            Primary_Affl_Field__c = 'Primary_Household__c',
            Auto_Program_Enrollment__c = true,
            Auto_Program_Enrollment_Role__c = 'Student',
            Auto_Program_Enrollment_Status__c = 'Current'
        );
        insert afflMapping;

        AutoEnrollmentMappingModel autoEnrollmentMappingModel = new AutoEnrollmentMappingModel(
            afflMapping.Name,
            afflMapping.Account_Record_Type__c,
            'DifferentRole',
            'DifferentStatus',
            false
        );

        AutoEnrollmentMappingMapper autoEnrollmentMappingMapperInstance = AutoEnrollmentMappingMapper.getInstance();
        Test.startTest();
        autoEnrollmentMappingMapperInstance.updateAffiliationMappingFromModel(
            new List<AutoEnrollmentMappingModel>{ autoEnrollmentMappingModel }
        );
        Test.stopTest();

        Affl_Mappings__c updatedAfflMapping = Affl_Mappings__c.getInstance(afflMapping.name);
        System.assertEquals(
            false,
            updatedAfflMapping.Auto_Program_Enrollment_Role__c,
            'Auto Program Enrollment should be false.'
        );
        System.assertEquals(
            'DifferentRole',
            updatedAfflMapping.Auto_Program_Enrollment_Role__c,
            'Auto Program Enrollment Role should be set to DifferentRole.'
        );
        System.assertEquals(
            'DifferentStatus',
            updatedAfflMapping.Auto_Program_Enrollment_Status__c,
            'Auto Program Enrollment Status should be set to DifferentStatus.'
        );
    }
}
