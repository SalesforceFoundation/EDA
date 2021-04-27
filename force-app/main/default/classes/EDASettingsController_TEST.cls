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
* @description Test class for EDASettingsController.
*/
@isTest 
public with sharing class EDASettingsController_TEST {

    /**************************************************************************************************************************
    * @description Test method to verify that the locateUserPermissionService method 
    * returns an instance of UserPermissionService
    ***************************************************************************************************************************/
    @isTest
    private static void locatePermissionSetMapperTest() {
        Test.startTest();
            UserPermissionService userPermissionServiceInstance = UserPermissionService.getInstance();
        Test.stopTest();

        System.assertEquals(UserPermissionService.instance, userPermissionServiceInstance);
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the checkAccessForCurrentUser method 
    * returns true if current user has access.
    ***************************************************************************************************************************/
    @isTest
    private static void checkAccessForCurrentUserHasAccess() {
        UserPermissionService.instance = new STUB_UserPermissionServiceHasAccess();
        
        Test.startTest();
            Boolean accessForCurrentUser = EDASettingsController.checkAccessForCurrentUser();
        Test.stopTest();

        System.assertEquals(true, accessForCurrentUser);
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the checkAccessForCurrentUser method 
    * returns false if current user no access.
    ***************************************************************************************************************************/
    @isTest
    private static void checkAccessForCurrentUserNoAccess() {
        UserPermissionService.instance = new STUB_UserPermissionServiceNoAccess();
        
        Test.startTest();
            Boolean accessForCurrentUser = EDASettingsController.checkAccessForCurrentUser();
        Test.stopTest();

        System.assertEquals(false, accessForCurrentUser);
    }

    /**************************************************************************************************************************
    ****************************************************** STUB CLASS *********************************************************
    **************************************************************************************************************************/

    /*************************************************************************************************************
    * @description Stub class to simulate the response from UserPermissionService to return true
    */
    private class STUB_UserPermissionServiceHasAccess extends UserPermissionService {
        public override Boolean checkViewSetupForCurrentUser() {
            return true;     
        }
    }

    /*************************************************************************************************************
    * @description Stub class to simulate the response from UserPermissionService to return false
    */
    private class STUB_UserPermissionServiceNoAccess extends UserPermissionService {
        public override Boolean checkViewSetupForCurrentUser() {
            return false;     
        }
    }
}
