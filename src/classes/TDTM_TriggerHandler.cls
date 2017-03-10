/*
    Copyright (c) 2013, Salesforce.org
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
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description Class called from each of the triggers (only one per object) that follow the TDTM design. It's in 
* charge of figuring out which of the classes that do the actual work need to be called, and calling them.
*/
public class TDTM_TriggerHandler {
    
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
    public static void run(Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate,
    Boolean isDelete, Boolean isUnDelete, List<SObject> newList, List<SObject> oldList, 
    Schema.DescribeSObjectResult describeObj) {
                
        try {
            TDTM_Runnable.Action thisAction = TDTM_TriggerActionHelper.determineTriggerAction(isBefore, 
                                                          isAfter, isInsert, isUpdate, isDelete, isUnDelete);
            UTIL_Debug.debugWithInfo('****ACTION: ' + thisAction + ' on ' + describeObj.getLabel());
        
            TDTM_Runnable.DmlWrapper dmlWrapper = new TDTM_Runnable.DmlWrapper();
            
            // Get the classes to run. Note that we are using the local object name, so it works for managed and unmanaged objects.
            List<TDTM_Global_API.TdtmToken> classesToCall = TDTM_Config.getclassesToCallForObject(describeObj.getLocalName(), thisAction);
            UTIL_Debug.debug('****Classes To Call on ' + thisAction + ' for ' + describeObj.getLocalName() + ': ' + JSON.serializePretty(classesToCall));
            
            if(classesToCall != null && classesToCall.size() > 0) {
                //Run the relevant classes
                for (TDTM_Global_API.TdtmToken classToCall : classesToCall) {
                    TDTM_Runnable.DmlWrapper dmlWrapperLocal = new TDTM_Runnable.DmlWrapper();
                    dmlWrapperLocal = runClass(classToCall, newList, oldList, thisAction, describeObj);
                    if(dmlWrapperLocal != null) {
                        if(dmlWrapperLocal.objectsToInsert != null && !dmlWrapperLocal.objectsToInsert.isEmpty())
                            dmlWrapper.objectsToInsert.addAll(dmlWrapperLocal.objectsToInsert);
                        if(dmlWrapperLocal.objectsToUpdate != null && !dmlWrapperLocal.objectsToUpdate.isEmpty())
                            dmlWrapper.objectsToUpdate.addAll(dmlWrapperLocal.objectsToUpdate);
                        if(dmlWrapperLocal.objectsToDelete != null && !dmlWrapperLocal.objectsToDelete.isEmpty())
                            dmlWrapper.objectsToDelete.addAll(dmlWrapperLocal.objectsToDelete);
                        if(dmlWrapperLocal.objectsToUndelete != null && !dmlWrapperLocal.objectsToUndelete.isEmpty())
                            dmlWrapper.objectsToUndelete.addAll(dmlWrapperLocal.objectsToUndelete);
                    }          
                    UTIL_Debug.debugWithInfo('****Finished executing: ' + classToCall.className);
                }
                             
                //Process the result
                if(dmlWrapper != null)
                   processDML(dmlWrapper, true);
            }
        } catch(Exception e) {
            UTIL_Debug.debug(LoggingLevel.WARN, '****Exception caught in run method of TDTM_TriggerHandler: ' + e.getMessage());
            UTIL_Debug.debug(LoggingLevel.WARN, '\n****Stack Trace:\n' + e.getStackTraceString() + '\n');
            
            if(!UTIL_CustomSettingsFacade.getSettings().Disable_Error_Handling__c) {
                       
                //use the correct list
                List<SObject> populatedList = newList == null || newList.isEmpty() ? oldList : newList;
                //if we're only doing DML on one object and the caught exception is handled,
                //trap the error and add the message to the page.
                if (populatedList.size() == 1 && ERR_ExceptionHandler.isHandledException(e)) {
                    ERR_ExceptionHandler.beautifyExceptionMessage(e);
                    populatedList[0].addError(e);
                    return;
                } else {
                    throw e;
                }
            } else { // re-throwing exception if error handling is disabled 
                throw e;
            }
        }

    }
    
