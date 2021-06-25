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
* @description Class to act a mapper for Administrative Account Naming functionality.
*/
public virtual with sharing class AccountNamingSettingsMapper {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static AccountNamingSettingsMapper instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected AccountNamingSettingsMapper() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern.
    * @return The instance of AccountNamingSettingsMapper.
    **********************************************************************************/
    public static AccountNamingSettingsMapper getInstance() {
        if (instance == null) {
            instance = new AccountNamingSettingsMapper();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Retrieves an Account Naming Settings model with naming the values for
    * administrative and household account naming from hierarchy settings. 
    * @return An AccountNamingSettingsModel
    **********************************************************************************/
    public virtual AccountNamingSettingsModel getAccountNamingSettingsModel() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettingsFacade.getSettings();

        AccountNamingSettingsModel accountNamingSetttingsModel = 
            new AccountNamingSettingsModel(
                hierarchySettings.Admin_Account_Naming_Format__c, 
                hierarchySettings.Household_Account_Naming_Format__c, 
                hierarchySettings.Admin_Other_Name_Setting__c,
                hierarchySettings.Household_Other_Name_Setting__c,
                hierarchySettings.Automatic_Household_Naming__c
            );

       return accountNamingSetttingsModel;
    }

    /**********************************************************************************
    * @description Retrieves an Account Naming Settings model with valid naming formats 
    * for administrative accounts. 
    * @return An AccountNamingFormatModel
    **********************************************************************************/
    public virtual AccountNamingFormatModel getAdministrativeAccountNamingFormatModel() {
        Map<String, String> validAdminAccountNamingFormatsByName = new Map<String, String>();

        validAdminAccountNamingFormatsByName.put('lastNameAdminAcc', Label.lastNameAdminAcc);
        validAdminAccountNamingFormatsByName.put('firstNameLastNameAdminACC', Label.firstNameLastNameAdminACC);
        validAdminAccountNamingFormatsByName.put('lastNameFirstNameAdminAcc', Label.lastNameFirstNameAdminAcc);
        validAdminAccountNamingFormatsByName.put('acctNamingOther', Label.acctNamingOther);

        return new AccountNamingFormatModel(validAdminAccountNamingFormatsByName);
    }

    /**********************************************************************************
    * @description Retrieves an Account Naming Settings model with valid naming formats 
    * for household accounts. 
    * @return An AccountNamingFormatModel
    **********************************************************************************/
    public virtual AccountNamingFormatModel getHouseholdAccountNamingFormatModel() {
        Map<String, String> validHHAccountNamingFormatsByName = new Map<String, String>();

        validHHAccountNamingFormatsByName.put('lastNameHH', Label.lastNameHH);
        validHHAccountNamingFormatsByName.put('lastNameFirstNameHH', Label.lastNameFirstNameHH);
        validHHAccountNamingFormatsByName.put('firstNameLastNameHH', Label.firstNameLastNameHH);
        validHHAccountNamingFormatsByName.put('lastNameFamily', Label.lastNameFamily);
        validHHAccountNamingFormatsByName.put('lastNameFirstNameFamily', Label.lastNameFirstNameFamily);
        validHHAccountNamingFormatsByName.put('firstNameLastNameFamily', Label.firstNameLastNameFamily);
        validHHAccountNamingFormatsByName.put('acctNamingOther', Label.acctNamingOther);

        return new AccountNamingFormatModel(validHHAccountNamingFormatsByName);
    }
}
