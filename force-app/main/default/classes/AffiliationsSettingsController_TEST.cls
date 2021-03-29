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
 * @description Test class for AffiliaitonsSettingsController class
 */
@isTest
private with sharing class AffiliationsSettingsController_TEST {
    /**************************************************************************************************************************************************
     * @description Test method to verify that the locateAffiliaitonsSettingsVMapper method returns instance of locateAffiliaitonsSettingsVMapper.
     *************************************************************************************************************************************************/
    @isTest
    private static void locateAffiliaitonsSettingsVMapper() {
        Test.startTest();
        AffiliationsSettingsVMapper affiliaitonsSettingsVMapperInstance = AffiliationsSettingsController.locateAffiliationsSettingsVMapper();
        Test.stopTest();

        System.assertEquals(
            AffiliationsSettingsVMapper.getInstance(),
            affiliaitonsSettingsVMapperInstance,
            'Should return the instance of locateAffiliaitonsSettingsVMapper.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getAffiliationsSettingsVModel method returns a AffiliationsSettingsVModel
     * representing Affiliations Settings in Hierarchy Settings.
     ****************************************************************************************************************************/
    @isTest
    private static void getAffiliationsSettingsVModel() {
        AffiliationsSettingsVMapper.instance = new STUB_AffiliationsSettingsVMapper();

        Test.startTest();
        AffiliationsSettingsVModel affiliationsSettingsVModel = AffiliationsSettingsController.getAffiliationsSettingsVModel();
        Test.stopTest();

        System.assertEquals(
            true,
            affiliationsSettingsVModel.accountRecordTypesEnforced,
            'Affiliation recordtype should be enforced.'
        );
    }

    /****************************************************************************************************************************
     * @description Test method to verify that the getAffiliationsSettingsVModel method fails gracefully when an exception is
     * encountered.
     ****************************************************************************************************************************/
    @isTest
    private static void getAffiliationsSettingsViewModelException() {
        AffiliationsSettingsVMapper.instance = new STUB_ExceptionAffiliationsSettingsVMapper();

        try {
            Test.startTest();
            AffiliationsSettingsVModel affiliationsSettingsVModel = AffiliationsSettingsController.getAffiliationsSettingsVModel();
            Test.stopTest();
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Should throw exception.');
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUBS **************************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationsSettingsVMapper to return a valid AffiliationsSettingVModel
     **************************************************************************************************************************************/
    private class STUB_AffiliationsSettingsVMapper extends AffiliationsSettingsVMapper {
        public override AffiliationsSettingsVModel getAffiliationsSettingsViewModel() {
            return new AffiliationsSettingsVModel(true);
        }
    }

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from AffiliationsSettingsVMapper to throw an exception
     **************************************************************************************************************************************/
    private class STUB_ExceptionAffiliationsSettingsVMapper extends AffiliationsSettingsVMapper {
        public override AffiliationsSettingsVModel getAffiliationsSettingsViewModel() {
            throw new TestException('Exception encountered!');
        }
    }

    private class TestException extends Exception {
    }
}
