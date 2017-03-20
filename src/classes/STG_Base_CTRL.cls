/*
    Copyright (c) 2017, Salesforce.org
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
* @date 2017
* @group Settings
* @group-content ../../ApexDocContent/Settings.htm
* @description Base Class for Settings Components with Aura Enabled Methods
*/
public with sharing class STG_Base_CTRL {

    public Boolean hasPerm {get;set;} // Permission check

    /*******************************************************************************************
    * @description Constructor that sets boolean value to determine is User can access Settings page 
    */ 	
	public STG_Base_CTRL() {
        User user = [SELECT Profile.PermissionsCustomizeApplication FROM User where Id = :UserInfo.getUserId()];
        this.hasPerm = user.Profile.PermissionsCustomizeApplication;
	}

	@AuraEnabled
	public static Hierarchy_Settings__c getSettings() {
		return UTIL_CustomSettingsFacade.getSettings();
	}

	@AuraEnabled
	public static List<Affl_Mappings__c> getAfflMappings() {
		return UTIL_CustomSettingsFacade.getAfflMappings();
	}

	@AuraEnabled
	public static List<Relationship_Lookup__c> getReciprocalSettings() {
		return UTIL_CustomSettingsFacade.getReciprocalSettings();
	}

	@AuraEnabled
    public static List<Relationship_Auto_Create__c> getAutoCreateSettings() {
		return UTIL_CustomSettingsFacade.getAutoCreateSettings();
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
    public static String newAfflMpg(String accRecType, String primaryField, Boolean autoEnroll, String autoEnrollStatus, String autoEnrollRole) {
        Affl_Mappings__c newMapping = new Affl_Mappings__c(Name = accRecType, Account_Record_Type__c = accRecType,
        Auto_Program_Enrollment__c = autoEnroll, Auto_Program_Enrollment_Role__c = autoEnrollRole,
        Auto_Program_Enrollment_Status__c = autoEnrollStatus, Primary_Affl_Field__c = primaryField);
        insert newMapping;
        if(UTIL_CustomSettingsFacade.getAfflMappings() != null)
            UTIL_CustomSettingsFacade.afflMappings.add(newMapping);
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
        if(UTIL_CustomSettingsFacade.getReciprocalSettings() != null)
            UTIL_CustomSettingsFacade.relationshipLookup.add(newSetting);
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
        if(UTIL_CustomSettingsFacade.getAutoCreateSettings() != null)
        	UTIL_CustomSettingsFacade.relationshipAutocreate.add(newSetting);
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
        if(UTIL_CustomSettingsFacade.getAfflMappings() != null) {
	        for(Integer i = 0; i < UTIL_CustomSettingsFacade.AfflMappings.size(); i++) {
	            if(UTIL_CustomSettingsFacade.AfflMappings[i].ID == idType) {
	                UTIL_CustomSettingsFacade.AfflMappings.remove(i);
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
        if(UTIL_CustomSettingsFacade.getReciprocalSettings() != null) {
            for(Integer i = 0; i < UTIL_CustomSettingsFacade.getReciprocalSettings().size(); i++) {
                if(UTIL_CustomSettingsFacade.getReciprocalSettings()[i].ID == idType) {
                    UTIL_CustomSettingsFacade.getReciprocalSettings().remove(i);
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
        if( UTIL_CustomSettingsFacade.getAutoCreateSettings() != null) {
            for(Integer i = 0; i < UTIL_CustomSettingsFacade.relationshipAutocreate.size(); i++) {
                if(UTIL_CustomSettingsFacade.relationshipAutocreate[i].ID == idType) {
                    UTIL_CustomSettingsFacade.relationshipAutocreate.remove(i);
                    break;
                }
            }
        }
    }

	/*******************************************************************************************************
    * @description Executes Ethnicity Race Batch
    * @return Id of Ethnicity Race Batch Job
    */
    @AuraEnabled
    public static Id executeEthnicityRaceBatch() {
        CON_EthnicityRace_BATCH contbatch = new CON_EthnicityRace_BATCH();
        Id jobId = Database.executeBatch( contbatch , 200 );
        if(jobId == null) {
            throw new AuraHandledException('There was a problem starting the Batch.');
        } else {
            return jobId;
        }
    }
}