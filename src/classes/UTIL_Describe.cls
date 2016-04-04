/*
    Copyright (c) 2014 Salesforce.org
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
/**
* @author Salesforce Foundation
* @date 2014
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description This class allows easy access to object and field description information from within other classes.
*
* It is called statically, and therefore will supply the same information to all calls made from
* within one transaction, or set of trigger calls. This is beneficial because this info should
* be the same for all calls in a transaction, and by calling it statically we reduce the calls
* that are made, making the total transaction more efficient.
*/

public class UTIL_Describe {

    // throw custom exceptions when a bogus object or field is provided.
    public class SchemaDescribeException extends Exception {}

    //maps to hold the describe info
    private static Map<String, Schema.SObjectType> gd;
    private static Map<String, Schema.DescribeSObjectResult> objectDescribes = new Map<String, Schema.DescribeSObjectResult>();
    private static Map<String, Map<String, Schema.SObjectField>> fieldTokens = new Map<String,Map<String, Schema.SObjectField>>();
    private static Map<String, Map<String, Schema.DescribeFieldResult>> fieldDescribes = new Map<String,Map<String, Schema.DescribeFieldResult>>();

    /*******************************************
    * Gets describe maps for a new object
    ********************************************/
    static void fillMapsForObject(string objectName) {
        // get the object map the first time
        if (gd==null) gd = Schema.getGlobalDescribe();

        // get the object description
        if (gd.containsKey(objectName)) {

            if (!objectDescribes.containsKey(objectName))
                objectDescribes.put(objectName, gd.get(objectName).getDescribe());
        } else {
            throw new SchemaDescribeException('Invalid object name \'' + objectName + '\'');
        }
    }

    /*******************************************
    * Gets a field map for a new object/field pair
    ********************************************/
    private static void fillFieldMapsForObject(string objectName, string fieldName) {
        // get the object map the first time
        fillMapsForObject(objectName);

        // get the field description
        if (!fieldTokens.containsKey(objectName)) {
            fieldTokens.put(objectName, objectDescribes.get(objectName).fields.getMap());
            fieldDescribes.put(objectName, new Map<String, Schema.DescribeFieldResult>());
        }
        if (!fieldDescribes.get(objectName).containsKey(fieldName)) {
            if (fieldTokens.get(objectName).containsKey(fieldName)) {
                Schema.DescribeFieldResult dfr = fieldTokens.get(objectName).get(fieldName).getDescribe();
                fieldDescribes.get(objectName).put(fieldName, dfr);
            } else {
                throw new SchemaDescribeException('Invalid field name \'' + fieldName + '\'');
            }
        }
    }

    /*******************************************
    * Gets all field maps for a new object
    ********************************************/
    static void fillFieldMapsForObject(string objectName) {
        // get the object map the first time
        fillMapsForObject(objectName);

        // get the field description
        if (!fieldTokens.containsKey(objectName)) {
            fieldTokens.put(objectName, objectDescribes.get(objectName).fields.getMap());
            fieldDescribes.put(objectName, new Map<String, Schema.DescribeFieldResult>());
        }

        //Map<String, Schema.SObjectField> fieldsMap = objectDescribes.get(objectName).fields.getMap();
        if (fieldTokens.get(objectName).size() != fieldDescribes.get(objectName).size()) {
            for ( string fieldName : fieldTokens.get(objectName).keyset()) {
                if (!fieldDescribes.get(objectName).containsKey(fieldName)) {
                    Schema.DescribeFieldResult dfr = fieldTokens.get(objectName).get(fieldName).getDescribe();
                    fieldDescribes.get(objectName).put(fieldName, dfr);
                }
            }
        }
    }

