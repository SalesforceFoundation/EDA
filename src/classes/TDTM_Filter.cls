public with sharing class TDTM_Filter {

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
        		
        		if(fieldType == Schema.DisplayType.Boolean) {
        			Boolean val = Boolean.valueOf(classToRunRecord.get('Filter_Value__c'));
        			UTIL_Debug.debug('****Boolean filter field with value: ' + val);
        			//filter records by condition
        			for(SObject o : newList) {
        				if(o.get(filterField) != val) {
        					filtered.newList.add(o);
        				}
        			}
        		} else if(fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.Email) {
        			String val;
        			Object valNoCasting = classToRunRecord.get('Filter_Value__c');
        			if(valNoCasting != null) {
        				val = String.valueOf(valNoCasting);
        			} else {
        				UTIL_Debug.debug('****Filter value is null');
        			}
        			UTIL_Debug.debug('****Text/email filter field with value: ' + val);
        			//filter records by condition
        			for(SObject o : newList) {
        				if(o.get(filterField) != val) {
        					UTIL_Debug.debug('****Adding object back to new list: ' + o);
        					filtered.newList.add(o);
        				}
        			}
        			for(SObject o : oldList) {
        				if(o.get(filterField) != val) {
        					UTIL_Debug.debug('****Adding object back to old list: ' + o);
        					filtered.oldList.add(o);
        				}
        			}
        		}
        		UTIL_Debug.debug('****Filtered new list: ' + JSON.serializePretty(filtered.newList));
        	}
    	} catch(Exception e) {
    		UTIL_Debug.debug(LoggingLevel.WARN, '****Invalid filtering condition');
    	}
    	return filtered;
    }
    
    public class FilteredLists {
    	public List<SObject> newList;
    	public List<SObject> oldList;
    	
    	public FilteredLists() {
    		newList = new List<SObject>();
    		oldList = new List<SObject>();
    	}
    }
}