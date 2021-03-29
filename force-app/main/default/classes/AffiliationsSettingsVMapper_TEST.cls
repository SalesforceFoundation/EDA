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
 * @description Test class for AffiliationsSettingsVMapper.
 */
@isTest
private with sharing class AffiliationsSettingsVMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * AffiliationsSettingsVMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        AffiliationsSettingsVMapper affiliationsSettingsVMapperInstance = AffiliationsSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationsSettingsVMapper.instance,
            affiliationsSettingsVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            affiliationsSettingsVMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * AffiliationsSettingsVMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        AffiliationsSettingsVMapper affiliationsSettingsVMapperInstance1 = AffiliationsSettingsVMapper.getInstance();
        AffiliationsSettingsVMapper affiliationsSettingsVMapperInstance2 = AffiliationsSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            AffiliationsSettingsVMapper.instance,
            affiliationsSettingsVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            affiliationsSettingsVMapperInstance1,
            affiliationsSettingsVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            affiliationsSettingsVMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test to verify locateAffiliationsSettingsService() returns an instance of the AccountRecordTypeAutoDeletionService class.
     **************************************************************************************************************************/
    @isTest
    private static void locateAffiliationsSettingsService() {
        AffiliationsSettingsVMapper affiliationsSettingsVMapperInstance = AffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        AffiliationsSettingsService AffiliationsSettingsServiceInstance = affiliationsSettingsVMapperInstance.locateAffiliationsSettingsService();
        Test.stopTest();

        System.assertEquals(
            AffiliationsSettingsService.getInstance(),
            AffiliationsSettingsServiceInstance,
            'Should return instance of locateAffiliationsSettingsService class.'
        );
        System.assertEquals(
            true,
            AffiliationsSettingsServiceInstance != null,
            'Instance of locateAffiliationsSettingsService class should not be null.'
        );
    }

    /*************************************************************************************************************
     * @description Test method to verify getAffiliationsSettingsViewModel() returns a DualListboxVModel
     * representing only the active Account Record Types as selected and available options.  It also ensures that
     * all active Record Types are represented as available options regardless of whether they are also in the
     * selected list.
     *************************************************************************************************************/
    @isTest
    private static void getAffiliationsSettingsViewModel() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        AffiliationsSettingsVMapper affiliationsSettingsVMapperInstance = AffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        AffiliationsSettingsVModel affiliationsSettingsVModel = affiliationsSettingsVMapperInstance.getAffiliationsSettingsViewModel();
        Test.stopTest();

        System.assertEquals(
            true,
            affiliationsSettingsVModel.accountRecordTypesEnforced,
            'Should return the value store in the custom settings.'
        );
    }
}
