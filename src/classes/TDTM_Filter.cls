/*
    Copyright (c) 2015, Salesforce.org
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
* @date 2015
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description Allows running TDTM class only for those records that do not meet the filtering criteria.
* Those that do are taken out from the list of records to process. 
*/
public class TDTM_Filter {
    
    /* @description  The name of the class being run.*/
    TDTM_Global_API.TdtmToken tdtmToken;
    /* * @description The records that were passed to the trigger as trigger.new. */
    List<SObject> newList;
    /* @description The records that were passed to the trigger as trigger.old. */
    List<SObject> oldList;
    /* @description The type of SObject the class runs for. */
    DescribeSObjectResult describeObj;
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
    public TDTM_Filter(TDTM_Global_API.TdtmToken token, List<SObject> newList, List<SObject> oldList, 
    DescribeSObjectResult describeObj) {
        this.tdtmToken = tdtmToken;
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
    		filterField = tdtmToken.getFilterField();
    		if(filterField != null) {
	        	if(filterField.contains('.')) { //If the field to filter on is made of relationships
	        	    filterByRelationship();
	        	} else { //No need to break down the field condition
	        	    if(filterField.endsWith('__c')) {
	        	        fieldName = UTIL_Namespace.StrTokenNSPrefix(filterField); 
	        	    } else {
	        	        fieldName = filterField;
	        	    }
	        	    filterByField();
	        	}
	        	return filtered;
	    	}
    	} catch(Exception e) {
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
        
        List<String> filterFullChain = (filterField.split('\\.', 0)); //separate cross object references, i.e. account.name   
        fieldName = filterFullChain[filterFullChain.size() - 1]; //get the field name itself
        String parentObjectName = filterFullChain[filterFullChain.size() - 2]; //get the name of the field parent = last object in the chain      
        UTIL_Debug.debug('****filterFullChain: ' + filterFullChain);
        
        //remove the field, to have only the parent object chain
        for(Integer i = 0; i < (filterFullChain.size() - 1); i++)
            filterObjectChain.add(filterFullChain[i]);
        
        //For the special Parent field on Account case. The relationship is called "Parent", but the object is Account.
        if(filterFullChain.size() > 2 && filterFullChain[filterFullChain.size() - 3]  == 'Account' && filterFullChain[filterFullChain.size() - 2] == 'Parent') {
            parentObjectName = 'Account'; //If we don't do this, we get "Exception: Invalid object name 'Parent'" when calling getObjectDescribe, because the 
            //element in the map retrieved from the parent is ParentId.
        }
        
        SObjectField field = getSObjectFilterField(parentObjectName);
        
        if(field != null) { //the field name is valid for the object at the top of the chain!
            filterValue = getFilter(field);
            UTIL_Debug.debug('****Filter value: ' + filterValue);
            filterByCondition(newListRelatedFields, oldListRelatedFields);
        } else {
            addErrorToAll();
        }       
    }
    
    /*******************************************************************************************************
    * @description Adds an error message to all the records in the trigger.
    * @return void
    */
    private void addErrorToAll() {
        for(Integer i = 0; i < newList.size(); i++) {
            UTIL_Debug.debug('****Invalid filter error added in TDTM_Filter');
            newList[i].addError(Label.InvalidFilter + ' ' + tdtmToken.getClassName());
            filtered.newList.add(newList[i]);
        }
    }
    
    /*******************************************************************************************************
    * @description We need the SObjectField to know the type of the filter field and determine if any manipulation 
    * is necessary. All the filter conditions are stored as strings, but some many need to be transformed to 
    * compare against the values in the trigger records. For example, is a filtering condition is stored as 'true' 
    * we'll need to transform it into the Boolean value true.
    * @param parentObjectName The name of the object that is the parent of the filter field, as initally defined in the filtering
    * condition.
    * @return SObjectField The field to filter on as SObjectField.
    */
    private SObjectField getSObjectFilterField(String parentObjectName) {
        UTIL_Debug.debug('****Bottom child: ' + fieldName);
        UTIL_Debug.debug('****Bottom parent: ' + parentObjectName);
        SObjectField field = getSOField(parentObjectName, fieldName);
        UTIL_Debug.debug('****Field in object: ' + field);
        
        if(field == null) {
            //If the field is not valid, go up the object chain until we find one that is valid. Then go back down to find the object type
            //at each level, until we get to the type of the parent of the filter field.
            ChainLink firstValidLink = findValidObjectInChain(filterObjectChain.size() - 1);
            //Now go back down the chain. What we really want is the object type of the parent of the filter field.
            ChainLink link = firstValidLink;
            for(Integer i = firstValidLink.objectChainIndex + 1; i < filterObjectChain.size(); i++) {
                UTIL_Debug.debug('****Parent object name: ' + link.objectReferenced);
                field = getSOField(link.objectReferenced, filterObjectChain[i]);
                UTIL_Debug.debug('****field back up the chain: ' + field);
                String objectReferenced = getObjectTypeReferenced(link.objectReferenced, filterObjectChain[i]);
                link = new ChainLink(field, objectReferenced, link.objectReferenced, i);
            }
            field = getSOField(link.objectReferenced, fieldName);
        }
        return field;
    }
    
