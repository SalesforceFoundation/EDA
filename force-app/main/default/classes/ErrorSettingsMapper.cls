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
 * @description Mapper class for Error Settings functionality in EDA settings
 */
public virtual with sharing class ErrorSettingsMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static ErrorSettingsMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected ErrorSettingsMapper() {
    }

    /******************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of ErrorSettingsMapper.
     ******************************************************************************/
    public static ErrorSettingsMapper getInstance() {
        if (instance == null) {
            instance = new ErrorSettingsMapper();
        }

        return instance;
    }

    /*******************************************************************************************
     * @description Retrieve a model representing error settings specified in Hierarchy Settings.
     * @return An ErrorSettingsModel
     ********************************************************************************************/
    public virtual ErrorSettingsModel getErrorSettingsModel() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettingsFacade.getSettings();
        String errorNotificationsCategory;

        if (String.isBlank(hierarchySettings.Error_Notifications_To__c)) {
            errorNotificationsCategory = '';
        } else if (hierarchySettings.Error_Notifications_To__c == 'All Sys Admins') {
            errorNotificationsCategory = 'All Sys Admins';
        } else if (hierarchySettings.Error_Notifications_To__c.startsWith(this.getUserIdPrefix())) {
            errorNotificationsCategory = 'User';
        } else if (hierarchySettings.Error_Notifications_To__c.startsWith(this.getChatterGroupIdPrefix())) {
            errorNotificationsCategory = 'Chatter Group';
        }

        return new ErrorSettingsModel(
            hierarchySettings.Store_Errors_On__c,
            hierarchySettings.Error_Notifications_On__c,
            errorNotificationsCategory,
            hierarchySettings.Error_Notifications_To__c,
            hierarchySettings.Enable_Debug__c,
            !hierarchySettings.Disable_Error_Handling__c
        );
    }

    /**********************************************************************************
     * @description Retrieves the valid error notification recipient categories for
     * Error Settings
     * @return A map of strings to labels for valid error notification recipient
     * categories
     **********************************************************************************/
    @TestVisible
    public virtual Map<String, String> getValidErrorNotificationRecipientCategoryLabelsByValue() {
        Map<String, String> validErrorNotificationRecipientCategoryLabelsByValue = new Map<String, String>();

        validErrorNotificationRecipientCategoryLabelsByValue.put('All Sys Admins', Label.stgOptAllSysAdmins);
        validErrorNotificationRecipientCategoryLabelsByValue.put('User', Label.stgOptUser);
        validErrorNotificationRecipientCategoryLabelsByValue.put('Chatter Group', Label.stgOptChatterGroup);

        return validErrorNotificationRecipientCategoryLabelsByValue;
    }

    /*******************************************************************************************
     * @description Retrieves the Id prefix for the User SObjectType in a chaching-safe method
     * @return The Id prefix for the User SObjectType
     ********************************************************************************************/
    @TestVisible
    private String getUserIdPrefix() {
        Schema.DescribeSObjectResult userSObjectDescribeResult = UTIL_Describe.getObjectDescribe('User');
        return userSObjectDescribeResult.getKeyPrefix();
    }

    /*******************************************************************************************
     * @description Retrieves the Id prefix for the CollaborationGroup SObjectType, Chatter
     * Groups, in a chaching-safe method or an invalid match if chatter is not enabled
     * @return The Id prefix for the CollaborationGroup SObjectType
     ********************************************************************************************/
    @TestVisible
    private String getChatterGroupIdPrefix() {
        String keyPrefix = 'NeverValid';
        //Avoid hard chatter dependency
        if (Schema.SObjectType.User.isFeedEnabled()) {
            Schema.DescribeSObjectResult chatterGroupSObjectDescribeResult = UTIL_Describe.getObjectDescribe(
                'CollaborationGroup'
            );
            keyPrefix = chatterGroupSObjectDescribeResult.getKeyPrefix();
        }

        return keyPrefix;
    }
}
