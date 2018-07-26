/*
    Copyright (c) 2018 Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
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
* @date 2018
* @group Utilities
* @description Unit tests for UTIL_Profile class
*/
@isTest
private class UTIL_Profile_TEST {

    /**************************************************************************************************************************
    @description Test multiple calls of the method getInstance() to make sure the UTIL_Profile instance is constructed only once.
    verify: The query should run only once.
    ***************************************************************************************************************************/
    private static testMethod void testGetInstanceQueriesOnceOnMultipleCalls() {
        System.assertEquals(0, Limits.getQueries(), 'The query count should be 0');

        UTIL_Profile profileUtil = UTIL_Profile.getInstance();
        //The getInstance() executes a query on the Profile.
        System.assertNotEquals(null, profileUtil, 'The getInstance() should return an instance of UTIL_Profile');
        System.assertEquals(1, Limits.getQueries(), 'The query count should be 1 because the getInstance() constructs the UTIL_Profile');

        profileUtil = UTIL_Profile.getInstance();

        //Verify the getInstance() does not execute the query again.
        System.assertNotEquals(null, profileUtil, 'The getInstance() should have the same instance of UTIL_Profile');
        System.assertEquals(1, Limits.getQueries(), 'The query count should not increase');
    }

    /**************************************************************************************************************************
    @description Test the getProfileIds() with valid Profile name.
    verify: getProfileIds() returns all Profile Ids for the specified Profile Name
    ***************************************************************************************************************************/
    private static testMethod void testGetProfileIdsWithValidProfileName() {
        Map<String, List<Profile>> orgProfilesByName = getProfilesByName();

        Test.startTest();
        UTIL_Profile profileUtil = UTIL_Profile.getInstance();
        Test.stopTest();

        System.assertNotEquals(null, profileUtil, 'The GetInstance should return an instance of UTIL_Profile');

        for (String profileName : orgProfilesByName.keySet()) {
            List<Id> profileIds = profileUtil.getProfileIds(profileName);
            Set<Id> currentProfileIds = new Map<Id, Profile>(orgProfilesByName.get(profileName)).keySet();

            System.assertEquals(
                    currentProfileIds.size(),
                    profileIds.size(),
                    'The number of Profiles for ' + profileName + ' profile should be equal to the profileUtil.getProfileIds()'
            );

            System.assert(currentProfileIds.containsAll(profileIds), 'Expected and retrieved Profile Ids should be the same');
        }
    }

    /**************************************************************************************************************************
    @description Test the getProfileIds() with invalid Profile name.
    verify: getProfileIds() returns empty List
    ***************************************************************************************************************************/
    private static testMethod void testGetProfileIdsWithInvalidProfileName() {
        Test.startTest();
        UTIL_Profile profileUtil = UTIL_Profile.getInstance();
        Test.stopTest();

        System.assertNotEquals(null, profileUtil, 'The getInstance() should return an instance of UTIL_Profile');
        System.assertEquals(0, profileUtil.getProfileIds('INVALID_PROFILE_NAME').size(), 'No profile Id should be returned');
    }

    // Helpers
    /////////////

    /*********************************************************************************************************
    * @description Get a Map of all Profiles grouped by Name
    * @return Map<String, List<Profile>> Map of Profiles grouped by Name
    */
    private static Map<String, List<Profile>> getProfilesByName() {
        Map<String, List<Profile>> result = new Map<String,List<Profile>>();

        for (Profile currentProfile :[
                SELECT Name
                FROM Profile
        ]) {
            if (result.containsKey(currentProfile.Name) == false) {
                result.put(currentProfile.Name, new List<Profile>());
            }
            result.get(currentProfile.Name).add(currentProfile);
        }

        return result;
    }
}