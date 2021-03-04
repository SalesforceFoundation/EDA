/*
    Copyright (c) 2009, 2012, Salesforce.org
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
* @date 2011,2012
* @group Relationships
* @group-content ../../ApexDocContent/Relationships.htm
* @description Testing for the Relationships classes.
*/
@isTest
private class REL_Relationships_TEST {

    private static Contact c1;//male
    private static Contact c2;//female
    private static Contact c3;//unknown

    /*********************************************************************************************************
    * @description Helper for test methods, creates a Auto Create Relationship settings and Relationship
    * Lookup settings.
    */
    private static void setupRelationshipTestData(Hierarchy_Settings__c rs) {

        //set running user to avoid dml issue
        System.runAs(new User(Id = UserInfo.getUserId())) {

            if (rs != null) {
                UTIL_CustomSettingsFacade.getSettingsForTests(rs);
            } else {
                UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting',
                												                        Store_Errors_On__c = true));
            }

            //add autocreate settings for CMs
            delete [SELECT Id FROM Relationship_Auto_Create__c];
            insert new Relationship_Auto_Create__c(Name = 'AutoCreate', Object__c = 'CampaignMember',
                                                    Field__c = 'ContactId', Relationship_Type__c = 'TestType',
                                                    Campaign_Types__c = 'Other;');

            Relationship_Auto_Create__c contactRelationshipAutoCreate = new Relationship_Auto_Create__c(Name = 'AutoCreate2', 
                                                                                                        Object__c = 'Contact',
                                                                                                        Field__c = 'ReportsToId', 
                                                                                                        Relationship_Type__c = 'TestType');
            insert contactRelationshipAutoCreate;
            
            //add Reciprocal Relationship
            delete [SELECT Id FROM Relationship_Lookup__c];
            insert new Relationship_Lookup__c(Name = 'TestLookupType', Male__c = 'TestMaleType',
                                                Female__c = 'TestFemaleType', Neutral__c = 'TestNeutralType');
            insert new Relationship_Lookup__c(Name = 'TestLookupType2', Male__c = 'TestMaleType2',
                                                Female__c = 'TestFemaleType2', Neutral__c = 'TestNeutralType2',
                                                Active__c = false);

