/*
    Copyright (c) 2014, Salesforce.org
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
* @date 2014
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description Helper class that retrieves custom settings and sets defaults.
* Needs to be "without sharing" so that the Install Script can run it.
*/
public without sharing class UTIL_CustomSettingsFacade {

    //storing user-level custom settings in-memory to avoid trying to insert/update them
    //twice and thus trigger the "duplicate OwnerId" error
    static Hierarchy_Settings__c settings;

    //storing org-level custom settings in-memory to avoid slowing down the settings page
    static Hierarchy_Settings__c orgSettings;

    //list settings
    public static List<Affl_Mappings__c> afflMappings;
    public static List<Relationship_Auto_Create__c> relationshipAutocreate;
    public static List<Relationship_Lookup__c> relationshipLookup;

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
		hs.Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID();
		hs.Accounts_Addresses_Enabled__c = UTIL_Describe.getBizAccRecTypeID() + ';' + UTIL_Describe.getAdminAccRecTypeID() + ';';
        hs.Disable_Preferred_Email_Enforcement__c = false;
		hs.Contacts_Addresses_Enabled__c = true;
		hs.Household_Addresses_RecType__c = UTIL_Describe.getHhAccRecTypeID();
		hs.Reciprocal_Method__c = 'List Setting';
        hs.Store_Errors_On__c = true;
        hs.Error_Notifications_On__c = false;
        hs.Error_Notifications_To__c = ERR_Notifier.NotificationOptions.sysAdmins;
        hs.Disable_Error_Handling__c = false;
        hs.Enable_Debug__c = false;
        hs.Affl_ProgEnroll_Del__c = false;
        hs.Affl_ProgEnroll_Del_Status__c = 'Former';
        hs.Async_Error_Check_Last_Run__c = null;
        hs.Admin_Account_Naming_Format__c = '{!LastName} Administrative Account';
        hs.Household_Account_Naming_Format__c = '{!LastName} Household';
        hs.Automatic_Household_Naming__c = false;
        hs.Affiliation_Record_Type_Enforced__c = false;
        hs.Administrative_Account_Record_Type__c = UTIL_Describe.getAdminAccRecTypeID();

    }

    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, but all other methods will see these settings
    * as the configured settings.
    * @param mySettings Settings instance with the values to set.
    * @return Hierarchy_Settings__c The configured settings.
    **/
    public static Hierarchy_Settings__c getSettingsForTests(Hierarchy_Settings__c mySettings) {
        if(settings == null)
            settings = new Hierarchy_Settings__c();

        //create our own based on what's passed in from the test
        settings.Account_Processor__c = mySettings.Account_Processor__c;
        settings.Accounts_Addresses_Enabled__c = mySettings.Accounts_Addresses_Enabled__c;
        settings.Contacts_Addresses_Enabled__c = mySettings.Contacts_Addresses_Enabled__c;
        settings.Simple_Address_Change_Treated_as_Update__c = mySettings.Simple_Address_Change_Treated_as_Update__c;
        settings.Household_Addresses_RecType__c = mySettings.Household_Addresses_RecType__c;
        settings.Reciprocal_Method__c = mySettings.Reciprocal_Method__c;
        settings.Error_Notifications_On__c = mySettings.Error_Notifications_On__c;
        settings.Error_Notifications_To__c = mySettings.Error_Notifications_To__c;
        settings.Store_Errors_On__c = mySettings.Store_Errors_On__c;
        settings.Async_Error_Check_Last_Run__c = mySettings.Async_Error_Check_Last_Run__c;
        settings.Affl_ProgEnroll_Del__c = mySettings.Affl_ProgEnroll_Del__c;
        settings.Affl_ProgEnroll_Del_Status__c = mySettings.Affl_ProgEnroll_Del_Status__c;
        settings.Accounts_to_Delete__c =  mySettings.Accounts_to_Delete__c;
        settings.Enable_Course_Connections__c = mySettings.Enable_Course_Connections__c;
        settings.Faculty_RecType__c = mySettings.Faculty_RecType__c;
        settings.Student_RecType__c = mySettings.Student_RecType__c;
        settings.Disable_Preferred_Email_Enforcement__c = mySettings.Disable_Preferred_Email_Enforcement__c;
        settings.Household_Account_Naming_Format__c = mySettings.Household_Account_Naming_Format__c;
        settings.Automatic_Household_Naming__c = mySettings.Automatic_Household_Naming__c;
        settings.Affiliation_Record_Type_Enforced__c = mySettings.Affiliation_Record_Type_Enforced__c;
        settings.Administrative_Account_Record_Type__c = mySettings.Administrative_Account_Record_Type__c;
        
        orgSettings = settings;
        return settings;
    }

    /*******************************************************************************************************
    * @description Retrieves the existing Affiliation Mappings list custom settings.
    * @return List<Affl_Mappings__c> Existing Affiliation Mappings custom settings in a list.
    **/
    public static List<Affl_Mappings__c> getAfflMappings() {
        if(afflMappings == null) {
        afflMappings = [select Account_Record_Type__c, Primary_Affl_Field__c, Auto_Program_Enrollment__c, Auto_Program_Enrollment_Role__c,
               Auto_Program_Enrollment_Status__c from Affl_Mappings__c order by Account_Record_Type__c limit 50000];
        }
        return afflMappings;
    }

    /*******************************************************************************************************
    * @description Retrieves the existing Relationship Reciprocal list custom settings.
    * @return List<Relationship_Lookup__c> Existing Relationship Reciprocal custom settings in a list.
    **/
    public static List<Relationship_Lookup__c> getReciprocalSettings() {
        if(relationshipLookup == null) {
            relationshipLookup = [select Id, Name, Active__c, Female__c, Male__c, Neutral__c from Relationship_Lookup__c limit 50000];
        }
        return relationshipLookup;
    }

    /*******************************************************************************************************
    * @description Retrieves the existing Relationship Auto-Create list custom settings.
    * @return List<Relationship_Auto_Create__c> Existing Relationship Auto-Create custom settings in a list.
    **/
    public static List<Relationship_Auto_Create__c> getAutoCreateSettings() {
        if(relationshipAutocreate == null) {
            relationshipAutocreate = [select Id, Name, Campaign_Types__c, Field__c, Object__c, Relationship_Type__c from Relationship_Auto_Create__c
                limit 50000];
        }
        return relationshipAutocreate;
    }

    /*******************************************************************************************************
    * @description Gets if Course Connections is enabled
    * @return Boolean
    */
    public static Boolean courseConnectionsEnabled() {
        if (getSettings().Enable_Course_Connections__c) {
            if (getSettings().Student_RecType__c != null &&
                 getSettings().Faculty_RecType__c != null &&
                 getSettings().Student_RecType__c.length() >= 15 &&
                 getSettings().Faculty_RecType__c.length() >= 15 &&
                 getSettings().Faculty_RecType__c != getSettings().Student_RecType__c) {
                return true;
            } else if (Test.isRunningTest()) {
                return true;
            }
        }
        return false;
    }
}