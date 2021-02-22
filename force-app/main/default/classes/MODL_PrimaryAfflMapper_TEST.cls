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
* @group-content ../../ApexDocContent/Contacts.htm
* @description Test class for MODL_PrimaryAfflMapper.cls
*/
@isTest
private class MODL_PrimaryAfflMapper_TEST {

    /**********************************************************************************************************
    * @description Tests that MODL_PrimaryAfflMapper generates a valid model with all the four Parameters 
    **********************************************************************************************************/
    @isTest
    static void constructorWithAllParametersTestValid() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        Schema.RecordTypeInfo busiOrgInfo = UTIL_Describe.getRecordTypeInfoByDeveloperName('Account', 'Business_Organization');
        Schema.DescribeFieldResult contactFieldDescribeResult = UTIL_Describe.getFieldDescribe('Contact', prefix + 'Primary_Organization__c');

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        insert mappings;

        Test.startTest();
            MODL_PrimaryAfflMapper conPrimayAfflModl = new MODL_PrimaryAfflMapper(busiOrgInfo, contactFieldDescribeResult, mappings[0].Primary_Affl_Field__c, mappings[0].Account_Record_Type__c, true);
        Test.stopTest();

        System.assertEquals(true, conPrimayAfflModl.getIsValid());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), conPrimayAfflModl.getAccountRecordTypeId());
        System.assertEquals(prefix + 'Primary_Organization__c', conPrimayAfflModl.getContactFieldApiName());
        System.assertEquals(mappings[0].Primary_Affl_Field__c, conPrimayAfflModl.getSettingsContactFieldValue());
        System.assertEquals(mappings[0].Account_Record_Type__c, conPrimayAfflModl.getSettingsRecordTypeFieldValue());
    }

    /**********************************************************************************************************
    * @description Tests that MODL_PrimaryAfflMapper generates an invalid model with all the four Parameters 
    **********************************************************************************************************/
    @isTest
    static void constructorWithAllParametersTestNotValid() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        Schema.RecordTypeInfo busiOrgInfo = UTIL_Describe.getRecordTypeInfoByDeveloperName('Account', 'Business_Organization');
        Schema.DescribeFieldResult contactFieldDescribeResult = UTIL_Describe.getFieldDescribe('Contact', prefix + 'Primary_Organization__c');

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        insert mappings;

        Test.startTest();
            MODL_PrimaryAfflMapper conPrimayAfflModl = new MODL_PrimaryAfflMapper(busiOrgInfo, contactFieldDescribeResult, mappings[0].Primary_Affl_Field__c, mappings[0].Account_Record_Type__c, false);
        Test.stopTest();

        System.assertEquals(false, conPrimayAfflModl.getIsValid());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), conPrimayAfflModl.getAccountRecordTypeId());
        System.assertEquals(prefix + 'Primary_Organization__c', conPrimayAfflModl.getContactFieldApiName());
        System.assertEquals(mappings[0].Primary_Affl_Field__c, conPrimayAfflModl.getSettingsContactFieldValue());
        System.assertEquals(mappings[0].Account_Record_Type__c, conPrimayAfflModl.getSettingsRecordTypeFieldValue());
    }

    /**********************************************************************************************************
    * @description Tests that MODL_PrimaryAfflMapper generates a valid model with  
    * ContactDescribeFieldResult, Mapping Settings Parameters and no Schema.RecordTypeInfo 
    **********************************************************************************************************/
    @isTest
    static void  constructorWithContactDescribeFieldResultValidTest() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        Schema.DescribeFieldResult contactFieldDescribeResult = UTIL_Describe.getFieldDescribe('Contact', prefix + 'Primary_Organization__c');

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        insert mappings;

        Test.startTest();
            MODL_PrimaryAfflMapper conPrimayAfflModl = new MODL_PrimaryAfflMapper(contactFieldDescribeResult, mappings[0].Primary_Affl_Field__c, mappings[0].Account_Record_Type__c, true);
        Test.stopTest();

        System.assertEquals(true, conPrimayAfflModl.getIsValid());
        System.assertEquals(mappings[0].Account_Record_Type__c, conPrimayAfflModl.getAccountRecordTypeId());
        System.assertEquals(prefix + 'Primary_Organization__c', conPrimayAfflModl.getContactFieldApiName());
        System.assertEquals(mappings[0].Primary_Affl_Field__c, conPrimayAfflModl.getSettingsContactFieldValue());
        System.assertEquals(mappings[0].Account_Record_Type__c, conPrimayAfflModl.getSettingsRecordTypeFieldValue());
    }

    /**********************************************************************************************************
    * @description Tests that MODL_PrimaryAfflMapper generates an invalid model with  
    * ContactDescribeFieldResult, Mapping Settings Parameters and no Schema.RecordTypeInfo 
    **********************************************************************************************************/
    @isTest
    static void  constructorWithContactDescribeFieldResultNotValidTest() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        Schema.DescribeFieldResult contactFieldDescribeResult = UTIL_Describe.getFieldDescribe('Contact', prefix + 'Primary_Organization__c');

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        insert mappings;

        Test.startTest();
            MODL_PrimaryAfflMapper conPrimayAfflModl = new MODL_PrimaryAfflMapper(contactFieldDescribeResult, mappings[0].Primary_Affl_Field__c, mappings[0].Account_Record_Type__c, false);
        Test.stopTest();

        System.assertEquals(false, conPrimayAfflModl.getIsValid());
        System.assertEquals(mappings[0].Account_Record_Type__c, conPrimayAfflModl.getAccountRecordTypeId());
        System.assertEquals(prefix + 'Primary_Organization__c', conPrimayAfflModl.getContactFieldApiName());
        System.assertEquals(mappings[0].Primary_Affl_Field__c, conPrimayAfflModl.getSettingsContactFieldValue());
        System.assertEquals(mappings[0].Account_Record_Type__c, conPrimayAfflModl.getSettingsRecordTypeFieldValue());
    }

    /**********************************************************************************************************
    * @description Tests that MODL_PrimaryAfflMapper generates a valid model with Schema.RecordTypeInfo, 
    * Mapping Settings Parameters and no ContactDescribeFieldResult
    **********************************************************************************************************/
    @isTest
    static void  constructorWithRecordTypeInfoValidTest() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        Schema.RecordTypeInfo busiOrgInfo = UTIL_Describe.getRecordTypeInfoByDeveloperName('Account', 'Business_Organization');

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        insert mappings;

        Test.startTest();
            MODL_PrimaryAfflMapper conPrimayAfflModl = new MODL_PrimaryAfflMapper(busiOrgInfo, mappings[0].Primary_Affl_Field__c, mappings[0].Account_Record_Type__c, true);
        Test.stopTest();

        System.assertEquals(true, conPrimayAfflModl.getIsValid());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), conPrimayAfflModl.getAccountRecordTypeId());
        System.assertEquals(mappings[0].Primary_Affl_Field__c, conPrimayAfflModl.getContactFieldApiName());
        System.assertEquals(mappings[0].Primary_Affl_Field__c, conPrimayAfflModl.getSettingsContactFieldValue());
        System.assertEquals(mappings[0].Account_Record_Type__c, conPrimayAfflModl.getSettingsRecordTypeFieldValue());
    }

    /**********************************************************************************************************
    * @description Tests that MODL_PrimaryAfflMapper generates an invalid model with Schema.RecordTypeInfo, 
    * Mapping Settings Parameters and no ContactDescribeFieldResult
    **********************************************************************************************************/
    @isTest
    static void  constructorWithRecordTypeInfoNotValidTest() {

        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        Schema.RecordTypeInfo busiOrgInfo = UTIL_Describe.getRecordTypeInfoByDeveloperName('Account', 'Business_Organization');

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));
        insert mappings;

        Test.startTest();
            MODL_PrimaryAfflMapper conPrimayAfflModl = new MODL_PrimaryAfflMapper(busiOrgInfo, mappings[0].Primary_Affl_Field__c, mappings[0].Account_Record_Type__c, false);
        Test.stopTest();

        System.assertEquals(false, conPrimayAfflModl.getIsValid());
        System.assertEquals(UTIL_Describe_API.getBizAccRecTypeID(), conPrimayAfflModl.getAccountRecordTypeId());
        System.assertEquals(mappings[0].Primary_Affl_Field__c, conPrimayAfflModl.getContactFieldApiName());
        System.assertEquals(mappings[0].Primary_Affl_Field__c, conPrimayAfflModl.getSettingsContactFieldValue());
        System.assertEquals(mappings[0].Account_Record_Type__c, conPrimayAfflModl.getSettingsRecordTypeFieldValue());
    }
}