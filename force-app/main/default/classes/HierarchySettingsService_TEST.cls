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
* @description Test class for HierarchySettingsService class
*/
@isTest
public with sharing class HierarchySettingsService_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * HierarchySettingsService class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {

        Test.startTest();
            HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            HierarchySettingsService.instance, 
            hierarchySettingsServiceInstance, 
            'Instance of mapper class returned should match static instance variable.'
        );

        System.assertEquals(
            true, 
            hierarchySettingsServiceInstance != null, 
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * HierarchySettingsService class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {

        Test.startTest();
            HierarchySettingsService hierarchySettingsServiceInstance1 = HierarchySettingsService.getInstance();
            HierarchySettingsService hierarchySettingsServiceInstance2 = HierarchySettingsService.getInstance();
        Test.stopTest();

        System.assertEquals(
            HierarchySettingsService.instance, 
            hierarchySettingsServiceInstance1, 
            'Instance of mapper class returned should match static instance variable.'
        );

        System.assertEquals(
            hierarchySettingsServiceInstance1, 
            hierarchySettingsServiceInstance2, 
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );

        System.assertEquals(
            true, 
            hierarchySettingsServiceInstance1 != null, 
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the locateHierarchySettingsMapper method returns a valid instance of 
    * HierarchySettingsMapper.
    ***************************************************************************************************************************/
    @isTest 
    private static void locateHierarchySettingsMapperValid(){
        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        HierarchySettingsMapper hierarchySettingsMapperInstance = hierarchySettingsServiceInstance.locateHierarchySettingsMapper();
        Test.stopTest();

        System.assertEquals(
            HierarchySettingsMapper.getInstance(), 
            hierarchySettingsMapperInstance, 
            'Should return instance of HierarchySettingsMapper.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the locateUserPermissionService method returns a valid instance of 
    * UserPermissionService.
    ***************************************************************************************************************************/
    @isTest 
    private static void locateUserPermissionServiceValid(){
        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        UserPermissionService userPermissionServiceInstance = hierarchySettingsServiceInstance.locateUserPermissionService();
        Test.stopTest();

        System.assertEquals(
            UserPermissionService.getInstance(), 
            userPermissionServiceInstance, 
            'Should return instance of UserPermissionService.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method returns true when an update to Hierarchy
    * Settings is successfully processed.
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsValid() {
        HierarchySettingsMapper.instance = new STUB_HierarchySettingsMapper();

        HierarchySettingsChangesVModel hierarchySettingsChangesVModel = new HierarchySettingsChangesVModel();
        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        Test.startTest();
        Boolean updateHierarchySettingsResult = 
            hierarchySettingsServiceInstance.updateHierarchySettings(hierarchySettingsChangesVModel);
        Test.stopTest();

        System.assertEquals(
            true, 
            updateHierarchySettingsResult,
            'Should return true indicating a successful update.'
        );
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method throws an exception when an exception is 
    * encountered from the UserPermissionService class
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsPermissionException() {
        // stub UserPermissionService().checkViewSetupForCurrentUser()
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the updateHierarchySettings method throws an exception when an exception is 
    * encountered from the HierarchySettingsMapper class
    ***************************************************************************************************************************/
    @isTest 
    private static void updateHierarchySettingsThrownException() {
        HierarchySettingsMapper.instance = new STUB_HierarchySettingsMapperExceptionResponse();

        HierarchySettingsChangesVModel hierarchySettingsChangesVModel = new HierarchySettingsChangesVModel();
        HierarchySettingsService hierarchySettingsServiceInstance = HierarchySettingsService.getInstance();

        try {
            Test.startTest();
            Boolean updateHierarchySettingsResult = 
            hierarchySettingsServiceInstance.updateHierarchySettings(hierarchySettingsChangesVModel);
            Test.stopTest();
        } catch(TestException e) {
            System.assertEquals(
                'Test Exception encountered', 
                e.getMessage(),
                'Should throw an error.'
            );
        }
    }

    /**************************************************************************************************************************
    ****************************************************** STUBS **************************************************************
    **************************************************************************************************************************/
    
    /**************************************************************************************************************************************
    * @description Stub class to simulate a successful response from HierarchySettingsMapper 
    **************************************************************************************************************************************/ 
    private class STUB_HierarchySettingsMapper extends HierarchySettingsMapper {
        public override Boolean updateHierarchySettings(HierarchySettingsChangesVModel hierarchySettingsChangesVModel) {
            return true;
        }
    }

    /**************************************************************************************************************************************
    * @description Stub class to simulate an exception response from HierarchySettingsMapper 
    **************************************************************************************************************************************/ 
    private class STUB_HierarchySettingsMapperExceptionResponse extends HierarchySettingsMapper {
        public override Boolean updateHierarchySettings(HierarchySettingsChangesVModel hierarchySettingsChangesVModel) {
            throw new TestException('Test Exception encountered');
        }
    }

    /********************************************************************************************************
    * @description A custom exception class to for testing.
    ********************************************************************************************************/
    public class TestException extends Exception {}
}
