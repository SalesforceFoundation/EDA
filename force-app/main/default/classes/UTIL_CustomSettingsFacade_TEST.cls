/*
    Copyright (c) 2011, Salesforce.org
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
 * @date 2015
 * @group Utilities
 * @group-content ../../ApexDocContent/Utilities.htm
 * @description Tests for UTIL_CustomSettingsFacade. Mainly for the @isTest
 * methods, since the others were tested by other tests.
 */
@isTest
public with sharing class UTIL_CustomSettingsFacade_TEST {
    private static ID orgRecTypeID;
    private static ID householdRecTypeID;
    private static ID adminRecTypeID;

    public static void recTypesSetup() {
        orgRecTypeID = UTIL_Describe_API.getBizAccRecTypeID();
        householdRecTypeID = UTIL_Describe.getHhAccRecTypeID();
        adminRecTypeID = UTIL_Describe_API.getAdminAccRecTypeID();
    }

    @isTest
    public static void getAfflMappings() {
        insert new Affl_Mappings__c(
            Name = 'edu',
            Account_Record_Type__c = 'educational institution',
            Primary_Affl_Field__c = 'primary educational institution',
            Auto_Program_Enrollment__c = true,
            Auto_Program_Enrollment_Role__c = 'student',
            Auto_Program_Enrollment_Status__c = 'current'
        );

        Test.startTest();
        List<Affl_Mappings__c> mappings = UTIL_CustomSettingsFacade.getAfflMappings();
        Test.stopTest();

        System.assertEquals(1, mappings.size());
    }

    @isTest
    private static void getAutoCreateSettings() {
        insert new Relationship_Auto_Create__c(
            Name = 'test' + system.now(),
            Object__c = 'Contact',
            Field__c = 'coworker__c',
            Relationship_Type__c = 'coworker',
            Campaign_Types__c = 'fun event'
        );

        Test.startTest();
        List<Relationship_Auto_Create__c> settings = UTIL_CustomSettingsFacade.getAutoCreateSettings();
        Test.stopTest();

        System.assertEquals(1, settings.size());
    }

    /**
     * @description Tests getting new relationship autocreate settings for Contact
     */
    @isTest
    public static void getAutoCreateSettingsForContactNew() {
        insert new Relationship_Auto_Create__c(
            Name = 'test' + System.now(),
            Object__c = 'Contact',
            Field__c = 'coworker__c',
            Relationship_Type__c = 'coworker',
            Campaign_Types__c = 'fun event'
        );

        Test.startTest();
        List<Relationship_Auto_Create__c> relAutoCreateForContactList = UTIL_CustomSettingsFacade.getAutoCreateSettingsForContact();
        Test.stopTest();

        System.assertNotEquals(
            true,
            relAutoCreateForContactList.isEmpty(),
            'Relationship auto create settings for Contact should not be empty.'
        );
        System.assertEquals(
            1,
            relAutoCreateForContactList.size(),
            'Only one relationship auto create mapping should exist for the Contact.'
        );
    }

    /**
     * @description Tests getting relationship autocreate settings caching for Contact
     */
    @isTest
    public static void getAutoCreateSettingsForContactCached() {
        insert new Relationship_Auto_Create__c(
            Name = 'test' + System.now(),
            Object__c = 'Contact',
            Field__c = 'coworker__c',
            Relationship_Type__c = 'coworker',
            Campaign_Types__c = 'fun event'
        );

        List<Relationship_Auto_Create__c> relAutoCreateForContactList = UTIL_CustomSettingsFacade.getAutoCreateSettingsForContact();

        Test.startTest();
        List<Relationship_Auto_Create__c> relAutoCreateForContactCachedList = UTIL_CustomSettingsFacade.getAutoCreateSettingsForContact();
        Test.stopTest();

        System.assertEquals(
            relAutoCreateForContactList,
            relAutoCreateForContactCachedList,
            'Relationship auto create mappings for contact should be cached.'
        );
    }

    @isTest
    public static void getOrgSettings() {
        Hierarchy_Settings__c hs = UTIL_CustomSettings_API.getOrgSettings();

        System.assertEquals(false, hs.Error_Notifications_On__c);
    }

    // Positive test for getPrimaryAfflMappings method
    @isTest
    public static void getPrimaryAfflMappings() {
        String prefix = UTIL_Namespace.StrTokenNSPrefix('');

        insert new Affl_Mappings__c(
            Name = 'edu',
            Account_Record_Type__c = 'Academic_Program',
            Primary_Affl_Field__c = prefix + 'Primary_Academic_Program__c',
            Auto_Program_Enrollment__c = true,
            Auto_Program_Enrollment_Role__c = 'student',
            Auto_Program_Enrollment_Status__c = 'current'
        );

        Test.startTest();
        List<Affl_Mappings__c> mappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();
        Test.stopTest();

        System.assertEquals(1, mappings.size());
    }

    // NULL test for getPrimaryAfflMappings method
    @isTest
    public static void getPrimaryAfflMappingsNULLTest() {
        Test.startTest();
        List<Affl_Mappings__c> mappings = UTIL_CustomSettingsFacade.getPrimaryAfflMappings();
        Test.stopTest();

        System.assertEquals(0, mappings.size());
    }

    @isTest
    public static void getReciprocalSettings() {
        insert new Relationship_Lookup__c(
            Name = 'test' + system.now(),
            Active__c = true,
            Female__c = 'wife',
            Male__c = 'husband',
            Neutral__c = 'spouse'
        );

        Test.startTest();
        List<Relationship_Lookup__c> settings = UTIL_CustomSettingsFacade.getReciprocalSettings();
        Test.stopTest();

        System.assertEquals(1, settings.size());
    }

    /**
     * @description Tests getting new active relationship lookup settings
     */
    @isTest
    public static void getActiveRelationshipLookupsNew() {
        List<Relationship_Lookup__c> relationshipLookups = new List<Relationship_Lookup__c>();
        relationshipLookups.add(
            new Relationship_Lookup__c(
                Name = 'test' + system.now() + '1',
                Active__c = true,
                Female__c = 'wife',
                Male__c = 'husband',
                Neutral__c = 'spouse'
            )
        );
        relationshipLookups.add(
            new Relationship_Lookup__c(
                Name = 'test' + system.now() + '2',
                Active__c = false,
                Female__c = 'wife',
                Male__c = 'husband',
                Neutral__c = 'spouse'
            )
        );
        insert relationshipLookups;

        Test.startTest();
        List<Relationship_Lookup__c> activeRelationshipLookups = UTIL_CustomSettingsFacade.getActiveRelationshipLookups();
        Test.stopTest();

        System.assertNotEquals(
            true,
            activeRelationshipLookups.isEmpty(),
            'The active Reciprocal Relationship settings list should not be empty.'
        );
        System.assertEquals(
            1,
            activeRelationshipLookups.size(),
            'Only one reciprocal relationship mapping should be found.'
        );
    }

    /**
     * @description Tests caching active relationship lookup settings
     */
    @isTest
    public static void getActiveRelationshipLookupsCached() {
        List<Relationship_Lookup__c> relationshipLookups = new List<Relationship_Lookup__c>();
        relationshipLookups.add(
            new Relationship_Lookup__c(
                Name = 'test' + system.now() + '1',
                Active__c = true,
                Female__c = 'wife',
                Male__c = 'husband',
                Neutral__c = 'spouse'
            )
        );
        relationshipLookups.add(
            new Relationship_Lookup__c(
                Name = 'test' + system.now() + '2',
                Active__c = false,
                Female__c = 'wife',
                Male__c = 'husband',
                Neutral__c = 'spouse'
            )
        );
        insert relationshipLookups;

        List<Relationship_Lookup__c> activeRelationshipLookups = UTIL_CustomSettingsFacade.getActiveRelationshipLookups();

        Test.startTest();
        List<Relationship_Lookup__c> activeRelationshipLookups2 = UTIL_CustomSettingsFacade.getActiveRelationshipLookups();
        Test.stopTest();

        System.assertEquals(
            activeRelationshipLookups,
            activeRelationshipLookups2,
            'Active Reciprocal Relationship mappings should be cached.'
        );
    }
}
