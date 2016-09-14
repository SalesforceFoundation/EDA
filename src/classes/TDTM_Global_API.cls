/*
    Copyright (c) 2016, Salesforce.org
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
* @date 2016
* @group TDTM
* @group-content ../../ApexDocContent/API.htm
* @description Provides methods to call the Trigger Handler class, which in turns calls the classes that need to
* run for each DML action on a set of records, and to retrieve the default HEDA TDTM configuration.
*/
global class TDTM_Global_API {
    
    /*******************************************************************************************************
    * @description Method to be called from each of the triggers (only one per object) that follow the TDTM 
    * design. Figures out which classes need to be called, and calls them.
    * @param isBefore Are we in a before trigger context.
    * @param isAfter Are we in an after trigger context.
    * @param isInsert Did the trigger run in response to an insert operation.
    * @param isUpdate Did the trigger run in response to an update operation.
    * @param isDelete Did the trigger run in response to a delete operation.
    * @param isUnDelete Did the trigger run in response to an undelete operation.
    * @param newList The records that were passed to the trigger as trigger.new.
    * @param oldList The records that were passed to the trigger as trigger.old.
    * @param describeObj The type of SObject the class runs for.
    * @param dao The class that is going to retrieve all the TDTM records.
    * @return void
    */
    global static void run(Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,
    Boolean isDelete, Boolean isUnDelete, List<SObject> newList, List<SObject> oldList, 
    Schema.DescribeSObjectResult describeObj) {
        
        TDTM_TriggerHandler.run(isBefore, isAfter, isInsert, isUpdate, isDelete, isUnDelete, newList, oldList, describeObj);
    }
    
    /********************************************************************************************************
    * @description Returns the default TDTM configuration. 
    * @return List<Trigger_Handler__c> a list of trigger handler records with the default values. The records
    *         have not yet been inserted in the database. You can manipulate them, if necessary, and insert 
    *         them. If no Trigger_Handler__c records exist, the application will insert the defaults when any 
    *         of the triggers run. 
    *********************************************************************************************************/
    global static List<TdtmToken> getTdtmConfig() {
        return TDTM_Config.getTdtmConfig();
    }
    /********************************************************************************************************
    * @description
    * @return
    *********************************************************************************************************/
    global static void setTdtmConfig(List<TdtmToken> tokens) {
        TDTM_Config.setTdtmConfig(tokens);
    }
    
    /********************************************************************************************************
    * @description
    *********************************************************************************************************/
    global class TdtmToken {
        private String className;
        private String targetObject;
        private String actions;
        private Boolean active;
        private Integer loadOrder;
        private Boolean async;
        private String filterField;
        private String filterValue;
        
        /********************************************************************************************************
        * @description
        *********************************************************************************************************/
        global TdtmToken(String className, String targetObject, String actions, Boolean active, Integer loadOrder, 
        Boolean async, String filterField, String filterValue) {
            this.className = className;
            this.targetObject = targetObject;
            this.actions = actions;
            this.active = active;
            this.loadOrder = loadOrder;
            this.async = async;
            this.filterField = filterField;
            this.filterValue = filterValue;
        }
        
        /********************************************************************************************************
        * @description
        *********************************************************************************************************/
        global String getClassName()    { return className; }
        
        /********************************************************************************************************
        * @description
        *********************************************************************************************************/
        global String getTargetObject() { return targetObject; }
        
        /********************************************************************************************************
        * @description
        *********************************************************************************************************/
        global String getActions()      { return actions; }
        
        /********************************************************************************************************
        * @description
        *********************************************************************************************************/
        global Boolean isActive()       { return active; }
        
        /********************************************************************************************************
        * @description
        *********************************************************************************************************/
        global Integer getLoadOrder()   { return loadOrder; }
        
        /********************************************************************************************************
        * @description
        *********************************************************************************************************/
        global Boolean isAsync()        { return async; }
       
        /********************************************************************************************************
        * @description
        *********************************************************************************************************/
        global String getFilterField() { return filterField; }
        
        /********************************************************************************************************
        * @description
        *********************************************************************************************************/
        global String getFilterValue() { return filterValue; }
    }
}