    /*******************************************************************************************************
    * @description Finds the first valid object in the chain, that is the first item in the chain built from the filtering
    * condition where the name is an actual object name. If none of the items in the chain are an actual object, it will 
    * go all the way back up to the object the class is running on.
    * @objectChainIndex The index of the element in the chain to inspect.  
    */
    private ChainLink findValidObjectInChain(Integer objectChainIndex) {
        SObjectField field;
        if(objectChainIndex == 0) {
            UTIL_Debug.debug('****Top child: ' + filterObjectChain[objectChainIndex]);
            String topParent = describeObj.getName();
            UTIL_Debug.debug('****Top parent: ' + topParent);
            field = getSOField(topParent, filterObjectChain[objectChainIndex]);
            String objectReferenced = getObjectTypeReferenced(describeObj.getName(), filterObjectChain[objectChainIndex]);
            ChainLink link = new ChainLink(field, objectReferenced, describeObj.getName(), objectChainIndex);
            return link;
        } else {
            String child = filterObjectChain[objectChainIndex];
            UTIL_Debug.debug('****Child: ' + child);
            String parent = filterObjectChain[objectChainIndex -1];
            UTIL_Debug.debug('****Parent: ' + parent);
            String objectReferenced = getObjectTypeReferenced(parent, child);
            UTIL_Debug.debug('****objectReferenced: ' + objectReferenced);
            if(parent != null) {
	            field = getSOField(parent, child);
	            UTIL_Debug.debug('****Field in findValidObjectInChain: ' + field);
	            if(field == null) {
	                return findValidObjectInChain(--objectChainIndex);
	            } else {
	                ChainLink link = new ChainLink(field, objectReferenced, parent, objectChainIndex);
	                return link;
	            }
            } else {
                return findValidObjectInChain(--objectChainIndex);
            }
        }
    }
    
    /*******************************************************************************************************
    * @description Get the object type of the filter field. For example, the field might be called Current_Address__c, 
    * but the object is Address__c.
    * @param parent The parent object of the field.
    * @param child The field for which we are trying to find the object type referenced.
    * @return String The name of the object referenced by child, if any. 
    */
    private String getObjectTypeReferenced(String parent, String child) {
        String objPointingTo;
        DescribeSObjectResult objectDescribe;
        try {
            parent = fromRtoC(parent);
            UTIL_Debug.debug('****Parent in getObjectTypeReferenced: ' + parent);
            child = fromRtoC(child);
            UTIL_Debug.debug('****Child in getObjectTypeReferenced: ' + child);
	        objectDescribe = UTIL_Describe.getObjectDescribe(parent);
	        if(objectDescribe != null) {
		        Map<String, SObjectField> fieldsMap = objectDescribe.fields.getMap();
		        DescribeFieldResult customObjParentDescribe = fieldsMap.get(child).getDescribe();
		        List <sObjectType> refs = customObjParentDescribe.getReferenceTo();
		        if(refs != null && refs.size() == 1) {
		            objPointingTo = refs[0].getDescribe().getName();
		            UTIL_Debug.debug('****Child object is of type ' + objPointingTo);
		        } else if(refs.size() > 1) {
		            UTIL_Debug.debug('****Field could be pointing to more than one type of object. ' +
		                             ' We should iterate through each and see which one contains that field.');   
		        }
	        }
        } catch(UTIL_Describe.SchemaDescribeException e) {
            UTIL_Debug.debug('****Invalid object name: ' + parent);
            return null;
        }
        return objPointingTo;
    }
    
