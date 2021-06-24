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
 * @group EDA Settings
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description Class to generate a view model for Administrative Account Naming Settings.
 */
public virtual with sharing class AccountNamingSettingsVMapper {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static AccountNamingSettingsVMapper instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected AccountNamingSettingsVMapper() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of AccountNamingSettingsVMapper.
     **********************************************************************************/
    public static AccountNamingSettingsVMapper getInstance() {
        if (instance == null) {
            instance = new AccountNamingSettingsVMapper();
        }

        return instance;
    }

    /************************************************************************************
     * @description Retrieve a view model representing the Account Naming settings
     * in Hierarchy Settings.
     * @return An AccountNamingSettingsVModel
     ************************************************************************************/
    public virtual AccountNamingSettingsVModel getAccountNamingSettingsVModel() {
        // get model representing current Account Naming settings in Hierarchy Settings
        AccountNamingSettingsModel currentAccountNamingSettingsModel = this.locateAccountNamingSettingsService()
            .getAccountNamingSettingsModel();

        // get valid naming formats for Admin and HH accounts
        AccountNamingFormatModel administrativeAccountNamingFormatModel = this.locateAccountNamingSettingsService()
            .getAdministrativeAccountNamingFormatModel();
        AccountNamingFormatModel householdAccountNamingFormatModel = this.locateAccountNamingSettingsService()
            .getHouseholdAccountNamingFormatModel();

        List<ComboboxValueVModel> administrativeAccountNamingComboboxValueVModelsList = new List<ComboboxValueVModel>();
        List<ComboboxValueVModel> householdAccountNamingComboboxValueVModelsList = new List<ComboboxValueVModel>();

        for (
            String adminNamingFormat : administrativeAccountNamingFormatModel.validAccountNamingFormatsByName.values()
        ) {
            administrativeAccountNamingComboboxValueVModelsList.add(
                new ComboboxValueVModel(adminNamingFormat, adminNamingFormat)
            );
        }

        for (String hhNamingFormat : householdAccountNamingFormatModel.validAccountNamingFormatsByName.values()) {
            householdAccountNamingComboboxValueVModelsList.add(new ComboboxValueVModel(hhNamingFormat, hhNamingFormat));
        }

        ComboboxVModel administrativeAccountNameFormatComboboxVModel = new ComboboxVModel(
            currentAccountNamingSettingsModel.administrativeAccountNameFormat,
            administrativeAccountNamingComboboxValueVModelsList
        );

        ComboboxVModel householdAccountNameFormatComboboxVModel = new ComboboxVModel(
            currentAccountNamingSettingsModel.householdAccountNamingFormat,
            householdAccountNamingComboboxValueVModelsList
        );

        return new AccountNamingSettingsVModel(
            currentAccountNamingSettingsModel.customAdministrativeAccountNameFormat,
            currentAccountNamingSettingsModel.customHouseholdAccountNameFormat,
            currentAccountNamingSettingsModel.autoHouseholdAccountNamingEnabled,
            administrativeAccountNameFormatComboboxVModel,
            householdAccountNameFormatComboboxVModel
        );
    }

    /**********************************************************************************
     * @description Retrieve an instance of AccountNamingSettingsService.
     * @return An instance of AccountNamingSettingsService class.
     **********************************************************************************/
    @TestVisible
    private AccountNamingSettingsService locateAccountNamingSettingsService() {
        return AccountNamingSettingsService.getInstance();
    }
}
