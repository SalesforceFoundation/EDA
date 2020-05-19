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
public virtual with sharing class SRVC_UniqueRecord {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static SRVC_UniqueRecord instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected SRVC_UniqueRecord() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of SRVC_UniqueRecord.
    ******************************************************************************/
    public static SRVC_UniqueRecord getInstance() {
        if (instance == NULL) {
            instance = new SRVC_UniqueRecord();
        }

        return instance;
    }

    // Enum to use the elements as Keys for a map collection
    @TestVisible
    private enum KEYS {WITHOUTIDS, WITHIDS}

    /****************************************************************************************************************
    @description Combines multiple record instances with same ID into one for a given list of Sobjects of same type
    @params listToCheck The list of records to be checked and made unique
    @return uniqueRecords The list of merged records
    *****************************************************************************************************************/
    public List<SObject> getUniqueRecords(List<SObject> listToCheck) {
        // If listToCheck is NULL or has only one entry, return the list
        if (listToCheck == NULL || listToCheck.size() <= 1) {
            return listToCheck;
        }

        // Filter out records without Ids
        Map<KEYS, List<SObject>> filteredRecordMap = this.filterRecordsForIds(listToCheck);

        List<SObject> returnList = this.getUniqueRecordsByIds(filteredRecordMap.get(KEYS.WITHIDS));

        if (filteredRecordMap.get(KEYS.WITHOUTIDS).isEmpty() == false) {
            returnList.addAll(filteredRecordMap.get(KEYS.WITHOUTIDS));
        }

        return returnList;
    }

    /******************************************************************************************************
    @description Returns a list of unique records for a given list of SObject records with same Ids
    @params sObjectRecords A list of SOBject records with multiple occurence of same ids
    @return A list of unique records
    ********************************************************************************************************/
    @TestVisible
    private List<SObject> getUniqueRecordsByIds(List<SObject> sObjectRecords) {
        // If list has 1 or less records Return list as is, we can't have duplicates, return
        if (sObjectRecords.size() <= 1) {
            return sObjectRecords;
        }

        Map<Id, SObject> idToSObjectRecordMap = new Map<Id, SObject>();

        for (Sobject record: sObjectRecords) {

            if (!idToSObjectRecordMap.containsKey(record.Id)) {
                idToSObjectRecordMap.put(record.Id, record.getSObjectType().newSobject(record.Id));
            }

            SObject uniqueRecord = this.combineRecords(record, idToSObjectRecordMap.get(record.id)); 

            idToSObjectRecordMap.put(record.Id, uniqueRecord);
        }

        return idToSObjectRecordMap.values();
    }

    /******************************************************************************************************
    @description Method to combine recurring occurance of an SObject Records
    @params SObjectRecord The SObjectRecord to combine the field for
    @params newSobjectRecord A new instance of the SOBject record
    @params allChildRelationshipNames A List of all ChildRelationshipNames for the given SObjectType
    @return interimRecord An interming record to hold the combined record
    ********************************************************************************************************/
    @TestVisible
    private SObject combineRecords(SObject sObjectRecord, SObject newSobjectRecord) {

        List<String> childRelationshipNames = UTIL_Describe.getAllChildRelationshipNames(sObjectRecord.getSObjectType());

        Map<String, Object> fieldNameToValues = sObjectRecord.getPopulatedFieldsAsMap();
        SObject interimRecord = newSobjectRecord;
        //run code in loop below to combine records together
        for (String fieldName: fieldNameToValues.keySet()) {
            if (!childRelationshipNames.contains(fieldName)) {  // Do not add field Names from related records
                interimRecord.put(fieldName, fieldNameToValues.get(fieldName));
            }
        }
        return interimRecord;

    }

    /******************************************************************************************************
    @description Filters SObjects into two lists, one with ids, one without ids
    @params allSObjectRecords The list of records to be checked and made unique
    @return returnMap A key value pair for recordsWithoutIds and recordsWithIds
    ********************************************************************************************************/
    @TestVisible
    private Map<KEYS, List<SObject>> filterRecordsForIds(List<SObject> allSObjectRecords) {
        Map<KEYS, List<SObject>> returnMap = new Map<KEYS, List<SObject>>();

        List<SObject> recordsWithoutIds = new List<SObject>();
        List<SObject> recordsWithIds = new List<SObject>();

        for (SObject sObjectToCheck: allSObjectRecords) {
            if (sObjectToCheck.Id == NULL) {
                recordsWithoutIds.add(sObjectToCheck);
            }
            else {
                recordsWithIds.add(sObjectToCheck);
            }
        }

        returnMap.put(KEYS.WITHOUTIDS, recordsWithoutIds);
        returnMap.put(KEYS.WITHIDS, recordsWithIds);
        return returnMap;
    }
}