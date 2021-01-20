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
* @description Test class for AfffiliationMappingsMapper class.
*/
@isTest
public with sharing class AffiliationMappingsMapper_TEST {

    /*****************************************************************************
    * @description Test to verify getAffiliationMappingsModelValid() generates
    * models matching the affiliation mappings set in EDA Settings. 
    *****************************************************************************/
    @isTest 
    private static void getAffiliationMappingsModelValid(){
        String prefix = UTIL_Namespace.StrTokenNSPrefix('');

        List<Affl_Mappings__c> primaryAfflMappingsList = new List<Affl_Mappings__c>();
        primaryAfflMappingsList.add(
            new Affl_Mappings__c(
                Name = 'Business Organization', 
                Account_Record_Type__c = 'Business_Organization', 
                Primary_Affl_Field__c = prefix + 'Primary_Organization__c'
            ));

        primaryAfflMappingsList.add(
            new Affl_Mappings__c(
                Name = 'Invalid Affiliation Mapping', 
                Account_Record_Type__c = 'Invalid Mapping', 
                Primary_Affl_Field__c =  prefix + 'Invalid_Mapping__c'
            )
        );
        
        insert primaryAfflMappingsList;

        Map<String, Affl_Mappings__c> primaryAfflMappingByName = new Map<String, Affl_Mappings__c>();

        for (Affl_Mappings__c primaryAfflMapping : primaryAfflMappingsList){
            primaryAfflMappingByName.put(primaryAfflMapping.Name, primaryAfflMapping);
        }

        Test.startTest();
        List<AffiliationMappingsModel> afflMappingModelsList = 
            AffiliationMappingsMapper.getInstance().getAffiliationMappingsModel();
        Test.stopTest();        

        for (AffiliationMappingsModel affiliationMappingsModel : afflMappingModelsList){
            Affl_Mappings__c matchingPrimaryAffl = primaryAfflMappingByName.get(affiliationMappingsModel.name);

            System.assertEquals(
                matchingPrimaryAffl.Name, 
                affiliationMappingsModel.name, 
                'Affiliation Mapping Model name should match Primary Affiliation.'
            );

            System.assertEquals(
                matchingPrimaryAffl.Primary_Affl_Field__c, 
                affiliationMappingsModel.primaryAffiliationField, 
                'Affiliation Mapping Model Field Name should match Primary Affiliation.'
            );

            if (affiliationMappingsModel.name == 'Invalid Affiliation Mapping'){
                System.assertEquals(
                    'Invalid Mapping', 
                    affiliationMappingsModel.accountRecordTypeId, 
                    'Affiliation Mapping Model account record type should match developer name listed in affiliation mapping when no matching record type exists in org.'
                );
            } else {
                System.assertEquals(
                    (String)Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(matchingPrimaryAffl.Account_Record_Type__c)?.getRecordTypeId(), 
                    affiliationMappingsModel.accountRecordTypeId, 
                    'Affiliation Mapping Model account record type should match Id for record type matching specified developer name in affiliation mapping when one exists in org.'
                );
            }
            
            System.assertEquals(
                matchingPrimaryAffl.Auto_Program_Enrollment__c, 
                affiliationMappingsModel.autoProgramEnrollment, 
                'Affiliation Mapping Model auto enrollment should match Primary Affiliation.'
            );
            System.assertEquals(
                matchingPrimaryAffl.Auto_Program_Enrollment_Status__c, 
                affiliationMappingsModel.autoProgramEnrollmentStatus, 
                'Affiliation Mapping Model auto enrollment status should match Primary Affiliation.'
            );

            System.assertEquals(
                matchingPrimaryAffl.Auto_Program_Enrollment_Role__c, 
                affiliationMappingsModel.autoProgramEnrollmentRole, 
                'Affiliation Mapping Model auto enrollment role should match Primary Affiliation.'
            );
        }
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AffiliationMappingsMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AffiliationMappingsMapper AffiliationMappingsMapperInstance = AffiliationMappingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AffiliationMappingsMapper.instance, AffiliationMappingsMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, AffiliationMappingsMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AffiliationMappingsMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AffiliationMappingsMapper AffiliationMappingsMapperInstance1 = AffiliationMappingsMapper.getInstance();
            AffiliationMappingsMapper AffiliationMappingsMapperInstance2 = AffiliationMappingsMapper.getInstance();
        Test.stopTest();

        System.assertEquals(AffiliationMappingsMapper.instance, AffiliationMappingsMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(AffiliationMappingsMapperInstance1, AffiliationMappingsMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, AffiliationMappingsMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }
}