    private static TDTM_Runnable.DmlWrapper runClass(TDTM_Global_API.TdtmToken tdtmToken, List<SObject> newList, List<SObject> oldList, 
    TDTM_Runnable.Action thisAction, Schema.DescribeSObjectResult describeObj) {
                
        if(tdtmToken.className != null) {
            Type classType = Type.forName(tdtmToken.className);
            
            if(classType != null) {     
                Object classInstance = classType.newInstance();
                
                //The objects we create dynamically need to implement the TDTM_Runnable interface
                if(classInstance instanceof TDTM_Runnable) {
                    TDTM_Runnable classToRunInstance = (TDTM_Runnable)classInstance;
                    
                    //A class can only run asynchronously (calling a future) if we have the ids of the
                    //records we want to affect. This means we can only run it for after in insert. 
                    //Also,a future cannot be called from a future or batch method.
                    if(tdtmToken.async && thisAction != TDTM_Runnable.Action.BeforeInsert && !System.isFuture() && !System.isBatch()) {
                        UTIL_Debug.debug('****Calling asynchronously: ' + tdtmToken.className);
                        runAsync(classToRunInstance, tdtmToken.className, newList, oldList, thisAction, describeObj);
                    } else {
                        UTIL_Debug.debugWithInfo('****Calling synchronously: ' + tdtmToken.className);
                        
                        TDTM_Filter filter = new TDTM_Filter(tdtmToken, newList, oldList, describeObj);
                        TDTM_Filter.FilteredLists filtered = filter.filter();
                        
                        if(filtered != null) {
                            return classToRunInstance.run(filtered.newList, filtered.oldList, thisAction, describeObj);
                        } else {
                            return classToRunInstance.run(newList, oldList, thisAction, describeObj);
                        }
                    }
                } else {
                    UTIL_Debug.debug(LoggingLevel.WARN, '****The class does not implement the required interface.');
                }
            } else {
                UTIL_Debug.debug(LoggingLevel.WARN, '****ClassType was null.');
            }
        } else {
            UTIL_Debug.debug(LoggingLevel.WARN, '****ClassToCall was null');
        }
        return null;
    }
    
    private static void runAsync(TDTM_Runnable classToRun, String classToRunName, List<SObject> newList, 
    List<SObject> oldList, TDTM_Runnable.Action thisAction, Schema.DescribeSObjectResult describeObj) {
       Map<Id,SObject> nm = new Map<Id,SObject>(newList);
       
       Map<Id,SObject> om;
       if(oldList != null) om = new Map<Id,SObject>(oldList);
       else om = new Map<Id, SObject>();
       
       classToRun.runFutureNonStatic(nm.keySet(), om.keySet(), thisAction.name(), describeObj.getName(), classToRunName);
    }
    
    /*******************************************************************************************************
    * @description Performs pending DML operations, on the records stored in the DMLWrapper that it gets as parameter.
    * We want this method to be static so that it can be called from the future method in TDTM_Runnable.
    * @param dmlWrapper The class that contains the records that need to have DML performed on.
    * @param allOrNone weather or not to continue the operation if an error is encountered. Callers will need to deal with errors is allOrNone is false.
    * @return void
    */
    public static ERR_Handler.Errors processDML(TDTM_Runnable.DmlWrapper dmlWrapper, Boolean allOrNone) {
        dmlWrapper.groupByType(); //sort thyself!
        
        /**We keep the Database methods with the opt_allOrNone flag set to false to be able to alert the client 
        process of all the errors that occurred in the context **/
        List<Database.SaveResult> insertResults = Database.insert(dmlWrapper.objectsToInsert, allOrNone);        
        List<Database.SaveResult> updateResults = Database.update(dmlWrapper.objectsToUpdate, allOrNone);        
        List<Database.DeleteResult> deleteResults = Database.delete(dmlWrapper.objectsToDelete, allOrNone);        
        List<Database.UndeleteResult> undeleteResults = Database.undelete(dmlWrapper.objectsToUndelete, allOrNone); //Not yet using this one, afaik, but no reason not to support it.
        //@TODO: We cannot support upsert because you cannot do upsert on SObject. You have to specify the actual type.        
        //Also, should we support Database.merge?
        
        //Process the results.
        ERR_Handler.Errors errors = ERR_Handler.getErrors(insertResults, updateResults, deleteResults, undeleteResults, 
            dmlWrapper.objectsToInsert, dmlWrapper.objectsToUpdate, dmlWrapper.objectsToDelete, dmlWrapper.objectsToUndelete);
            
        return errors;
    }
}