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
 * @description Test class for UserService class.
 */
@isTest
private with sharing class UserService_TEST {
    /**
     * @description Test method to verify that the getInstance method returns a new instance of the
     * UserService class when one does not already exist.
     */
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        UserService serviceInstance = UserService.getInstance();
        Test.stopTest();

        System.assertEquals(
            UserService.instance,
            serviceInstance,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(true, serviceInstance != null, 'Instance of service class should not be null.');
    }

    /**
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * UserService class when one already exists.
     */
    @isTest
    private static void getInstanceExisting() {
        UserService serviceInstance1 = UserService.getInstance();

        Test.startTest();
        UserService serviceInstance2 = UserService.getInstance();
        Test.stopTest();

        System.assertEquals(
            UserService.instance,
            serviceInstance1,
            'Instance of service class returned should match static instance variable.'
        );
        System.assertEquals(
            serviceInstance1,
            serviceInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );
        System.assertEquals(true, serviceInstance2 != null, 'Instance of service class should not be null.');
    }

    /**
     * @description Test method to verify that a user model is retrieved by an Id
     */
    @isTest
    private static void getUserModelById() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        UserMapper.instance = new STUB_UserMapper(userId);
        UserService userServiceInstance = UserService.getInstance();

        Test.startTest();
        UserModel userModel = userServiceInstance.getUserModelById(userId);
        Test.stopTest();

        System.assertEquals(userId, userModel.Id, 'User Model id should match user id.');
        System.assertEquals('User Name', userModel.name, 'User Model name should match user name.');
        System.assertEquals(true, userModel.isActive, 'User Model is active should match user is active.');
        System.assertEquals('user@test.com', userModel.email, 'User Model email should match user email.');
        System.assertEquals(
            'https://example.com/user.png',
            userModel.smallPhotoUrl,
            'User Model small photo url should match user small photo url.'
        );
    }

    /**
     * @description Test method to verify that getting user models like a name is functional
     */
    @isTest
    private static void getUserModelsLikeName() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        UserMapper.instance = new STUB_UserMapper(userId);
        UserService userServiceInstance = UserService.getInstance();

        Test.startTest();
        List<UserModel> userModelList = userServiceInstance.getUserModelsLikeName('User Name', 1);
        Test.stopTest();

        System.assertEquals(1, userModelList.size(), 'Only 1 user model should be retrieved.');
        System.assertEquals(
            userId,
            userModelList[0].id,
            'The user model retrieved should be for the id of those specified in the mapper.'
        );
    }

    /**
     * @description Test method to verify that getting user models like a name is functional
     */
    @isTest
    private static void getUserModelsLikeNameNegative() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        UserMapper.instance = new STUB_UserMapper(userId);
        UserService userServiceInstance = UserService.getInstance();

        Test.startTest();
        List<UserModel> userModelList = userServiceInstance.getUserModelsLikeName('Not User Name', 1);
        Test.stopTest();

        System.assert(userModelList.isEmpty(), 'Only 0 user model should be retrieved.');
    }

    /**
     * @description Test method to verify that getting the model label is functional
     */
    @isTest
    private static void getModelObjectLabel() {
        UserMapper.instance = new STUB_UserMapper(null);
        UserService userServiceInstance = UserService.getInstance();

        Test.startTest();
        String userObjectLabel = userServiceInstance.getModelObjectLabel();
        Test.stopTest();

        System.assertEquals('User', userObjectLabel, 'Label retrieved should be that provided by the mapper.');
    }

    /**
     * @description Stub class to simulate the response from UserMapper
     */
    private class STUB_UserMapper extends UserMapper {
        private Id userId;

        STUB_UserMapper(Id userId) {
            this.userId = userId;
        }

        public override UserModel getUserModelById(Id userId) {
            return new UserModel(userId, 'User Name', true, 'user@test.com', 'https://example.com/user.png');
        }

        public override List<UserModel> getUserModelsLikeName(String userNameMatch, Integer recordLimit) {
            List<UserModel> userModelList = new List<UserModel>();

            if ('User Name'.toLowerCase().contains(userNameMatch.toLowerCase())) {
                userModelList.add(
                    new UserModel(this.userId, 'User Name', true, 'user@test.com', 'https://example.com/user.png')
                );
            }

            return userModelList;
        }

        public override String getModelObjectLabel() {
            return 'User';
        }
    }
}
