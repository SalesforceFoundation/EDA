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
* @description Installs Script for the HEDA package.
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
            UTIL_CustomSettingsFacade.getSettings();
            insertMappings(); //putting the logic in a different method to be able to call it from the anonymous window
            insertRelationshipLookups();
            //Schedule Seasonal Addresses recurring job daily
            scheduleJobIfNotScheduled('Seasonal Addresses Update', '0 15 0 * * ?', 'ADDR_Seasonal_SCHED');

            // Install TDTM Configuration
            List<TDTM_Global_API.TdtmToken> defaultTokens = TDTM_Global_API.getDefaultTdtmConfig();
            TDTM_Global_API.setTdtmConfig(defaultTokens, 'hed');

            // Format existing contact email addresses
            CON_Email_BATCH contbatch = new CON_Email_BATCH(context);
            Database.executeBatch( contbatch );

        //Updates, manual or pushed by publisher.
        } else if(context.isUpgrade() || context.isPush()) {

            Version previousVersion = context.previousVersion();

            disablePreferredEmailEnforcement(previousVersion);

            if(previousVersion != null && previousVersion.compareTo(new Version(1,37)) < 0) {

                // Handle when updating to namespaced handlers
                List<TDTM_Global_API.TdtmToken> defaultTokens = TDTM_Global_API.getDefaultTdtmConfig();
                TDTM_Global_API.setTdtmConfig(defaultTokens);
            } else {

                // Upgrade TDTM Configuration
                List<TDTM_Global_API.TdtmToken> defaultTokens = TDTM_Global_API.getDefaultTdtmConfig();
                TDTM_Global_API.setTdtmConfig(defaultTokens, 'hed');
            }
         }

         reparentAdminAddrs(context.previousVersion());

        //Schedule Async APEX Error Processing recurring hourly
        scheduleJobIfNotScheduled('HEDA Async Apex Error Processing', '0 0 * * * ?', 'ERR_AsyncErrors_SCHED');
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
            mappings.add(new Affl_Mappings__c(Name = 'Academic Program', Account_Record_Type__c = 'Academic Program', Primary_Affl_Field__c = 'Primary Academic Program', Auto_Program_Enrollment__c = true, Auto_Program_Enrollment_Status__c = 'Current', Auto_Program_Enrollment_Role__c = 'Student'));
            mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
            mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
            mappings.add(new Affl_Mappings__c(Name = 'Educational Institution', Account_Record_Type__c = 'Educational Institution', Primary_Affl_Field__c = 'Primary Educational Institution'));
            mappings.add(new Affl_Mappings__c(Name = 'Department', Account_Record_Type__c = 'University Department', Primary_Affl_Field__c = 'Primary Department'));
            mappings.add(new Affl_Mappings__c(Name = 'Sports', Account_Record_Type__c = 'Sports Organization', Primary_Affl_Field__c = 'Primary Sports Organization'));
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
            lookups.add(new Relationship_Lookup__c(Name = 'Son', Male__c = 'Father', Female__c = 'Mother', Neutral__c = 'Parent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Daughter', Male__c = 'Father', Female__c = 'Mother', Neutral__c = 'Parent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Child', Male__c = 'Father', Female__c = 'Mother', Neutral__c = 'Parent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Aunt', Male__c = 'Nephew', Female__c = 'Niece', Neutral__c = 'Sibling\'s Child', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Uncle', Male__c = 'Nephew', Female__c = 'Niece', Neutral__c = 'Sibling\'s Child', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Husband', Male__c = 'Husband', Female__c = 'Wife', Neutral__c = 'Spouse', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Wife', Male__c = 'Husband', Female__c = 'Wife', Neutral__c = 'Spouse', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Grandmother', Male__c = 'Grandson', Female__c = 'Granddaughter', Neutral__c = 'Grandchild', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Grandfather', Male__c = 'Grandson', Female__c = 'Granddaughter', Neutral__c = 'Grandchild', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Grandparent', Male__c = 'Grandson', Female__c = 'Granddaughter', Neutral__c = 'Grandchild', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Grandson', Male__c = 'Grandfather', Female__c = 'Grandmother', Neutral__c = 'Grandparent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Granddaughter', Male__c = 'Grandfather', Female__c = 'Grandmother', Neutral__c = 'Grandparent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Grandchild', Male__c = 'Grandfather', Female__c = 'Grandmother', Neutral__c = 'Grandparent', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Employer', Male__c = 'Employee', Female__c = 'Employee', Neutral__c = 'Employee', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Employee', Male__c = 'Employer', Female__c = 'Employer', Neutral__c = 'Employer', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Sibling\'s Child', Male__c = 'Uncle', Female__c = 'Aunt', Neutral__c = 'Parent\'s Sibling', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Parent\'s Sibling', Male__c = 'Nephew', Female__c = 'Niece', Neutral__c = 'Sibling\'s Child', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Nephew', Male__c = 'Uncle', Female__c = 'Aunt', Neutral__c = 'Parent\'s Sibling', Active__c = true));
            lookups.add(new Relationship_Lookup__c(Name = 'Niece', Male__c = 'Uncle', Female__c = 'Aunt', Neutral__c = 'Parent\'s Sibling', Active__c = true));
            insert lookups;
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

        if(scheduledJobs.size() == 0) {
            Type classType = Type.forName(className);

            if(classType != null) {
               Object instance = classType.newInstance();
               if(instance instanceof Schedulable)
                   return System.schedule(JobName, frequency, (Schedulable)instance);
            }
        }
        return null;
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
    * @description DEPRECATED: Inserts the default TDTM records, if necessary. Updates those that need to be updated, since the last package
    * upgrade.
    * @param defaultTdtmConfig The default TDTM configuration. Using DI just so it's easier to test it. Only includes items from TDTM_DefaultConfig
    * @return void
    */
     //cumulusci-managed@deprecated
     global static void updateDefaultTdtmConfig(List<TDTM_Global_API.TdtmToken> defaultTdtmConfig) {
        TDTM_Global_API.setTdtmConfig(defaultTdtmConfig);     
    }
}