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
 * @description View Mapper class for Error Settings functionality in EDA settings
 */
public virtual with sharing class ErrorSettingsVMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static ErrorSettingsVMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected ErrorSettingsVMapper() {
    }

    /******************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of ErrorSettingsVMapper.
     ******************************************************************************/
    public static ErrorSettingsVMapper getInstance() {
        if (instance == null) {
            instance = new ErrorSettingsVMapper();
        }

        return instance;
    }

    /*********************************************************************************************
     * @description Retrieve a view model representing the error settings in hierarchy settings.
     * @return An ErrorSettingsVModel
     *********************************************************************************************/
    public virtual ErrorSettingsVModel getErrorSettingsViewModel() {
        ErrorSettingsModel errorSettingsModel = this.locateErrorSettingsService().getErrorSettingsModel();
        ComboboxVModel errorNotificationsRecipientCategoryVModel = this.getErrorNotificationsRecipientCategoryVModel(
            errorSettingsModel
        );
        LookupResult errorNotificationRecipientVModel = this.getLookupResultForSetting(
            errorSettingsModel.errorNotificationsRecipientCategory,
            errorSettingsModel.errorNotificationsRecipient
        );

        return new ErrorSettingsVModel(
            errorSettingsModel.storeErrors,
            errorSettingsModel.sendErrorNotifications,
            errorNotificationsRecipientCategoryVModel,
            errorSettingsModel.enableDebug,
            errorSettingsModel.errorHandling,
            errorNotificationRecipientVModel
        );
    }

    /******************************************************************************
     * @description Retrieve the valid error notification recipient category
     * combobox view model
     * @param errorSettingsModel The error settings model to get combobox value
     * Vmodels from
     * @return The valid error notification recipient category combobox view model
     ******************************************************************************/
    @TestVisible
    private ComboboxVModel getErrorNotificationsRecipientCategoryVModel(ErrorSettingsModel errorSettingsModel) {
        List<ComboboxValueVModel> errorNotificationsRecipientCategoryVModelList = new List<ComboboxValueVModel>();

        Map<String, String> errorNotificationsRecipientCategoryByValue = this.locateErrorSettingsService()
            .getValidErrorNotificationRecipientCategoryLabelsByValue();

        List<String> errorNotificationsRecipientCategoryValueList = new List<String>(
            errorNotificationsRecipientCategoryByValue.keySet()
        );
        errorNotificationsRecipientCategoryValueList.sort();

        for (String categoryValue : errorNotificationsRecipientCategoryValueList) {
            errorNotificationsRecipientCategoryVModelList.add(
                new ComboboxValueVModel(errorNotificationsRecipientCategoryByValue.get(categoryValue), categoryValue)
            );
        }

        return new ComboboxVModel(
            errorSettingsModel.errorNotificationsRecipientCategory,
            errorNotificationsRecipientCategoryVModelList
        );
    }

    /******************************************************************************
     * @description Retrieve the lookup result for a user based on its id
     * @param userIdString The string representing a user Id, representing the
     * possibility that it is not an Id
     * @return A LookupResult for a user model
     ******************************************************************************/
    @TestVisible
    private LookupResult getLookupResultForSetting(String errorRecipientCategory, String errorRecipient) {
        switch on errorRecipientCategory {
            when 'All Sys Admins' {
                return null;
            }
            when 'Chatter Group' {
                return this.getChatterGroupLookupResultById(errorRecipient);
            }
            when 'User' {
                return this.getUserLookupResultById(errorRecipient);
            }
            when else {
                //Deliberately permit invalid values to be pulled but have it be blank
                return null;
            }
        }
    }

    /******************************************************************************
     * @description Retrieve the lookup result for a user based on its id
     * @param userIdString The string representing a user Id, representing the
     * possibility that it is not an Id
     * @return A LookupResult for a user id
     ******************************************************************************/
    @TestVisible
    private LookupResult getUserLookupResultById(String userIdString) {
        Id userId;

        try {
            userId = Id.valueOf(userIdString);
        } catch (System.StringException se) {
            return null;
        }

        UserModel userModel = UserService.getInstance().getUserModelById(userId);

        if (userModel == null) {
            return null;
        }

        return this.locateUserLookupResultVMapper().getLookupResultFromUserModel(userModel);
    }

    /******************************************************************************
     * @description Retrieve the lookup result for a chatter group based on its id
     * @param chatterGroupIdString The string representing a chatter group Id,
     * representing the possibility that it is not an Id
     * @return A LookupResult for a chatter group id
     ******************************************************************************/
    @TestVisible
    private LookupResult getChatterGroupLookupResultById(String chatterGroupIdString) {
        Id chatterGroupId;

        try {
            chatterGroupId = Id.valueOf(chatterGroupIdString);
        } catch (System.StringException se) {
            return null;
        }

        ChatterGroupModel chatterGroupModel = ChatterGroupService.getInstance()
            .getChatterGroupModelById(chatterGroupId);

        if (chatterGroupModel == null) {
            return null;
        }

        return this.locateChatterGroupLookupResultVMapper().getLookupResultFromChatterGroupModel(chatterGroupModel);
    }

    /******************************************************************************
     * @description Retrieve an instance of the ErrorSettingsService class.
     * @return An instance of ErrorSettingsService
     ******************************************************************************/
    @TestVisible
    private ErrorSettingsService locateErrorSettingsService() {
        return ErrorSettingsService.getInstance();
    }

    /******************************************************************************
     * @description Retrieve an instance of the UserService class.
     * @return An instance of UserService
     ******************************************************************************/
    @TestVisible
    private UserService locateUserService() {
        return UserService.getInstance();
    }

    /******************************************************************************
     * @description Retrieve an instance of the ChatterGroupService class.
     * @return An instance of ChatterGroupService
     ******************************************************************************/
    @TestVisible
    private ChatterGroupService locateChatterGroupService() {
        return ChatterGroupService.getInstance();
    }

    /******************************************************************************
     * @description Retrieve an instance of the UserLookupResultVMapper class.
     * @return An instance of UserLookupResultVMapper
     ******************************************************************************/
    @TestVisible
    private UserLookupResultVMapper locateUserLookupResultVMapper() {
        return UserLookupResultVMapper.getInstance();
    }

    /******************************************************************************
     * @description Retrieve an instance of the ChatterGroupLookupResultVMapper class.
     * @return An instance of ChatterGroupLookupResultVMapper
     ******************************************************************************/
    @TestVisible
    private ChatterGroupLookupResultVMapper locateChatterGroupLookupResultVMapper() {
        return ChatterGroupLookupResultVMapper.getInstance();
    }
}
