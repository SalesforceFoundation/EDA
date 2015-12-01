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
 * @description Class that queries custom object to retrieve classes to call for creation or modification
 * of a record of a specific object type.
 */
public class TDTM_ObjectDataGateway {
    
    private static List<ToRunOnObjectAction> classesQueried = new List<ToRunOnObjectAction>();
    private static Integer rowCount;
    
    /*******************************************************************************************************
     * @description Checks is any TDTM records exist.
     * @return Boolean True is there are no TDTM records. False otherwise.
     */
    public Boolean isEmpty() {
    	if(rowCount == null) {
	    	List<AggregateResult> result = [select count(Id) rowCount from Trigger_Handler__c where Class__c != null];
	    	rowCount = (Integer)result[0].get('rowCount');
    	}
    	if(rowCount == 0)
            return true;    
        return false;
    }
    
    /*******************************************************************************************************
     * @description Returns the classes that will be called for the specified ojbect and action. Returned list 
     *              is sorted by load order.
     * @param objectName The name of the object.
     * @param action The action (before insert, after insert,...). 
     * @return List<SObject> List of classes to call, sorted by load order.
     **/
    public List<SObject> getClassesToCallForObject(String objectName, TDTM_Runnable.Action action) {   
        ToRunOnObjectAction toRun = objectActionQueried(objectName, action);
        if(toRun != null) {
        	return toRun.classesToCall;
        } else {
            List<SObject> classesToCall =  [select Asynchronous__c, Class__c, Load_Order__c, Object__c, Active__c, 
                Trigger_Action__c, Filter_Field__c, Filter_Value__c from Trigger_Handler__c 
                where Active__c = true and Object__c = :objectName and Trigger_Action__c includes ( :action.name() ) 
                order by Load_Order__c];
            toRun = new ToRunOnObjectAction(objectName, action, classesToCall);
            classesQueried.add(toRun);
            return classesToCall;
        }
    }
    
    private static ToRunOnObjectAction objectActionQueried(String objectName, TDTM_Runnable.Action action) {
    	for(ToRunOnObjectAction toRun : classesQueried) {
    		if(toRun.objectName == objectName && toRun.action == action) {
    		  return toRun;
    		}
    	}
    	return null;
    }
    
    private class ToRunOnObjectAction {
    	private String objectName;
    	private TDTM_Runnable.Action action;
    	private List<SObject> classesToCall;
    	
    	ToRunOnObjectAction(String objectName, TDTM_Runnable.Action action, List<SObject> classesToCall) {
    		this.objectName = objectName;
    		this.action = action;
    		this.classesToCall = classesToCall;
    	}
    }
}