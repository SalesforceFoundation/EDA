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
        ComboboxVModel errorNotificationsRecipientCategoryComboboxVModel = this.getErrorNotificationsRecipientCategoryComboboxVModel(
            errorSettingsModel
        );

        return new ErrorSettingsVModel(
            errorSettingsModel.storeErrors,
            errorSettingsModel.sendErrorNotifications,
            errorNotificationsRecipientCategoryComboboxVModel,
            errorSettingsModel.enableDebug,
            errorSettingsModel.errorHandling
        );
    }

    /******************************************************************************
     * @description Retrieve the valid error notification recipient category
     * combobox view model
     * @param errorSettingsModel The error settings model to get combobox value
     * Vmodels from
     * @return The valid error notification recipient category combobox view model
     ******************************************************************************/
    private ComboboxVModel getErrorNotificationsRecipientCategoryComboboxVModel(ErrorSettingsModel errorSettingsModel) {
        List<ComboboxValueVModel> errorNotificationsRecipientCategoryVModelList = new List<ComboboxValueVModel>();

        List<String> errorNotificationsRecipientCategoryValueList = new List<String>(
            errorSettingsModel.validErrorNotificationsRecipientCategoryLabelsByValue.keySet()
        );
        errorNotificationsRecipientCategoryValueList.sort();

        for (String categoryValue : errorNotificationsRecipientCategoryValueList) {
            errorNotificationsRecipientCategoryVModelList.add(
                new ComboboxValueVModel(
                    errorSettingsModel.validErrorNotificationsRecipientCategoryLabelsByValue.get(categoryValue),
                    categoryValue
                )
            );
        }

        return new ComboboxVModel(
            errorSettingsModel.errorNotificationsRecipientCategory,
            errorNotificationsRecipientCategoryVModelList
        );
    }

    /******************************************************************************
     * @description Retrieve an instance of the ErrorSettingsService class.
     * @return An instance of ErrorSettingsService
     ******************************************************************************/
    @TestVisible
    private ErrorSettingsService locateErrorSettingsService() {
        return ErrorSettingsService.getInstance();
    }
}
