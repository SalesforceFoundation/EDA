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
 * @group-content ../../ApexDocContent/
 * @description Test class for AffiliationsSettingsService class.
 */
@isTest
private with sharing class AffiliationsSettingsService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AffiliationsSettingsService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AffiliationsSettingsService affiliationsSettingsServiceInstance = AffiliationsSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationsSettingsService.instance,
            affiliationsSettingsServiceInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            affiliationsSettingsServiceInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AffiliationsSettingsService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AffiliationsSettingsService affiliationsSettingsServiceInstance1 = AffiliationsSettingsService.getInstance();
        AffiliationsSettingsService affiliationsSettingsServiceInstance2 = AffiliationsSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationsSettingsService.instance,
            affiliationsSettingsServiceInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            affiliationsSettingsServiceInstance1,
            affiliationsSettingsServiceInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            affiliationsSettingsServiceInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateAffiliatonsSettingsMapper method returns instance of AffiliationsSettingsMapper
     ***********************************************************************************************************************************/
    @isTest
    private static void locateAffiliatonsSettingsMapper() {
        AffiliationsSettingsService affiliationsSettingsServiceInstance = AffiliationsSettingsService.getInstance();

        Test.startTest();
        AffiliationsSettingsMapper affiliationsSettingsMapperInstance = affiliationsSettingsServiceInstance.locateAffiliatonsSettingsMapper();
        Test.stopTest();

        System.assertEquals(
            AffiliationsSettingsMapper.getInstance(),
            affiliationsSettingsMapperInstance,
            'Should return the instance of affiliationsSettingsMapperInstance'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getAffiliationsSettingsModel method returns a valid AffiliationsSettingsModel
     ***********************************************************************************************************************************/
    @isTest
    private static void getAffiliationsSettingsModelValid() {
        AffiliationsSettingsMapper.instance = new STUB_AffiliationsSettingsMapper();

        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        AffiliationsSettingsService affiliationsSettingsServiceInstance = AffiliationsSettingsService.getInstance();

        Test.startTest();
        AffiliationsSettingsModel affiliationsSettingsModel = affiliationsSettingsServiceInstance.getAffiliationsSettingsModel();
        Test.stopTest();

        System.assertEquals(
            true,
            affiliationsSettingsModel.accountRecordTypesEnforced,
            'Should be set to the value of hierarchy settings.'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationsSettingsMapper to return a valid AffiliationsSettingsModel
     **************************************************************************************************************************************/
    private class STUB_AffiliationsSettingsMapper extends AffiliationsSettingsMapper {
        public override AffiliationsSettingsModel getAffiliationsSettingsModel() {
            return new AffiliationsSettingsModel(true);
        }
    }
}
