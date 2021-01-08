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
        Test.startTest();
        List<AffiliationMappingsModel> afflMappingModelsList = 
            AffiliationMappingsMapper.getInstance().getAffiliationMappingsModel();
        Test.stopTest();

        List<Affl_Mappings__c> primaryAfflMappingsList = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();
        Map<String, Affl_Mappings__c> primaryAfflMappingByName = new Map<String, Affl_Mappings__c>();

        for (Affl_Mappings__c primaryAfflMapping : primaryAfflMappingsList){
            primaryAfflMappingByName.put(primaryAfflMapping.Name, primaryAfflMapping);
        }

        for (AffiliationMappingsModel afflMappingModel : afflMappingModelsList){
            Affl_Mappings__c matchingPrimaryAffl = primaryAfflMappingByName.get(afflMappingModel.name);
            System.assertEquals(
                matchingPrimaryAffl.Name, 
                afflMappingModel.name, 
                'Affiliation Mapping Model name should match Primary Affiliation.'
            );

            System.assertEquals(
                matchingPrimaryAffl.Primary_Affl_Field__c, 
                afflMappingModel.primaryAffiliationField, 
                'Affiliation Mapping Model Field Name should match Primary Affiliation.'
            );

            System.assertEquals(
                matchingPrimaryAffl.Account_Record_Type__c, 
                afflMappingModel.accountRecordTypeId, 
                'Affiliation Mapping Model account record type should match Primary Affiliation.'
            );

            System.assertEquals(
                matchingPrimaryAffl.Auto_Program_Enrollment__c, 
                afflMappingModel.autoProgramEnrollment, 
                'Affiliation Mapping Model auto enrollment should match Primary Affiliation.'
            );
            System.assertEquals(
                matchingPrimaryAffl.Auto_Program_Enrollment_Status__c, 
                afflMappingModel.autoProgramEnrollmentStatus, 
                'Affiliation Mapping Model auto enrollment status should match Primary Affiliation.'
            );

            System.assertEquals(
                matchingPrimaryAffl.Auto_Program_Enrollment_Role__c, 
                afflMappingModel.autoProgramEnrollmentRole, 
                'Affiliation Mapping Model auto enrollment role should match Primary Affiliation.'
            );
        }
    }
}
