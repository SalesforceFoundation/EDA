/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
 * @date 2021
 * @group
 * @group-content ../../ApexDocContent/
 * @description Returns a list of PicklistEntry models
 */
public virtual with sharing class PicklistEntryService {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static PicklistEntryService instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected PicklistEntryService() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of PicklistEntryService.
     ******************************************************************************/
    public static PicklistEntryService getInstance() {
        if (instance == null) {
            instance = new PicklistEntryService();
        }

        return instance;
    }

    /*******************************************************************************************************
     * @description Returns a map of PicklistEntry Models by name
     * @return Map<String,PicklistEntryModel> The list of PicklistEntry Models
     ********************************************************************************************************/
    public virtual Map<String, PicklistEntryModel> getModelsByNameForSObjectField(
        SObjectType sObjectTypeName,
        SObjectField SObjectFieldName
    ) {
        return locatePicklistEntryMapper().getModelsByNameForSObjectField(sObjectTypeName, SObjectFieldName);
    }

    /*******************************************************************************************************
     * @description Returns a map of active PicklistEntry Models by name
     * @return Map<String,PicklistEntryModel> The list of PicklistEntry Models
     ********************************************************************************************************/
    public virtual Map<String, PicklistEntryModel> getActivePicklistEntryModelsByName(
        Map<String, PicklistEntryModel> picklistEntryModelsByName
    ) {
        Map<String, PicklistEntryModel> activePicklistEntryModelsByName = new Map<String, PicklistEntryModel>();

        for (PicklistEntryModel picklistEntryModel : picklistEntryModelsByName.values()) {
            if (picklistEntryModel.isActive == true) {
                activePicklistEntryModelsByName.put(picklistEntryModel.name, picklistEntryModel);
            }
        }

        return activePicklistEntryModelsByName;
    }

    /*******************************************************************************************************
     * @description Returns the instance of PicklistEntryMapper class
     * @return The instance of PicklistEntryMapper class
     ********************************************************************************************************/
    @TestVisible
    private PicklistEntryMapper locatePicklistEntryMapper() {
        return PicklistEntryMapper.getInstance();
    }
}
