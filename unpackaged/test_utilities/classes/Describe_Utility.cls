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
* @date 2020
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description This class allows easy access to object and field description information from within other classes.
*
* It is called statically, and therefore will supply the same information to all calls made from
* within one transaction, or set of trigger calls. This is beneficial because this info should
* be the same for all calls in a transaction, and by calling it statically we reduce the calls
* that are made, making the total transaction more efficient.
*/
@isTest
public class Describe_Utility {

    // throw custom exceptions when a bogus object or field is provided.
    public class SchemaDescribeException extends Exception {}

    //maps to hold the describe info
    private static Map<String, Schema.SObjectType> sObjectTokenBySObjectApiName;
    private static Map<String, Schema.DescribeSObjectResult> describeSObjectResultByObjectApiName = new Map<String, Schema.DescribeSObjectResult>();
    private static Map<String, Map<String, Schema.SObjectField>> fieldTokensByObjectApiName = new Map<String, Map<String, Schema.SObjectField>>();
    private static Map<String, Map<String, Schema.DescribeFieldResult>> objectApiNameToDescribeFieldResultMapByFieldApiName = new Map<String, Map<String, Schema.DescribeFieldResult>>();
    private static Map<String, Map<String, Schema.DescribeFieldResult>> objectApiNameToDescribeFieldResultMapByFieldLabelName = new Map<String, Map<String, Schema.DescribeFieldResult>>();

    /*******************************************
    * Gets describe maps for a new object
    ********************************************/
    static void fillMapsForObject(string objectName) {

        // get the object map the first time
        if (sObjectTokenBySObjectApiName == null) {
            sObjectTokenBySObjectApiName = Schema.getGlobalDescribe();
        } 

        // get the object description
        if (sObjectTokenBySObjectApiName.containsKey(objectName)) {

            if (!describeSObjectResultByObjectApiName.containsKey(objectName)) {
                describeSObjectResultByObjectApiName.put(objectName, sObjectTokenBySObjectApiName.get(objectName).getDescribe());
            }    
        } else {
            throw new SchemaDescribeException('Invalid object name \'' + objectName + '\'');
        }
    }


    /*******************************************
    * Gets all field maps for a new object
    ********************************************/
    static void fillFieldMapsForObject(string objectName) {

        // get the object map the first time
        fillMapsForObject(objectName);

        // get the field description
        if (!fieldTokensByObjectApiName.containsKey(objectName)) {
            fieldTokensByObjectApiName.put(objectName, describeSObjectResultByObjectApiName.get(objectName).fields.getMap());
            objectApiNameToDescribeFieldResultMapByFieldApiName.put(objectName, new Map<String, Schema.DescribeFieldResult>());
            objectApiNameToDescribeFieldResultMapByFieldLabelName.put(objectName, new Map<String, Schema.DescribeFieldResult>());
        }

        if (objectApiNameToDescribeFieldResultMapByFieldApiName.get(objectName).size() != objectApiNameToDescribeFieldResultMapByFieldApiName.get(objectName).size()) {

            for (string fieldName : fieldTokensByObjectApiName.get(objectName).keyset()) {

                if (!objectApiNameToDescribeFieldResultMapByFieldApiName.get(objectName).containsKey(fieldName)) {
                    Schema.DescribeFieldResult dfr = fieldTokensByObjectApiName.get(objectName).get(fieldName).getDescribe();
                    objectApiNameToDescribeFieldResultMapByFieldApiName.get(objectName).put(fieldName, dfr);
                    objectApiNameToDescribeFieldResultMapByFieldLabelName.get(objectName).put(dfr.getLabel(), dfr);
                }
            }
        }
    }


    /********************************************
    * Gets a field map for a new object/field pair
    *********************************************/
    private static void fillFieldMapsForObject(string objectName, string fieldName) {

        // get the object map the first time
        fillMapsForObject(objectName);

        // get the field description
        if (!fieldTokensByObjectApiName.containsKey(objectName)) {
            fieldTokensByObjectApiName.put(objectName, describeSObjectResultByObjectApiName.get(objectName).fields.getMap());
            objectApiNameToDescribeFieldResultMapByFieldApiName.put(objectName, new Map<String, Schema.DescribeFieldResult>());
            objectApiNameToDescribeFieldResultMapByFieldLabelName.put(objectName, new Map<String, Schema.DescribeFieldResult>());
        }

        if (!objectApiNameToDescribeFieldResultMapByFieldApiName.get(objectName).containsKey(fieldName)) {

            if (fieldTokensByObjectApiName.get(objectName).containsKey(fieldName)) {
                Schema.DescribeFieldResult dfr = fieldTokensByObjectApiName.get(objectName).get(fieldName).getDescribe();
                objectApiNameToDescribeFieldResultMapByFieldApiName.get(objectName).put(fieldName, dfr);
                objectApiNameToDescribeFieldResultMapByFieldLabelName.get(objectName).put(dfr.getLabel(), dfr);
            } else {
                throw new SchemaDescribeException('Invalid field name \'' + fieldName + '\'');
            }
        }
    }

    /*******************************************************************************************************
    * @description Gives field friendly name
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the label of the field
    */
    public static string getFieldLabelFromObjectApiAndFieldApi(String objectName, String fieldName) {

        // make sure we have this field's schema mapped
        if (!objectApiNameToDescribeFieldResultMapByFieldApiName.containsKey(objectName) || 
            !objectApiNameToDescribeFieldResultMapByFieldApiName.get(objectName).containsKey(fieldName)) {
            fillFieldMapsForObject(objectName, fieldName);
        }

        Schema.DescribeFieldResult dfr = objectApiNameToDescribeFieldResultMapByFieldApiName.get(objectName).get(fieldName);
        return dfr.getLabel();
    }
}
