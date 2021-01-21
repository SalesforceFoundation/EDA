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
* @description Test class for AffiliationMappingsService class.
*/
@isTest
public with sharing class AffiliationMappingsService_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * AffiliationMappingsService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            AffiliationMappingsService AffiliationMappingsServiceInstance = AffiliationMappingsService.getInstance();
        Test.stopTest();

        System.assertEquals(AffiliationMappingsService.instance, AffiliationMappingsServiceInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, AffiliationMappingsServiceInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * AffiliationMappingsService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            AffiliationMappingsService AffiliationMappingsServiceInstance1 = AffiliationMappingsService.getInstance();
            AffiliationMappingsService AffiliationMappingsServiceInstance2 = AffiliationMappingsService.getInstance();
        Test.stopTest();

        System.assertEquals(AffiliationMappingsService.instance, AffiliationMappingsServiceInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(AffiliationMappingsServiceInstance1, AffiliationMappingsServiceInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, AffiliationMappingsServiceInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getAffiliationMappingsModels method returns a list of Affiliation Mappings
    * models corresponding to affiliation mappings specified in EDA Settings.
    ***************************************************************************************************************************/
    @isTest 
    private static void getAffiliationMappingsModelsValid(){
        AffiliationMappingsMapper.instance = new STUB_AffiliationMappingsMapper();

        AffiliationMappingsService affiliationMappingsServiceInstance = AffiliationMappingsService.getInstance();

        Test.startTest();
        List<AffiliationMappingsModel> afflMappingsModelList = affiliationMappingsServiceInstance.getAffiliationMappingsModels();
        Test.stopTest();

        System.assertEquals(
            'Test Academic Program', 
            afflMappingsModelList[0].name, 
            'Affiliation Model name should match primary affiliation.'
        );

        System.assertEquals(
            'Test_Academic_Program', 
            afflMappingsModelList[0].accountRecordTypeFieldValue, 
            'Affiliation Model record type should match primary affiliation.'
        );

        System.assertEquals(
            'Test Primary Academic Program', 
            afflMappingsModelList[0].primaryAffiliationField, 
            'Affiliation Model primary affiliation field should match primary affiliation.'
        );

        System.assertEquals(
            true, 
            afflMappingsModelList[0].autoProgramEnrollment, 
            'Affiliation Model auto enrollment should match primary affiliation.'
        );

        System.assertEquals(
            'Test Current', 
            afflMappingsModelList[0].autoProgramEnrollmentStatus, 
            'Affiliation Model auto enrollment status should match primary affiliation.'
        );

        System.assertEquals(
            'Test Student', 
            afflMappingsModelList[0].autoProgramEnrollmentRole, 
            'Affiliation Model auto enrollment role should match primary affiliation.'
        );

        System.assertEquals(
            'Test Household Account', 
            afflMappingsModelList[1].name, 
            'Affiliation Model name should match primary affiliation.'
        );

        System.assertEquals(
            'Test_HH_Account', 
            afflMappingsModelList[1].accountRecordTypeFieldValue, 
            'Affiliation Model record type should match primary affiliation.'
        );

        System.assertEquals(
            'Test Primary Household', 
            afflMappingsModelList[1].primaryAffiliationField, 
            'Affiliation Model primary affiliation field should match primary affiliation.'
        );

        System.assertEquals(
            false, 
            afflMappingsModelList[1].autoProgramEnrollment, 
            'Affiliation Model auto enrollment should match primary affiliation.'
        );

        System.assertEquals(
            '""', 
            afflMappingsModelList[1].autoProgramEnrollmentStatus, 
            'Affiliation Model auto enrollment status should match primary affiliation.'
        );

        System.assertEquals(
            '""', 
            afflMappingsModelList[1].autoProgramEnrollmentRole, 
            'Affiliation Model auto enrollment role should match primary affiliation.'
        );
    }

    /***********************************************************************************************************************************
    * @description Test method to verify that the locateAffiliationMappingsMapper method returns instance of AffiliationMappingsMapper
    ***********************************************************************************************************************************/
    @isTest
    private static void locateAffiliationMappingsMapper() {

        AffiliationMappingsService affiliationMappingsServiceInstance = AffiliationMappingsService.getInstance();

        Test.startTest();
            AffiliationMappingsMapper affiliationMappingsMapperInstance = 
                affiliationMappingsServiceInstance.locateAffiliationMappingsMapper();
        Test.stopTest();

        System.assertEquals(AffiliationMappingsMapper.getInstance(), affiliationMappingsMapperInstance, 'Should return the instance of AffiliationMappingsMapper');
    }

    /***********************************************************************************************************************************
    ****************************************************** STUBS ***********************************************************************
    ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
    * @description Stub class to simulate the response from AffiliationMappingsMapper to return a valid list of models representing Primary
    * Affiliation Mappings.
    **************************************************************************************************************************************/ 
    private class STUB_AffiliationMappingsMapper extends AffiliationMappingsMapper {
 
        public override List<AffiliationMappingsModel> getAffiliationMappingsModel() {
            List<AffiliationMappingsModel> afflMappingsModelsList = new List<AffiliationMappingsModel>();

            afflMappingsModelsList.add(new AffiliationMappingsModel(
                'Test Academic Program',
                'Test_Academic_Program',
                'Test Primary Academic Program',
                true,
                'Test Current',
                'Test Student'
            ));

            afflMappingsModelsList.add(new AffiliationMappingsModel(
                'Test Household Account',
                'Test_HH_Account',
                'Test Primary Household',
                false,
                '',
                ''
            ));

            return afflMappingsModelsList;
        }
    }
}
