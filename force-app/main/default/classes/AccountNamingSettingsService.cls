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
* @description Class to act as a service layer buffer to the view mapper layer.
*/
public virtual with sharing class AccountNamingSettingsService {
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static AccountNamingSettingsService instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected AccountNamingSettingsService() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of AccountNamingSettingsService.
    **********************************************************************************/
    public static AccountNamingSettingsService getInstance() {
        if (instance == null) {
            instance = new AccountNamingSettingsService();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Retrieves an Account Naming Settings model with the available 
    * account naming formats specified from hierarchy settings. 
    * @return An AccountNamingSettingsModel
    **********************************************************************************/
    public virtual AccountNamingSettingsModel getAccountNamingSettingsModel() {
        return this.locateAccountNamingSettingsMapper().getAccountNamingSettingsModel();
    }

    /**********************************************************************************
    * @description Retrieves an AccountNamingFormatModel with the available 
    * account administrative account naming formats.
    * @return An AccountNamingFormatModel
    **********************************************************************************/
    public virtual AccountNamingFormatModel getAdministrativeAccountNamingFormatModel() {
        return this.locateAccountNamingSettingsMapper().getAdministrativeAccountNamingFormatModel();
    }

    /**********************************************************************************
    * @description Retrieves an AccountNamingFormatModel with the available 
    * account household account naming formats.
    * @return An AccountNamingFormatModel
    **********************************************************************************/
    public virtual AccountNamingFormatModel getHouseholdAccountNamingFormatModel() {
        return this.locateAccountNamingSettingsMapper().getHouseholdAccountNamingFormatModel();
    }

    /**********************************************************************************
    * @description Retrieves an instance of the AccountNamingSettingsMapper class.
    * @return An instance of AccountNamingSettingsMapper
    **********************************************************************************/
    @TestVisible
    private AccountNamingSettingsMapper locateAccountNamingSettingsMapper() {
        return AccountNamingSettingsMapper.getInstance();
    }
}
