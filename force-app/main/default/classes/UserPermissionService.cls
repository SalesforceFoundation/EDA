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
* @description Service class for User Permission.
*/
public virtual with sharing class UserPermissionService {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static UserPermissionService instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected UserPermissionService() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of UserPermissionService.
    ******************************************************************************/
    public static UserPermissionService getInstance() {
        if (instance == null) {
            instance = new UserPermissionService();
        }

        return instance;
    }

    /*****************************************************************************
    * @description Check if current user has access to view setup.
    * @return If current user has access to view setup
    ******************************************************************************/
    public virtual Boolean checkViewSetupForCurrentUser() {
        Set<Id> assignedPermissionSetIdsSet = this.locatePermissionSetAssignmentMapper().getAssignedPermissionSetIdsSetForCurrentUser();
        Boolean viewSetupForCurrentUser = this.locatePermissionSetMapper().checkPermissionSetsWithViewSetupFromIds(assignedPermissionSetIdsSet);

        if (viewSetupForCurrentUser == false) {
            throw new NoAccessException();
        }

        return true;
    }

    /******************************************************************************
    * @description Retrieves an instance of the PermissionSetAssignmentMapper class.
    * @return An instance of PermissionSetAssignmentMapper.
    ******************************************************************************/
    @TestVisible
    private PermissionSetAssignmentMapper locatePermissionSetAssignmentMapper() {
        return PermissionSetAssignmentMapper.getInstance();
    }

    /******************************************************************************
    * @description Retrieves an instance of the PermissionSetMapper class.
    * @return An instance of PermissionSetMapper.
    ******************************************************************************/
    @TestVisible
    private PermissionSetMapper locatePermissionSetMapper() {
        return PermissionSetMapper.getInstance();
    }
}
