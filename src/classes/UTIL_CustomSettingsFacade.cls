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
    @AuraEnabled
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
        settings.Error_Notifications_On__c = mySettings.Error_Notifications_On__c;
        settings.Error_Notifications_To__c = mySettings.Error_Notifications_To__c;
        settings.Store_Errors_On__c = mySettings.Store_Errors_On__c;
        
        orgSettings = settings;
        return settings;
    }
    
    /*******************************************************************************************************
    * @description Retrieves the existing Affiliation Mappings list custom settings.
    * @return List<Affl_Mappings__c> Existing Affiliation Mappings custom settings in a list.
    **/
    @AuraEnabled
    public static List<Affl_Mappings__c> getAfflMappings() {
        return [select Account_Record_Type__c, Primary_Affl_Field__c, Auto_Program_Enrollment__c, Auto_Program_Enrollment_Role__c, 
                                                      Auto_Program_Enrollment_Status__c from Affl_Mappings__c];
    }
    
    /*******************************************************************************************************
    * @description Retrieves the existing Relationship Reciprocal list custom settings.
    * @return List<Relationship_Lookup__c> Existing Relationship Reciprocal custom settings in a list.
    **/
    @AuraEnabled
    public static List<Relationship_Lookup__c> getReciprocalSettings() {
        return [select Name, Active__c, Female__c, Male__c, Neutral__c from Relationship_Lookup__c];
    }
    
    /*******************************************************************************************************
    * @description Retrieves the existing Relationship Auto-Create list custom settings.
    * @return List<Relationship_Auto_Create__c> Existing Relationship Auto-Create custom settings in a list.
    **/
    @AuraEnabled
    public static List<Relationship_Auto_Create__c> getAutoCreateSettings() {
        return [select Campaign_Types__c, Field__c, Object__c, Relationship_Type__c from Relationship_Auto_Create__c];
    }
    
    /*******************************************************************************************************
    * @description Saves the Hierarchy Settings passed from the client.
    * @return void
    **/    
    @AuraEnabled
    public static void saveHierarchySettings(Hierarchy_Settings__c hierarchySettings) {
        upsert hierarchySettings;
    }
    
    /*******************************************************************************************************
    * @description Saves the Affiliation Mappings passed from the client.
    * @return void
    **/  
    @AuraEnabled
    public static void saveAfflMappings(List<Affl_Mappings__c> afflMappings) {
        //upsert afflMappings; We cannot do this because apparently the type information gets lost when called from the client.
        List<Affl_Mappings__c> toInsert = new List<Affl_Mappings__c>();
        List<Affl_Mappings__c> toUpdate = new List<Affl_Mappings__c>();
        for(Affl_Mappings__c setting : afflMappings) {
            if(setting.ID == null) {
                toInsert.add(setting);
            } else {
                toUpdate.add(setting);
            }
        }
        insert toInsert;
        update toUpdate;
    }
    
    /*******************************************************************************************************
    * @description Saves the Reciprocal Settings passed from the client.
    * @return void
    **/  
    @AuraEnabled
    public static void saveReciprocalSettings(List<Relationship_Lookup__c> reciprocalSettings) {
        //upsert reciprocalSettings; We cannot do this because apparently the type information gets lost when called from the client.
        List<Relationship_Lookup__c> toInsert = new List<Relationship_Lookup__c>();
        List<Relationship_Lookup__c> toUpdate = new List<Relationship_Lookup__c>();
        for(Relationship_Lookup__c setting : reciprocalSettings) {
            if(setting.ID == null) {
                toInsert.add(setting);
            } else {
                toUpdate.add(setting);
            }
        }
        insert toInsert;
        update toUpdate;
    }
    
    /*******************************************************************************************************
    * @description Saves the Auto-Create Settings passed from the client.
    * @return void
    **/  
    @AuraEnabled
    public static void saveAutoCreateSettings(List<Relationship_Auto_Create__c> autoCreateSettings) {
        //upsert autoCreateSettings; We cannot do this because apparently the type information gets lost when called from the client.
        List<Relationship_Auto_Create__c> toInsert = new List<Relationship_Auto_Create__c>();
        List<Relationship_Auto_Create__c> toUpdate = new List<Relationship_Auto_Create__c>();
        for(Relationship_Auto_Create__c setting : autoCreateSettings) {
            if(setting.ID == null) {
                toInsert.add(setting);
            } else {
                toUpdate.add(setting);
            }
        }
        insert toInsert;
        update toUpdate;
    }
    
    @AuraEnabled
    public static void newReciprocalSetting(String name, String male, String female, String neutral, Boolean active) {
        Relationship_Lookup__c newSetting = new Relationship_Lookup__c(Name = name, Female__c = female, Male__c = male, 
                                                                        Neutral__c = neutral, Active__c = active);
        insert newSetting;
    }
}