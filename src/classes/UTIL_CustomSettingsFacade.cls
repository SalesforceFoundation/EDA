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

    //storing user-level custom settings in-memory to avoid trying to isert/update them
    //twice and thus trigger the "duplicate OwnerId" error
    static Hierarchy_Settings__c settings;

    //storing org-level custom settings in-memory to avoid slowing down the settings page
    static Hierarchy_Settings__c orgSettings;
    
    //list settings
    static List<Affl_Mappings__c> afflMappings;
    static List<Relationship_Auto_Create__c> relationshipAutocreate;
    static List<Relationship_Lookup__c> relationshipLookup;

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
		hs.Account_Processor__c = UTIL_Describe.getAdminAccRecTypeID();
		hs.Accounts_Addresses_Enabled__c = UTIL_Describe.getBizAccRecTypeID() + ';' + UTIL_Describe.getAdminAccRecTypeID() + ';';
		hs.Contacts_Addresses_Enabled__c = true;
		hs.Household_Addresses_RecType__c = UTIL_Describe.getHhAccRecTypeID();
		hs.Reciprocal_Method__c = 'List Setting';
        hs.Store_Errors_On__c = true;
        hs.Error_Notifications_On__c = true;
        hs.Error_Notifications_To__c = ERR_Notifier.NotificationOptions.sysAdmins;
        hs.Disable_Error_Handling__c = false;
        hs.Enable_Debug__c = false;
        hs.Affl_ProgEnroll_Del__c = false;
        hs.Affl_ProgEnroll_Del_Status__c = 'Former';
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
        settings.Accounts_Addresses_Enabled__c = mySettings.Accounts_Addresses_Enabled__c;
        settings.Contacts_Addresses_Enabled__c = mySettings.Contacts_Addresses_Enabled__c;
        settings.Simple_Address_Change_Treated_as_Update__c = mySettings.Simple_Address_Change_Treated_as_Update__c;
        settings.Household_Addresses_RecType__c = mySettings.Household_Addresses_RecType__c;
        settings.Reciprocal_Method__c = mySettings.Reciprocal_Method__c;
        settings.Error_Notifications_On__c = mySettings.Error_Notifications_On__c;
        settings.Error_Notifications_To__c = mySettings.Error_Notifications_To__c;
        settings.Store_Errors_On__c = mySettings.Store_Errors_On__c;
        settings.Affl_ProgEnroll_Del__c = mySettings.Affl_ProgEnroll_Del__c;
        settings.Affl_ProgEnroll_Del_Status__c = mySettings.Affl_ProgEnroll_Del_Status__c;
        settings.Accounts_to_Delete__c =  mySettings.Accounts_to_Delete__c;
        
        orgSettings = settings;
        return settings;
    }
    
    /*******************************************************************************************************
    * @description Retrieves the existing Affiliation Mappings list custom settings.
    * @return List<Affl_Mappings__c> Existing Affiliation Mappings custom settings in a list.
    **/
    @AuraEnabled
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
    @AuraEnabled
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
    @AuraEnabled
    public static List<Relationship_Auto_Create__c> getAutoCreateSettings() {
        if(relationshipAutocreate == null) {
            relationshipAutocreate = [select Id, Name, Campaign_Types__c, Field__c, Object__c, Relationship_Type__c from Relationship_Auto_Create__c
                limit 50000];
        }
        return relationshipAutocreate;
    }
    
    /*******************************************************************************************************
    * @description Saves the Hierarchy Settings passed from the client.
    * @param hierarchySettings The Hierarchy_Settings__c record to upsert.
    * @return void
    **/    
    @AuraEnabled
    public static void saveHierarchySettings(Hierarchy_Settings__c hierarchySettings) {
        upsert hierarchySettings;
    }
    
    /*******************************************************************************************************
    * @description Saves the Affiliation Mappings passed from the client.
    * @param afflMappings The list of Affl_Mappings__c records to updsert.
    * @return void
    **/  
    @AuraEnabled
    public static void saveAfflMappings(List<Affl_Mappings__c> mappings) {
        //upsert afflMappings; We cannot do this because apparently the type information gets lost when called from the client.
        List<Affl_Mappings__c> toInsert = new List<Affl_Mappings__c>();
        List<Affl_Mappings__c> toUpdate = new List<Affl_Mappings__c>();
        for(Affl_Mappings__c setting : mappings) {
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
    * @param reciprocalSettings The list of Relationship_Lookup__c records to upsert.
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
    * @param autoCreateSettings The list of Relationship_Auto_Create__c records to upsert.
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
    
    /*******************************************************************************************************
    * @description Creates a new Affiliation Mapping List Setting record.
    * @param accRecType The value of the Account_Record_Type__c field in the Affl_Mappings__c record to create.
    * @param primaryField The value of the Primary_Affl_Field__c field in the Affl_Mappings__c record to create.
    * @param autoEnroll The value of the Auto_Program_Enrollment__c field in the Affl_Mappings__c record to create.
    * @param autoEnrollStatus The value of the Auto_Program_Enrollment_Status__c field in the Affl_Mappings__c record to create.
    * @param autoEnrollRole The value of the Auto_Program_Enrollment_Role__c field in the Affl_Mappings__c record to create.
    * @return String The Id of the record that has just been created, as a String.
    **/ 
    @AuraEnabled
    public static String newAfflMpg(String accRecType, String primaryField, Boolean autoEnroll, String autoEnrollStatus, 
    String autoEnrollRole) {
        Affl_Mappings__c newMapping = new Affl_Mappings__c(Name = accRecType, Account_Record_Type__c = accRecType, 
        Auto_Program_Enrollment__c = autoEnroll, Auto_Program_Enrollment_Role__c = autoEnrollRole, 
        Auto_Program_Enrollment_Status__c = autoEnrollStatus, Primary_Affl_Field__c = primaryField);
        insert newMapping;
        if(afflMappings != null)
            afflMappings.add(newMapping);
        return newMapping.Id;
    }
    
    /*******************************************************************************************************
    * @description Creates a new Reciprocal List Setting record.
    * @param name The value of the Name field in the Relationship_Lookup__c record to create.
    * @param male The value of the Male__c field in the Relationship_Lookup__c record to create.
    * @param female The value of the Female__c field in the Relationship_Lookup__c record to create.
    * @param neutral The value of the Neutral__c field in the Relationship_Lookup__c record to create.
    * @param active The value of the Active__c field in the Relationship_Lookup__c record to create.
    * @return String The Id of the record that has just been created, as a String.
    **/ 
    @AuraEnabled
    public static String newReciprocalSetting(String name, String male, String female, String neutral, Boolean active) {
        Relationship_Lookup__c newSetting = new Relationship_Lookup__c(Name = name, Female__c = female, Male__c = male, 
                                                                        Neutral__c = neutral, Active__c = active);
        insert newSetting;
        if(relationshipLookup != null)
            relationshipLookup.add(newSetting);
        return newSetting.Id;
    }
    
    /*******************************************************************************************************
    * @description Creates a new Auto-Create List Setting record.
    * @param obj The value of the Object__c field in the Relationship_Auto_Create__c record to create.
    * @param field The value of the Field__c field in the Relationship_Auto_Create__c record to create.
    * @param relType The value of the Relationship_Type__c field in the Relationship_Auto_Create__c record to create.
    * @param campaigns The value of the Campaign_Types__c field in the Relationship_Auto_Create__c record to create.
    * @return String The Id of the record that has just been created, as a String.
    **/ 
    @AuraEnabled
    public static String newAutoCreateSetting(String obj, String field, String relType, String campaigns) {
        Relationship_Auto_Create__c newSetting = new Relationship_Auto_Create__c(Name = 'AutoCreateRel-' + system.now(), 
                        Object__c = obj, Field__c = field, Relationship_Type__c = relType, Campaign_Types__c = campaigns);
        insert newSetting;
        if(relationshipAutoCreate != null)
        relationshipAutoCreate.add(newSetting);
        return newSetting.Id;
    }
    
    /*******************************************************************************************************
    * @description Deletes an Auto-Create List Setting record.
    * @return void
    */
    @AuraEnabled
    public static void deleteAfflMappingRecord(String idString) {
        ID idType = ID.valueOf(IdString);
        delete [select Id from Affl_Mappings__c where Id = :idType];
        if(AfflMappings != null) {
	        for(Integer i = 0; i < AfflMappings.size(); i++) {
	            if(AfflMappings[i].ID == idType) {
	                AfflMappings.remove(i);
	                break;
	            }
	        }
        }
    }
    
    /*******************************************************************************************************
    * @description Deletes a Relationship Lookup List Setting record.
    * @return void
    */
    @AuraEnabled
    public static void deleteRecSettingRecord(String idString) {
        ID idType = ID.valueOf(IdString);
        delete [select Id from Relationship_Lookup__c where Id = :idType];
        if(relationshipLookup != null) {
            for(Integer i = 0; i < relationshipLookup.size(); i++) {
                if(relationshipLookup[i].ID == idType) {
                    relationshipLookup.remove(i);
                    break;
                }
            }
        }
    }
    
    /*******************************************************************************************************
    * @description Deletes an Auto-Create List Setting record.
    * @return void
    */
    @AuraEnabled
    public static void deleteAutoCreateRecord(String idString) {
        ID idType = ID.valueOf(IdString);
        delete [select Id from Relationship_Auto_Create__c where Id = :idType];
        if(relationshipAutoCreate != null) {
            for(Integer i = 0; i < relationshipAutoCreate.size(); i++) {
                if(relationshipAutoCreate[i].ID == idType) {
                    relationshipAutoCreate.remove(i);
                    break;
                }
            }
        }
    }
}