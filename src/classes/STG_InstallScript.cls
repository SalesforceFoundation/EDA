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

    	    //Insert default TDTM config (not necessary, but better to be explicit).
    	    List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getTdtmConfig();
            TDTM_Global_API.setTdtmConfig(tokens); 

            // Format existing contact email addresses
            CON_Email_BATCH contbatch = new CON_Email_BATCH();
            Database.executeBatch( contbatch );
    	 
    	 //Updates, manual of pushed by publisher.
    	 } else if(context.isUpgrade() || context.isPush()) {
    	    //Update TDTM configuration, if necessary.
    	    List<TDTM_Global_API.TdtmToken> defaultTdtmConfig = TDTM_Global_API.getDefaultTdtmConfig();

            updateDefaultTdtmConfig(defaultTdtmConfig);
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
    * @description Inserts the default TDTM records, if necessary. Updates those that need to be updated, since the last package
    * upgrade.
    * @param defaultTdtmConfig The default TDTM configuration. Using DI just so it's easier to test it.
    * @return void
    */
    @TestVisible 
    global static void updateDefaultTdtmConfig(List<TDTM_Global_API.TdtmToken> defaultTdtmConfig) {
        //Getting the config that is really in the database.
        List<Trigger_Handler__c> existingHandlers = [select Class__c, Object__c, Trigger_Action__c, Active__c, Load_Order__c, Asynchronous__c, Filter_Field__c, 
                                                       Filter_Value__c, User_Managed__c from Trigger_Handler__c where Class__c != null];
        List<TDTM_Global_API.TdtmToken> existingTdtmConfig = new List<TDTM_Global_API.TdtmToken>();
        for(Trigger_Handler__c handler : existingHandlers) {
            existingTdtmConfig.add(new TDTM_Global_API.TdtmToken(handler.Class__c, handler.Object__c, handler.Trigger_Action__c, Integer.valueOf(handler.Load_Order__c), 
                   handler.Active__c, handler.Asynchronous__c, handler.Filter_Field__c, handler.Filter_Value__c, handler.User_Managed__c));
        }

        List<TDTM_Global_API.TdtmToken> newTdtmConfig = new List<TDTM_Global_API.TdtmToken>();
        
        //Insert those that are in the list of default handlers but aren't in the database
        for(TDTM_Global_API.TdtmToken defaultToken : defaultTdtmConfig) {
            Boolean alreadyExists = false;
            for(TDTM_Global_API.TdtmToken existingToken : existingTdtmConfig) {
                if(defaultToken.className == existingToken.className && defaultToken.targetObject == existingToken.targetObject) {
                    alreadyExists = true;
                    
                    //Determine if order, actions, or filter have changed, for those that have not been flagged as user-managed.
                    if(!existingToken.userManaged && (
                        defaultToken.loadOrder != existingToken.loadOrder || 
                        defaultToken.actions != existingToken.actions ||
                        defaultToken.filterField != existingToken.filterField || 
                        defaultToken.filterValue != existingToken.filterValue)
                    ) {
                        UTIL_Debug.debug('****It was not user managed and has changed: ' + existingToken.className);
                        existingToken.loadOrder = defaultToken.loadOrder;
                        existingToken.actions = defaultToken.actions;
                        existingToken.filterField = defaultToken.filterField;
                        existingToken.filterValue = defaultToken.filterValue;
                        newTdtmConfig.add(existingToken);
                    //If it already exists and nothing has changed, put it in, as we are going to replace the whole config. It shouldn't
                    //matter if we add defaultToken or existingToken, as they should be the same.
                    } else if(!existingToken.userManaged && defaultToken.loadOrder == existingToken.loadOrder || 
                    defaultToken.actions == existingToken.actions) {
                        UTIL_Debug.debug('****It was not user managed and has not changed: ' + existingToken.className);
                        newTdtmConfig.add(existingToken);
                    } else if(existingToken.userManaged) {
                        UTIL_Debug.debug('****It was user managed,so we should not change it: ' + existingToken.className);
                        newTdtmConfig.add(existingToken);
                    }
                    break;
                }
            }
            
            if(!alreadyExists) {
                UTIL_Debug.debug('****New token: ' + defaultToken.className);
                newTdtmConfig.add(defaultToken);
            }
        }
        
        UTIL_Debug.debug('****newTdtmConfig: ' + JSON.serializePretty(newTdtmConfig));
        
        TDTM_Global_API.setTdtmConfig(newTdtmConfig);
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
}