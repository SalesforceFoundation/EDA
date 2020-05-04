/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group
* @group-content ../../ApexDocContent/
* @description Combines records for a particular sObject Type having Ids and returns unique records
*/
public class SRVC_UniqueRecord {
    /****************************************************************************************************************
    @description Combines multiple record instances with same ID into one for a given list of Sobjects of same type
    @params listToCheck The list of records to be checked and made unique
    @return finalResults The list of merged records
    *****************************************************************************************************************/
    public List<SObject> getUniqueRecords(List<SObject> listToCheck) {
        
        // Constructor

        // If listToCheck has only one entry, return the list
        if (listToCheck == NULL || listToCheck.size() <= 1) {
            return listToCheck;
        }

        // Create an Id to a New SObject Record map
        Map<Id, SObject> idToNewSObjectRecord = this.createIdToNewSObjectMap(listToCheck);

        // Get the list of all ChildRelationshipNames for the given SObject record
        List<String> childRelationshipNames = this.getChildRelationshipNames(listToCheck[0]);

        // map with sobjectType as key and list of child rel names as values

        // Return the list of unique records
        return this.getUniqueRecordList(listToCheck, childRelationshipNames, idToNewSObjectRecord);
    }

    /******************************************************************************************************
    @description Returns a map of id to record for a given list of sObject records
    @params sObjectRecords List of sObject records
    @return idToSObjectRecordNew A map of id to record for the given sObject records
    ********************************************************************************************************/
    @TestVisible
    private Map<Id, SObject> createIdToNewSObjectMap(List<SObject> sObjectRecords) {
        Map<Id, SObject> idToSObjectRecordNew = new Map<Id, SObject>();
        for(SObject record: sObjectRecords) {
            idToSObjectRecordNew.put(record.Id, record.getSObjectType().newSobject(record.Id));
        }
        return idToSObjectRecordNew;
    }
    // map of id to soBJect, list of rejected sobject (no ids) - new class
    /*******************************************************************************************************************************************
    @description Returns a list of all the ChildRelationshipNames based on the sObject type for a given record of sObject
    @params listToCheck The sObject record to find the childrelationship names for
    @return SRVC_ChildRelationshipNames.findAllChildRelationshipNames(sObjectType) A list of all the ChildRelationshipNames for the given record
    *********************************************************************************************************************************************/
    @TestVisible
    private List<String> getChildRelationshipNames(SObject sObjectRecord) {
       Schema.SObjectType sObjectType = sObjectRecord.getSObjectType();
       return UTIL_Describe_API.getAllChildRelationshipNames(sObjectType);
    }

    /******************************************************************************************************
    @description Combines record instances with same ID into one for a given list of Sobjects of same type
    @params sObjectRecords The list of records to be checked and made unique
    @params allChildRelationshipNames A list of all the ChildRelationshipNames for the given records type
    @params idToSObjectRecord A map of id to record for the given sObject records
    @return uniqueRecords A list of unique records
    ********************************************************************************************************/
    @TestVisible
    private List<SObject> getUniqueRecordList(List<SObject> sObjectRecords, List<String> allChildRelationshipNames, Map<Id, SObject> idToSObjectRecord) {
        List<SObject> uniqueRecords = new List<SObject>();
        for (Sobject record: sObjectRecords) {
            Map<String, Object> fieldNameToValues = record.getPopulatedFieldsAsMap();
            SObject interimRecord = idToSObjectRecord.get(record.Id);

            for (String fieldName: fieldNameToValues.keySet()) {
                if ((allChildRelationshipNames != NULL) &&
                    ((allChildRelationshipNames.isEmpty()) || (!allChildRelationshipNames.isEmpty() && !allChildRelationshipNames.contains(fieldName)))) {  // Do not add fields from related records
                    interimRecord.put(fieldName, fieldNameToValues.get(fieldName));
                }
            }
            idToSObjectRecord.put(record.Id, interimRecord);
        }
        uniqueRecords.addAll(idToSObjectRecord.values());
        return uniqueRecords;
    }

}