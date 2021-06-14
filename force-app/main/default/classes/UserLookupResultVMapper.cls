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
 * @description View Mapper class for User Lookup Search functionality in EDA settings
 */
public virtual with sharing class UserLookupResultVMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static UserLookupResultVMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected UserLookupResultVMapper() {
    }

    /******************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of UserLookupResultVMapper.
     ******************************************************************************/
    public static UserLookupResultVMapper getInstance() {
        if (instance == null) {
            instance = new UserLookupResultVMapper();
        }

        return instance;
    }

    /************************************************************************************************************
     * @description Retrieve a list of sorted LookupResults representing a user
     * @param userNameMatch The string to match user names to
     * @param recordLimit The number of records to limit the query to
     * @return A list of Lookup Results with a name matching the search string
     ************************************************************************************************************/
    public virtual List<LookupResult> getLookupResultsLikeUserName(String userNameMatch, Integer recordLimit) {
        List<UserModel> userModelList = this.locateUserService().getUserModelsLikeName(userNameMatch, recordLimit);
        List<LookupResult> lookupResultList = new List<LookupResult>();

        for (UserModel userModel : userModelList) {
            lookupResultList.add(this.getLookupResultFromUserModel(userModel));
        }

        lookupResultList.sort();
        return lookupResultList;
    }

    /************************************************************************************************************
     * @description Creates a lookup result from a user model
     * @param userModel The user model to convert to a Lookup Result
     * @return The lookup result
     ************************************************************************************************************/
    public virtual LookupResult getLookupResultFromUserModel(UserModel userModel) {
        String lookupResultLabel = UserService.getInstance().getModelObjectLabel();

        return new LookupResult(
            userModel.name,
            userModel.id,
            'standard:avatar',
            userModel.smallPhotoUrl,
            lookupResultLabel,
            userModel.email
        );
    }

    /******************************************************************************
     * @description Retrieves an instance of the UserService class.
     * @return An instance of UserService.
     ******************************************************************************/
    @TestVisible
    private UserService locateUserService() {
        return UserService.getInstance();
    }
}