    /*******************************************************************************************************
    * @description Returns new object of given type.
    * @param objectName the name of the object to create
    * @return the new SObject
    */
    public static SObject getPrototypeObject(String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName))
            fillMapsForObject(objectName);

        return gd.get(objectName).newSObject();
    }

    /*******************************************************************************************************
    * @description Returns object friendly name.
    * @param objectName the name of the object to lookup
    * @return the Label of the object
    */
    public static string getObjectLabel(String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName))
            fillMapsForObject(objectName);

        return objectDescribes.get(objectName).getLabel();
    }

    /*******************************************************************************************************
    * @description Returns object describe data.
    * @param objectName the name of the object to lookup
    * @return Schema.DescribeSObjectResult of the object
    */
    public static Schema.DescribeSObjectResult getObjectDescribe(String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName))
            fillMapsForObject(objectName);

        return objectDescribes.get(objectName);
    }

    /*******************************************************************************************************
    * @description Compares Id to verify object type
    * @param salesforceId of the object
    * @param objectName
    * @return true if the Id is for the given object type, false otherwise.
    */
    public static boolean isObjectIdThisType(Id salesforceId, String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName))
            fillMapsForObject(objectName);

        // now grab the requested id prefix
        boolean ret = false;
        if (salesforceId != null) {
            string prefix = objectDescribes.get(objectName).getKeyPrefix();
            if (prefix != null)
                ret = ((string)(salesforceId)).startsWith(prefix);
        }
        return ret;
    }

    /*******************************************************************************************************
    * @description Returns all field describe data
    * @param objectName the name of the object to look up
    * @return Map<String, Schema.DescribeFieldResult> a map of object names to describe file results.
    */
    public static Map<String, Schema.DescribeFieldResult> getAllFieldsDescribe(String objectName) {

        // make sure we have this field's schema mapped
        fillFieldMapsForObject(objectName);

        Map<String, Schema.DescribeFieldResult> fieldMap = fieldDescribes.get(objectName);
        return fieldMap;
    }

    /*******************************************************************************************************
    * @description Gives field type name - ID, STRING, TEXTAREA, DATE, DATETIME, BOOLEAN, REFERENCE,
    * PICKLIST, MULTIPICKLIST, CURRENCY, DOUBLE, INTEGER, PERCENT, PHONE, EMAIL
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the name of the of the field's type
    */
    public static string getFieldType(String objectName, String fieldName) {
        // fields in our own package must not have their prefix for the Describe Field Map
        fieldName = UTIL_Namespace.StrTokenRemoveNSPrefix(fieldName);

        // make sure we have this field's schema mapped
        if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName))
            fillFieldMapsForObject(objectName, fieldName);

        Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
        return dfr.getType().name();
    }

    /*******************************************************************************************************
    * @description Gives field type name - ID, STRING, TEXTAREA, DATE, DATETIME, BOOLEAN, REFERENCE,
    * PICKLIST, MULTIPICKLIST, CURRENCY, DOUBLE, INTEGER, PERCENT, PHONE, EMAIL
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return Displaytype the Displaytype of the field
    */
    public static Schema.Displaytype getFieldDisplaytype(String objectName, String fieldName) {
        // fields in our own package must not have their prefix for the Describe Field Map
        fieldName = UTIL_Namespace.StrTokenRemoveNSPrefix(fieldName);

        // make sure we have this field's schema mapped
        if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName))
            fillFieldMapsForObject(objectName, fieldName);

        Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
        return dfr.getType();
    }

    /*******************************************************************************************************
    * @description Returns field describe data
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return Schema.DescribeFieldResult the describe field result for the given field
    */
    public static Schema.DescribeFieldResult getFieldDescribe(String objectName, String fieldName) {
        // fields in our own package must not have their prefix for the Describe Field Map
        fieldName = UTIL_Namespace.StrTokenRemoveNSPrefix(fieldName);

        // make sure we have this field's schema mapped
        if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName))
            fillFieldMapsForObject(objectName, fieldName);

        Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
        return dfr;
    }

    /*******************************************************************************************************
    * @description Gives field friendly name
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the label of the field
    */
    public static string getFieldLabel(String objectName, String fieldName) {
        // fields in our own package must not have their prefix for the Describe Field Map
        fieldName = UTIL_Namespace.StrTokenRemoveNSPrefix(fieldName);

        // make sure we have this field's schema mapped
        if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName))
            fillFieldMapsForObject(objectName, fieldName);

        Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
        return dfr.getLabel();
    }

    /*******************************************************************************************************
    * @description Gives field friendly name without throwing exception if not valid.
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the label of the field
    */
    public static string getFieldLabelSafe(string strObj, string strField) {
        try {
            return getFieldLabel(strObj, strField);
        } catch (Exception e) {
            return strField;
        }
    }

    /*******************************************************************************************************
    * @description checks whether the field exists
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return boolean whether the field exists
    */
    public static boolean isValidField(String objectName, String fieldName) {
        // fields in our own package must not have their prefix for the Describe Field Map
        fieldName = UTIL_Namespace.StrTokenRemoveNSPrefix(fieldName);

        // make sure we have this field's schema mapped
        try {
            if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName))
                fillFieldMapsForObject(objectName, fieldName);

            Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
            return dfr != null;
        } catch (exception ex) {
            return false;
        }
    }

    /*******************************************************************************************************
    * @description utility to check for compatible datatypes for data copying
    * @param dtSrc the DisplayType of the source object
    * @param dtTgt the DisplayType of the target object
    * @return true if the types can be copied between
    */
    public static boolean canDisplaytypesCopy(Schema.Displaytype dtSrc, Schema.Displaytype dtTgt) {

        if (dtSrc == dtTgt)
           return true;

        // date can go to datetime
        if (dtSrc == Schema.Displaytype.Date && dtTgt == Schema.Displaytype.DateTime)
           return true;

        // numbers can implictly cast to other numbers
        if ((dtSrc == Schema.Displaytype.Currency ||
            dtSrc == Schema.Displaytype.Double ||
            dtSrc == Schema.Displaytype.Integer ||
            dtSrc == Schema.Displaytype.Percent) &&
           (dtTgt == Schema.Displaytype.Currency ||
            dtTgt == Schema.Displaytype.Double ||
            dtTgt == Schema.Displaytype.Integer ||
            dtTgt == Schema.Displaytype.Percent)) {
            return true;
        }

        // text can go to longer text
        if (dtSrc == Schema.Displaytype.String && dtTgt == Schema.Displaytype.TextArea)
            return true;

        return false;
    }

    /*******************************************************************************************************
    * @description utility to return a list of strings from a field set.
    * @param strObject the name of the object
    * @param strFS the name of the object's field set
    * @return a list of strings of field names in the field set
    */
    // utility to return a list of strings from a field set.
    public static list<string> listStrFromFieldSet(string strObject, string strFS) {
        list<string> listStrFields = new list<string>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(strObject);
        Schema.DescribeSObjectResult d = targetType.getDescribe(); 
        Schema.FieldSet fs = d.fieldSets.getMap().get(strFS); 
        if (fs == null) {
            return null;
        } else {
            for(Schema.FieldSetMember f : fs.getFields()) {
                if (f.getFieldPath().contains('.')) {
                    throw (new SchemaDescribeException('Related field \'' + f.getFieldPath() + '\' not supported ' +
                        'in field set \'' + strFS + '\'.  You can only include fields directly on object \'' + strObject + '\'.'));
                }
                listStrFields.add(f.getFieldPath());
            }
            return listStrFields;
        }
    }

    /*******************************************************************************************************
    * @description Returns a comma separated string of field names from a field set.
    * @param strObject the name of the object
    * @param strFS the name of the object's field set
    * @return a comma separated string of field names in the field set
    */
    public static string strFieldNamesFromFieldSet(string strObject, string strFS) {
        string strFields = '';
        for (string str : listStrFromFieldSet(strObject, strFS)) {
            strFields += str + ',';
        }
        return strFields.substring(0, strFields.length()-1);
    }

    /*******************************************************************************************************
    * @description Cache for the record type DeveloperName-to-ID map.
    */
    private static Map<String, Id> mapRecordTypes;
    
    /*******************************************************************************************************
     * @description Returns a map of active, user-available RecordType IDs for a given SObjectType,
     * keyed by each RecordType's unique, unchanging DeveloperName. 
     * @param objectName Name of the object to retrieve record types for.
     * @return Map<String, Id> Map of DeveloperName-to-ID of available record types for object specified. 
     */
    public static Map<String, Id> getRecTypesMapByDevName(String objectName) {	    
	    return getRecTypesMap(objectName, true);
	}
	
	/*******************************************************************************************************
     * @description Returns a map of active, user-available RecordType IDs for a given SObjectType,
     * keyed by each RecordType's Name. 
     * @param objectName Name of the object to retrieve record types for.
     * @return Map<String, Id> Map of Name-to-ID of available record types for object specified. 
     */
    @AuraEnabled
    public static Map<String, Id> getRecTypesMapByName(String objectName) {
        return getRecTypesMap(objectName, false);
    }
    
    /*******************************************************************************************************
     * @description Returns a map of active, user-available RecordType IDs for a given SObjectType, keyed
     * by either the RecordType's Name or the Developer Name, depending on the value of the second param. 
     * @param objectName Name of the object to retrieve record types for.
     * @param devName True if we want the key of the returned map to be the record type's developer name.
     * False if we want it to be the friendly name.
     * @return Map<String, Id> Map of Name-to-ID or DeveloperName-to-ID (depending on the second paramater), 
     * of available record types for object specified. 
     */
    private static Map<String, Id> getRecTypesMap(String objectName, Boolean devName) {      
        if(mapRecordTypes == null) {
            mapRecordTypes = new Map<String, Id>();
        
            // Get the Describe Result
            fillMapsForObject(objectName);
            Schema.DescribeSObjectResult obj = objectDescribes.get(objectName);
        
            // Obtain ALL Active Record Types for the given SObjectType objectType
            String soql = 'SELECT Id, Name, DeveloperName FROM RecordType ' + 'WHERE SObjectType = \'' 
                          + String.escapeSingleQuotes(obj.getName()) + '\' ' + 'AND IsActive = TRUE';
            List<SObject> results;
            try {
                results = Database.query(soql);
            } catch (Exception ex) {
                results = new List<SObject>();
            }
        
            // Obtain the RecordTypeInfos for this SObjectType objectType
            Map<Id,Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByID();
        
            for (SObject rt : results) { 
                // Check RecordType IS available for the running user
                if (!Test.isRunningTest()) {
                    if (recordTypeInfos.get(rt.Id).isAvailable()) {
                        if(devName) {
                            mapRecordTypes.put(String.valueOf(rt.get('DeveloperName')), rt.Id);
                        } else {
                            mapRecordTypes.put(String.valueOf(rt.get('Name')), rt.Id);
                        }
                    }
                // We don't want our tests to depend on the profile configuration in the org. Otherwise tests
                // might fail just because the user running them does not have certain record types assigned.
                } else {
                    if(devName) {
                        mapRecordTypes.put(String.valueOf(rt.get('DeveloperName')), rt.Id);
                    } else {
                        mapRecordTypes.put(String.valueOf(rt.get('Name')), rt.Id);
                    }
                }
            }
        }
        return mapRecordTypes;
    }
	
	/*******************************************************************************************************
     * @description Returns the ID of the Administrative Account record type, if it exists.
     * @return String The ID of the Administrative Account record type as a String.
     */
	public static String getAdminAccRecTypeID() {
	    return getRecTypesMapByDevName('Account').get('Administrative');
	}
	
	/*******************************************************************************************************
     * @description Returns the ID of the Household Account record type, if it exists.
     * @return String The ID of the Household Account record type as a String.
     */
	public static String getHhAccRecTypeID() {
	    return getRecTypesMapByDevName('Account').get('HH_Account');
	}
	
	/*******************************************************************************************************
     * @description Returns the ID of the Business Account record type, if it exists.
     * @return String The ID of the Business Account record type as a String.
     */
	public static String getBizAccRecTypeID() {
	    return getRecTypesMapByDevName('Account').get('Business_Organization');
	}
}