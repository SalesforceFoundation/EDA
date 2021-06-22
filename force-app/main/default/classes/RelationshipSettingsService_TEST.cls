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
 * @description Test class for RelationshipSettingsService class.
 */
@isTest
private with sharing class RelationshipSettingsService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * RelationshipSettingsService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        RelationshipSettingsService relationshipSettingsServiceInstance = RelationshipSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            RelationshipSettingsService.instance,
            relationshipSettingsServiceInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            RelationshipSettingsServiceInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * RelationshipSettingsService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        RelationshipSettingsService relationshipSettingsServiceInstance1 = RelationshipSettingsService.getInstance();
        RelationshipSettingsService relationshipSettingsServiceInstance2 = RelationshipSettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            RelationshipSettingsService.instance,
            relationshipSettingsServiceInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            relationshipSettingsServiceInstance1,
            relationshipSettingsServiceInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            relationshipSettingsServiceInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the locateRelationshipSettingsMapper method returns instance of RelationshipSettingsMapper
     ***********************************************************************************************************************************/
    @isTest
    private static void locateRelationshipSettingsMapper() {
        RelationshipSettingsService relationshipSettingsServiceInstance = RelationshipSettingsService.getInstance();

        Test.startTest();
        RelationshipSettingsMapper relationshipSettingsMapperInstance = RelationshipSettingsServiceInstance.locateRelationshipSettingsMapper();
        Test.stopTest();

        System.assertEquals(
            RelationshipSettingsMapper.getInstance(),
            relationshipSettingsMapperInstance,
            'Should return the instance of RelationshipSettingsMapperInstance'
        );
    }

    /***********************************************************************************************************************************
     * @description Test method to verify that the getRelationshipSettingsModel method returns a valid RelationshipSettingsModel
     ***********************************************************************************************************************************/
    @isTest
    private static void getRelationshipSettingsModelValid() {
        RelationshipSettingsMapper.instance = new STUB_RelationshipSettingsMapper();

        RelationshipSettingsService relationshipSettingsServiceInstance = RelationshipSettingsService.getInstance();

        Test.startTest();
        RelationshipSettingsModel relationshipSettingsModel = relationshipSettingsServiceInstance.getRelationshipSettingsModel();
        Test.stopTest();

        System.assertEquals(
            'List Setting',
            relationshipSettingsModel.reciprocalMethod,
            'Should be set to the value of hierarchy settings.'
        );

        System.assertEquals(
            true,
            relationshipSettingsModel.allowAutoCreatedDuplicates,
            'Should be set to the value of hierarchy settings.'
        );
    }

    /***********************************************************************************************************************************
     ****************************************************** STUBS ***********************************************************************
     ***********************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Stub class to simulate the response from RelationshipSettingsMapper to return a valid RelationshipSettingsModel
     **************************************************************************************************************************************/
    private class STUB_RelationshipSettingsMapper extends RelationshipSettingsMapper {
        public override RelationshipSettingsModel getRelationshipSettingsModel() {
            return new RelationshipSettingsModel('List Setting', true);
        }
    }
}
