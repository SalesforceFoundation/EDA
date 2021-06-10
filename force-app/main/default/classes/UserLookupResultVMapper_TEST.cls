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
 * @group-content ../../ApexDocContent/Tests
 * @description Test class for UserLookupResultVMapper
 */
@isTest
private with sharing class UserLookupResultVMapper_TEST {
    /**
     * @description Test method to verify that the getInstance method returns a new instance of the
     * UserLookupResultVMapper class when one does not already exist.
     */
    @isTest
    private static void getInstanceNew() {
        Test.startTest();
        UserLookupResultVMapper userLookupResultVMapperInstance = UserLookupResultVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            UserLookupResultVMapper.instance,
            userLookupResultVMapperInstance,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            true,
            userLookupResultVMapperInstance != null,
            'Instance of service class should not be null.'
        );
    }

    /**
     * @description Test method to verify that the getInstance method returns the existing instance of the
     * UserLookupResultVMapper class when one already exists.
     */
    @isTest
    private static void getInstanceExisting() {
        Test.startTest();
        UserLookupResultVMapper userLookupResultVMapperInstance1 = UserLookupResultVMapper.getInstance();
        UserLookupResultVMapper userLookupResultVMapperInstance2 = UserLookupResultVMapper.getInstance();
        Test.stopTest();

        System.assertEquals(
            UserLookupResultVMapper.instance,
            userLookupResultVMapperInstance1,
            'Instance of service class returned should match static instance variable.'
        );

        System.assertEquals(
            userLookupResultVMapperInstance1,
            userLookupResultVMapperInstance2,
            'Subsequent retrievals of service class instance should return existing instance.'
        );

        System.assertEquals(
            true,
            userLookupResultVMapperInstance1 != null,
            'Instance of service class should not be null.'
        );
    }

    /**
     * @description Test method to verify that the locateUserServiceValid method returns instance of UserService
     */
    @isTest
    private static void locateUserServiceValid() {
        UserLookupResultVMapper userLookupResultVMapperInstance = UserLookupResultVMapper.getInstance();

        Test.startTest();
        UserService userServiceInstance = userLookupResultVMapperInstance.locateUserService();
        Test.stopTest();

        System.assertEquals(
            UserService.getInstance(),
            userServiceInstance,
            'Should return the instance of UserService'
        );
    }

    /**
     * @description Test method to verify that the getLookupResultFromUserModel method returns a mapped Lookup Result
     */
    @isTest
    private static void getLookupResultFromUserModel() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        UserService.instance = new STUB_UserService(userId);
        UserLookupResultVMapper userLookupResultVMapperInstance = UserLookupResultVMapper.getInstance();

        UserModel userModel = new UserModel(userId, 'User Name', true, 'user@test.com', 'https://example.com/user.png');

        Test.startTest();
        LookupResult lookupResult = userLookupResultVMapperInstance.getLookupResultFromUserModel(userModel);
        Test.stopTest();

        System.assertEquals('User Name', lookupResult.label, 'Lookup Result label should be the expected label.');
        System.assertEquals(userId, lookupResult.value, 'Lookup Result value should be the expected value.');
        System.assertEquals('standard:avatar', lookupResult.icon, 'Lookup Result icon should be the expected icon.');
        System.assertEquals(
            'User',
            lookupResult.alternativeText,
            'Lookup Result alternative text should be the expected value.'
        );
        System.assertEquals(
            'https://example.com/user.png',
            lookupResult.imageUrl,
            'Lookup Result image url should be the expected value.'
        );
        System.assertEquals('user@test.com', lookupResult.meta, 'Lookup Result meta should be the expected value.');
    }
    /**
     * @description Test method to verify that the getLookupResultFromUserModel method returns a mapped Lookup Result
     */
    @isTest
    private static void getLookupResultsLikeName() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        UserService.instance = new STUB_UserService(userId);
        UserLookupResultVMapper userLookupResultVMapperInstance = UserLookupResultVMapper.getInstance();

        Test.startTest();
        List<LookupResult> lookupResultList = userLookupResultVMapperInstance.getLookupResultsLikeName('User', 1);
        Test.stopTest();

        System.assertEquals(1, lookupResultList.size(), 'Only 1 Lookup result should be retrieved.');

        LookupResult lookupResult = lookupResultList[0];

        System.assertEquals('User Name', lookupResult.label, 'Lookup Result label should be the expected label.');
        System.assertEquals(userId, lookupResult.value, 'Lookup Result value should be the expected value.');
        System.assertEquals('standard:avatar', lookupResult.icon, 'Lookup Result icon should be the expected icon.');
        System.assertEquals(
            'User',
            lookupResult.alternativeText,
            'Lookup Result alternative text should be the expected value.'
        );
        System.assertEquals(
            'https://example.com/user.png',
            lookupResult.imageUrl,
            'Lookup Result image url should be the expected value.'
        );
        System.assertEquals('user@test.com', lookupResult.meta, 'Lookup Result meta should be the expected value.');
    }

    /**
     * @description Stub class to simulate the response from UserMapper
     */
    private class STUB_UserService extends UserService {
        private Id userId;

        STUB_UserService(Id userId) {
            this.userId = userId;
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
