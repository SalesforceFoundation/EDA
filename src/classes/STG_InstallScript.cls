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
* @group Settings
* @description Install Script for the HEDAP package. 
*/
global without sharing class STG_InstallScript implements InstallHandler {

	/*******************************************************************************************************
    * @description Runs on package install.
    * @param context The install context.
    * @return void
    */
    global void onInstall(InstallContext context) {
    	if(context.previousVersion() == null) {
    		UTIL_CustomSettingsFacade.getContactsSettings();
    		insertMappings(); //putting the logic in a different method to be able to call it from the anonymous window
    	 } else if(context.isUpgrade() || context.isPush()) {
    	 	List<Trigger_Handler__c> defaultHandlers = TDTM_DefaultConfig.getDefaultRecords(); 
            insertTdtmDefaults(defaultHandlers);
    	 }
    }
    
    global static void insertMappings() {
    	List<Affl_Mappings__c> mappings = [select ID from Affl_Mappings__c];
    	if(mappings.size() == 0) {
    		mappings.add(new Affl_Mappings__c(Name = 'Administrative', Account_Record_Type__c = 'Administrative', Primary_Affl_Field__c = 'Primary Administrative Account'));
	    	mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));	
	    	mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
	    	mappings.add(new Affl_Mappings__c(Name = 'Educational Institution', Account_Record_Type__c = 'Educational Institution', Primary_Affl_Field__c = 'Primary Educational Institution', Auto_Academic_Record__c = true));
	    	mappings.add(new Affl_Mappings__c(Name = 'Department', Account_Record_Type__c = 'University Department', Primary_Affl_Field__c = 'Primary Department', Auto_Academic_Record__c = true));
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
                                                       from Trigger_Handler__c];

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
}