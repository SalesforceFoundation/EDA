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
    	if(context.previousVersion() == null) {
    		UTIL_CustomSettingsFacade.getSettings();
    		insertMappings(); //putting the logic in a different method to be able to call it from the anonymous window
    		insertRelationshipLookups();
    		//Schedule Seasonal Addresses recurring job daily
    		scheduleJobIfNotScheduled('Seasonal Addresses Update', '0 15 0 * * ?', 'ADDR_Seasonal_SCHED');
    	 } else if(context.isUpgrade() || context.isPush()) {
    	 	List<Trigger_Handler__c> defaultHandlers = TDTM_DefaultConfig.getDefaultRecords(); 
            insertTdtmDefaults(defaultHandlers);
    	 }
    	 
    	 //Replace the value in the "Account Processor" field with the ID of the record type that was there
    	 if(context.previousVersion() != null && context.previousVersion().compareTo(new Version(1,7)) == 0) {
    	     UTIL_Debug.debug('***Upgrading to version 1.7');
    	     Hierarchy_Settings__c settings = UTIL_CustomSettingsFacade.getSettings();
    	     String accModel = settings.Account_Processor__c;
    	     if(!String.isBlank(accModel)) {
    	         String accRecTypeID = UTIL_Describe.getRecTypesMapByName('Account').get(accModel);
    	         if(accRecTypeID != null) {
    	             settings.Account_Processor__c = accRecTypeID;
    	             update settings;
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
    * upgradade. Public just for testing purposes (it should otherwise be private).
    * @param defaultHandlers The default TDTM records.
    * @return void
    */
    public static void insertTdtmDefaults(List<Trigger_Handler__c> defaultHandlers) {
        List<Trigger_Handler__c> existingHandlers = [select Class__c, Object__c, Load_Order__c, Trigger_Action__c, User_Managed__c 
                                                       from Trigger_Handler__c where Class__c != null];

        List<Trigger_Handler__c> handlersToInsert = new List<Trigger_Handler__c>();
        List<Trigger_Handler__c> handlersToUpdate = new List<Trigger_Handler__c>();
        
        //Insert those that are in the list of default handlers but aren't in the database
        for(Trigger_Handler__c defaultHandler : defaultHandlers) {
            Boolean alreadyExists = false;
            Boolean needsUpdate = false;
            for(Trigger_Handler__c existingHandler : existingHandlers) {
                if(defaultHandler.Class__c == existingHandler.Class__c && defaultHandler.Object__c == existingHandler.Object__c) {
                    alreadyExists = true;
                    //Determine if order or action has changed (compare old load order with new load order, old action with new action)
                    //Filter to only those that have not been flagged as user-managed
                    if(!existingHandler.User_Managed__c && (defaultHandler.Load_Order__c != existingHandler.Load_Order__c || 
                    defaultHandler.Trigger_Action__c != existingHandler.Trigger_Action__c)) {
                        existingHandler.Load_Order__c = defaultHandler.Load_Order__c;
                        existingHandler.Trigger_Action__c = defaultHandler.Trigger_Action__c;
                        handlersToUpdate.add(existingHandler);
                    }
                    break;
                }
            }
            if(!alreadyExists)
                handlersToInsert.add(defaultHandler); 
        }    
        if(handlersToInsert.size() > 0) insert handlersToInsert;
        if(handlersToUpdate.size() > 0) update handlersToUpdate;
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