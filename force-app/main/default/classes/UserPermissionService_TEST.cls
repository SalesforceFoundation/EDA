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
 * @description Test class for UserPermissionService.
 */
@isTest
public with sharing class UserPermissionService_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * UserPermissionService class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        UserPermissionService userPermissionServiceInstance = UserPermissionService.getInstance();
        Test.stopTest();

        System.assertEquals(
            UserPermissionService.instance,
            userPermissionServiceInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            true,
            userPermissionServiceInstance != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * UserPermissionService class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        UserPermissionService UserPermissionServiceInstance1 = UserPermissionService.getInstance();
        UserPermissionService UserPermissionServiceInstance2 = UserPermissionService.getInstance();
        Test.stopTest();

        System.assertEquals(
            UserPermissionService.instance,
            UserPermissionServiceInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            UserPermissionServiceInstance1,
            UserPermissionServiceInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(
            true,
            UserPermissionServiceInstance1 != null,
            'Instance of mapper class should not be null.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locatePermissionSetAssignmentMapper method
     * returns an instance of PermissionSetAssignmentMapper
     ***************************************************************************************************************************/
    @isTest
    private static void locatePermissionSetAssignmentMapperTest() {
        Test.startTest();
        PermissionSetAssignmentMapper permissionSetAssignmentMapperInstance = PermissionSetAssignmentMapper.getInstance();
        Test.stopTest();

        System.assertEquals(PermissionSetAssignmentMapper.instance, permissionSetAssignmentMapperInstance);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the locatePermissionSetMapper method
     * returns an instance of PermissionSetMapper
     ***************************************************************************************************************************/
    @isTest
    private static void locatePermissionSetMapperTest() {
        Test.startTest();
        PermissionSetMapper permissionSetMapperInstance = PermissionSetMapper.getInstance();
        Test.stopTest();

        System.assertEquals(PermissionSetMapper.instance, PermissionSetMapperInstance);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the checkCustomizeApplicationForCurrentUser returns true when current user has access.
     ***************************************************************************************************************************/
    @isTest
    private static void checkCustomizeApplicationForCurrentUserHasAccess() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperHasAccess();

        Test.startTest();
        Boolean customizeApplicationForCurrentUser = UserPermissionService.getInstance()
            .checkCustomizeApplicationForCurrentUser();
        Test.stopTest();

        System.assertEquals(true, customizeApplicationForCurrentUser);
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the checkCustomizeApplicationForCurrentUser returns false when current user has no access.
     ***************************************************************************************************************************/
    @isTest
    private static void checkCustomizeApplicationForCurrentUserNoAccess() {
        PermissionSetMapper.instance = new STUB_PermissionSetMapperNoAccess();

        try {
            Test.startTest();
            Boolean customizeApplicationForCurrentUser = UserPermissionService.getInstance()
                .checkCustomizeApplicationForCurrentUser();
            Test.stopTest();
        } catch (System.NoAccessException ex) {
            System.assertEquals(
                'System.NoAccessException',
                ex.getTypeName(),
                'NoAccessException should be thrown when exception occurs.'
            );
            System.assertEquals(
                'Script-thrown exception',
                ex.getMessage(),
                'NoAccessException text should be associated with message when exception occurs.'
            );
        }
    }

    /**************************************************************************************************************************
     ****************************************************** STUB CLASS *********************************************************
     **************************************************************************************************************************/

    /*************************************************************************************************************
     * @description Stub class to simulate the response from PermissionSetMapper to return true
     */
    private class STUB_PermissionSetMapperHasAccess extends PermissionSetMapper {
        public override Boolean checkPermissionSetsWithCustomizeApplicationFromIds(Set<Id> permissionSetIdsSet) {
            return true;
        }
    }

    /*************************************************************************************************************
     * @description Stub class to simulate the response from PermissionSetMapper to return false
     */
    private class STUB_PermissionSetMapperNoAccess extends PermissionSetMapper {
        public override Boolean checkPermissionSetsWithCustomizeApplicationFromIds(Set<Id> permissionSetIdsSet) {
            return false;
        }
    }
}