    /*******************************************************************************************************
    * @description Gets the SObjectField for the fieldName field name in parentObjectName.
    * @param parentObjectName The name of the object containing the field, as a string.
    * @param fieldName The name of the field we are looking for, as a string.
    * @return SObjectField The field we are looking for.
    */
    private SObjectField getSOField(String parentObjectName, String fieldName) {
        parentObjectName = fromRtoC(parentObjectName);  
        fieldName = fromRtoC(fieldName);
        UTIL_Debug.debug('****Parent in getSOField: ' + parentObjectName); 
        UTIL_Debug.debug('****Child in getSOField: ' + fieldName);
        try {
            DescribeSObjectResult objectDescribe = UTIL_Describe.getObjectDescribe(parentObjectName);
            if(objectDescribe != null) {
                Map<String, SObjectField> fieldsMap = objectDescribe.fields.getMap();
                return fieldsMap.get(fieldName);
            } else {
                return null;
            }
        } catch(UTIL_Describe.SchemaDescribeException e) {
            UTIL_Debug.debug('****Invalid object name: ' + parentObjectName);
            return null;
        }
    }
    
    /*******************************************************************************************************
    * @description Replaces __r with __c in the string passed, in case that's the only difference between the name
    * used to query and the actual object named referenced. It also adds the package prefix, if necessary.
    * @param The relationship name.
    * @return String The object name, if the name of a custom relationship was passed. 
    */
    private String fromRtoC(String fieldName) {
        //Remove custom field/object suffix
        if(fieldName.endsWith('__r') || fieldName.endsWith('__c')) {
            String suffix;
            if(fieldName.endsWith('__r')) {
                suffix = '__r';
                fieldName = fieldName.removeEnd('__r');
            }
            else if(fieldName.endsWith('__c')) {
                suffix = '__c';
                fieldName = fieldName.removeEnd('__c');
            }
            //Add prefix ONLY IF it hasn't already been added
            if(!fieldName.contains('__'))
                fieldName = UTIL_Namespace.StrTokenNSPrefix(fieldName);
            //Put suffix back
            fieldName = fieldName + suffix;
        }
        
        if(fieldName.endsWith('__r'))
            return fieldName.replace('__r', '__c');
        else
            return fieldName;
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
	        String dynamicQuery = 'select ' + String.escapeSingleQuotes(filterField) + ' from ' + describeObj.getName() +  ' where ID in :compListIDs';
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
        SObjectField field = describeObj.fields.getMap().get(fieldName);
        UTIL_Debug.debug('****Field in object: ' + field);
        if(field != null) { //the field name is valid!
            filterValue = getFilter(field);
            UTIL_Debug.debug('****Filter value: ' + filterValue);
            filterByCondition(null, null);
        } else {
            addErrorToAll();
        }
    }
    
    /*******************************************************************************************************
    * @description Returns the value to compare against in the correct type.
    * @param Field The SObjectField used in the filtering comparison.
    * @return Object The value to compare against when filtering, already in the correct type. 
    */
    private Object getFilter(SObjectField field) {
        //let's find the field type
        DisplayType fieldType = field.getDescribe().getType();
        UTIL_Debug.debug('****Filter field type: ' + fieldType);
        String val = tdtmToken.getFilterValue();    
        if(fieldType == DisplayType.Boolean) {
            if(val == 'true') {
                return true;
            } else if(val == 'false') {
                return false;
            }
        } else if(fieldType == DisplayType.Date) {
            return Date.parse(val);
        } else if(fieldType == DisplayType.Reference) {
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
    
    /*******************************************************************************************************
    * @description Wrapper representing a link in the chain obtained from the filtering condition.
    */
    public class ChainLink {
        public SObjectField field;
        public String fieldName;
        public String objectReferenced;
        public String parentName;
        public Integer objectChainIndex;
        
        public ChainLink(SObjectField field, String objectReferenced, String parentName, Integer objectChainIndex) {
            this.field = field;
            this.fieldName = this.field.getDescribe().getName(); //@TODO: optimize this to save describe calls?
            this.objectReferenced = objectReferenced;
            this.parentName = parentName;
            this.objectChainIndex = objectChainIndex;
        }
    }
}