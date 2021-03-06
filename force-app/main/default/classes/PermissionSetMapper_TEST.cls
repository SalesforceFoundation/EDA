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
 * @description Test class for PermissionSetMapper.
 */
@isTest
public with sharing class PermissionSetMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * PermissionSetMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        PermissionSetMapper permissionSetMapperInstance = PermissionSetMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            PermissionSetMapper.instance,
            permissionSetMapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(true, permissionSetMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * PermissionSetMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        PermissionSetMapper permissionSetMapperInstance1 = PermissionSetMapper.getInstance();
        PermissionSetMapper permissionSetMapperInstance2 = PermissionSetMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            PermissionSetMapper.instance,
            permissionSetMapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            permissionSetMapperInstance1,
            permissionSetMapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(true, permissionSetMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the checkPermissionSetsWithCustomizeApplicationFromIds method returns true
     * if any provided permission set has access to view setup
     * TODO: Commented out because PermissionsManageTranslation failing beta builds and downstream packages.
     ***************************************************************************************************************************/
    /*@isTest
    private static void checkPermissionSetsWithCustomizeApplicationFromIdsTrue() {
        List<PermissionSet> permissionSets = new List<PermissionSet>();
        for (Integer i = 0; i < 5; i++) {
            PermissionSet permissionSet = new PermissionSet(
                PermissionsCustomizeApplication = false,
                Name = 'testName' + i,
                Label = 'testLabel' + i
            );
            permissionSets.add(permissionSet);
        }
        permissionSets[0].PermissionsViewSetup = true;
        permissionSets[0].PermissionsViewRoles = true;
        permissionSets[0].PermissionsManageCustomPermissions = true;
        permissionSets[0].PermissionsManageTranslation = true;
        permissionSets[0].PermissionsCustomizeApplication = true;
        insert permissionSets;

        Test.startTest();
        Set<Id> permissionSetIdsSet = new Set<Id>();
        for (PermissionSet permissionSet : permissionSets) {
            permissionSetIdsSet.add(permissionSet.Id);
        }
        Boolean permissionSetsWithCustomizeApplication = PermissionSetMapper.getInstance()
            .checkPermissionSetsWithCustomizeApplicationFromIds(permissionSetIdsSet);
        Test.stopTest();

        System.assertEquals(
            true,
            permissionSetsWithCustomizeApplication,
            'Some of the provided permission sets should have access to view setup'
        );
    }*/

    /**************************************************************************************************************************
     * @description Test method to verify that the checkPermissionSetsWithCustomizeApplicationFromIds method returns false
     * if no provided permission set has access to view setup
     ***************************************************************************************************************************/
    @isTest
    private static void checkPermissionSetsWithCustomizeApplicationFromIdsFalse() {
        List<PermissionSet> permissionSets = new List<PermissionSet>();
        for (Integer i = 0; i < 5; i++) {
            PermissionSet permissionSet = new PermissionSet(
                PermissionsCustomizeApplication = false,
                Name = 'testName' + i,
                Label = 'testLabel' + i
            );
            permissionSets.add(permissionSet);
        }
        insert permissionSets;

        Test.startTest();
        Set<Id> permissionSetIdsSet = new Set<Id>();
        for (PermissionSet permissionSet : permissionSets) {
            permissionSetIdsSet.add(permissionSet.Id);
        }
        Boolean permissionSetsWithCustomizeApplication = PermissionSetMapper.getInstance()
            .checkPermissionSetsWithCustomizeApplicationFromIds(permissionSetIdsSet);
        Test.stopTest();

        System.assertEquals(
            false,
            permissionSetsWithCustomizeApplication,
            'None of the provided permission sets should have access to view setup'
        );
    }
}
