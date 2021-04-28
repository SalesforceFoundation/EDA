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
 * @group Health Check
 * @group-content ../../ApexDocContent/HealthCheck.htm
 * @description Model representing an abstraction of Affiliation Mappings in EDA Settings.
 */
public with sharing class AffiliationMappingsModel {
    public String name;
    public String accountRecordTypeFieldValue;
    public String primaryAffiliationField;
    public Boolean autoProgramEnrollment;
    public String autoProgramEnrollmentStatus;
    public String autoProgramEnrollmentRole;

    /*****************************************************************************************************************
     * @description Six argument constructor
     * @param  name The name of the affiliation mappings in Affl_Mappings__c custom settings
     * @param accountRecordTypeFieldValue The value in Account_Record_Type__c field in Affl_Mappings__c custom settings
     * @param primaryAffiliationField The value in Primary_Affl_Field__c in  Primary_Affl_Field__c custom settings
     * @param autoProgramEnrollment The value in Auto_Program_Enrollment__c in  Primary_Affl_Field__c custom settings
     * @param autoProgramEnrollmentStatus The value in Auto_Program_Enrollment_Status__c	 in  Primary_Affl_Field__c custom settings
     * @param autoProgramEnrollmentRole The value in Auto_Program_Enrollment_Role__c in  Primary_Affl_Field__c custom settings
     *****************************************************************************************************************/

    public AffiliationMappingsModel(
        String name,
        String accountRecordTypeFieldValue,
        String primaryAffiliationField,
        Boolean autoProgramEnrollment,
        String autoProgramEnrollmentStatus,
        String autoProgramEnrollmentRole
    ) {
        this.name = name;
        this.autoProgramEnrollment = autoProgramEnrollment;

        this.accountRecordTypeFieldValue = String.isBlank(accountRecordTypeFieldValue)
            ? '""'
            : accountRecordTypeFieldValue;
        this.primaryAffiliationField = String.isBlank(primaryAffiliationField) ? '""' : primaryAffiliationField;
        this.autoProgramEnrollmentStatus = String.isBlank(autoProgramEnrollmentStatus)
            ? '""'
            : autoProgramEnrollmentStatus;
        this.autoProgramEnrollmentRole = String.isBlank(autoProgramEnrollmentRole) ? '""' : autoProgramEnrollmentRole;
    }

    /*****************************************************************************************************************
     * @description Three argument constructor
     * @param  name The name of the affiliation mappings in Affl_Mappings__c custom settings
     * @param accountRecordTypeFieldValue The value in Account_Record_Type__c field in Affl_Mappings__c custom settings
     * @param primaryAffiliationField The value in Primary_Affl_Field__c in  Primary_Affl_Field__c custom settings
     *****************************************************************************************************************/

    public AffiliationMappingsModel(String name, String accountRecordTypeFieldValue, String primaryAffiliationField) {
        this.name = name;

        this.accountRecordTypeFieldValue = String.isBlank(accountRecordTypeFieldValue)
            ? '""'
            : accountRecordTypeFieldValue;

        this.primaryAffiliationField = String.isBlank(primaryAffiliationField) ? '""' : primaryAffiliationField;
    }

    /*****************************************************************************************************************
     * @description Three argument constructor
     * @param name The name of the affiliation mappings in Affl_Mappings__c custom settings
     * @param accountRecordTypeFieldValue The value in Account_Record_Type__c field in Affl_Mappings__c custom settings
     *****************************************************************************************************************/

    public AffiliationMappingsModel(String name, String accountRecordTypeFieldValue) {
        this.name = name;

        this.accountRecordTypeFieldValue = String.isBlank(accountRecordTypeFieldValue)
            ? '""'
            : accountRecordTypeFieldValue;
    }
}
