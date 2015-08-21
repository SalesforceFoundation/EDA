/*
    Copyright (c) 2014, Salesforce.com Foundation
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation
* @date 2014
* @group Utilities
* @description Helper class that retrieves custom settings and sets defaults.
* Needs to be "without sharing" so that the Install Script can run it.
*/
public without sharing class UTIL_CustomSettingsFacade {

    //storing user-level custom settings in-memory to avoid trying to isert/update them
    //twice and thus trigger the "duplicate OwnerId" error
    static Hierarchy_Settings__c settings;

    //storing org-level custom settings in-memory to avoid slowing down the settings page
    static Hierarchy_Settings__c orgSettings;

    /*******************************************************************************************************
    * @description Returns the default settings.
    * @return Hierarchy_Settings__c custom settings record.
    * At the org level, if no user level settings are defined. The ID field should be checked to determine if
    * the returned record already exists or doesn't exist in the database.
    */
    public static Hierarchy_Settings__c getSettings() {
        if(Test.isRunningTest() && settings == null) {
        	settings = new Hierarchy_Settings__c();
        	configSettings(settings);
        } else if (settings == null) {
            settings = Hierarchy_Settings__c.getInstance();
            if(settings.Id == null)
                settings = getOrgSettings();
        }
        return settings;
    }

    /*******************************************************************************************************
    * @description Returns the org-level settings. Default org-level settings will be created
    * if none exist. Meant to be called only from settings page and install script.
    * @return Hierarchy_Settings__c org-level settings.
    */
    public static Hierarchy_Settings__c getOrgSettings() {
        if(orgSettings == null) {
            orgSettings = Hierarchy_Settings__c.getOrgDefaults();
            if(orgSettings.Id == null) {
                configSettings(orgSettings);
                orgSettings.Setupownerid = UserInfo.getOrganizationId();
                if(!Test.isRunningTest())
                    upsert orgSettings;
            }
        }
        return orgSettings;
    }


    /*******************************************************************************************************
     * Private methods that will configure the default org-level custom settings.
     **/
    private static void configSettings(Hierarchy_Settings__c hs) {
		hs.Account_Processor__c = 'Administrative';
		hs.Organizational_Account_Addresses_Enabled__c = true;
		hs.Household_Account_Addresses_Enabled__c = true;
		hs.Reciprocal_Method__c = 'List Settings';
        hs.Automatic_Affiliation_Creation_Turned_On__c = true;
        hs.Store_Errors_On__c = true;
        hs.Error_Notifications_On__c = true;
        hs.Error_Notifications_To__c = ERR_Notifier.NotificationOptions.sysAdmins;
        hs.Disable_Error_Handling__c = false;
        hs.Enable_Debug__c = false;
    }

    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, but all other methods will see these settings
    * as the configured settings.
    * @parameter mySettings Settings instance with the values to set.
    * @return Hierarchy_Settings__c The configured settings.
    **/
    public static Hierarchy_Settings__c getSettingsForTests(Hierarchy_Settings__c mySettings) {
        if(settings == null)
            settings = new Hierarchy_Settings__c();

        //create our own based on what's passed in from the test
        settings.Account_Processor__c = mySettings.Account_Processor__c;
        settings.Organizational_Account_Addresses_Enabled__c = mySettings.Organizational_Account_Addresses_Enabled__c;
        settings.Simple_Address_Change_Treated_as_Update__c = mySettings.Simple_Address_Change_Treated_as_Update__c;
        settings.Household_Account_Addresses_Enabled__c = mySettings.Household_Account_Addresses_Enabled__c;
        settings.Reciprocal_Method__c = mySettings.Reciprocal_Method__c;
        settings.Gender_Field__c = mySettings.Gender_Field__c;
        settings.Automatic_Affiliation_Creation_Turned_On__c = mySettings.Automatic_Affiliation_Creation_Turned_On__c;
        settings.Error_Notifications_On__c = mySettings.Error_Notifications_On__c;
        settings.Error_Notifications_To__c = mySettings.Error_Notifications_To__c;
        settings.Store_Errors_On__c = mySettings.Store_Errors_On__c;
        
        orgSettings = settings;
        return settings;
    }
}