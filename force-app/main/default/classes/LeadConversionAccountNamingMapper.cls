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
* @group EDA Settings
* @group-content ../../ApexDocContent/edaSettings.htm
* @description Mapper class acting as the mapper layer to abstract data in Database
* for Account Naming functionality.
*/
public virtual with sharing class LeadConversionAccountNamingMapper {
    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static LeadConversionAccountNamingMapper instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected LeadConversionAccountNamingMapper() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of LeadConversionAccountNamingMapper.
    ******************************************************************************/
    public static LeadConversionAccountNamingMapper getInstance() {
        if (instance == null) {
            instance = new LeadConversionAccountNamingMapper();
        }

        return instance;
    }

    /*****************************************************************************
    * @description Retrieves an LeadConversionAccountNamingModel populated with
    * a list of Account Record Type Ids specified in Hierarchy Settings 
    * selected for renaming Accounts during Lead Conversion.
    * @return A LeadConversionAccountNamingModel
    *****************************************************************************/
    public virtual LeadConversionAccountNamingModel getLeadConversionAccountNamingModel() {
        Hierarchy_Settings__c hierarchySettings = UTIL_CustomSettingsFacade.getSettings();

        if (String.isEmpty(hierarchySettings.Lead_Converted_Account_RTypes__c) == true) {
            return new LeadConversionAccountNamingModel(new List<String>());
        }  

        // split on semi-colon and optional space
        List<String> recordTypesToNameList = hierarchySettings.Lead_Converted_Account_RTypes__c.split(';\\s?');
        return new LeadConversionAccountNamingModel(recordTypesToNameList);
    }
}
