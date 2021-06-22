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
 * @description Model to represent data required for Relationship Settings functionality.
 */

public with sharing class RelationshipSettingsVModel {
    @AuraEnabled
    public ComboboxVModel reciprocalMethodComboboxVModel { get; private set; }
    @AuraEnabled
    public Boolean preventAutoCreatedDuplicates { get; private set; }

    /*****************************************************************************************************************
     * @description Constructor to assign values to the properties
     * @param  reciprocalMethodComboboxVModel A ComboboxVModel value representing the Reciprocal_Method__c setting in
      Hierarchy Settings and all the available values for selection
     *  @param  preventAutoCreatedDuplicates A Boolean value representing the inverse of Allow_AutoCreated_Duplicates__c setting in
     Hierarchy Settings
     *****************************************************************************************************************/
    public RelationshipSettingsVModel(
        ComboboxVModel reciprocalMethodComboboxVModel,
        Boolean preventAutoCreatedDuplicates
    ) {
        this.reciprocalMethodComboboxVModel = reciprocalMethodComboboxVModel;
        this.preventAutoCreatedDuplicates = preventAutoCreatedDuplicates;
    }
}
