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
 * @description Test class for UserMapper class.
 */
@isTest
private with sharing class UserMapper_TEST {
    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns a new instance of the
     * UserMapper class when one does not already exist.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        UserMapper mapperInstance = UserMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            UserMapper.instance,
            mapperInstance,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(true, mapperInstance != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * UserMapper class when one already exists.
     ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        UserMapper mapperInstance1 = UserMapper.getInstance();

        Test.startTest();
        UserMapper mapperInstance2 = UserMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            UserMapper.instance,
            mapperInstance1,
            'Instance of mapper class returned should match static instance variable.'
        );
        System.assertEquals(
            mapperInstance1,
            mapperInstance2,
            'Subsequent retrievals of mapper class instance should return existing instance.'
        );
        System.assertEquals(true, mapperInstance2 != null, 'Instance of mapper class should not be null.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that a user model is retrieved by an Id
     ***************************************************************************************************************************/
    @isTest
    private static void getUserModelById() {
        UserMapper userMapperInstance = UserMapper.getInstance();
        Id userToTestId = UTIL_UnitTestData_TEST.createNewUserForTests(System.now().getTime() + '@testerson.com').id;
        User userToTest = [SELECT Id, Name, isActive, Email, SmallPhotoUrl FROM User WHERE Id = :userToTestId];

        Test.startTest();
        UserModel userModel = userMapperInstance.getUserModelById(userToTest.id);
        Test.stopTest();

        System.assertEquals(userToTest.Id, userModel.Id, 'User Model id should match user id.');
        System.assertEquals(userToTest.Name, userModel.name, 'User Model name should match user name.');
        System.assertEquals(
            userToTest.IsActive,
            userModel.isActive,
            'User Model is active should match user is active.'
        );
        System.assertEquals(userToTest.Email, userModel.email, 'User Model email should match user email.');
        System.assertEquals(
            userToTest.SmallPhotoUrl,
            userModel.smallPhotoUrl,
            'User Model small photo url should match user small photo url.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that getting user models like a name is functional
     ***************************************************************************************************************************/
    @isTest
    private static void getUserModelsLikeName() {
        UserMapper userMapperInstance = UserMapper.getInstance();
        List<Id> userToTestIdList = new List<Id>();
        userToTestIdList.add(
            UTIL_UnitTestData_TEST.createNewUserForTests(System.now().getTime() + '@testerson.com').id
        );
        userToTestIdList.add(
            UTIL_UnitTestData_TEST.createNewUserForTests(System.now().getTime() + '@testerson.com2').id
        );

        Map<Id, User> usersByIds = new Map<Id, User>(
            [SELECT Id, Name, isActive, Email, SmallPhotoUrl FROM User WHERE Id IN :userToTestIdList]
        );

        Test.startTest();
        List<UserModel> userModelList = userMapperInstance.getUserModelsLikeName('Smith', 1);
        Test.stopTest();

        System.assertEquals(1, userModelList.size(), 'Only 1 user model should be retrieved.');
        System.assertNotEquals(
            null,
            usersByIds.get(userModelList[0].id),
            'The user model retrieved should be within the map of those created.'
        );
    }

    /**************************************************************************************************************************
     * @description Test method to verify that getting user models like a name is functional
     ***************************************************************************************************************************/
    @isTest
    private static void getUserModelsLikeNameNegative() {
        UserMapper userMapperInstance = UserMapper.getInstance();
        List<Id> userToTestIdList = new List<Id>();
        userToTestIdList.add(
            UTIL_UnitTestData_TEST.createNewUserForTests(System.now().getTime() + '@testerson.com').id
        );
        userToTestIdList.add(
            UTIL_UnitTestData_TEST.createNewUserForTests(System.now().getTime() + '@testerson.com2').id
        );

        Map<Id, User> usersByIds = new Map<Id, User>(
            [SELECT Id, Name, isActive, Email, SmallPhotoUrl FROM User WHERE Id IN :userToTestIdList]
        );

        Test.startTest();
        List<UserModel> userModelList = userMapperInstance.getUserModelsLikeName('Not Smith', 1);
        Test.stopTest();

        System.assert(userModelList.isEmpty(), 'No user models should be retrieved.');
    }

    /**************************************************************************************************************************
     * @description Test method to verify that getting the model label is functional
     ***************************************************************************************************************************/
    @isTest
    private static void getModelObjectLabel() {
        UserMapper userMapperInstance = UserMapper.getInstance();

        Test.startTest();
        String userObjectLabel = userMapperInstance.getModelObjectLabel();
        Test.stopTest();

        System.assertEquals(
            UTIL_Describe.getObjectDescribe('User').getLabel(),
            userObjectLabel,
            'Label retrieved should be that of the user object label'
        );
    }
}
