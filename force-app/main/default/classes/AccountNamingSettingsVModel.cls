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
 * @description View model to represent data associated with Account Naming functionality.
 */
public with sharing class AccountNamingSettingsVModel {
    @AuraEnabled
    public String customAdministrativeAccountNameFormat { get; private set; }

    @AuraEnabled
    public String customHouseholdAccountNameFormat { get; private set; }

    @AuraEnabled
    public Boolean autoHouseholdAccountNamingEnabled { get; private set; }

    @AuraEnabled
    public ComboboxVModel administrativeAccountNameFormat { get; private set; }

    @AuraEnabled
    public ComboboxVModel householdAccountNameFormat { get; private set; }

    /**************************************************************************************************************************
     * @description Five argument constructor
     * @param  customAdministrativeAccountNameFormat A String representing a custom format to be used for Admin account names
     * @param  customHouseholdAccountNameFormat A String representing a custom format to be used for HH account names
     * @param  autoHouseholdAccountNamingEnabled A Boolean to indicate whether automatic HH naming functionality is enabled
     * @param  administrativeAccountNameFormat A ComboboxVModel representing the selected and available formats for Admin Account naming
     * @param  householdAccountNameFormat A ComboboxVModel representing the the selected and available formats for HH Account naming
     * @return An AccountNamingSettingsVModel with all properties populated
     **************************************************************************************************************************/
    public AccountNamingSettingsVModel(
        String customAdministrativeAccountNameFormat,
        String customHouseholdAccountNameFormat,
        Boolean autoHouseholdAccountNamingEnabled,
        ComboboxVModel administrativeAccountNameFormat,
        ComboboxVModel householdAccountNameFormat
    ) {
        this.customAdministrativeAccountNameFormat = String.isBlank(customAdministrativeAccountNameFormat)
            ? ''
            : customAdministrativeAccountNameFormat;

        this.customHouseholdAccountNameFormat = String.isBlank(customHouseholdAccountNameFormat)
            ? ''
            : customHouseholdAccountNameFormat;

        this.autoHouseholdAccountNamingEnabled = autoHouseholdAccountNamingEnabled;
        this.administrativeAccountNameFormat = administrativeAccountNameFormat;
        this.householdAccountNameFormat = householdAccountNameFormat;
    }
}
