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

    /****************************************************************************************************************
    @description Combines multiple record instances with same ID into one for a given list of Sobjects of same type
    @params listToCheck The list of records to be checked and made unique
    @return uniqueRecords The list of merged records
    *****************************************************************************************************************/
    @TestVisible
    public List<SObject> getUniqueRecords(List<SObject> listToCheck) {
        // If listToCheck is NULL or has only one entry, return the list
        if (listToCheck == NULL || listToCheck.size() <= 1) {
            return listToCheck;
        }

        //Filter out records without Ids
        Map<String,List<SObject>> filteredRecordMap = this.filterRecordsForIds(listToCheck);

        List<SObject> returnList = this.getUniqueRecordsByIds( filteredRecordMap.get('withIds') );

        if (filteredRecordMap.get('withoutIds').isEmpty() == false) {
            returnList.addAll(filteredRecordMap.get('withoutIds'));
        }

        return returnList;
    }

    //Filters SObjects into two lists, one with ids, one without ids. Maybe make this an enum later?
    private Map<String,List<SObject>> filterRecordsForIds(List<SObject> listToCheck) {
        Map<String,List<SObject>> returnMap = new Map<String,List<SObject>>();
        
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

        returnMap.put('withoutIds',recordsWithoutIds);
        returnMap.put('withIds',recordsWithIds);
        return returnMap;
    }


    /******************************************************************************************************
    @description Combines record instances with same ID into one for a given list of Sobjects of same type
    @params sObjectRecords The list of records to be checked and made unique
    @params allChildRelationshipNames A list of all the ChildRelationshipNames for the given records type
    @params idToSObjectRecord A map of id to record for the given sObject records
    @return uniqueRecords A list of unique records
    ********************************************************************************************************/
    @TestVisible
    private List<SObject> getUniqueRecordsByIds(List<SObject> sObjectRecords) {

        //Check for 1 or less records
            //Return list as is, we can't have duplicates, return

        //instantiate necessary variables outside of the loop
        Map<SObjectType, List<String>> sObjectTyptToAllChildRelationshipName = new Map<SObjectType, List<String>>(); //Note, we should really be cacheing this in UTIL_Describe and then the method will return either the instance of it or assemble it and give us a new instance of it.
        Map<Id,SObject> idToSObjectRecordMap = new Map<Id,SObject>(); //return the values from this, final state, but working state also

        //For each record
        for (Sobject record: sObjectRecords) {
            //if record id not in idToSObjectRecordMap key, this is the first time we have seen it
                //Create new record empty record, put record in idToSObjectRecordMap

            //Make this into a method to assemble a record, returns SObject, takes the current sObject, the map's existing sObject value, and sObjectTyptToAllChildRelationshipName (modifies it in flight for now until we can cache better)
            //SObject uniqueRecord = this.combineRecords(record, idToSObjectRecordMap.get(record.id), sObjectTyptToAllChildRelationshipName);
                //METHOD START
                    //Get the name child relationship name map for the SObject into a List for us to work with! Consider a method for this too
                    //List<String> childRelationshipNames = this.getChildRelationshipNamesForObject(record,sObjectTypeToChildRelationships)
                        //METHOD START
                            if (sObjectTypeToChildRelationships.containsKey(record.getSObjectType()) == FALSE) {
                                sObjectTypeToChildRelationships.put(record.getSObjectType(), UTIL_Describe_API.getAllChildRelationshipNames(record.getSObjectType()));
                            }
                            return sObjectTypeToChildRelationships.get(record.getSObjectType());
                        //METHOD END
                        //Create it if we need to, and cache it for good measure => sObjectTyptToAllChildRelationshipName
                        Map<String, Object> fieldNameToValues = record.getPopulatedFieldsAsMap();
                        SObject interimRecord = record.getSObjectType().newSobject(record.Id)
                    //run code in loop below to combine records together
                        for (String fieldName: fieldNameToValues.keySet()) {
                            if (
                                !childRelationshipNames.contains(fieldName)
                            ) {  // Do not add field Names from related records
                                interimRecord.put(fieldName, fieldNameToValues.get(fieldName));
                            }
                        }
                //METHOD END
            idToSObjectRecordMap.put(record.Id, uniqueRecord);
        }

        return idToSObjectRecordMap.values();
    }

    /*******************************************************************************************************
    * @description An inner class to create value objects
    ********************************************************************************************************/
    private class uniqueRecordValueObjectClass {
        private List<SObject> allSObjectRecords = new List<SObject>();
        private List<SObject> noIdRecords = new List<SObject>();
        private List<SObject> recordWithIds = new List<SObject>();
        private Map<Id, SObject> idToNewSobjectRecord = new Map<Id, SObject>();
        private Map<SObjectType, List<String>> sObjectTypeToChildRelationships = new Map<SObjectType, List<String>>();
        
        // Constructor
        public uniqueRecordValueObjectClass(List<SObject> allSObjectRecords) {
            this.allSObjectRecords = allSObjectRecords;
        }
        
        /******************************************************************************************************************************************
        @description Creates a list of records with no Ids and creates a map with SObjectTypes as key and list of ChildRelationshipNames as values
        *******************************************************************************************************************************************/
        public void createListAndMap() {
            for (SObject each: allSObjectRecords) {
                if (each.Id == NULL) {
                    noIdRecords.add(each);
                }
                else {
                    recordWithIds.add(each);
                    idToNewSobjectRecord.put(each.Id, each.getSObjectType().newSobject(each.Id));
                    if (sObjectTypeToChildRelationships.containsKey(each.getSObjectType()) == FALSE) {
                        sObjectTypeToChildRelationships.put(each.getSObjectType(), UTIL_Describe_API.getAllChildRelationshipNames(each.getSObjectType()));
                    }
                }
            }
        }
    }
}