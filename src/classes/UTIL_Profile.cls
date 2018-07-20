/*
    Copyright (c) 2018, Salesforce.org
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
* @description Utility for Profiles
*/
public class UTIL_Profile {
    /** @description System Administrator Profile Name */
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';

    /** @description static instance of the current class (UTIL_Profile). It is used as the instance in a Singleton context */
    private static UTIL_Profile utilProfile;

    /** @description Map of the Profiles grouped by Name */
    private Map<String, List<Profile>> profilesByName;

    /*********************************************************************************************************
    * @description Get the instance of the current class
    * @return UTIL_Profile The instance of the current class.
    */
    public static UTIL_Profile getInstance() {
        if (utilProfile == null) {
            utilProfile = new UTIL_Profile();
        }
        return utilProfile;
    }

    /*********************************************************************************************************
    * @description The Constructor, which is private because we are using the Singleton Pattern.
    * The UTIL_Profile object needs to be constructed only from the static method getInstance()
    */
    private UTIL_Profile() {
        profilesByName = getProfilesByName();
    }

    /*********************************************************************************************************
    * @description Get Profile Ids for the specified Profile Name
    * @param profileName Profile Name
    * @return List<Id> List of Profile Ids
    */
    public List<Id> getProfileIds(String profileName) {
        if (profilesByName.containsKey(profileName) == false) {
            return new List<Id>();
        }

        Set<Id> profileIds = new Map<Id, Profile>(profilesByName.get(profileName)).keySet();
        return new List<Id>(profileIds);
    }

    /*********************************************************************************************************
    * @description Build a Map of Profiles grouped by Name
    * @return Map<String, List<Profile>> Map of Profiles grouped by Name
    */
    private Map<String, List<Profile>> getProfilesByName() {
        Map<String, List<Profile>> result = new Map<String, List<Profile>>();

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