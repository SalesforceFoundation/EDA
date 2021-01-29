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
* @group-content ../../ApexDocContent/HealthCheck.htm
* @description Service class for Record Type
*/
public virtual with sharing class RecordTypeService {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static RecordTypeService instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected RecordTypeService() {}

    /******************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of RecordTypeService.
    ******************************************************************************/
    public static RecordTypeService getInstance() {
        if (instance == null) {
            instance = new RecordTypeService();
        }

        return instance;
    }

    /******************************************************************************
    * @description Get a map of Record Type Model By Id for specified SObjectType
    * @param SObjectype An SObject from which to retrieve associated record types
    * @return A map of Record Type Models By Id
    ******************************************************************************/
    public virtual Map<Id, RecordTypeModel> getModelByIdMapForSObjectType(Schema.SObjectType sObjectType) {
        return this.locateRecordTypeMapper().getModelByIdMapForSObjectType(sObjectType);
    }

    /******************************************************************************
    * @description Get the Record Type Model from the map of record type model by id
    * @param recordTypeId string of Record Type Id 
    * @param recordTypeModelById map of Record Type Model By Id
    * @return An instance of Record Type Model
    ******************************************************************************/
    public virtual RecordTypeModel getRecordTypeModelFromMap(
        String recordTypeId, 
        Map<Id, RecordTypeModel> recordTypeModelById
    ) { 
        try {
            return recordTypeModelById.get(Id.valueOf(recordTypeId));
        } catch (System.StringException ex) {
            return null;
        }
    }

    /******************************************************************************
    * @description Retrieve a record type model for a specified record type name or label.
    * @param recordTypeNameOrLabel A string representing the name or label for a record type
    * @param recordTypeModelByName A map of record type models by name
    * @param recordTypeModelByLabel A map of record type models by label
    * @return A Record Type Model corresponding to the specified record type label or name
    ******************************************************************************/
    public virtual RecordTypeModel getRecordTypeModelFromNameAndLabelMaps(
        String recordTypeNameOrLabel, 
        Map<String, RecordTypeModel> recordTypeModelByName,
        Map<String, RecordTypeModel> recordTypeModelByLabel
    ) { 
        RecordTypeModel recordTypeModel = recordTypeModelByName.get(recordTypeNameOrLabel);

        if (recordTypeModel== null) {
            recordTypeModel = recordTypeModelByLabel.get(recordTypeNameOrLabel);
        }

        return recordTypeModel;
    }

    /******************************************************************************
    * @description Generate a map of Record Type Models By developer name.
    * @param recordTypeModelById A map of recordTypeModels by Id
    * @return A map of Record Type Model By Name
    ******************************************************************************/
    public Map<String, RecordTypeModel> getRecordTypeModelByName(Map<Id, RecordTypeModel> recordTypeModelById) {
        Map<String, RecordTypeModel> recordTypeModelsByName = new Map<String, RecordTypeModel>();

        for (RecordTypeModel recordTypeModel : recordTypeModelById.values()) {
            recordTypeModelsByName.put(recordTypeModel.developerName, recordTypeModel);
        }

        return recordTypeModelsByName;
    }

    /******************************************************************************
    * @description Generate a map of Record Type Models By developer label.
    * @param recordTypeModelById A map of recordTypeModels by Id
    * @return A map of Record Type Model By Label
    ******************************************************************************/
    public Map<String, RecordTypeModel> getRecordTypeModelByLabel(Map<Id, RecordTypeModel> recordTypeModelById) {
        Map<String, RecordTypeModel> recordTypeModelsByLabel = new Map<String, RecordTypeModel>();

        for (RecordTypeModel recordTypeModel : recordTypeModelById.values()) {
            recordTypeModelsByLabel.put(recordTypeModel.name, recordTypeModel);
        }

        return recordTypeModelsByLabel;
    }

    /******************************************************************************
    * @description Retrieves an instance of the RecordTypeMapper class.
    * @return An instance of RecordTypeMapper.
    ******************************************************************************/
    @TestVisible
    private RecordTypeMapper locateRecordTypeMapper() {
        return RecordTypeMapper.getInstance();
    }
}
