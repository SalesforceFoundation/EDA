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

    /* @description  An instance of the class being run.*/
    SObject classToRunRecord; 
    /* * @description The records that were passed to the trigger as trigger.new. */
    List<SObject> newList;
    /* @description The records that were passed to the trigger as trigger.old. */
    List<SObject> oldList;
    /* @description The type of SObject the class runs for. */
    Schema.DescribeSObjectResult describeObj;
    /* @description filterField The field to filter on, including the whole relationship chain, i.e. "Account.Name".*/
    String filterField;
    /* The field to filter on in the parent object, i.e. "Name". */
    String fieldName;
    /* @description The value to compare against when filtering, already in the correct type. */
    Object filterValue;
    /* @description An instance of the wrapper object that contains the filtered newList and oldList. */
    FilteredLists filtered;
    /* @description The chain of parent objects used in the filter, not including the object the class is running on. 
    i.e., if the class runs on Contact this could be "Account", and if it runs on Opportunity "Contact.Account"*/
    List<String> filterObjectChain;
    
    /*******************************************************************************************************
    * @description Constructor. Sets properties.
    * @param classToRunRecord The class being run.
    * @param newList The records that were passed to the trigger as trigger.new.
    * @param oldList The records that were passed to the trigger as trigger.old.
    * @param describeObj The type of SObject the class runs for.
    */
    public TDTM_Filter(SObject classToRunRecord, List<SObject> newList, List<SObject> oldList, 
    Schema.DescribeSObjectResult describeObj) {
        this.classToRunRecord = classToRunRecord;
        this.newList = newList;
        this.oldList = oldList;
        this.describeObj = describeObj;
        filtered = new FilteredLists();
        filterObjectChain = new List<String>();
    }
    
	/*******************************************************************************************************
    * @description Filters records to process.
    * @return FilteredLists An instance of the wrapper object that contains the filtered newList and oldList.
    */
    public FilteredLists filter() {
    	try {
    		filterField = String.valueOf(classToRunRecord.get('Filter_Field__c'));
    		if(filterField != null) {
	        	if(filterField.contains('.')) { //If the field to filter on is made of relationships
	        	    filterByRelationship();
	        	} else {
	        	    fieldName = filterField; //No need to break down the field condition
	        	    filterByField();
	        	}
	        	return filtered;
	    	}
    	} catch(Exception e) {
    		UTIL_Debug.debug(LoggingLevel.WARN, '****Invalid filtering condition');
    		UTIL_Debug.debug(LoggingLevel.WARN, '****Exception: ' + e.getMessage());
    		UTIL_Debug.debug(LoggingLevel.WARN, '\n****Stack Trace:\n' + e.getStackTraceString() + '\n');
    	}
    	return null;
    }
    
    /*******************************************************************************************************
    * @description Filters newList and oldList based on the value of a related field.
    * @return void 
    */
    private void filterByRelationship() {        
        List<SObject> newListRelatedFields = queryRelatedFields(newList);
        List<SObject> oldListRelatedFields = queryRelatedFields(oldList);
        Map<String, Schema.SObjectField> fieldsMap;
        
        List<String> splitField = (filterField.split('\\.', 0)); //separate cross object references, i.e. account.name   
        fieldName = splitField[splitField.size() - 1]; //get the field name itself
        String parentObjectName = splitField[splitField.size() - 2]; //get the name of the field parent = last object in the chain      
        UTIL_Debug.debug('****splitField: ' + splitField);
        
        //For the special Parent field on Account case
        if(splitField.size() > 2 && splitField[splitField.size() - 3]  == 'Account' && splitField[splitField.size() - 2] == 'Parent') {
            UTIL_Debug.debug('****The relationship is called "Parent", but the object is Account');
            parentObjectName = 'Account'; //If we don't do this, we get "Exception: Invalid object name 'Parent'" when calling getObjectDescribe below.
        }
        
        //For the Custom Object at the top of the chain case
        if(splitField.size() >= 2 && (splitField[splitField.size() - 2]).endsWith('__r')) {
            UTIL_Debug.debug('****The parent object is custom');
            parentObjectName = parentObjectName.replace('__r', '__c');
            
            //Getting the type of the object that is the parent of the filter field, even if it's custom.
            String parentOfParent;
            //Get the parent object of the object at the top of the chain. If there is only one object in the chain, the parent
            //is the object in the trigger.
            if(splitField.size() > 2) {
                parentOfParent = splitField[splitField.size() - 3];
            } else {
                parentOfParent = describeObj.getName();
            }
            UTIL_Debug.debug('****Parent of parent: ' + parentOfParent);
            
            String objPointingTo;
            //Get the object type of the field. For example, the field might be called Current_Address__c, but the object is Address__c
            fieldsMap = UTIL_Describe.getObjectDescribe(parentOfParent).fields.getMap();
            Schema.DescribeFieldResult customObjParentDescribe = fieldsMap.get(parentObjectName).getDescribe();
            List <Schema.sObjectType> refs = customObjParentDescribe.getReferenceTo();
            if(refs != null && refs.size() == 1) {
                objPointingTo = refs[0].getDescribe().getName();
                UTIL_Debug.debug('****Object with filter field is of type ' + objPointingTo);
            } else if(refs.size() > 1) {
                UTIL_Debug.debug('****Field could be pointing to more than one type of object. We will have to iterate through each and see which one contains that field.');   
            }
            parentObjectName = objPointingTo;
        }
        
        //remove the field, to have only the parent object chain
        for(Integer i = 0; i < (splitField.size() - 1); i++)
            filterObjectChain.add(splitField[i]);
        UTIL_Debug.debug('****Parent objects chain: ' + JSON.serializePretty(filterObjectChain));
        
        fieldsMap = UTIL_Describe.getObjectDescribe(parentObjectName).fields.getMap();
        Schema.SObjectField field = fieldsMap.get(fieldName);
        UTIL_Debug.debug('****Field in object: ' + field);
        
        if(field != null) { //the field name is valid for the object at the top of the chain!
            filterValue = getFilter(field);
            UTIL_Debug.debug('****Filter value: ' + filterValue);
            filterByCondition(newListRelatedFields, oldListRelatedFields);
        } else {
            UTIL_Debug.debug('****The field name is invalid.');
        }       
    }
    
    /*******************************************************************************************************
    * @description Queries the fields that are part of the relationship filter, since these values are not initially
    * present in the records the triggers acts on.
    * @param compList The list of records to query.
    * @return List<SObject> A list of records pointing to the same records that are present in newList or oldList,
    * but containing only the fields defined in the query condition. The returned list is also in the same order as 
    * newList or oldList.
    */
    private List<SObject> queryRelatedFields(List<SObject> compList) {
        List<SObject> withRelatedFields = new List<SObject>(); //We don't want to modify the original list, but use a new one instead.
        if(compList != null) {
	        Map<ID, SObject> compMap = new Map<ID, SObject>(compList);
	        Set<ID> compListIDs = compMap.keySet();
	        //query filter values, in case they are not in the trigger
	        String dynamicQuery = 'select ' + filterField + ' from ' + describeObj.getName() +  ' where ID in :compListIDs';
	        UTIL_Debug.debug('****Relationship filter dynamic query: ' + dynamicQuery);
	        Map<ID, SObject> withRelatedFieldsMap = new Map<ID, SObject>(Database.query(dynamicQuery));
	        //Let's make sure we return them in the same order as the list passed as param
	        for(SObject compRecord : compList) {
	            withRelatedFields.add(withRelatedFieldsMap.get(compRecord.ID));
	        }
        }
        return withRelatedFields;
    }
    
    /*******************************************************************************************************
    * @description Filters newList and oldList based on the value of a field on the trigger records.
    * @return FilteredLists An instance of the wrapper object that contains the filtered newList and oldList. 
    */
    private void filterByField() {
        //get field type
        Schema.SObjectField field = describeObj.fields.getMap().get(fieldName);
        UTIL_Debug.debug('****Field in object: ' + field);
        if(field != null) { //the field name is valid!
            filterValue = getFilter(field);
            UTIL_Debug.debug('****Filter value: ' + filterValue);
            filterByCondition(null, null);
        } else {
            UTIL_Debug.debug('****The field name is invalid.');
        }
    }
    
    /*******************************************************************************************************
    * @description Returns the value to compare against in the correct type.
    * @param Field The SObjectField used in the filtering comparison.
    * @return Object The value to compare against when filtering, already in the correct type. 
    */
    private Object getFilter(Schema.SObjectField field) {
        //let's find the field type
        Schema.DisplayType fieldType = field.getDescribe().getType();
        UTIL_Debug.debug('****Filter field type: ' + fieldType);
        String val = String.valueOf(classToRunRecord.get('Filter_Value__c'));    
        if(fieldType == Schema.DisplayType.Boolean) {
            if(val == 'true') {
                return true;
            } else if(val == 'false') {
                return false;
            }
        } else if(fieldType == Schema.DisplayType.Date) {
            return Date.parse(val);
        } else if(fieldType == Schema.DisplayType.Reference) {
            return ID.valueOf(val);
        } else { //We'll treat everything else as a string, including String, Email, Phone, and Picklist
            return val;
        }
        return null;
    }
    
    /*******************************************************************************************************
    * @description Filters newList and oldList based on the defined filtering criteria. 
    * @param newListRelatedFields A list of records pointing to the same records that are present in newList, 
    * but containing only the fields defined in the query condition. In the same order as newList.
    * @param oldListRelatedFields A list of records pointing to the same records that are present in oldList, 
    * but containing only the fields defined in the query condition. In the same order as newList.
    * @return void 
    */
    private void filterByCondition(List<SObject> newListRelatedFields, List<SObject> oldListRelatedFields) {
        if(filterObjectChain.size() == 0) { //The field in in the same object the trigger fires on
	    	filterList(newList, filtered.newList);
			filterList(oldList, filtered.oldList);	
        } else { //The field is in a related object
            filterListByRelatedField(newListRelatedFields, newList, filtered.newList);
            filterListByRelatedField(oldListRelatedFields, oldList, filtered.oldList);
        }
    }
    
    /*******************************************************************************************************
    * @description Populates filteredList with the records from originalList that don't match the filtering
    * criteria included in listRelatedFields. Used for filtering criteria based on a relationship.
    * @param listRelatedFields A list of records pointing to the same records that are present in originalList, 
    * but containing only the fields defined in the query condition. In the same order as originalList.
    * @param originalList The original list whose records not matching the filter criteria will be added to 
    * the resulting filtered list.
    * @param filteredList The resulting filtered list.
    * @return void 
    */
    private void filterListByRelatedField(List<SObject> listWithRelatedFields, List<SObject> originalList, 
    List<SObject> filteredList) {
        if(listWithRelatedFields != null && listWithRelatedFields.size() > 0) {
            for(Integer i = 0; i < listWithRelatedFields.size(); i++) {
                SObject o = listWithRelatedFields[i];
                UTIL_Debug.debug('****Object in trigger: ' + o);
                Boolean addDirectly = false;
                //traverse parent relationships until the last one
                if (o != null) { //if the object at the bottom of the chain (the one in the trigger) isn't null
                    for (String parentObj : filterObjectChain) {
                        if(o != null) { //if each following object in the chain isn't null
	                        UTIL_Debug.debug('****Object to traverse: ' + parentObj);
	                        o = o.getsObject(parentObj);
	                        UTIL_Debug.debug('****Parent object: ' + o);
                        } else {
                            UTIL_Debug.debug('****Object in the chain is null, we should add element directly to filteredList');
                            addDirectly = true;
                            break;
                        }
                    }
                    
                }
                //in case the topmost object in the chain is null
                if(o == null) {
                    UTIL_Debug.debug('****Top object in the chain is null, we should add element directly to filteredList');
                    addDirectly = true;
                }
                //perform the filtering
                UTIL_Debug.debug('****Filtering by field ' + fieldName + ', with value ' + filterValue + ' on object ' + o);
                if(addDirectly || (o != null && o.get(fieldName) != filterValue)) {
                    UTIL_Debug.debug('****Adding object to filtered list: ' + originalList[i]);    
                    filteredList.add(originalList[i]);
                }
            }
        }
    }
    
    /*******************************************************************************************************
    * @description Populates filteredList with the records from listToFilter that don't match the filtering
    * criteria.
    * @param listToFilter The list of records to filter.
    * @param filteredList The resulting filtered list.
    * @return void 
    */
    private void filterList(List<SObject> listToFilter, List<SObject> filteredList) {
        if(listToFilter != null && listToFilter.size() > 0) {
            for(SObject o : listToFilter) {
                if(o.get(fieldName) != filterValue) {
                    filteredList.add(o);
                }
            }
        } 
    }
    
    /*******************************************************************************************************
    * @description Wrapper containing the filtered new and old lists of records, so we can return both simultaneously 
    * from a method.
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