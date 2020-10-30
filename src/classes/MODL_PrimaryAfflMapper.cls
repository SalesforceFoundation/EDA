/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group 
* @group-content ../../ApexDocContent/
* @description Model class for CON_PrimaryLanguage_TDTM. Captures 'Account Record Type', 'Contact Primary Affl Field' values from EDA Settings
* and RecordTypeInfo for Account and DescribeFieldResult for Contact. Provides getter methods for 'Account Record Type' from EDA Settings and 
* 'Contact Primary Affl Field'from EDA Settings, AccountRecordTypeId and ContactFieldApiName.
*/
public class MODL_PrimaryAfflMapper {

    private Id accRecordTypeId;
    private Boolean isValid;
    private String accRecTypeDeveloperName;
    private String accRecTypeName;
    private String contactFieldApiName;
    private String contactFieldLabel;
    private String primaryAfflFieldValueFromSettings;
    private String accRecTypeValueFromSettings;

    /*******************************************************************************************************
    * @description Constructor with 5 parameters
    * @param accountRecordTypeInfo Schema.RecordTypeInfo of Account
    * @param contactDescribeFieldResult Schema.DescribeFieldResult for Contact's field
    * @param settingsContactFieldValue 'Contact Primary Affl Field' from EDA Settings.
    * @param settingsRecordTypeValue 'Account Record Type' value from EDA Settings.
    * @param isValid Boolean flag to indicate whether the Record Type Affiliation maps to a valid Account record type.
    *******************************************************************************************************/ 
    public MODL_PrimaryAfflMapper(Schema.RecordTypeInfo accountRecordTypeInfo, Schema.DescribeFieldResult contactDescribeFieldResult, String settingsContactFieldValue, String settingsRecordTypeValue, Boolean isValid) {
        this.accRecordTypeId = accountRecordTypeInfo.getRecordTypeId();
        this.isValid = isValid;
        this.accRecTypeDeveloperName = accountRecordTypeInfo.getDeveloperName();
        this.accRecTypeName = accountRecordTypeInfo.getName();
        this.contactFieldApiName = contactDescribeFieldResult.getName();
        this.contactFieldLabel = contactDescribeFieldResult.getLabel();
        this.primaryAfflFieldValueFromSettings = settingsContactFieldValue;
        this.accRecTypeValueFromSettings = settingsRecordTypeValue;
    }

    /*******************************************************************************************************
    * @description Constructor with 4 parameters
    * @param contactDescribeFieldResult Schema.DescribeFieldResult for Contact's field
    * @param settingsContactFieldValue 'Contact Primary Affl Field' from EDA Settings.
    * @param settingsRecordTypeValue 'Account Record Type' value from EDA Settings.
    * @param isValid Boolean flag to indicate whether the Record Type Affiliation maps to a valid Account record type.
    *******************************************************************************************************/ 
    public MODL_PrimaryAfflMapper(Schema.DescribeFieldResult contactDescribeFieldResult, String settingsContactFieldValue, String settingsRecordTypeValue, Boolean isValid) {
        this.isValid = isValid;
        this.contactFieldApiName = contactDescribeFieldResult.getName();
        this.contactFieldLabel = contactDescribeFieldResult.getLabel();
        this.primaryAfflFieldValueFromSettings = settingsContactFieldValue;
        this.accRecTypeValueFromSettings = settingsRecordTypeValue;
    }

    /*******************************************************************************************************
    * @description Constructor with 4 parameters
    * @param accountRecordTypeInfo Schema.RecordTypeInfo of Account
    * @param settingsContactFieldValue 'Contact Primary Affl Field' from EDA Settings.
    * @param settingsRecordTypeValue 'Account Record Type' value from EDA Settings.
    * @param isValid Boolean flag to indicate whether the Record Type Affiliation maps to a valid Account record type.
    *******************************************************************************************************/ 
    public MODL_PrimaryAfflMapper(Schema.RecordTypeInfo accountRecordTypeInfo, String settingsContactFieldValue, String settingsRecordTypeValue, Boolean isValid) {
        this.accRecordTypeId = accountRecordTypeInfo.getRecordTypeId();
        this.isValid = isValid;
        this.accRecTypeDeveloperName = accountRecordTypeInfo.getDeveloperName();
        this.accRecTypeName = accountRecordTypeInfo.getName();
        this.primaryAfflFieldValueFromSettings = settingsContactFieldValue;
        this.accRecTypeValueFromSettings = settingsRecordTypeValue;
    }

    /*******************************************************************************************************
    * @description Getter method to return the Account Record Type Id. If it is not available then returns
    * 'Account Record Type' value from EDA Settings.
    * @return Account Record Type Id or 'Account Record Type' value from EDA Settings
    *******************************************************************************************************/ 
    public String getAccountRecordTypeId() {
        if (this.accRecordTypeId == null) {
            return this.accRecTypeValueFromSettings;
        }
        return (String)this.accRecordTypeId;
    }

    /*******************************************************************************************************
    * @description Getter method to return the isValid property.
    * @return True if setting is valid, False otherwise.
    *******************************************************************************************************/ 
    public Boolean getIsValid() {
        return this.isValid;
    }

    /*******************************************************************************************************
    * @description Getter method to return the Contact Field API name. If it is not available then returns
    * 'Contact Primary Affl Field' from EDA Settings.
    * @return Field API name for Contact or 'Primary Affl Field' value from EDA Settings
    *******************************************************************************************************/ 
    public String getContactFieldApiName() {
        if (String.isEmpty(this.contactFieldApiName) == true) {
            return this.primaryAfflFieldValueFromSettings; 
        }
        return this.contactFieldApiName;
    }

    /*******************************************************************************************************
    * @description Getter method to return the 'Contact Primary Affl Field' value from EDA Settings.
    * @return 'Primary Affl Field' value from EDA Settings
    *******************************************************************************************************/ 
    public String getSettingsContactFieldValue() {
        return this.primaryAfflFieldValueFromSettings;
    }

    /*******************************************************************************************************
    * @description Getter method to return the 'Account Record Type' value from EDA Settings.
    * 'Account Record Type' value from EDA Settings
    *******************************************************************************************************/ 
    public String getSettingsRecordTypeFieldValue() {
        return this.accRecTypeValueFromSettings;
    }

}