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
* @group Permission
* @group-content ../../ApexDocContent/Permission.htm
* @description Mapper class for Permission Set assignment.
*/
public virtual with sharing class PermissionSetAssignmentMapper {
    
    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static PermissionSetAssignmentMapper instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected PermissionSetAssignmentMapper() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of PermissionSetAssignmentMapper.
    ******************************************************************************/
    public static PermissionSetAssignmentMapper getInstance() {

        if (instance == null) {
            instance = new PermissionSetAssignmentMapper();
        }

        return instance;
    }

    /*****************************************************************************
    * @description Get a list of permission set ids assigned to the current user.
    * @return A Set of permission set ids assigned to the current user.
    ***************************************************************************************************************************/
    public Set<Id> getAssignedPermissionSetIdsSetForCurrentUser() {

        Set<Id> assignedPermissionSetIdsSet = new Set<Id>();

        List<PermissionSetAssignment> permissionSetAssignments = [SELECT PermissionSetId
                                                                FROM PermissionSetAssignment
                                                                WHERE AssigneeId = :UserInfo.getUserId()];
        for (PermissionSetAssignment permissionSetAssignment : permissionSetAssignments) {
            assignedPermissionSetIdsSet.add(permissionSetAssignment.PermissionSetId);
        }
        
        return assignedPermissionSetIdsSet;      
    }
}
