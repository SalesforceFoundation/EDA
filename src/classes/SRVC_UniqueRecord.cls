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
    /******************************************************************************************************
    @description Combines record instances with same ID into one
    @params listToCheck The list of records to be checked and merged
    @return finalResults The list of merged records
    ********************************************************************************************************/
    @TestVisible
    public static List<SObject> getUniqueRecords(List<SObject> listToCheck) {
        
        Map<Id, SObject> idToRecord = new Map<Id, SObject>();
        List<SObject> uniqueRecords = new List<SObject>();

        for(SObject record: listToCheck) {
            idToRecord.put(record.Id, record.getSObjectType().newSobject(record.Id));          
        }
        
        String sObjectName;
        Schema.SObjectType sObjectType;
        List<String> childObjectNames;
      
        if(listToCheck != NULL && listToCheck.size() > 1) {
            sObjectName = listToCheck[0].Id.getSObjectType().getDescribe().getName();
            sObjectType = Schema.getGlobalDescribe().get(sObjectName);
            childObjectNames = SRVC_ChildRelationshipNames.findAllChildRelationshipNames(sObjectType);
        }
        
        for (Sobject record: listToCheck) {
            Map<String, Object> fieldNameToValues = record.getPopulatedFieldsAsMap();
            SObject interimRecord = idToRecord.get(record.Id);
             
            for (String fieldName: fieldNameToValues.keySet()) {
                if (childObjectNames != NULL && !childObjectNames.contains(fieldName)) {  // Do not add fields from related records
                    interimRecord.put(fieldName, fieldNameToValues.get(fieldName));
                }
            }
            idToRecord.put(record.Id, interimRecord);
        }
        uniqueRecords.addAll(idToRecord.values());
        return uniqueRecords;
    }
}        