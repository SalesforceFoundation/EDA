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
* @description Helps determine if errors occurred during the DML operations performed during the transaction, and with 
* the necessary storing and notification of these errors.
* @group ErrorHandling
* @group-content ../../ApexDocContent/ErrorHandling.htm
*/
public class ERR_Handler {
	
	public enum Context {
    	/* @description Address context. */
	    ADDR, 
	    /* @description Affiliations context. */
	    AFFL, 
	    /* @description Contacts context. */
	    CON, 
	    /* @description Opportunities context. */
	    OPP, 
	    /* @description Relationships context. */
	    REL, 
	    /* @description Settings context. */
	    STTG, 
	    /* @description Table-Driven Trigger Management context. */
	    TDTM
    }
    
    /*******************************************************************************************************
    * @description Inner class that groups the result of processing the result of multiple DML operations performed
    *              using the Database class.
    */
    public class Errors {
    	/*
        * @description True if errors occurred in one of the DML operations. False otherwise.
        */
    	public Boolean errorsExist = false;
        /*
        * @description Error records.
        */
    	public List<Error__c> errorRecords = new List<Error__c>();
    }
    
    
    /*******************************************************************************************************
    * @description Processes the result of multiple DML operations performed using the Database class, to determine 
    *              if errors occurred. It does not store errors or send error email notifications. These operations
    *              should be performed after the rollback.
    *
    * @param insertResults The result of a Database.Insert operation.
    * @param updateResults The result of a Database.Update operation.
    * @param deleteResults The result of a Database.Delete operation.
    * @param undeleteResults The result of a Database.Undelete operation.
    * @param insertedObjects Objects that were inserted in the Database.Insert operation.
    * @param updatedObjects Objects that were updated in the Database.Update operation.
    * @param deletedObjects Objects that were deleted in the Database.Delete operation.
    * @param undeletedObjects Objects that were Undeleted in the Database.Undelete operation.
    *
    * @return Errors Combined result of all the DML operations.
    */
    public static Errors getErrors(
    List<Database.SaveResult> insertResults, List<Database.SaveResult> updateResults, 
    List<Database.DeleteResult> deleteResults, List<Database.UndeleteResult> undeleteResults, 
    List<SObject> insertedObjects, List<SObject> updatedObjects, 
    List<SObject> deletedObjects, List<SObject> undeletedObjects) {
                    
        Errors errors = new Errors();
        	
    	Errors insertErrors = getErrors(insertResults, insertedObjects);  //Insert
    	Errors updateErrors = getErrors(updateResults, updatedObjects);  //Update
    	Errors deleteErrors = getErrors(deleteResults, deletedObjects);  //Delete
    	Errors undeleteErrors= getErrors(undeleteResults, undeletedObjects);  //Undelete
    	
    	if(insertErrors.errorsExist || updateErrors.errorsExist || deleteErrors.errorsExist || undeleteErrors.errorsExist) {
    		errors.errorsExist = true;
    		errors.errorRecords.addAll(insertErrors.errorRecords);
    		errors.errorRecords.addAll(updateErrors.errorRecords);
    		errors.errorRecords.addAll(deleteErrors.errorRecords);
    		errors.errorRecords.addAll(undeleteErrors.errorRecords);
    	}
    	
    	// We do NOT want to try to store errors or send error email notifications here. We want to be able to 
    	//manually do that after the rollback.
 
    	return errors;
    }

