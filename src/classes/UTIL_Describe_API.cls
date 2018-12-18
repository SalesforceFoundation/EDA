/*
    Copyright (c) 2018 Salesforce.org
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
* @date 2018
* @group API
* @group-content ../../ApexDocContent/API.htm
* @description API class that exposes the Describe Utility methods.
*/
global class UTIL_Describe_API {

    /*******************************************************************************************************
    * @description Returns new object of given type.
    * @param objectName the name of the object to create
    * @return the new SObject
    */
    global static SObject getPrototypeObject(String objectName) {
        return UTIL_Describe.getPrototypeObject(objectName);
    }

    /*******************************************************************************************************
    * @description Returns object friendly name.
    * @param objectName the name of the object to lookup
    * @return the Label of the object
    */
    global static string getObjectLabel(String objectName) {
        return UTIL_Describe.getObjectLabel(objectName);
    }

    /*******************************************************************************************************
    * @description Returns object describe data.
    * @param objectName the name of the object to lookup
    * @return Schema.DescribeSObjectResult of the object
    */
    global static Schema.DescribeSObjectResult getObjectDescribe(String objectName) {
        return UTIL_Describe.getObjectDescribe(objectName);
    }

    /*******************************************************************************************************
    * @description Compares Id to verify object type
    * @param salesforceId of the object
    * @param objectName
    * @return true if the Id is for the given object type, false otherwise.
    */
    global static boolean isObjectIdThisType(Id salesforceId, String objectName) {
        return UTIL_Describe.isObjectIdThisType(salesforceId, objectName);
    }

    /*******************************************************************************************************
    * @description Returns all field describe data
    * @param objectName the name of the object to look up
    * @return Map<String, Schema.DescribeFieldResult> a map of object names to describe file results.
    */
    global static Map<String, Schema.DescribeFieldResult> getAllFieldsDescribe(String objectName) {
        return UTIL_Describe.getAllFieldsDescribe(objectName);
    }

    /*******************************************************************************************************
    * @description Gives field type name - ID, STRING, TEXTAREA, DATE, DATETIME, BOOLEAN, REFERENCE,
    * PICKLIST, MULTIPICKLIST, CURRENCY, DOUBLE, INTEGER, PERCENT, PHONE, EMAIL
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the name of the of the field's type
    */
    global static string getFieldType(String objectName, String fieldName) {
        return UTIL_Describe.getFieldType(objectName, fieldName);
    }

    /*******************************************************************************************************
    * @description Gives field type name - ID, STRING, TEXTAREA, DATE, DATETIME, BOOLEAN, REFERENCE,
    * PICKLIST, MULTIPICKLIST, CURRENCY, DOUBLE, INTEGER, PERCENT, PHONE, EMAIL
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return Displaytype the Displaytype of the field
    */
    global static Schema.Displaytype getFieldDisplaytype(String objectName, String fieldName) {
        return UTIL_Describe.getFieldDisplaytype(objectName, fieldName);
    }

    /*******************************************************************************************************
    * @description returns fields of given type by object
    * @param objectName the name of the object to look up
    * @param type the type of field to return - ID, STRING, TEXTAREA, DATE, DATETIME, BOOLEAN, REFERENCE,
    * PICKLIST, MULTIPICKLIST, CURRENCY, DOUBLE, INTEGER, PERCENT, PHONE, EMAIL
    * @return DescribeFieldResult Map of DescribeFieldResult
    */
    global static Map<String, Schema.DescribeFieldResult> getFieldsOfType(String objectName, String type) {
        return UTIL_Describe.getFieldsOfType(objectName, type);
    }

    /*******************************************************************************************************
    * @description Returns field describe data
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return Schema.DescribeFieldResult the describe field result for the given field
    */
    global static Schema.DescribeFieldResult getFieldDescribe(String objectName, String fieldName) {
        return UTIL_Describe.getFieldDescribe(objectName, fieldName);
    }

    /*******************************************************************************************************
    * @description Gives field friendly name
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the label of the field
    */
    global static string getFieldLabel(String objectName, String fieldName) {
        return UTIL_Describe.getFieldLabel(objectName, fieldName);
    }

    /*******************************************************************************************************
    * @description Gives field friendly name without throwing exception if not valid.
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the label of the field
    */
    global static string getFieldLabelSafe(string strObj, string strField) {
        return UTIL_Describe.getFieldLabelSafe(strObj, strField);
    }

    /*******************************************************************************************************
    * @description checks whether the field exists
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return boolean whether the field exists
    */
    global static boolean isValidField(String objectName, String fieldName) {
        return UTIL_Describe.isValidField(objectName, fieldName);
    }

    /*******************************************************************************************************
    * @description utility to check for compatible datatypes for data copying
    * @param dtSrc the DisplayType of the source object
    * @param dtTgt the DisplayType of the target object
    * @return true if the types can be copied between
    */
    global static boolean canDisplaytypesCopy(Schema.Displaytype dtSrc, Schema.Displaytype dtTgt) {
        return UTIL_Describe.canDisplaytypesCopy(dtSrc, dtTgt);
    }

    /*******************************************************************************************************
    * @description utility to return a list of strings from a field set.
    * @param strObject the name of the object
    * @param strFS the name of the object's field set
    * @return a list of strings of field names in the field set
    */
    // utility to return a list of strings from a field set.
    global static list<string> listStrFromFieldSet(string strObject, string strFS) {
        return UTIL_Describe.listStrFromFieldSet(strObject, strFS);
    }

    /*******************************************************************************************************
    * @description Returns a comma separated string of field names from a field set.
    * @param strObject the name of the object
    * @param strFS the name of the object's field set
    * @return a comma separated string of field names in the field set
    */
    global static string strFieldNamesFromFieldSet(string strObject, string strFS) {
        return UTIL_Describe.strFieldNamesFromFieldSet(strObject, strFS);
    }

    /*******************************************************************************************************
     * @description Returns a map of active, user-available RecordType IDs for a given SObjectType,
     * keyed by each RecordType's unique, unchanging DeveloperName.
     * @param objectName Name of the object to retrieve record types for.
     * @return Map<String, Id> Map of DeveloperName-to-ID of available record types for object specified.
     */
    global static Map<String, Id> getRecTypesMapByDevName(String objectName) {
	    return UTIL_Describe.getRecTypesMapByDevName(objectName);
	}

    /*******************************************************************************************************
     * @description Returns a map of active, user-available RecordType IDs for a given SObjectType,
     * keyed by each RecordType's Name.
     * @param objectName Name of the object to retrieve record types for.
     * @return Map<String, Id> Map of Name-to-ID of available record types for object specified.
     */
    @AuraEnabled
    global static Map<String, Id> getRecTypesMapByName(String objectName) {
	    return UTIL_Describe.getRecTypesMapByName(objectName);        
    }

    /*******************************************************************************************************
     * @description Returns a map of active, user-available picklist values and labels for a given
     * SObjectType and field, keyed by picklist label with a value of picklist value.
     * @param objectName Name of the object to retrieve picklist values for.
     * @param fieldName Name of the field to retrieve picklist values for.
     * False if we want it to be the friendly name.
     * @return Map<String, String> Map of picklist labels to values for the object and field specified.
     */
    @AuraEnabled
    global static Map<String, String> getPicklistActiveValuesMap(String objectName, String fieldName) {
	    return UTIL_Describe.getPicklistActiveValuesMap(objectName, fieldName);        
    }
	
    /*******************************************************************************************************
     * @description Returns the picklist default value for a given SObjectType and field.
     * @param objectName Name of the object to retrieve picklist values for.
     * @param fieldName Name of the field to retrieve picklist values for.
     * False if we want it to be the friendly name.
     * @return String Default picklist label for the object and field specified.
     */
    @AuraEnabled
    public static String getPicklistDefaultValueLabel(String objectName, String fieldName) {
	    return UTIL_Describe.getPicklistDefaultValueLabel(objectName, fieldName);        
    }

    /*******************************************************************************************************
     * @description Returns the ID of the Administrative Account record type, if it exists.
     * @return String The ID of the Administrative Account record type as a String.
     */
	global static String getAdminAccRecTypeID() {
	    return UTIL_Describe.getAdminAccRecTypeID();
	}

	/*******************************************************************************************************
     * @description Returns the ID of the Household Account record type, if it exists.
     * @return String The ID of the Household Account record type as a String.
     */
	global static String getHhAccRecTypeID() {
	    return UTIL_Describe.getHhAccRecTypeID();
	}

	/*******************************************************************************************************
     * @description Returns the ID of the Business Account record type, if it exists.
     * @return String The ID of the Business Account record type as a String.
     */
	global static String getBizAccRecTypeID() {
	    return UTIL_Describe.getBizAccRecTypeID();
	}

    /*******************************************************************************************************
     * @description Returns the ID of the Default Course Connection record type, if it exists. This record
     * type should only be used in testing.
     * @return String The ID of the Default Course Connection record type as a String.
     */
    global static String getDefaultConnectionRecTypeID() {
        return UTIL_Describe.getDefaultConnectionRecTypeID();
    }

    /*******************************************************************************************************
     * @description Returns the ID of the Faculty Course Connection record type, if it exists.
     * @return String The ID of the Faculty Course Connection record type as a String.
     */
    global static String getFacultyConnectionRecType() {
        return UTIL_Describe.getFacultyConnectionRecType();
    }

    /*******************************************************************************************************
     * @description Returns the ID of the Student Course Connection record type, if it exists.
     * @return String The ID of the Student Course Connection record type as a String.
     */
    global static String getStudentConnectionRecType() {
        return UTIL_Describe.getStudentConnectionRecType();
    }
    

}