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
 * @description Mapper class to retrieve data needed for User Models
 */
public virtual with sharing class UserMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static UserMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected UserMapper() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of UserMapper.
     ******************************************************************************/
    public static UserMapper getInstance() {
        if (instance == null) {
            instance = new UserMapper();
        }

        return instance;
    }

    /************************************************************************************************************
     * @description Retrieve a UserModel representing a user and its basic fields
     * @param userId The Id of the user to retrieve
     * @return A UserModel
     ************************************************************************************************************/
    public virtual UserModel getUserModelById(Id userId) {
        User userRetrieved = [
            SELECT Id, Name, Email, IsActive, SmallPhotoUrl
            FROM User
            WHERE Id = :userId
            WITH SECURITY_ENFORCED
        ];

        return new UserModel(
            userRetrieved.Id,
            userRetrieved.Name,
            userRetrieved.IsActive,
            userRetrieved.Email,
            userRetrieved.SmallPhotoUrl
        );
    }

    /************************************************************************************************************
     * @description Retrieve a list of UserModel representing a user and their basic fields
     * @param userNameMatch The string to match user names to
     * @param recordLimit The number of records to limit the query to
     * @return A UserModel
     ************************************************************************************************************/
    public virtual List<UserModel> getUserModelsLikeName(String userNameMatch, Integer recordLimit) {
        List<User> usersRetrievedList = [
            SELECT Id, Name, Email, IsActive, SmallPhotoUrl
            FROM User
            WHERE Name LIKE '%userNameMatch%'
            WITH SECURITY_ENFORCED
            LIMIT :recordLimit
        ];

        List<UserModel> userModelList = new List<UserModel>();

        for (User userRetrieved : usersRetrievedList) {
            userModelList.add(
                new UserModel(
                    userRetrieved.Id,
                    userRetrieved.Name,
                    userRetrieved.IsActive,
                    userRetrieved.Email,
                    userRetrieved.SmallPhotoUrl
                )
            );
        }
        return userModelList;
    }

    /************************************************************************************************************
     * @description Retrieve the label for the user object
     * @return The label for the user object
     ************************************************************************************************************/
    public virtual String getModelObjectLabel() {
        return UTIL_Describe.getObjectDescribe('User').getLabel();
    }
}
