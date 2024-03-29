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
* @group Settings
* @group-content ../../ApexDocContent/Settings.htm
* @description Installs Script for the EDA package.
*/
global without sharing class STG_InstallScript implements InstallHandler {

    /*******************************************************************************************************
    * @description Runs on package install.
    * @param context The install context.
    * @return void
    */
    global void onInstall(InstallContext context) {

        //Initial installation.
        if(context.previousVersion() == null) {
            UTIL_CustomSettingsFacade.getSettingsForNewInstalls();
            insertMappings(); //putting the logic in a different method to be able to call it from the anonymous window
            insertRelationshipLookups();
            //Schedule Seasonal Addresses recurring job daily
            scheduleJobIfNotScheduled('Seasonal Addresses Update', '0 15 0 * * ?', 'ADDR_Seasonal_SCHED');

            // Install TDTM Configuration
            List<TDTM_Global_API.TdtmToken> defaultTokens = TDTM_Global_API.getDefaultTdtmConfig();
            TDTM_Global_API.setTdtmConfig(defaultTokens, 'hed');

            // Enable new Preferred Phone sync functionality
            enablePreferredPhoneSync();

            // Format existing contact email addresses
            CON_Email_BATCH contbatch = new CON_Email_BATCH(context);
            Database.executeBatch( contbatch );

            // Enable Prevent Deletion Hierarchy Custom Settings
            enablePreventDeletionHierarchyCustomSettings(NULL);

        //Updates, manual or pushed by publisher.
        } else if(context.isUpgrade() || context.isPush()) {

            Version previousVersion = context.previousVersion();

            disablePreferredEmailEnforcement(previousVersion);

            disablePreferredPhoneEnforcement(previousVersion);

            populateAdminRecordTypeSetting(previousVersion);

            setDefaultContactLanguageFluency(previousVersion);
            
            // Enable Prevent Account Deletion and Prevent Plan Requirement Deletion Custom Settings
            enablePreventDeletionHierarchyCustomSettings(previousVersion);     

            if(previousVersion != null && previousVersion.compareTo(new Version(1,38)) < 0) {
                // We need to handle a special case to populate the Owned_by_Namespace__c field for EDA Orgs before 1.38.
                populateNamespaceHandlers();
            }

            // Upgrade TDTM Configuration
            List<TDTM_Global_API.TdtmToken> defaultTokens = TDTM_Global_API.getDefaultTdtmConfig();
            TDTM_Global_API.setTdtmConfig(defaultTokens, 'hed');

            // Submit telemetry data back to the LMO using Feature Management
            sendTelemetryData();
         }

         reparentAdminAddrs(context.previousVersion());

        //Schedule Async APEX Error Processing recurring hourly
        scheduleJobIfNotScheduled('HEDA Async Apex Error Processing', '0 0 * * * ?', 'ERR_AsyncErrors_SCHED');

        //Schedule Error Cleaning recurring daily
        scheduleJobIfNotScheduled('HEDA 90-day-old Error Cleaning', '0 0 0 * * ?', 'ERR_DeleteOutdated_SCHED');
    }

    global static void reparentAdminAddrs(Version previousVersion) {
        //Reparent administrative account children
         if(previousVersion != null && previousVersion.compareTo(new Version(1,14)) == 0) {
             UTIL_Debug.debug('***Upgrading to version 1.14');

             String adminRecTypeId = UTIL_Describe.getAdminAccRecTypeID();

             if(adminRecTypeId != null) {
                 //This loop should be processing 200 accounts, with their children, at a time
                 for(Account[] accs : [select ID, (select ID from Account.Contacts),
                                                      (select  Parent_Account__c, Parent_Contact__c from Account.Addresses__r)
                 from Account where RecordTypeID = :adminRecTypeID]) {

                     List<Address__c> addrsToUpdate = new List<Address__c>();

                     for(Account acc : accs) {
                         //We need to do this, because acc.Contacts.size() would throw an exception if the account had more than 200 contacts
                         Integer contactCount = 0;
                         Boolean tooMany = false;
                         for(Contact contact : acc.Contacts) {
                             contactCount++;
                             if(contactCount > 1) {
                                 tooMany = true;
                                 break;
                             }
                         }
                         //Administrative Accounts should have only one child contact
                         if(!tooMany) {
                             for(Address__c addr : acc.Addresses__r) {
                                 addr.Parent_Account__c = null;
                                 addr.Parent_Contact__c = acc.Contacts[0].Id;
                                 addrsToUpdate.add(addr);
                             }
                         }
                     }
                     update addrsToUpdate;
                 }
             }
         }
    }

    /*******************************************************************************************************
    * @description Inserts the default Affiliation Mappings.
    * @return void
    */
    global static void insertMappings() {
        List<Affl_Mappings__c> mappings = [select ID from Affl_Mappings__c where Account_Record_Type__c != null AND Primary_Affl_Field__c != null];
        if(mappings.size() == 0) {
            mappings.add(new Affl_Mappings__c(Name = 'Academic Program', Account_Record_Type__c = 'Academic_Program', Primary_Affl_Field__c = 'Primary_Academic_Program__c', Auto_Program_Enrollment__c = true, Auto_Program_Enrollment_Status__c = 'Current', Auto_Program_Enrollment_Role__c = 'Student'));
            mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business_Organization', Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c')));
            mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'HH_Account', Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')));
            mappings.add(new Affl_Mappings__c(Name = 'Educational Institution', Account_Record_Type__c = 'Educational_Institution', Primary_Affl_Field__c = 'Primary_Educational_Institution__c'));
            mappings.add(new Affl_Mappings__c(Name = 'University Department', Account_Record_Type__c = 'University_Department', Primary_Affl_Field__c = 'Primary_Department__c'));
            mappings.add(new Affl_Mappings__c(Name = 'Sports Organization', Account_Record_Type__c = 'Sports_Organization', Primary_Affl_Field__c = 'Primary_Sports_Organization__c'));            
            insert mappings;
        }
    }

    /*******************************************************************************************************
    * @description Inserts the default Relationship Lookup settings.
    * @return void
    */
    global static void insertRelationshipLookups() {
        Integer lookupCount = [select count() from Relationship_Lookup__c];
        if(lookupCount == 0) {
            List<Relationship_Lookup__c> lookups = new List<Relationship_Lookup__c>();
            lookups.add(new Relationship_Lookup__c(Name = 'Father', Male__c = 'Son', Female__c = 'Daughter', Neutral__c = 'Child', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Mother', Male__c = 'Son', Female__c = 'Daughter', Neutral__c = 'Child', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Parent', Male__c = 'Son', Female__c = 'Daughter', Neutral__c = 'Child', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Daughter', Male__c = 'Father', Female__c = 'Mother', Neutral__c = 'Parent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Son', Male__c = 'Father', Female__c = 'Mother', Neutral__c = 'Parent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Child', Male__c = 'Father', Female__c = 'Mother', Neutral__c = 'Parent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Husband', Male__c = 'Husband', Female__c = 'Wife', Neutral__c = 'Partner', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Wife', Male__c = 'Husband', Female__c = 'Wife', Neutral__c = 'Partner', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Partner', Male__c = 'Husband', Female__c = 'Wife', Neutral__c = 'Partner', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Aunt', Male__c = 'Nephew', Female__c = 'Niece', Neutral__c = 'Sibling\'s Child', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Uncle', Male__c = 'Nephew', Female__c = 'Niece', Neutral__c = 'Sibling\'s Child', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Parent\'s Sibling', Male__c = 'Nephew', Female__c = 'Niece', Neutral__c = 'Sibling\'s Child', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Nephew', Male__c = 'Uncle', Female__c = 'Aunt', Neutral__c = 'Parent\'s Sibling', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Niece', Male__c = 'Uncle', Female__c = 'Aunt', Neutral__c = 'Parent\'s Sibling', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Sibling\'s Child', Male__c = 'Uncle', Female__c = 'Aunt', Neutral__c = 'Parent\'s Sibling', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Grandfather', Male__c = 'Grandson', Female__c = 'Granddaughter', Neutral__c = 'Grandchild', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Grandmother', Male__c = 'Grandson', Female__c = 'Granddaughter', Neutral__c = 'Grandchild', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Grandparent', Male__c = 'Grandson', Female__c = 'Granddaughter', Neutral__c = 'Grandchild', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Granddaughter', Male__c = 'Grandfather', Female__c = 'Grandmother', Neutral__c = 'Grandparent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Grandson', Male__c = 'Grandfather', Female__c = 'Grandmother', Neutral__c = 'Grandparent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Grandchild', Male__c = 'Grandfather', Female__c = 'Grandmother', Neutral__c = 'Grandparent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Stepfather', Male__c = 'Stepson', Female__c = 'Stepdaughter', Neutral__c = 'Stepchild', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Stepmother', Male__c = 'Stepson', Female__c = 'Stepdaughter', Neutral__c = 'Stepchild', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Stepparent', Male__c = 'Stepson', Female__c = 'Stepdaughter', Neutral__c = 'Stepchild', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Stepdaughter', Male__c = 'Stepfather', Female__c = 'Stepmother', Neutral__c = 'Stepparent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Stepson', Male__c = 'Stepfather', Female__c = 'Stepmother', Neutral__c = 'Stepparent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Stepchild', Male__c = 'Stepfather', Female__c = 'Stepmother', Neutral__c = 'Stepparent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Foster Parent', Male__c = 'Foster Son', Female__c = 'Foster Daughter', Neutral__c = 'Foster Child', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Foster Daughter', Male__c = 'Foster Parent', Female__c = 'Foster Parent', Neutral__c = 'Foster Parent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Foster Son', Male__c = 'Foster Parent', Female__c = 'Foster Parent', Neutral__c = 'Foster Parent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Foster Child', Male__c = 'Foster Parent', Female__c = 'Foster Parent', Neutral__c = 'Foster Parent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Guardian', Male__c = 'Dependent', Female__c = 'Dependent', Neutral__c = 'Dependent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Dependent', Male__c = 'Guardian', Female__c = 'Guardian', Neutral__c = 'Guardian', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Employee', Male__c = 'Employer', Female__c = 'Employer', Neutral__c = 'Employer', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Employer', Male__c = 'Employee', Female__c = 'Employee', Neutral__c = 'Employee', Active__c = true));
            insert lookups;
        }
    }

    /*******************************************************************************************************
    * @description Disables Preferred Email handling when upgrading to 1.33
    * @return void
    */
    global static void disablePreferredEmailEnforcement(Version previousVersion) {
        if(previousVersion != null && previousVersion.compareTo(new Version(1,33)) < 0) {
            UTIL_Debug.debug('***Upgrading to version 1.33');
            Hierarchy_Settings__c orgSettings = Hierarchy_Settings__c.getOrgDefaults();
            if(orgSettings.Disable_Preferred_Email_Enforcement__c == null || orgSettings.Disable_Preferred_Email_Enforcement__c != true) {
                orgSettings.Disable_Preferred_Email_Enforcement__c = true;
            }
            upsert orgSettings;
        }
    }

    /*******************************************************************************************************
    * @description Disables Preferred Phone handling when upgrading to 1.82
    * @return void
    */
    global static void disablePreferredPhoneEnforcement(Version previousVersion) {
        if(previousVersion != null && previousVersion.compareTo(new Version(1,82)) < 0) {
            UTIL_Debug.debug('***Upgrading to version 1.82');
            Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
            if(orgSettings.Disable_Preferred_Phone_Enforcement__c == null || orgSettings.Disable_Preferred_Phone_Enforcement__c != true) {
                orgSettings.Disable_Preferred_Phone_Enforcement__c = true;
            }
            upsert orgSettings;
        }
    }

    /*******************************************************************************************************
    * @description Enabled Preferred Phone sync on initial installation.
    * @return void
    */
    global static void enablePreferredPhoneSync() {
        Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
        if (orgSettings.Enable_New_Preferred_Phone_Sync__c == null || orgSettings.Enable_New_Preferred_Phone_Sync__c != true) {
            orgSettings.Enable_New_Preferred_Phone_Sync__c = true;
        }
        upsert orgSettings;
    }

    /*******************************************************************************************************
    * @description DEPRECATED: Inserts the default TDTM records, if necessary. Updates those that need to be updated, since the last package
    * upgrade.
    * @param defaultTdtmConfig The default TDTM configuration. Using DI just so it's easier to test it. Only includes items from TDTM_DefaultConfig
    * @return void
    */
     //cumulusci-managed@deprecated
     global static void updateDefaultTdtmConfig(List<TDTM_Global_API.TdtmToken> defaultTdtmConfig) {
        TDTM_Global_API.setTdtmConfig(defaultTdtmConfig);
    }

    /*******************************************************************************************************
    * @description Populate Administrative record type custom setting when upgrading to 1.70
    * @return void
    */
    global static void populateAdminRecordTypeSetting(Version previousVersion) {
        if(previousVersion != null && previousVersion.compareTo(new Version(1,70)) < 0) {
            Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
            if(orgSettings.Administrative_Account_Record_Type__c == null || orgSettings.Administrative_Account_Record_Type__c == '') {
                orgSettings.Administrative_Account_Record_Type__c = UTIL_Describe.getAdminAccRecTypeID();
            }
            upsert orgSettings;
        }
    }
    
    /*******************************************************************************************************
    * @description Populate Default Contact Language Fluency custom setting when upgrading to 1.75
    * @return void
    */
    global static void setDefaultContactLanguageFluency(Version previousVersion) {
        if(previousVersion != null && previousVersion.compareTo(new Version(1,75)) < 0) {
            Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
            if(orgSettings.Default_Contact_Language_Fluency__c == null || orgSettings.Default_Contact_Language_Fluency__c == '') {
                orgSettings.Default_Contact_Language_Fluency__c = Label.stgFluent;
            }
            upsert orgSettings;
        }
    }

    /*******************************************************************************************************
    * @description Schedules a class that implements the Schedulable interface, if it's not already scheduled.
    * @param JobName The name to give the scheduled job.
    * @param frequency The frequency to schedule the job at.
    * @param className The class to schedule. Should implement the Schedulable interface.
    * @return The ID of the scheduled job.
    */
    public static String scheduleJobIfNotScheduled(String JobName, String frequency, String className) {

        //Check if the job is already scheduled - CronJobDetail is the parent and CronTrigger is the child
        //Type '7' is for scheduled Apex
        List<CronTrigger> scheduledJobs = [select Id, CronJobDetail.Id from CronTrigger
                    where CronJobDetail.Name = :JobName and CronJobDetail.JobType = '7'];

        if (scheduledJobs.size() == 0) {
            Type classType = Type.forName(className);

            if (classType != null) {
               Object instance = classType.newInstance();
               if (instance instanceof Schedulable) {
                   return System.schedule(JobName, frequency, (Schedulable)instance);
               }
            }
        }
        return null;
    }

    /*******************************************************************************************************
    * @description: Populate the Owned by Namespace field for EDA owned triggers. We have to update Trigger
    * handlers even if they are marked as user managed.
    */
    private static void populateNamespaceHandlers() {
        // Populate filters for soql query
        Set<String> objectTypes = new Set<String>();
        Set<String> classNames = new Set<String>();

        for (TDTM_Global_API.TdtmToken token : TDTM_Global_API.getDefaultTdtmConfig()) {
            objectTypes.add(token.targetObject);
            classNames.add(token.className);
        }

        // Get EDA trigger Handlers from the database
        List<Trigger_Handler__c> hedaHandlers = [SELECT Id, Name, Owned_by_Namespace__c FROM Trigger_Handler__c WHERE Class__c in: classNames AND Object__c in: objectTypes LIMIT 5000];

        for (Trigger_Handler__c t : hedaHandlers) {
            t.Owned_by_Namespace__c = 'hed';
        }

        update hedaHandlers;
    }

    @testVisible
    private static Boolean sendTelemetryDataMethodCalled = false;

    /*******************************************************************************************************
    * @description Calls the UTIL_OrgTelemetry_BATCH class to collect information about the current org and 
    * EDA setup information and sends it back to the EDA License Management Application to assist with better
    * understanding of how our customers use our application.
    */
    private static void sendTelemetryData() {
        sendTelemetryDataMethodCalled = true;
        if (!Test.isRunningTest()) {
            UTIL_OrgTelemetry.dispatchTelemetryBatchJob();
        }
    }

    /**************************************************************************************************************
    * @description Enables Prevent Hierarchy Custom Settings for new installs and push upgrades
    * @return void
    */
    global static void enablePreventDeletionHierarchyCustomSettings(Version previousVersion) {
        Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
        Boolean isNewInstallOrPushUpgradedTo195 = isNewInstallOrPushUpgrade(previousVersion, new Version(1,95));
        Boolean isNewInstallOrPushUpgradedTo196 = isNewInstallOrPushUpgrade(previousVersion, new Version(1,96));
        if (isNewInstallOrPushUpgradedTo195) {
            UTIL_Debug.debug('***Upgrading to version 1.95 or new installs');
            orgSettings = enablePreventAccountDeletionHierarchyCustomSettings();
            orgSettings = enablePreventPlanRequirementDeletionHierarchyCustomSettings(orgSettings);
        }
        if (isNewInstallOrPushUpgradedTo196) {
            UTIL_Debug.debug('***Upgrading to version 1.96 or new installs');
            orgSettings = enablePreventPPlanDeletionHierarchyCustomSettings();
        }
        upsert orgSettings;
    }

    /*****************************************************************************************************************************
    * @description Enables Prevent Account Deletion on Hierarchy Custom Settings for new installs and when upgrading to 1.95
    * @return void
    */
    @testVisible
    private static Hierarchy_Settings__c enablePreventAccountDeletionHierarchyCustomSettings() {
        Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
        if (orgSettings.Prevent_Account_Deletion__c == null || orgSettings.Prevent_Account_Deletion__c != true) {
            orgSettings.Prevent_Account_Deletion__c = true;
        }
        return orgSettings;
    }

    /**************************************************************************************************************************
    * @description Enables Plan Requirement Deletion on Hierarchy Custom Settings for new installs and when upgrading to 1.95
    * @return void
    */
    @testVisible
    private static Hierarchy_Settings__c enablePreventPlanRequirementDeletionHierarchyCustomSettings(Hierarchy_Settings__c hierarchySettings) {
 
        if (hierarchySettings.Prevent_Plan_Requirement_Deletion__c == null || hierarchySettings.Prevent_Plan_Requirement_Deletion__c != true) {
            hierarchySettings.Prevent_Plan_Requirement_Deletion__c = true;
        }
        return hierarchySettings;
    }

    /********************************************************************************************************************************
    * @description Enables Prevent Program Plan Deletion on Hierarchy Custom Settings for new installs and when upgrading to 1.96
    * @return void
    */
    @testVisible
    private static Hierarchy_Settings__c enablePreventPPlanDeletionHierarchyCustomSettings() {
        Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
        if (orgSettings.Prevent_Program_Plan_Deletion__c == null || orgSettings.Prevent_Program_Plan_Deletion__c != true) {
            orgSettings.Prevent_Program_Plan_Deletion__c = true;
        }
        return orgSettings;
    }

    /********************************************************************************************************************************
    * @description Method to check if the package is being newly installed or push upgraded to a particular version
    * @return true if it is either a new install or push upgraded to certain version else return false
    */
    @testVisible
    private static boolean isNewInstallOrPushUpgrade(Version previousVersion, Version newVersion) {
        if (previousVersion == null || previousVersion.compareTo(newVersion) < 0) {
            return true;
        }
        return false;
    }
}