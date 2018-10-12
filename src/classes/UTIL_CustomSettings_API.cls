/*
    Copyright (c) 2018 Salesforce.org
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
* @group API
* @group-content ../../ApexDocContent/API.htm
* @description API class that exposes the Custom Setting Facade Utility methods.
*/
global class UTIL_CustomSettings_API {

    /*******************************************************************************************************
    * @description Returns the default settings.
    * @return Hierarchy_Settings__c custom settings record.
    * At the org level, if no user level settings are defined. The ID field should be checked to determine if
    * the returned record already exists or doesn't exist in the database.
    */
    global static Hierarchy_Settings__c getSettings() {
        return UTIL_CustomSettingsFacade.getSettings();
    }

    /*******************************************************************************************************
    * @description Returns the org-level settings. Default org-level settings will be created
    * if none exist. Meant to be called only from settings page and install script.
    * @return Hierarchy_Settings__c org-level settings.
    */
    global static Hierarchy_Settings__c getOrgSettings() {
        return UTIL_CustomSettingsFacade.getOrgSettings();
    }

    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, but all other methods will see these settings
    * as the configured settings.
    * @param mySettings Settings instance with the values to set.
    * @return Hierarchy_Settings__c The configured settings.
    **/
    global static Hierarchy_Settings__c getSettingsForTests(Hierarchy_Settings__c mySettings) {
        return UTIL_CustomSettingsFacade.getSettingsForTests(mySettings);
    }

}