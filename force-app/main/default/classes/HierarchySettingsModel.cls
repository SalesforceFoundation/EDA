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
* @group-content ../../ApexDocContent/EdaSettings.htm
* @description Model to abstract data from database for Hierarchy Settings.
*/
public with sharing class HierarchySettingsModel {
    public Hierarchy_Settings__c hierarchySettings { get; private set; }
    
    /**************************************************************************
    * @description Single parameter constructor 
    * @param  hierarchySettings A Hierarchy_Settings__c object
    * @return A HierarchySettingsModel with all parameters populated.
    **************************************************************************/
    public HierarchySettingsModel(Hierarchy_Settings__c hierarchySettings) {
        this.hierarchySettings = hierarchySettings;
    }

    /****************************************************************************
    * @description Helper method to set the value for a Hierarchy Settings field
    * with a valud of type String.
    * @param  fieldName A Hierarchy Settings field name
    * @param  fieldValue A String value for the specified Hierarchy Settings field
    ****************************************************************************/
    public void setSettingsField(String fieldName, String fieldValue) {
        this.hierarchySettings.put(fieldName, fieldValue);
    }

    /****************************************************************************
    * @description Helper method to set the value for a Hierarchy Settings field
    * with a valud of type Boolean.
    * @param  fieldName A Hierarchy Settings field name
    * @param  fieldValue A Boolean value for the specified Hierarchy Settings field
    ****************************************************************************/
    public void setSettingsField(String fieldName, Boolean fieldValue) {
        this.hierarchySettings.put(fieldName, fieldValue);
    }

    /****************************************************************************
    * @description Helper method to set the value for a Hierarchy Settings field
    * with a valud of type DateTime.
    * @param  fieldName A Hierarchy Settings field name
    * @param  fieldValue A DateTime value for the specified Hierarchy Settings field
    ****************************************************************************/
    public void setSettingsField(String fieldName, Datetime fieldValue) {
        this.hierarchySettings.put(fieldName, fieldValue);
    }
}