            c1 = new Contact(Salutation = 'Mr.', FirstName = 'Walter_Test', LastName = 'Roosevelt_Test');
            c2 = new Contact(Salutation = 'Mrs.', FirstName = 'Jane_Test', LastName = 'Nixon_Test');
            c3 = new Contact(Salutation = 'Dr.', FirstName = 'Pat_Test', LastName = 'Cleveland_Test');
            insert new List<Contact> {c1, c2, c3};
        }
    }

    /*********************************************************************************************************
    * @description Tests relationships and mirroring
    */
    @isTest
    public static void testContactRel() {
        setupRelationshipTestData(null);

        Relationship__c rel = new Relationship__c(
              Contact__c = c1.Id,
              RelatedContact__c = c2.Id,
              Type__c = 'Friend',
              Status__c = 'Active',
              Description__c = 'notes');
        insert rel;

        System.assert(REL_Relationships_TDTM.reentrancyPrevented != true, 
            'Did not expect the reentrancy check to have prevented the REL_Relationships_TDTM trigger from processing again after an insert.');

        // check that rel gets created
        List<Relationship__c> relList = [SELECT Id, Contact__c, RelatedContact__c, Status__c,
                                          Type__c, ReciprocalRelationship__c
                                          FROM Relationship__c WHERE Id = :rel.Id LIMIT 1];
        // check for mirror rel
        List<Relationship__c> mirrorList = [SELECT Id, Contact__c, RelatedContact__c, Status__c,
                                              Type__c, ReciprocalRelationship__c
                                              FROM Relationship__c WHERE ReciprocalRelationship__c = :relList[0].Id LIMIT 1];


        //reference eachother
        System.assertEquals(relList[0].ReciprocalRelationship__c, mirrorList[0].Id);
        System.assertEquals(mirrorList[0].ReciprocalRelationship__c, relList[0].Id);

        //same types
        System.assertEquals(mirrorList[0].Type__c, 'Friend');
        System.assertEquals(relList[0].Type__c, 'Friend');

        // test changing the relationship
        relList[0].Type__c = 'Colleague';
        relList[0].Description__c = 'test desc';

        Test.startTest();
        update relList[0];
        Test.stopTest();

        System.assert(REL_Relationships_TDTM.reentrancyPrevented == true, 
            'Expected the reentrancy check to have prevented the REL_Relationships_TDTM trigger from processing again after an update.');

        // test change to the rel
        Relationship__c updated_original = [SELECT Id, Description__c, Type__c, ReciprocalRelationship__c
                                              FROM Relationship__c WHERE Id = :relList[0].Id LIMIT 1];

        //original should have updated relationship
        System.assertEquals('Colleague', updated_original.Type__c);
        //original should have updated notes
        System.assertEquals('test desc', updated_original.Description__c);

        Relationship__c updated_mirror = [SELECT Id, Type__c, Description__c, ReciprocalRelationship__c
                                              FROM Relationship__c WHERE ReciprocalRelationship__c = :relList[0].Id LIMIT 1];
        //mirror should have relationship set right
        System.assertEquals('Colleague', updated_mirror.Type__c);
        //mirror should have updated notes
        System.assertEquals('test desc', updated_mirror.Description__c);

        // test deleting the rel
        delete updated_original;
        List<Relationship__c> mirror_after_original_deleted = [SELECT Id
                                                           FROM Relationship__c
                                                           WHERE ReciprocalRelationship__c = :rel.Id];
        //mirror should be deleted as well
        System.assertEquals(0, mirror_after_original_deleted.size());
    }

    /*********************************************************************************************************
    * @description Test method for relationships and deleting the mirror record
    */
    @isTest
    public static void testOrphanedRelDelete() {
        setupRelationshipTestData(null);

        Relationship__c crel = new Relationship__c(Contact__c = c1.Id, RelatedContact__c = c2.Id, Type__c = 'Buddies');
        insert crel;

        // check that rel gets created
        Relationship__c crel_original = [SELECT Id, Description__c, Type__c, ReciprocalRelationship__c
                                        FROM Relationship__c WHERE Id = :crel.Id];
        //relationship should be set right
        System.assertEquals(crel_original.Type__c, 'Buddies');

        // check for mirror rel
        Relationship__c crel_mirror = [SELECT Id, Description__c, ReciprocalRelationship__c, Type__c
                                        FROM Relationship__c WHERE ReciprocalRelationship__c = :crel_original.Id];
        //mirror should reference the original
        System.assertEquals(crel_mirror.ReciprocalRelationship__c, crel_original.Id);
        Test.startTest();
        delete crel_mirror;
        Test.stopTest();

        //original relationship should have been automatically deleted
        List<Relationship__c> orphanedCrel = [SELECT Id FROM Relationship__c WHERE Id = :crel_original.Id];
        System.assertEquals(0, orphanedCrel.size());
    }

    /*********************************************************************************************************
    * @description Test method for deleting the original, should delete the reciprocal
    */
    @isTest
    public static void testRelationshipDelete() {
        setupRelationshipTestData(null);
        Relationship__c crel_original = new Relationship__c(Contact__c = c1.Id, RelatedContact__c = c2.Id,
                                                                Type__c = 'Buddies');
        insert crel_original;

        crel_original = [SELECT Id, Description__c, ReciprocalRelationship__c, Type__c
                                            FROM Relationship__c WHERE Id = :crel_original.Id];
        UTIL_Debug.debug('****Original relationship: ' + crel_original);

        // check mirror rel got created
        Relationship__c crel_mirror = [SELECT Id, Description__c, ReciprocalRelationship__c, Type__c
                                            FROM Relationship__c WHERE ReciprocalRelationship__c = :crel_original.Id];

        UTIL_Debug.debug('****Mirror relationship: ' + crel_mirror);

        //mirror should reference the original
        System.assertEquals(crel_original.Id, crel_mirror.ReciprocalRelationship__c);

        //original should reference mirror
        System.assertEquals(crel_mirror.Id, crel_original.ReciprocalRelationship__c);
        UTIL_Debug.debug('***Original successfully references mirror');

        Test.startTest();
        delete crel_original;
        Test.stopTest();
        system.assertEquals(0, [SELECT count() FROM Relationship__c WHERE Id = :crel_mirror.Id]);
    }

    /*********************************************************************************************************
    * @description Test method for campaign member auto create relationships - reentrancy is prevented
    */
    @isTest
    public static void testCampaignMemberReentrancyCheck() {
        setupRelationshipTestData(null);

        // Install Default HEDA TDTM Configuration
        List<TDTM_Global_API.TdtmToken> defaultTokens = TDTM_Global_API.getDefaultTdtmConfig();
        TDTM_Global_API.setTdtmConfig(defaultTokens, 'hed');

        // Add the Test TDTM for the Relationship object. This Test TDTM will simply update the campaign member that caused the relationship to be inserted.
        // So the flow would be: campaign member updated -> relationship updated -> campaign member updated again
        Trigger_Handler__c newTDTM = new Trigger_Handler__c(Active__c = true, Asynchronous__c = false,
            Class__c = 'UTIL_UnitTestData_TEST.Test_TDTM', Load_Order__c = 1, Object__c = 'Relationship__c',
            Owned_by_Namespace__c = 'hed', Trigger_Action__c = 'AfterInsert;AfterUpdate');
        insert newTDTM;

        //Insert a campaign
        Campaign campaign = new Campaign(Name = 'TestCampaign', IsActive = true, Type = 'Other');
        insert campaign;

        //Insert a campaign member
        CampaignMember cm = new CampaignMember(ContactId = c2.Id, CampaignId = campaign.Id);
        insert cm;

        // Ensure that the campaign member gets updated recursively
        UTIL_UnitTestData_TEST.sObjectsToUpdate = new List<SObject>{ cm };

        Test.startTest();
        // Turn the reentrancy flag on since the class won't actually insert any relationships, so the flag would remain off otherwise.
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.REL_Relationships_Cm_TDTM, true);
        cm.Status = 'SomethingDifferentForUpdate';
        update cm;
        Test.stopTest();

        System.assert(REL_Relationships_Cm_TDTM.reentrancyPrevented == true, 
            'Expected the reentrancy check to have prevented the REL_Relationships_Cm_TDTM trigger from processing again.');
    }

    /*********************************************************************************************************
    * @description Test method for campaign member auto create relationships on update.
    * We can't do a true test as ContactId is not updatable, but we'll hit the update for coverage.
    */
    @isTest
    public static void testAutoCreateCampaignMemberUpdate() {
        setupRelationshipTestData(null);
        //insert a campaignmember
        Campaign c = new Campaign(Name = 'TestCampaign', IsActive = true);
        insert c;
        CampaignMember cm = new CampaignMember(ContactId = c2.Id, CampaignId = c.Id);
        insert cm;
        //do an update and check that a second relationship set is created for the new Contact
        cm.Status = 'SomethingDifferentForUpdate';
        Test.startTest();
        update cm;
        Test.stopTest();

        System.assertNotEquals('We got here', 'Exception thrown on update');
    }

    /*********************************************************************************************************
    * @description Test method for auto creating relationships based on contact fields on contact insert.
    */
    @isTest
    public static void testAutoCreateContactInsert() {
        setupRelationshipTestData(null);

        //insert a new Contact
        Contact c = new Contact(LastName='ReportingIn', ReportsToId = c1.Id);

        Test.startTest();
        insert c;
        Test.stopTest();

        Relationship__c rel = [SELECT Id, Type__c, RelatedContact__c FROM Relationship__c WHERE Contact__c = :c.Id LIMIT 1];
        system.assertEquals('TestType', rel.Type__c);
        system.assertEquals(c1.Id, rel.RelatedContact__c);

        Relationship__c recRel = [SELECT Id, Type__c, RelatedContact__c, Contact__c FROM Relationship__c WHERE ReciprocalRelationship__c = :rel.Id];
        system.assertEquals('TestType', recRel.Type__c);
        system.assertEquals(c.Id, recRel.RelatedContact__c);
    }

    /*********************************************************************************************************
    * @description Test method for auto creating relationships based on contact fields on contact insert - synchronous.
    */
    @isTest
    public static void testAutoCreateContactInsertSynch() {
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));

        //insert a new Contact
        Contact c = new Contact(LastName = 'ReportingIn', ReportsToId = c1.Id);

        Test.startTest();
        insert c;
        Test.stopTest();

        Relationship__c rel = [SELECT Id, Type__c, RelatedContact__c FROM Relationship__c WHERE Contact__c = :c.Id LIMIT 1];
        system.assertEquals('TestType', rel.Type__c);
        system.assertEquals(c1.Id, rel.RelatedContact__c);

        Relationship__c recRel = [SELECT Id, Type__c, RelatedContact__c, Contact__c FROM Relationship__c WHERE ReciprocalRelationship__c = :rel.Id];
        system.assertEquals('TestType', recRel.Type__c);
        system.assertEquals(c.Id, recRel.RelatedContact__c);
    }

    /*********************************************************************************************************
    * @description Test method for auto creating relationships based on contact fields on contact update.
    */
    @isTest
    public static void testAutoCreateContactUpdate() {
        setupRelationshipTestData(null);

        //insert a new Contact
        Contact c = new Contact(LastName = 'ReportingIn', ReportsToId = c1.Id);
        insert c;
        c.ReportsToId = c2.Id;

        Test.startTest();
        update c;
        Test.stopTest();

        Relationship__c rel = [SELECT Id, Type__c, RelatedContact__c FROM Relationship__c WHERE Contact__c = :c.Id and RelatedContact__c = :c2.Id LIMIT 1];
        system.assertEquals('TestType', rel.Type__c);
        system.assertEquals(c2.Id, rel.RelatedContact__c);
    }

    /*********************************************************************************************************
    * @description Test method for auto creating relationships based on contact fields on contact update - reentrancy is prevented.
    */
    @isTest
    public static void testContactUpdateReentrancyPrevented() {
        setupRelationshipTestData(null);

        // Install Default HEDA TDTM Configuration
        List<TDTM_Global_API.TdtmToken> defaultTokens = TDTM_Global_API.getDefaultTdtmConfig();
        TDTM_Global_API.setTdtmConfig(defaultTokens, 'hed');

        // Add the Test TDTM for the Relationship object. This Test TDTM will simply update the contact that caused the relationship to be inserted.
        // So the flow would be: contact updated -> relationship updated -> contact updated again
        Trigger_Handler__c newTDTM = new Trigger_Handler__c(Active__c = true, Asynchronous__c = false,
            Class__c = 'UTIL_UnitTestData_TEST.Test_TDTM', Load_Order__c = 1, Object__c = 'Relationship__c',
            Owned_by_Namespace__c = 'hed', Trigger_Action__c = 'AfterInsert;AfterUpdate');
        insert newTDTM;

        //insert a new Contact
        Contact c = new Contact(LastName = 'ReportingIn', ReportsToId = c1.Id);
        insert c;
        c.ReportsToId = c2.Id;

        // Ensure that the contact gets updated recursively
        UTIL_UnitTestData_TEST.sObjectsToUpdate = new List<SObject>{ c };

        Test.startTest();
        update c;
        Test.stopTest();

        Relationship__c rel = [SELECT Id, Type__c, RelatedContact__c FROM Relationship__c WHERE Contact__c = :c.Id AND RelatedContact__c = :c2.Id LIMIT 1];
        system.assertEquals('TestType', rel.Type__c);
        system.assertEquals(c2.Id, rel.RelatedContact__c);

        System.assert(REL_Relationships_Con_TDTM.reentrancyPrevented == true, 
            'Expected the reentrancy check to have prevented the REL_Relationships_Con_TDTM trigger from processing again.');
    }

    /*********************************************************************************************************
    * @description Test value inversion reciprocal method, verify type.
    */
    @isTest
    public static void testInversionSettingsHaveType() {
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'Value Inversion'));

        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = c1.Id, RelatedContact__c = c2.Id, Type__c = 'Buddies-Friends')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();

        // check that rel gets created
        Relationship__c crel_original = [SELECT Id, Description__c, Type__c, ReciprocalRelationship__c FROM Relationship__c WHERE Id = :crel[0].Id];
        //relationship should be set right
        system.assertEquals(crel_original.Type__c, 'Buddies-Friends');

        // check for mirror rel
        Relationship__c crel_mirror = [SELECT Id, Description__c, ReciprocalRelationship__c, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel_original.Id];
        //mirror should reference the original
        system.assertEquals(crel_mirror.ReciprocalRelationship__c, crel_original.Id);
        system.assertEquals('Friends-Buddies', crel_mirror.Type__c);
    }

    /*********************************************************************************************************
    * @description Test value inversion reciprocal method, verify type.
    */
    @isTest
    public static void testInversionSettingsNoType() {
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'Value Inversion'));

        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = c1.Id, RelatedContact__c = c2.Id, Type__c = 'BuddiesFriends')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();

        // check that rel gets created
        Relationship__c crel_original = [SELECT Id, Description__c, Type__c, ReciprocalRelationship__c FROM Relationship__c WHERE Id = :crel[0].Id];
        //relationship should be set right
        system.assertEquals(crel_original.Type__c, 'BuddiesFriends');

        // check for mirror rel
        Relationship__c crel_mirror = [SELECT Id, Description__c, ReciprocalRelationship__c, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel_original.Id];
        //mirror should reference the original
        system.assertEquals(crel_mirror.ReciprocalRelationship__c, crel_original.Id);
        system.assertEquals('BuddiesFriends', crel_mirror.Type__c);
    }

    /*********************************************************************************************************
    * @description Test invalid settings config, verify mirror relationship works correctly
    */
    @isTest
    public static void testNoValidSettingsConfig() {
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'BAD_VALUE'));

        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = c1.Id, RelatedContact__c = c2.Id, Type__c = 'BuddiesFriends')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();

        // check that rel gets created
        Relationship__c crel_original = [SELECT Id, Description__c, Type__c, ReciprocalRelationship__c FROM Relationship__c WHERE Id = :crel[0].Id];
        //relationship should be set right
        system.assertEquals(crel_original.Type__c, 'BuddiesFriends');

        // check for mirror rel
        Relationship__c crel_mirror = [SELECT Id, Description__c, ReciprocalRelationship__c, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel_original.Id];
        //mirror should reference the original
        system.assertEquals(crel_mirror.ReciprocalRelationship__c, crel_original.Id);
        system.assertEquals('BuddiesFriends', crel_mirror.Type__c);
    }

    /*********************************************************************************************************
    * @description Test male contact (by salutation) gets male relationship type
    */
    @isTest
    public static void testMaleSalutationReciprocal() {
        setupRelationshipTestData(null);
        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = c1.Id, RelatedContact__c = c2.Id, Type__c = 'TestLookupType')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();

        Relationship__c recRel = [SELECT Id, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel[0].Id];
        system.assertEquals('TestMaleType', recRel.Type__c);
    }

    /*********************************************************************************************************
    * @description Test female contact (by salutation) gets female relationship type
    */
    @isTest
    public static void testFemaleSalutationReciprocal() {
        setupRelationshipTestData(null);
        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = c2.Id, RelatedContact__c = c1.Id, Type__c = 'TestLookupType')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();

        Relationship__c recRel = [SELECT Id, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel[0].Id];
        system.assertEquals('TestFemaleType', recRel.Type__c);
    }

    /*********************************************************************************************************
    * @description Test neutral contact (by salutation) gets neutral relationship type
    */
    @isTest
    public static void testNeutralSalutationReciprocal() {
        setupRelationshipTestData(null);
        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = c3.Id, RelatedContact__c = c2.Id, Type__c = 'TestLookupType')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();

        Relationship__c recRel = [SELECT Id, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel[0].Id];
        system.assertEquals('TestNeutralType', recRel.Type__c);
    }

    /*********************************************************************************************************
    * @description Test neutral contact (by gender field) gets neutral relationship type
    */
    @isTest
    public static void testNeutralGenderFieldReciprocal() {
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));
        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = c3.Id, RelatedContact__c = c2.Id, Type__c = 'TestLookupType')
        };
        c3.Gender__c = 'Neutral';
        update c3;

        Test.startTest();
        insert crel;
        Test.stopTest();

        Relationship__c recRel = [SELECT Id, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel[0].Id];
        system.assertEquals('TestNeutralType', recRel.Type__c);
    }

    /*********************************************************************************************************
    * @description Test male contact (by gender field) gets male relationship type
    */
    @isTest
    public static void testMaleGenderFieldReciprocal() {
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));
        c1.Gender__c = 'Male';
        update c1;
        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = c1.Id, RelatedContact__c = c2.Id, Type__c = 'TestLookupType')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();

        Relationship__c recRel = [SELECT Id, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel[0].Id];
        system.assertEquals('TestMaleType', recRel.Type__c);
    }

    /*********************************************************************************************************
    * @description Test female contact (by gender field) gets female relationship type
    */
    @isTest
    public static void testFemaleGenderFieldReciprocal() {
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));
        c2.Gender__c = 'Female';
        update c2;

        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = c2.Id, RelatedContact__c = c2.Id, Type__c = 'TestLookupType')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();

        Relationship__c recRel = [SELECT Id, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel[0].Id];
        system.assertEquals('TestFemaleType', recRel.Type__c);
    }

    /*********************************************************************************************************
    * @description For two contacts with no gender, manually set a gendered relationship. Verify that it stays
    * and that the reciprocal gets the neutral type by default.
    */
    static testMethod void testNoGenderManualRel() {
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));

        list<Contact> conList = new list<Contact>{
            new Contact(LastName = 'foo'),
            new Contact(LastName = 'foo2')
        };
        insert conList;

        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = conList[0].Id, RelatedContact__c = conList[1].Id, Type__c = 'TestLookupType')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();

        Relationship__c recRel = [SELECT Id, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel[0].Id];
        system.assertEquals('TestNeutralType', recRel.Type__c);

        recRel = [SELECT Id, Type__c FROM Relationship__c WHERE Id = :crel[0].Id];
        system.assertEquals('TestLookupType', recRel.Type__c);
    }

    /*********************************************************************************************************
    * @description For two contacts with no gender, manually set a gendered relationship. Change the status,
    * verify gendered relationship type hasn't changed, but that the status has changed.
    */
    static testMethod void testNoGenderManualRelStatusChange() {
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));

        list<Contact> conList = new list<Contact>{
            new Contact(LastName = 'foo'),
            new Contact(LastName = 'foo2')
        };
        insert conList;

        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = conList[0].Id, RelatedContact__c = conList[1].Id, Type__c = 'TestMaleType')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();

        Relationship__c recRel = [SELECT Id, Type__c FROM Relationship__c WHERE Id = :crel[0].Id];
        system.assertEquals('TestMaleType', recRel.Type__c);

        crel[0].Status__c = 'Former';
        update crel;

        recRel = [SELECT Id, Type__c FROM Relationship__c WHERE Id = :crel[0].Id];
        system.assertEquals('TestMaleType', recRel.Type__c);

        recRel = [SELECT Id, Status__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel[0].Id];
        system.assertEquals('Former', recRel.Status__c);

        crel[0].Status__c = 'Current';
        update crel;

        recRel = [SELECT Id, Type__c FROM Relationship__c WHERE Id = :crel[0].Id];
        system.assertEquals('TestMaleType', recRel.Type__c);

        recRel = [SELECT Id, Status__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel[0].Id];
        system.assertEquals('Current', recRel.Status__c);
    }

    /*********************************************************************************************************
    * @description For two contacts with an established relationship, change the gender field of one of the
    * contacts. Verify the relationship's type has changed per the changed gender, and that the reciprocal
    * hasn't changed.
    */
    static testMethod void testGenderChange() {
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));

        list<Contact> conList = new list<Contact>{
            new Contact(LastName = 'foo', Gender__c = 'Female'),
            new Contact(LastName = 'foo2', Gender__c = 'Male')
        };
        insert conList;

        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = conList[0].Id, RelatedContact__c = conList[1].Id, Type__c = 'TestLookupType')
        };

        insert crel;

        Relationship__c recRel = [SELECT Id, Type__c FROM Relationship__c WHERE Id = :crel[0].Id];
        system.assertEquals('TestLookupType', recRel.Type__c);

        recRel = [SELECT Id, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel[0].Id];
        system.assertEquals('TestFemaleType', recRel.Type__c);

        conList[1].Gender__c='Female';

        Test.startTest();
        update conList[1];
        Test.stopTest();

        recRel = [SELECT Id, Type__c FROM Relationship__c WHERE Id = :crel[0].Id];
        system.assertEquals('TestFemaleType', recRel.Type__c);

        recRel = [SELECT Id, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :crel[0].Id];
        system.assertEquals('TestFemaleType', recRel.Type__c);
    }

    /*********************************************************************************************************
    * @description Test error record creation when inserting a relationship with a required field missing.
    */
    @isTest
    public static void testErrorRecordCreation() {
        setupRelationshipTestData(null);

        List<Relationship__c> relationships = new List<Relationship__c>{
            new Relationship__c(Contact__c = c2.Id, Type__c = 'TestLookupType')
        };

        Test.startTest();
        Database.SaveResult[] insertResults = Database.insert(relationships, false);
        Test.stopTest();

        // We catch errors here because TDTM_TriggerHandler no loger processes errors.
        ERR_Handler.Errors errors = ERR_Handler.getErrors(insertResults,relationships);
        ERR_Handler.processErrors(errors.errorRecords, ERR_Handler.Context.REL.name());

        //assert an error - Required fields are missing: [Contact__c]
        //Contact__c is missing from the reciprocal relationship that gets automatically created.
        system.assertEquals(1, [SELECT count() from Error__c]);

        //update relationship - this will create the missing Contact__c field
        relationships[0].RelatedContact__c = c1.Id;
        Database.SaveResult[] updateResults = Database.update(relationships, false);
        system.assertNotEquals(null, relationships[0].Contact__c);

        //get errors
        errors = ERR_Handler.getErrors(updateResults, (List<SObject>)relationships);
        //we still get an error, because of the Related_Contact_Do_Not_Change validation rule on Relationship
        system.assertEquals(true, errors.errorsExist);
        system.assertEquals(1, errors.errorRecords.size());

        //assert no additional error record was created on update
        system.assertEquals(1, [SELECT count() FROM Error__c]);
    }

    /*********************************************************************************************************
    * @description Test method throws an exception for relationships and verifies an error is logged.
    */
    @isTest
    public static void testExceptionRecordCreation() {
        setupRelationshipTestData(null);

        ERR_Handler.processError(new MyException('TestException'), ERR_Handler.Context.REL);
        List<Error__c> errors = [SELECT Full_Message__c FROM Error__c];
        System.assertEquals(1, errors.size());
        System.assertEquals('TestException', errors[0].Full_Message__c);
    }

    /*********************************************************************************************************
    * @description Method to test the UTIL_CustomSettingsFacade class as a different user
    */
    @isTest
    public static void testRelationshipUTILS() {
        //to test the Relationship_Utils class
        System.runAs(new User(Id = UserInfo.getUserId())) {
           Boolean cAuto = REL_Utils.hasContactAutoCreate;
           Boolean cmAuto = REL_Utils.hasCMAutoCreate;
           System.assertEquals(false, cAuto);
           System.assertEquals(false, cmAuto);
        }
    }

    /*********************************************************************************************************
    * @description Test method for inserting two relationships in a single transaction.
    */
    @isTest
    public static void test2Rels1Transaction_v2() {
         // Create three contacts
        Contact mainClient = new Contact(FirstName = 'Main', LastName = 'AAAClient');
        Contact friend = new Contact(FirstName = 'Test', LastName = 'AAAFriend');
        Contact coworker = new Contact(FirstName = 'Test', LastName = 'AAACoworker');
        insert new List<Contact> {mainClient, friend, coworker};

        // Create two relationships
        Relationship__c r1 = new Relationship__c(Contact__c = mainClient.Id, RelatedContact__c = friend.Id, Type__c = 'Friend');
        Relationship__c r2 = new Relationship__c(Contact__c = mainClient.Id, RelatedContact__c = coworker.Id, Type__c = 'Coworker');

        Test.startTest();
        insert new List<Relationship__c> {r1, r2};
        Test.stopTest();

        Relationship__c nr = [SELECT Id, ReciprocalRelationship__c FROM Relationship__c WHERE Id = :r1.Id];
        system.assert(nr.ReciprocalRelationship__c != null);

        Relationship__c nr2 = [SELECT Id, ReciprocalRelationship__c FROM Relationship__c WHERE Id = :r2.Id];
        system.assert(nr2.ReciprocalRelationship__c != null);

        list<Relationship__c> rels = new list<Relationship__c>();
        rels.add(new Relationship__c(Contact__c = mainClient.Id, RelatedContact__c = friend.Id, Type__c = 'Friend2'));
        rels.add(new Relationship__c(Contact__c = mainClient.Id, RelatedContact__c = coworker.Id, Type__c = 'Coworker2'));
        insert rels;
        list<Relationship__c> rels2 = [SELECT Id, ReciprocalRelationship__c FROM Relationship__c WHERE Id = :rels[0].Id OR Id = :rels[1].Id];
        system.assertEquals(2, rels2.size());
        system.assert(rels2[0].ReciprocalRelationship__c != null);
        system.assert(rels2[1].ReciprocalRelationship__c != null);

    }

    /*********************************************************************************************************
    * @description Test method for deleting relationship and reciprocal relationship in a single transaction.
    */
    @isTest
    public static void deleteRelationshipAndReciRelationship() {
        setupRelationshipTestData(null);

        Relationship__c rel = new Relationship__c(Contact__c = c1.Id, relatedContact__c = c2.Id, Type__c = 'Friend');
        insert rel;

        //After insert the relationship, system should create the reciprocal relationship. So, we should have two relationships in the system.
        List<Relationship__c> relList = [SELECT Id FROM Relationship__c];
        system.assertEquals(2, relList.size());

        //now we delete the relationships, this will include relationship we inserted and the corresponding reciprocal relationship
        Test.startTest();
        delete relList;
        Test.stopTest();

        //We should be able to delete all relationship without error
        List<Relationship__c> relRemaining = [SELECT Id FROM Relationship__c];
        system.assertEquals(0, relRemaining.size());
    }

    /*********************************************************************************************************
    * @description Exception
    */
    public class MyException extends Exception{}


    /*********************************************************************************************************
    * @description Test method for campaign member auto create relationships
    */
    @isTest
    public static void testAutoCreateCampaignMemberInsert() {
        setupRelationshipTestData(null);

        //Insert a campaign
        Campaign campaign = new Campaign(Name = 'TestCampaign', IsActive = true, Type = 'Other');
        insert campaign;

        //Insert a campaign member
        CampaignMember cm = new CampaignMember(ContactId = c2.Id, CampaignId = campaign.Id);
        Test.startTest();
        insert cm;
        Test.stopTest();

        //Verify a relationship was automatically created when the campaign member was created
        List<Relationship__c> relationships = [SELECT Id, Type__c FROM Relationship__c
                                        WHERE Contact__c = :c2.Id];
        UTIL_Debug.debug('****Number of relationships after creating campaign member: ' + relationships.size());
        system.assertEquals(2, relationships.size());
        system.assertEquals('TestType', relationships[0].Type__c);

        //Verify a reciprocal relationship was also automatically created when the campaign member was created
        List<Relationship__c> reciprocalRelationships = [SELECT Id, Type__c FROM Relationship__c
                                        WHERE ReciprocalRelationship__c = :relationships[0].Id];
        UTIL_Debug.debug('****Number of reciprocal relationships: ' + reciprocalRelationships);
        system.assertEquals(1, reciprocalRelationships.size());
        system.assertEquals('TestType', reciprocalRelationships[0].Type__c);
    }

    /*********************************************************************************************************
    * @description Test method for campaign member auto create relationships - synchronous
    */
    @isTest
    public static void testAutoCreateCampaignMemberInsertSynch() {
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));

        //insert a campaignmember
        Campaign c = new Campaign(Name = 'TestCampaign', IsActive = true, Type = 'Other');
        insert c;
        CampaignMember cm = new CampaignMember(ContactId = c2.Id, CampaignId = c.Id);

        Test.startTest();
        insert cm;
        Test.stopTest();

        Relationship__c rel = [SELECT Id, Type__c FROM Relationship__c WHERE Contact__c = :c2.Id LIMIT 1];
        system.assertEquals('TestType', rel.Type__c);
        Relationship__c recRel = [SELECT Id, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :rel.Id];
        system.assertEquals('TestType', recRel.Type__c);
    }

    /*********************************************************************************************************
    * @description Test method for verifying automatic relationship creation won't create a duplicate.
    */
    @isTest
    public static void testAutoCreateDupePrevention() {
        setupRelationshipTestData(null);

        List<Relationship__c> crel = new List<Relationship__c>{
            new Relationship__c(Contact__c = c1.Id, RelatedContact__c = c2.Id, Type__c = 'TestType')
        };
        crel.add(new Relationship__c(Contact__c = c1.Id, RelatedContact__c = c2.Id, Type__c = 'TestType2'));
        insert crel;

        //update the ReportsToId to trigger autocreation
        c1.ReportsToId = c2.Id;

        Test.startTest();
        update c1;
        Test.stopTest();

        //assert we only have one relationship since we've deduped the auto-created one
        List<Relationship__c> rel = [SELECT Id, Type__c, RelatedContact__c FROM Relationship__c WHERE Contact__c = :c1.Id AND Type__c = 'TestType'];
        system.assertEquals('TestType', rel[0].Type__c);
        system.assertEquals(rel.size(), 1);
    }

    /*********************************************************************************************************
    * @description Test method for REL_Utils class when auto create settings exist
    */
    @isTest
    public static void testRelationshipUTILSAutoCreate() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new Relationship_Auto_Create__c(Name = 'contacttest'+ system.now(),
                                                    Object__c = 'Contact', Field__c = 'coworker__c',
                                                    Relationship_Type__c = 'coworker',
                                                    Campaign_Types__c = 'fun event');
            insert new Relationship_Auto_Create__c(Name = 'membertest'+ system.now(),
                                                    Object__c = 'CampaignMember', Field__c = 'member__c',
                                                    Relationship_Type__c = 'member',
                                                    Campaign_Types__c = 'fun event');

            Boolean cAuto = REL_Utils.hasContactAutoCreate;
            Boolean cmAuto = REL_Utils.hasCMAutoCreate;
            System.assertEquals(true, cAuto);
            System.assertEquals(true, cmAuto);
        }
    }

}