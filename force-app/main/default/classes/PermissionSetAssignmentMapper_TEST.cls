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
* @description Test class for PermissionSetAssignmentMapper.
*/
@isTest
public with sharing class PermissionSetAssignmentMapper_TEST {
    
    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * PermissionSetAssignmentMapper class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        PermissionSetAssignmentMapper permissionSetAssignmentMapperInstance = PermissionSetAssignmentMapper.getInstance();
        Test.stopTest();

        System.assertEquals(PermissionSetAssignmentMapper.instance, permissionSetAssignmentMapperInstance, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(true, permissionSetAssignmentMapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * PermissionSetAssignmentMapper class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
            PermissionSetAssignmentMapper permissionSetAssignmentMapperInstance1 = PermissionSetAssignmentMapper.getInstance();
            PermissionSetAssignmentMapper permissionSetAssignmentMapperInstance2 = PermissionSetAssignmentMapper.getInstance();
        Test.stopTest();

        System.assertEquals(PermissionSetAssignmentMapper.instance, permissionSetAssignmentMapperInstance1, 'Instance of mapper class returned should match static instance variable.');
        System.assertEquals(permissionSetAssignmentMapperInstance1, permissionSetAssignmentMapperInstance2, 'Subsequent retrievals of mapper class instance should return existing instance.');
        System.assertEquals(true, permissionSetAssignmentMapperInstance1 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getAssignedPermissionSetIdSetForCurrentUser method 
    * returns a set of permission set ids assigned to the current user when there are some assigned
    ***************************************************************************************************************************/
    @isTest
    private static void getAssignedPermissionSetIdsSetForCurrentUserExisting() {
        User user = UTIL_UnitTestData_TEST.createNewUserForTests('testUser@eda.com');

        List<PermissionSet> permissionSets = new List<PermissionSet>();
        for (Integer i = 0; i < 5; i++) {
            PermissionSet permissionSet = new PermissionSet(PermissionsViewSetup = false,
                                                            Name = 'testName' + i,
                                                            Label = 'testLabel' + i);
            permissionSets.add(permissionSet);
        }
        insert permissionSets;

        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet permissionSet : permissionSets) {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = user.Id,
                                                                                        PermissionSetId = permissionSet.Id);
            permissionSetAssignments.add(permissionSetAssignment);
        }
        insert permissionSetAssignments;

        
        Test.startTest();
            Set<Id> assignedPermissionSetIdsSet = new Set<Id>();
            System.runAs(user) {
                assignedPermissionSetIdsSet = PermissionSetAssignmentMapper.getInstance().getAssignedPermissionSetIdsSetForCurrentUser();
            }
        Test.stopTest();

        System.assertEquals(true, assignedPermissionSetIdsSet.contains(permissionSets[0].Id), 'assignedPermissionSetIdSet should contain every test permission set created');
        System.assertEquals(true, assignedPermissionSetIdsSet.contains(permissionSets[1].Id), 'assignedPermissionSetIdSet should contain every test permission set created');
        System.assertEquals(true, assignedPermissionSetIdsSet.contains(permissionSets[2].Id), 'assignedPermissionSetIdSet should contain every test permission set created');
        System.assertEquals(true, assignedPermissionSetIdsSet.contains(permissionSets[3].Id), 'assignedPermissionSetIdSet should contain every test permission set created');    
        System.assertEquals(true, assignedPermissionSetIdsSet.contains(permissionSets[4].Id), 'assignedPermissionSetIdSet should contain every test permission set created');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getAssignedPermissionSetIdSetForCurrentUser method 
    * returns a empty set of permission set ids assigned to the current user when there is no assigned
    ***************************************************************************************************************************/
    @isTest
    private static void getAssignedPermissionSetIdsSetForCurrentUserNoneAssigned() {
        User user = UTIL_UnitTestData_TEST.createNewUserForTests('testUser@eda.com');

        List<PermissionSet> permissionSets = new List<PermissionSet>();
        for (Integer i = 0; i < 5; i++) {
            PermissionSet permissionSet = new PermissionSet(PermissionsViewSetup = false,
                                                            Name = 'testName' + i,
                                                            Label = 'testLabel' + i);
            permissionSets.add(permissionSet);
        }
        insert permissionSets;
        
        Test.startTest();
            Set<Id> assignedPermissionSetIdsSet = new Set<Id>();
            System.runAs(user) {
                assignedPermissionSetIdsSet = PermissionSetAssignmentMapper.getInstance().getAssignedPermissionSetIdsSetForCurrentUser();
            }
        Test.stopTest();

        System.assertNotEquals(true, assignedPermissionSetIdsSet.contains(permissionSets[0].Id), 'assignedPermissionSetIdSet should contain every test permission set created');
        System.assertNotEquals(true, assignedPermissionSetIdsSet.contains(permissionSets[1].Id), 'assignedPermissionSetIdSet should contain every test permission set created');
        System.assertNotEquals(true, assignedPermissionSetIdsSet.contains(permissionSets[2].Id), 'assignedPermissionSetIdSet should contain every test permission set created');
        System.assertNotEquals(true, assignedPermissionSetIdsSet.contains(permissionSets[3].Id), 'assignedPermissionSetIdSet should contain every test permission set created');    
        System.assertNotEquals(true, assignedPermissionSetIdsSet.contains(permissionSets[4].Id), 'assignedPermissionSetIdSet should contain every test permission set created');
    }
}