    /*******************************************************************************************************
    * @description Processes the results of a single DML operation performed using the Database class to determine 
    *              if errors occurred. It does not store errors or send error email notifications. These operations
    *              should be performed after the rollback.
    *
    * @param dmlResults The results of a single DML operation performed using the Database class.
    * @param sObjects The records the DML operation was performed on.
    * @return Errors The erros that occurred during the DML operation perfored using the Database class.
    */    
    public static Errors getErrors(List<Object> dmlResults, List<SObject> sObjects) {    	
    	Errors errors = new Errors();
    	
    	if(dmlResults != null) {	
	    	for(Integer i=0; i<dmlResults.size(); i++) {
	        	Boolean isSuccess = true;
	        	if(dmlResults[i] instanceof Database.SaveResult) {
	        		isSuccess = ((Database.SaveResult)dmlResults[i]).isSuccess();
	        	} else if(dmlResults[i] instanceof Database.DeleteResult) {
	        		isSuccess = ((Database.DeleteResult)dmlResults[i]).isSuccess();
	        	} else if(dmlResults[i] instanceof Database.UndeleteResult) {
	        		isSuccess = ((Database.UndeleteResult)dmlResults[i]).isSuccess();
	        	}
	        	
	        	if(!isSuccess) {
	        		errors.errorsExist = true;
	        		
	        		//Creating error object
	        		Error__c err = createError(dmlResults[i], sObjects[i].getSObjectType().getDescribe().getName(), sObjects[i].Id);
	                errors.errorRecords.add(err);
	                
	                //We cannot use addError on the record here, because if we do, the whole transaction will be rolled back, and 
	                //no error record will be saved,or error notification sent.
	                
	                //Displaying an error message to the user
	                if(ApexPages.currentPage() != null)
	                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.Full_Message__c));
	        	}
	        }
    	}
    	return errors;
    }
    
    /*******************************************************************************************************
    * @description Custom class that extends the Exception built-in class, and indicates that there is an unrecoverable
    *              error that should be propagated all the way up the stack.
    */
    private class PropogateException extends Exception {}
    
    /*******************************************************************************************************
    * @description Creates an error record from an exception, stores it in the database (if enabled), and sends error
    *              notifications (if enabled).
                   This method should be used from inside the NPSP package, instead of the same one with that same name
                   that takes a String instead of an Enum as the second parameter.
    * @param e Exception to create error record from.
    * @return context The context the exception was raised on.
    */
    public static void processError(Exception e, Context context) {     
        processError(e, context.name());   
    }
    
    /*******************************************************************************************************
    * @description Creates an error record from an exception, stores it in the database (if enabled), and sends error
    *              notifications (if enabled).
    * @param e Exception to create error record from.
    * @return context The context the exception was raised on.
    */
    public static void processError(Exception e, String context) {     
        if(e != null) {         
            Error__c error = createError(e);
            processErrors(new Error__c[]{error}, context);
        }   
    }
    
    /*******************************************************************************************************
    * @description Stores errors in the database (if enabled), and sends error notifications (if enabled).
    * @param errorRecords The errors to store.
    * @param context The context the errors were raised on.
    * @return void
    */
    public static void processErrors(List<Error__c> errorRecords, String context) {
    	
    	if(errorRecords != null && errorRecords.size() > 0) {
	    	if(ApexPages.currentPage() != null) {
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorRecords[0].Full_Message__c));
	    	}
	                
	    	if(UTIL_CustomSettingsFacade.getSettings().Store_Errors_On__c) {
	    	   UTIL_Debug.debug('**** Storing errorRecords: ' + errorRecords);
	    	   Database.insert(errorRecords, false);
	    	}
	    	//ERR_Notifier takes care of checking the settings itself.
	        ERR_Notifier.sendErrorNotifications(context);
    	}
    }
    
    /*******************************************************************************************************
    * @description Creates an error record from an exception.
    * @param e Exception to create error record from.
    * @return Error__c Error record.
    */
	private static Error__c createError(Exception e) {
		Error__c error = new Error__c();
		error.Datetime__c = System.now();        
		error.Error_Type__c = e.getTypeName();
		error.Full_Message__c = e.getMessage();
		//Putting it into a local string to see if that helps storing the stack trace when we
		//are in a managed package.
		String stackTrace = e.getStackTraceString();
		UTIL_Debug.debug('****Stack trace: \n' + stackTrace);
		String message;
		if(String.isBlank(stackTrace) || stackTrace == '('+UTIL_Namespace.getNamespace()+')' || stackTrace == UTIL_Namespace.getNamespace()) {
			message = 'No stacktrace available at the time of saving the record. ';
		} else {
			message = 'Stacktrace available at the time of saving the record - ';
		}
		error.Stack_Trace__c = message + stackTrace;
		return error;
	}

    /*******************************************************************************************************
    * @description Creates an error record from the result of a DML operation performed through the Database class.
    * @param result The result of the Database DML operation. It cannot be more specific than Object, because the result of 
    *               the different DML operations that the Database class can perform don't have a common parent.
    * @param objectType The name of the type of object that caused the error.
    * @param objId The id of the record that caused the error. 
    * @return The error record.
    */
    private static Error__c createError(Object result, string objectType, id objId) {
    	Error__c error = new Error__c();
        error.Datetime__c = System.now();
        error.Object_Type__c = objectType;
        
    	if(result instanceof Database.SaveResult) {
    		Database.SaveResult saveResult = (Database.SaveResult) result;
    		error.Record_URL__c = getRecordURL(saveResult.getId(), objId);
	        error.Error_Type__c = getStatusCode(saveResult.getErrors()[0].getStatusCode());
	        error.Full_Message__c = saveResult.getErrors()[0].getMessage();	
    	} else if(result instanceof Database.DeleteResult) {
    		Database.DeleteResult deleteResult = (Database.DeleteResult) result;
            error.Record_URL__c = getRecordURL(deleteResult.getId(), objId);
            error.Error_Type__c = getStatusCode(deleteResult.getErrors()[0].getStatusCode());
            error.Full_Message__c = deleteResult.getErrors()[0].getMessage();
    	} else if(result instanceof Database.UndeleteResult) {
    		Database.UndeleteResult undeleteResult = (Database.UndeleteResult) result;
            error.Record_URL__c = getRecordURL(undeleteResult.getId(), objId);
            error.Error_Type__c = getStatusCode(undeleteResult.getErrors()[0].getStatusCode());
            error.Full_Message__c = undeleteResult.getErrors()[0].getMessage();
    	}
    
        UTIL_Debug.debug('**** createError() returns error: ' + error);
        return error;
    }
    
    /*******************************************************************************************************
    * @description Returns the URL of a record, if available.
    * @param saveResultId The id resulting from a DML operation of the Database class.
    * @param objId The id of the record the DML operation was performed on.
    * @return The URL of the record. Warning: it may not necessarily be valid.
    */
    private static String getRecordURL(Id saveResultId, Id objId) {
    	String recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        if (saveResultId != null)
            recordURL += saveResultId;
        else            
            recordURL += objId;
                     
        if (recordURL.startsWith('http:'))
            recordURL = recordURL.replaceFirst('http:', 'https:');
            
        return recordURL;
    }
    
    /*******************************************************************************************************
    * @description Returns the ID of the object the error is about if available.
    * @param error. The Error object.
    * @return ID the object's Id if available, otherwise null.
    */
    public static ID getErrorObjectId(Error__c error) {
        if (error.Record_URL__c != null) {
            return error.Record_URL__c.substringAfterLast('/');
        }
        return null;
    }
    
    /*******************************************************************************************************
    * @description Returns the status of the error that happened as a result of a DML operation performed through
    *              the Database class as a string.
    * @param status The status code.
    * @return The error status as a string.
    */
    private static String getStatusCode(system.StatusCode status) {
    	if (status == system.Statuscode.REQUIRED_FIELD_MISSING)
            return 'Required Field Missing';   
        else if (status == system.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION)
            return 'Custom Validation Rule Failed';
        else
            return 'Other';
    }
}