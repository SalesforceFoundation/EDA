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
 * @description Test class for PrimaryAffiliationsSettingsVMapper class
 */
@isTest
private with sharing class PrimaryAffiliationsSettingsVMapper_TEST {
    private static Integer loopCounter = 5;

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * PrimaryAffiliationsSettingsVMapper class when one does not already exist.
     **************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            PrimaryAffiliationsSettingsVMapper.instance,
            primaryAffiliationsSettingsVMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            primaryAffiliationsSettingsVMapperInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * PrimaryAffiliationsSettingsVMapper class when one already exists.
     **************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance1 = PrimaryAffiliationsSettingsVMapper.getInstance();
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance2 = PrimaryAffiliationsSettingsVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            PrimaryAffiliationsSettingsVMapper.instance,
            primaryAffiliationsSettingsVMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            primaryAffiliationsSettingsVMapperInstance1,
            primaryAffiliationsSettingsVMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            primaryAffiliationsSettingsVMapperInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateLookupFieldService() returns an instance of
     * the LookupFieldService class.
     ****************************************************************************************/
    @isTest
    private static void locateLookupFieldServiceValid() {
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        LookupFieldService lookupFieldServiceInstance = primaryAffiliationsSettingsVMapperInstance.locateLookupFieldService();
        Test.stopTest();

        System.assertEquals(
            LookupFieldService.getInstance(),
            lookupFieldServiceInstance,
            'Should return instance of LookupFieldService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateRecordTypeService() returns an instance of
     * the RecordTypeService class.
     ****************************************************************************************/
    @isTest
    private static void locateRecordTypeServiceValid() {
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        RecordTypeService recordTypeServiceInstance = primaryAffiliationsSettingsVMapperInstance.locateRecordTypeService();
        Test.stopTest();

        System.assertEquals(
            RecordTypeService.getInstance(),
            recordTypeServiceInstance,
            'Should return instance of RecordTypeService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify locateAffiliationMappingsService() returns an instance of
     * the AffiliationMappingsService class.
     ****************************************************************************************/
    @isTest
    private static void locateAffiliationMappingsServiceValid() {
        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        AffiliationMappingsService affiliationMappingsServiceInstance = primaryAffiliationsSettingsVMapperInstance.locateAffiliationMappingsService();
        Test.stopTest();

        System.assertEquals(
            AffiliationMappingsService.getInstance(),
            affiliationMappingsServiceInstance,
            'Should return instance of AffiliationMappingsService class.'
        );
    }

    /****************************************************************************************
     * @description Test method to verify getComboboxVModelOptionsForContactAccountLookupFields()
     * returns a list of ComboboxValueVModels representing the Account lookup fields on the
     * Contact object.
     ****************************************************************************************/
    @isTest
    private static void getComboboxVModelOptionsForContactAccountLookupFieldsValid() {
        List<LookupFieldModel> contactLookupFieldModelList = new List<LookupFieldModel>();

        for (Integer i = 0; i < loopCounter; i++) {
            contactLookupFieldModelList.add(new LookupFieldModel('Lookup Field Name ' + i, 'Lookup Field Label ' + i));
        }

        PrimaryAffiliationsSettingsVMapper primaryAffiliationsSettingsVMapperInstance = PrimaryAffiliationsSettingsVMapper.getInstance();

        Test.startTest();
        List<ComboboxValueVModel> lookupFieldComboboxValueVModelsList = primaryAffiliationsSettingsVMapperInstance.getComboboxVModelOptionsForContactAccountLookupFields(
            contactLookupFieldModelList
        );
        Test.stopTest();

        System.assertEquals(
            loopCounter,
            lookupFieldComboboxValueVModelsList.size(),
            'Should return ' +
            loopCounter +
            ' ComboboxValueVModels.'
        );

        for (Integer i = 0; i < loopCounter; i++) {
            System.assertEquals(
                'Lookup Field Name ' + i,
                lookupFieldComboboxValueVModelsList[i].value,
                'ComoboboxValueVModel value should match lookup field model name.'
            );

            System.assertEquals(
                'Lookup Field Label ' + i,
                lookupFieldComboboxValueVModelsList[i].label,
                'ComoboboxValueVModel label should match lookup field model label.'
            );
        }
    }
}
