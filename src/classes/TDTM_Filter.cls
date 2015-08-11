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
    	UTIL_Debug.debug('****New list before filtering: ' + JSON.serializePretty(newList));
    	try {
    		String filterField = String.valueOf(classToRunRecord.get('Filter_Field__c'));
    		if(filterField != null) {
	        	if(filterField.contains('.')) { //If the field to filter on is made of relationships
	        	    return filterByRelationship(filterField, classToRunRecord, newList, oldList, describeObj);
	        	} else {
	        	    return filterByField(filterField, classToRunRecord, newList, oldList, describeObj);
	        	}
	    	}
    	} catch(Exception e) {
    		UTIL_Debug.debug(LoggingLevel.WARN, '****Invalid filtering condition');
    		UTIL_Debug.debug(LoggingLevel.WARN, '****Exception: ' + e.getMessage());
    		UTIL_Debug.debug(LoggingLevel.WARN, '\n****Stack Trace:\n' + e.getStackTraceString() + '\n');
    	}
    	return new FilteredLists(); //To avoid returning null.
    }
    
    private static FilteredLists filterByRelationship(String filterField, SObject classToRunRecord, List<SObject> newList, 
    List<SObject> oldList, Schema.DescribeSObjectResult describeObj) {
        FilteredLists filtered = new FilteredLists();
        
        List<SObject> newListRelatedFields = queryRelatedFields(filterField, newList, describeObj);
        List<SObject> oldListRelatedFields = queryRelatedFields(filterField, oldList, describeObj);
        
        List<String> splitField = (filterField.split('\\.', 0)); //separate cross object references, i.e. account.name   
        String fieldName = splitField[splitField.size() - 1]; //get the field name itself
        String parentObjectName = splitField[splitField.size() - 2]; //get the name of the field parent = last object in the chain      
        
        //remove the field, to have only the parent object chain
        List<String> filterObjectChain = new List<String>();
        for(Integer i = 0; i < (splitField.size() - 1); i++)
            filterObjectChain.add(splitField[i]);
        UTIL_Debug.debug('****Parent objects chain: ' + JSON.serializePretty(filterObjectChain));
        
        Schema.SObjectField field = UTIL_Describe.getObjectDescribe(parentObjectName).fields.getMap().get(fieldName);
        UTIL_Debug.debug('****Field in object: ' + field);
        
        if(field != null) { //the field name is valid for the object at the top of the chain!
            Object filterValue = getFilter(field, classToRunRecord);
            filterByCondition(newList, oldList, newListRelatedFields, oldListRelatedFields, filterObjectChain, 
                                fieldName, filtered, filterValue);
            UTIL_Debug.debug('****Filtered new list: \n ' + JSON.serializePretty(filtered.newList));
        } else {
            UTIL_Debug.debug('****The field name is invalid.');
        }       
        return filtered;
    }
    
    private static List<SObject> queryRelatedFields(String filterField, List<SObject> compList, 
    Schema.DescribeSObjectResult describeObj) {
        Map<ID, SObject> compMap = new Map<ID, SObject>(compList);
        Set<ID> compListIDs = compMap.keySet();
        //query filter values, in case they are not in the trigger
        String dynamicQuery = 'select ' + filterField + ' from ' + describeObj.getName() +  ' where ID in :compListIDs';
        UTIL_Debug.debug('****Dynamic query: ' + dynamicQuery);
        Map<ID, SObject> withRelatedFieldsMap = new Map<ID, SObject>(Database.query(dynamicQuery));
        List<SObject> withRelatedFields = new List<SObject>();
        //Let's make sure we return them in the same order the list passed as param
        for(SObject compRecord : compList) {
            withRelatedFields.add(withRelatedFieldsMap.get(compRecord.ID));
        }
        return withRelatedFields;
    }
    
    private static FilteredLists filterByField(String filterField, SObject classToRunRecord, List<SObject> newList, 
    List<SObject> oldList, Schema.DescribeSObjectResult describeObj) {
        FilteredLists filtered = new FilteredLists();
        
        //get field type
        Map<String, Schema.SObjectField> fieldMap = describeObj.fields.getMap();
        Schema.SObjectField field = fieldMap.get(filterField);
        if(field != null) { //the field name is valid!
            Object filter = getFilter(field, classToRunRecord);
            filterByCondition(newList, oldList, null, null, null, filterField, filtered, filter);
            UTIL_Debug.debug('****Filtered new list: ' + JSON.serializePretty(filtered.newList));
        } else {
            UTIL_Debug.debug('****The field name is invalid.');
        }
        return filtered;
    }
    
    private static Object getFilter(Schema.SObjectField field, SObject classToRunRecord) {
        //let's find the field type
        Schema.DisplayType fieldType = field.getDescribe().getType();
        UTIL_Debug.debug('****Filter field type: ' + fieldType);
        String val = String.valueOf(classToRunRecord.get('Filter_Value__c'));
            
        if(fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.Email 
        || fieldType == Schema.DisplayType.Phone || fieldType == Schema.DisplayType.Picklist) {
            return val;
        } else if(fieldType == Schema.DisplayType.Boolean) {
            if(val == 'true') {
                return true;
            } else if(val == 'false') {
                return false;
            }
        } else if(fieldType == Schema.DisplayType.Date) {
            return Date.parse(val);
        } else if(fieldType == Schema.DisplayType.Reference) {
            return ID.valueOf(val);
        }
        return null;
    }
    
    private static void filterByCondition(List<SObject> newList, List<SObject> oldList, List<SObject> newListRelatedFields, 
    List<SObject>oldListRelatedFields, List<String> filterObjectChain, String filterField, FilteredLists filtered, Object val) {
        if(filterObjectChain == null) { //The field in in the same object the trigger fires on
	    	filterList(newList, filterField, filtered.newList, val);
			filterList(oldList, filterField, filtered.oldList, val);	
        } else { //The field is in a related object
            filterListByRelatedField(newListRelatedFields, newList, filtered.newList, filterObjectChain, filterField, val);
            filterListByRelatedField(oldListRelatedFields, oldList, filtered.oldList, filterObjectChain, filterField, val);
        }
    }
    
    private static void filterListByRelatedField(List<SObject> listRelatedFields, List<SObject> originalList, 
    List<SObject> filteredList, List<String> filterObjectChain, String filterField, Object val) {
        if(listRelatedFields != null && listRelatedFields.size() > 0) {
            for(Integer i = 0; i < listRelatedFields.size(); i++) {
                SObject o = listRelatedFields[i];
                //SObject original = o; //I just want to keep a reference to the original object, to be able to filter on it.
                UTIL_Debug.debug('****Object in trigger: ' + o);
                //traverse parent relationships until the last one
                if (o != null) {
                    for (String parentObj : filterObjectChain) {
                        UTIL_Debug.debug('****Object to traverse: ' + parentObj);
                        o = o.getsObject(parentObj);
                        UTIL_Debug.debug('****Parent object: ' + o);
                    }
                }
                //perform the filtering
                UTIL_Debug.debug('****Filtering by field ' + filterField + ', with value ' + val + ' on object ' + o);
                if(o != null && o.get(filterField) != val) {
                    UTIL_Debug.debug('****Adding object ' + originalList[i] + ' to filtered list.');    
                    filteredList.add(originalList[i]);
                }
            }
        }
    }
    
    private static void filterList(List<SObject> listToFilter, String filterField, List<SObject> filteredList, Object val) {
        if(listToFilter != null && listToFilter.size() > 0) {
            for(SObject o : listToFilter) {
                if(o.get(filterField) != val) {
                    filteredList.add(o);
                }
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