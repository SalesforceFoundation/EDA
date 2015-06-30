/*
    Copyright (c) 2015, Salesforce.com Foundation
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
* @date 2015
* @group TDTM
* @description Allows running TDTM class only for those records that do not meet the filtering criteria.
* Those that do are taken out from the list of records to process. 
*/
public with sharing class TDTM_Filter {

	/*******************************************************************************************************
    * @description Filters records to process.
    * @param classToRunRecord The class being run.
    * @param newList The records that were passed to the trigger as trigger.new.
    * @param oldList The records that were passed to the trigger as trigger.old.
    * @param describeObj The type of SObject the class runs for.
    * @return Void
    */
    public static FilteredLists filter(SObject classToRunRecord, List<SObject> newList, List<SObject> oldList, 
    Schema.DescribeSObjectResult describeObj) {
    	FilteredLists filtered = new FilteredLists();
    	try {
    		String filterField = String.valueOf(classToRunRecord.get('Filter_Field__c'));
    		UTIL_Debug.debug('****Filter field: ' + filterField);
        	//get field type
        	Map<String, Schema.SObjectField> fieldMap = describeObj.fields.getMap();
        	Schema.SObjectField field = fieldMap.get(filterField);
        	if(field != null) { //the field name is valid!	
        		//let's find the field type
        		Schema.DisplayType fieldType = field.getDescribe().getType();
        		UTIL_Debug.debug('****Filter field type: ' + fieldType);
        		String val = String.valueOf(classToRunRecord.get('Filter_Value__c'));
	        		
        		if(fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.Email 
        		|| fieldType == Schema.DisplayType.Phone || fieldType == Schema.DisplayType.Picklist) {
        			filterByCondition(newList, oldList, filterField, filtered, val);
        		} else if(fieldType == Schema.DisplayType.Boolean) {
        			if(val == 'true') {
        				filterByCondition(newList, oldList, filterField, filtered, true);
        			} else if(val == 'false') {
        				filterByCondition(newList, oldList, filterField, filtered, false);
        			}
    			} else if(fieldType == Schema.DisplayType.Date) {
    				Date dateVal = Date.parse(val);
    				filterByCondition(newList, oldList, filterField, filtered, dateVal); 
    			}
        		
        		UTIL_Debug.debug('****Filtered new list: ' + JSON.serializePretty(filtered.newList));
        	}
    	} catch(Exception e) {
    		UTIL_Debug.debug(LoggingLevel.WARN, '****Invalid filtering condition');
    	}
    	return filtered;
    }
    
    private static void filterByCondition(List<SObject> newList, List<SObject> oldList, String filterField, FilteredLists filtered, Object val) {
    	for(SObject o : newList) {
			if(o.get(filterField) != val) {
				filtered.newList.add(o);
			}
		}
		for(SObject o : oldList) {
			if(o.get(filterField) != val) {
				filtered.oldList.add(o);
			}
		}
    }
    
    /*******************************************************************************************************
    * @description Contains the filtered new and old lists of records, so we can return both from the filter method.
    */
    public class FilteredLists {
    	public List<SObject> newList;
    	public List<SObject> oldList;
    	
    	public FilteredLists() {
    		newList = new List<SObject>();
    		oldList = new List<SObject>();
    	}
    }
}