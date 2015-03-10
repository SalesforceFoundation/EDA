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
    static Contacts_And_Orgs_Settings__c contactsSettings;
    static Relationship_Settings__c relationshipsSettings;
    static Affiliations_Settings__c affiliationsSettings;
    static Error_Settings__c errorSettings;
    
    //storing org-level custom settings in-memory to avoid slowing down the settings page
    static Contacts_And_Orgs_Settings__c orgContactsSettings;
    static Relationship_Settings__c orgRelationshipsSettings;
    static Affiliations_Settings__c orgAffiliationsSettings;
    static Error_Settings__c orgErrorSettings;
    
    /*******************************************************************************************************
    * @description Returns the default Contacts and Orgs settings. 
    * @return Contacts_And_Orgs_Settings__c Custom settings record for Contacts and Orgs configuration. 
    * At the org level, if no user level settings are defined. The ID field should be checked to determine if 
    * the returned record already exists or doesn't exist in the database.      
    */
    public static Contacts_And_Orgs_Settings__c getContactsSettings() {
        if(Test.isRunningTest() && contactsSettings == null) {
        	contactsSettings = new Contacts_And_Orgs_Settings__c();
        	configContactsSettings(contactsSettings);
        } else if (contactsSettings == null) {
            contactsSettings = Contacts_And_Orgs_Settings__c.getInstance();
            if(contactsSettings.Id == null)
                contactsSettings = getOrgContactsSettings();
        }    
        return contactsSettings;
    }

    /*******************************************************************************************************
    * @description Returns the default Relationships settings. 
    * @return Relationship_Settings__c Custom settings record for Relationships configuration. At the org level, 
    * if no user level settings are defined. The ID field should be checked to determine if the returned record already
    * exists or doesn't exist in the database.
    */
    public static Relationship_Settings__c getRelationshipSettings() {
        if(Test.isRunningTest() && relationshipsSettings == null) {
            relationshipsSettings = new Relationship_Settings__c();
            configRelationshipsSettings(relationshipsSettings);
        } else if (relationshipsSettings == null) {
            relationshipsSettings = Relationship_Settings__c.getInstance();
            if(relationshipsSettings.Id == null)
                relationshipsSettings = getOrgRelationshipSettings();
        }
        return relationshipsSettings;
    }
    
    /*******************************************************************************************************
    * @description Returns the default Affiliations settings. 
    * @return Affiliations_Settings__c Custom settings record for Affiliations configuration. At the org level, 
    * if no user level settings are defined. The ID field should be checked to determine if the returned record already
    * exists or doesn't exist in the database.
    */
    public static Affiliations_Settings__c getAffiliationsSettings() {
        if(Test.isRunningTest() && affiliationsSettings == null) {
            affiliationsSettings = new Affiliations_Settings__c();
            configAffiliationsSettings(affiliationsSettings);
        } else if(affiliationsSettings == null) {      
            affiliationsSettings = Affiliations_Settings__c.getInstance();
            if(affiliationsSettings.Id == null) 
                affiliationsSettings = getOrgAffiliationsSettings();
        }
        return affiliationsSettings;
    }
    
    /*******************************************************************************************************
    * @description Returns the default Error Handling settings. 
    * @return Error_Settings__c Custom settings record for Error Handling configuration. At the org level, if no user 
    * level settings are defined. The ID field should be checked to determine if the returned record already
    * exists or doesn't exist in the database.
    */
    public static Error_Settings__c getErrorSettings() {
        if(Test.isRunningTest() && errorSettings == null) {
            errorSettings = new Error_Settings__c();
            configErrorSettings(errorSettings, null);
        } else if(errorSettings == null) {
            errorSettings = Error_Settings__c.getInstance();
            if(errorSettings.Id == null)
                errorSettings = getOrgErrorSettings();
        }    
        return errorSettings;
    }

    /*******************************************************************************************************
    * @description Returns the org-level Contacts and Orgs settings. Default org-level settings will be created 
    * if none exist. Meant to be called only from settings page and install script.
    * @return Contacts_And_Orgs_Settings__c Org-level settings for Contacts and Orgs.
    */
    public static Contacts_And_Orgs_Settings__c getOrgContactsSettings() {
        if(orgContactsSettings == null) {
            orgContactsSettings = Contacts_And_Orgs_Settings__c.getOrgDefaults();
            if(orgContactsSettings.Id == null) {
                configContactsSettings(orgContactsSettings);
                orgContactsSettings.Setupownerid = UserInfo.getOrganizationId();
                if(!Test.isRunningTest())
                    upsert orgContactsSettings;
            }
        }
        return orgContactsSettings;
    }
    
    /*******************************************************************************************************
    * @description Returns the org-level Relationship settings. Default org-level settings will be created 
    * if none exist. Meant to be called only from settings page and install script.
    * @return Relationship_Settings__c Org-level settings for Relationships.
    */
    public static Relationship_Settings__c getOrgRelationshipSettings() {
        if(orgRelationshipsSettings == null) { 
            orgRelationshipsSettings = Relationship_Settings__c.getOrgDefaults();
            if(orgRelationshipsSettings.Id == null) {
                configRelationshipsSettings(orgRelationshipsSettings);
                if(!Test.isRunningTest())
                    upsert orgRelationshipsSettings;
            }
        }
        return orgRelationshipsSettings;
    }
    
    /*******************************************************************************************************
    * @description Returns the org-level Affiliation settings. Default org-level settings will be created 
    * if none exist. Meant to be called only from settings page and install script.
    * @return Affiliations_Settings__c Org-level settings for Affiliations.
    */
    public static Affiliations_Settings__c getOrgAffiliationsSettings() {
        if(orgAffiliationsSettings == null) {
            orgAffiliationsSettings = Affiliations_Settings__c.getOrgDefaults();
            if(orgAffiliationsSettings.Id == null) {
                configAffiliationsSettings(orgAffiliationsSettings);
                if(!Test.isRunningTest())
                    upsert orgAffiliationsSettings;
            }
        }
        return orgAffiliationsSettings;
    }
    
    /*******************************************************************************************************
    * @description Returns the org-level Error settings. Default org-level settings will be created 
    * if none exist. Meant to be called only from settings page and install script.
    * @return Error_Settings__c Org-level settings for Errors.
    */
    public static Error_Settings__c getOrgErrorSettings() {
        if(orgErrorSettings == null) {
            orgErrorSettings = Error_Settings__c.getOrgDefaults();
            if(orgErrorSettings.Id == null) {
                configErrorSettings(orgErrorSettings, null);
                if(!Test.isRunningTest())
                    upsert orgErrorSettings;
            }
        }
        return orgErrorSettings;
    }


    /*******************************************************************************************************
     * Private methods that will configure the default org-level custom settings.
     **/
    private static void configContactsSettings(Contacts_And_Orgs_Settings__c cs) {
		cs.Account_Processor__c = 'Household Account';
    }
    
    private static void configRelationshipsSettings(Relationship_Settings__c rs) {
        rs.Reciprocal_Method__c = 'List Settings';
    }
    
    private static void configAffiliationsSettings(Affiliations_Settings__c afs) {
        afs.Automatic_Affiliation_Creation_Turned_On__c = true;
    }

    private static void configErrorSettings(Error_Settings__c es, String notificationsTo) {   
        es.Store_Errors_On__c = true;
        es.Error_Notifications_On__c = true;
        es.Error_Notifications_To__c = ERR_Notifier.NotificationOptions.sysAdmins;
        es.Disable_Error_Handling__c = false;
        es.Enable_Debug__c = false;
    }

    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, but all other methods will see these settings
    * as the configured settings.
    * @parameter mySettings Settings instance with the values to set.
    * @return Contacts_And_Orgs_Settings__c The configured settings.
    **/
    public static Contacts_And_Orgs_Settings__c getContactsSettingsForTests(Contacts_And_Orgs_Settings__c mySettings) {
        if(contactsSettings == null)
            contactsSettings = new Contacts_And_Orgs_Settings__c();
        
        //create our own based on what's passed in from the test
        contactsSettings.One_to_One_RecordTypeID__c = mySettings.One_to_One_RecordTypeID__c;
        contactsSettings.Account_Processor__c = mySettings.Account_Processor__c;
        contactsSettings.Opportunity_Contact_Role_Default_role__c = mySettings.Opportunity_Contact_Role_Default_role__c;
        contactsSettings.Payments_Enabled__c = mySettings.Payments_Enabled__c;
        contactsSettings.Simple_Address_Change_Treated_as_Update__c = mySettings.Simple_Address_Change_Treated_as_Update__c;
        contactsSettings.Household_Account_Addresses_Disabled__c = mySettings.Household_Account_Addresses_Disabled__c;
        orgContactsSettings = contactsSettings;
        return contactsSettings;
    }
    
    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, but all other methods will see these settings
    * as the configured settings.
    * @parameter mySettings Settings instance with the values to set.
    * @return Relationship_Settings__c The configured settings.
    **/
    public static Relationship_Settings__c getRelationshipsSettingsForTests(Relationship_Settings__c mySettings) {
        if(relationshipsSettings == null)
            relationshipsSettings = new Relationship_Settings__c();
        
        relationshipsSettings.Reciprocal_Method__c = mySettings.Reciprocal_Method__c;
        relationshipsSettings.Gender_Field__c = mySettings.Gender_Field__c;
        orgRelationshipsSettings = relationshipsSettings;
        return relationshipsSettings;
    }
    
    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, but all other methods will see these settings
    * as the configured settings.
    * @parameter mySettings Settings instance with the values to set.
    * @return Affiliations_Settings__c The configured settings.
    **/
    public static Affiliations_Settings__c getAffiliationsSettingsForTests(Affiliations_Settings__c mySettings) {
        if(affiliationsSettings == null)
           affiliationsSettings = new Affiliations_Settings__c();
           
        affiliationsSettings.Automatic_Affiliation_Creation_Turned_On__c = mySettings.Automatic_Affiliation_Creation_Turned_On__c;   
        orgAffiliationsSettings = affiliationsSettings;
        return affiliationsSettings;
    }
    
    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, but all other methods will see these settings
    * as the configured settings.
    * @parameter mySettings Settings instance with the values to set.
    * @return Error_Settings__c The configured settings.
    **/
    public static Error_Settings__c getErrorSettingsForTests(Error_Settings__c mySettings) {
        if(errorSettings == null)
           errorSettings = new Error_Settings__c();
           
        errorSettings.Error_Notifications_On__c = mySettings.Error_Notifications_On__c;   
        errorSettings.Error_Notifications_To__c = mySettings.Error_Notifications_To__c;
        errorSettings.Store_Errors_On__c = mySettings.Store_Errors_On__c;
        orgErrorSettings = errorSettings;
        return errorSettings;  
    }
}