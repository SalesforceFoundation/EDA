/*
    Copyright (c) 2011, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation
* @date 2015
* @group Utilities
* @description Tests for UTIL_CustomSettingsFacade. Mainly for the @isTest 
* methods, since the others were tested by other tests.
*/
@isTest
public with sharing class UTIL_CustomSettingsFacade_TEST {
    
    @isTest
    public static void getAfflMappings() {
        insert new Affl_Mappings__c(Name = 'edu', Account_Record_Type__c = 'educational institution', 
            Primary_Affl_Field__c = 'primary educational institution', Auto_Program_Enrollment__c = true, 
            Auto_Program_Enrollment_Role__c = 'student', Auto_Program_Enrollment_Status__c = 'current');
        
        Test.startTest();
        List<Affl_Mappings__c> mappings = UTIL_CustomSettingsFacade.getAfflMappings();
        Test.stopTest();
        
        System.assertEquals(1, mappings.size());
    }
    
    @isTest
    public static void getReciprocalSettings() {
        insert new Relationship_Lookup__c(Name = 'test' + system.now(), Active__c = true, Female__c = 'wife',
        Male__c = 'husband', Neutral__c = 'spouse'); 
        
        Test.startTest();
        List<Relationship_Lookup__c> settings = UTIL_CustomSettingsFacade.getReciprocalSettings();
        Test.stopTest();
        
        System.assertEquals(1, settings.size());
    }

    @isTest
    public static void getAutoCreateSettings() {
        insert new Relationship_Auto_Create__c(Name = 'test'+ system.now(), Object__c = 'Contact', Field__c = 'coworker__c', 
        Relationship_Type__c = 'coworker', Campaign_Types__c = 'fun event'); 
        
        Test.startTest();
        List<Relationship_Auto_Create__c> settings = UTIL_CustomSettingsFacade.getAutoCreateSettings();
        Test.stopTest();
        
        System.assertEquals(1, settings.size());
    }
   
    @isTest
    public static void saveHierarchySettings() {
        Hierarchy_Settings__c hs = new Hierarchy_Settings__c();
        hs.Account_Processor__c = 'Administrative';
        hs.Organizational_Account_Addresses_Enabled__c = true;
        
        Test.startTest();
        UTIL_CustomSettingsFacade.saveHierarchySettings(hs);
        Test.stopTest();
        
        List<Hierarchy_Settings__c> hss = [select Organizational_Account_Addresses_Enabled__c from Hierarchy_Settings__c 
            where Account_Processor__c = 'Administrative'];
        System.assertEquals(1, hss.size());
        System.assertEquals(true, hss[0].Organizational_Account_Addresses_Enabled__c);
    }
  
    @isTest
    public static void saveAfflMappings() {
        List<Affl_Mappings__c> afflMappings = new List<Affl_Mappings__c>();
        afflMappings.add(new Affl_Mappings__c(Name = 'edu', Account_Record_Type__c = 'educational institution', 
            Primary_Affl_Field__c = 'primary educational institution', Auto_Program_Enrollment__c = true, 
            Auto_Program_Enrollment_Role__c = 'student', Auto_Program_Enrollment_Status__c = 'current'));
        
        Test.startTest();
        UTIL_CustomSettingsFacade.saveAfflMappings(afflMappings);
        Test.stopTest();
        
        afflMappings = [select Account_Record_Type__c from Affl_Mappings__c where Primary_Affl_Field__c = 'primary educational institution'];
        System.assertEquals(1, afflMappings.size());
        System.assertEquals('educational institution', afflMappings[0].Account_Record_Type__c);
    }
 
    @isTest
    public static void saveReciprocalSettings() {
        List<Relationship_Lookup__c> reciprocalSettings = new List<Relationship_Lookup__c>();
        
        Test.startTest();
        UTIL_CustomSettingsFacade.saveReciprocalSettings(reciprocalSettings);
        Test.stopTest();
    }
 
    @isTest
    public static void saveAutoCreateSettings() {
        List<Relationship_Auto_Create__c> autoCreateSettings = new List<Relationship_Auto_Create__c>();
        autoCreateSettings.add(new Relationship_Auto_Create__c(Name = 'test'+ system.now(),  Object__c = 'Contact', 
                Field__c = 'coworker__c', Relationship_Type__c = 'coworker', Campaign_Types__c = 'fun event'));
        
        Test.startTest();
        UTIL_CustomSettingsFacade.saveAutoCreateSettings(autoCreateSettings);
        Test.stopTest();
        
        autoCreateSettings = [select Field__c from Relationship_Auto_Create__c where Relationship_Type__c = 'coworker'];
        System.assertEquals(1, autoCreateSettings.size());
        System.assertEquals('coworker__c', autoCreateSettings[0].Field__c);
    }
    
    @isTest
    public static void newDeleteReciprocalSetting() {
        Test.startTest();
        UTIL_CustomSettingsFacade.newReciprocalSetting('test' + system.now(), 'husband', 'wife', 'spouse', true);
        Test.stopTest();
        
        List<Relationship_Lookup__c> settings = [select Male__c, Female__c from Relationship_Lookup__c where Neutral__c = 'spouse'];
        System.assertEquals(1, settings.size());
        System.assertEquals('husband', settings[0].Male__c);
        System.assertEquals('wife', settings[0].Female__c);
        
        UTIL_CustomSettingsFacade.deleteRecSettingRecord(settings[0].Id);
        settings = [select Id from Relationship_Lookup__c where Id = :settings[0].Id];
        System.assertEquals(0, settings.size());
    }
    
    @isTest
    public static void newDeleteAutoCreateSetting() {   
        Test.startTest();
        UTIL_CustomSettingsFacade.newAutoCreateSetting('Contact', 'coworker__c', 'coworker', '');
        Test.stopTest();
        
        List<Relationship_Auto_Create__c> settings = [select Object__c, Field__c from Relationship_Auto_Create__c where 
                                                Relationship_Type__c = 'coworker'];
        System.assertEquals(1, settings.size());
        System.assertEquals('Contact', settings[0].Object__c);
        System.assertEquals('coworker__c', settings[0].Field__c);
        
        UTIL_CustomSettingsFacade.deleteAutoCreateRecord(settings[0].Id);
        settings = [select Id from Relationship_Auto_Create__c where Id = :settings[0].Id];
        System.assertEquals(0, settings.size());
    }
}