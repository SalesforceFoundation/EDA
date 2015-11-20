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
* @description Testing for the Relationships class
*/
@isTest
public class REL_Relationships_TEST {
	
	/*********************************************************************************************************
    * @description If you only want to run a single test in this class, fill in its name here.
    * If you want to run all tests, then use '*'
    */
    private static string strTestOnly = '*';
    
    private static Contact c1;//male
    private static Contact c2;//female
    private static Contact c3;//unknown
    
    /*********************************************************************************************************
    * @description Helper for test methods, creates a Auto Create Relationship settings and Relationship 
    * Lookup settings.
    */
    private static void setupRelationshipTestData(Hierarchy_Settings__c rs){
        
        //set running user to avoid dml issue
        System.runAs(new User(id = UserInfo.getUserId())){
                     
            if (rs != null)
                UTIL_CustomSettingsFacade.getSettingsForTests(rs);
            else
                UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting', 
                												                        Store_Errors_On__c = true));         
            
            //add autocreate settings for CMs 
            delete [select id from Relationship_Auto_Create__c];
            insert new Relationship_Auto_Create__c(Name='AutoCreate',Object__c='CampaignMember',
                                                    Field__c='ContactId',Relationship_Type__c = 'TestType',
                                                    Campaign_Types__c = 'Other;');    
            
            insert new Relationship_Auto_Create__c(Name='AutoCreate2',Object__c='Contact',
                                                    Field__c='ReportsToId',Relationship_Type__c = 'TestType');
            
            //add Reciprocal Relationship
            delete [select id from Relationship_Lookup__c];
            insert new Relationship_Lookup__c(Name='TestLookupType',Male__c='TestMaleType',
                                                Female__c='TestFemaleType',Neutral__c='TestNeutralType');
            insert new Relationship_Lookup__c(Name='TestLookupType2',Male__c='TestMaleType2',
                                                Female__c='TestFemaleType2',Neutral__c='TestNeutralType2',
                                                Active__c=false);                                
        
            c1 = new Contact(Salutation = 'Mr.', FirstName = 'Walter_Test', LastName = 'Roosevelt_Test');
            c2 = new Contact(Salutation = 'Mrs.', FirstName = 'Jane_Test', LastName = 'Nixon_Test');        
            c3 = new Contact(Salutation = 'Dr.', FirstName = 'Pat_Test', LastName = 'Cleveland_Test');
            insert new Contact[] {c1, c2, c3};
        }
    }
    
    /*********************************************************************************************************
    * @description Tests relationships and mirroring
    */
    @isTest 
    public static void testContactRel() {
    	if (strTestOnly != '*' && strTestOnly != 'testContactRel') return;
             
        setupRelationshipTestData(null);     
      
        Relationship__c rel = new Relationship__c(
              contact__c = c1.id, 
              relatedcontact__c = c2.id, 
              Type__c='Friend',
              Status__c='Active',
              Description__c='notes');
        insert rel;
        
        // check that rel gets created
        List<Relationship__c> relList = [select id,contact__c,Relatedcontact__c,Status__c,
                                          Type__c, ReciprocalRelationship__c
                                          from Relationship__c where Id= :rel.Id limit 1];
        // check for mirror rel
        List<Relationship__c> mirrorList = [select id,contact__c,Relatedcontact__c,Status__c,
                                              Type__c,ReciprocalRelationship__c  
                                              from Relationship__c where ReciprocalRelationship__c=:relList[0].Id limit 1];
        
        
        //reference eachother
        System.assertEquals(relList[0].ReciprocalRelationship__c, mirrorList[0].Id);
        System.assertEquals(mirrorList[0].ReciprocalRelationship__c, relList[0].Id);

        //same types
        System.assertEquals(mirrorList[0].Type__c, 'Friend');
        System.assertEquals(relList[0].Type__c, 'Friend');  
        
        // test changing the relationship
        relList[0].Type__c = 'Colleague';
        relList[0].Description__c = 'test desc';        
        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;
        
        Test.startTest();
        update relList[0];
        Test.stopTest();        
        
        // test change to the rel
        Relationship__c updated_original = [select id, Description__c, Type__c,ReciprocalRelationship__c 
                                              from Relationship__c where id = :relList[0].Id limit 1];
                                              
        //original should have updated relationship
        System.assertEquals('Colleague', updated_original.Type__c);
        //original should have updated notes
        System.assertEquals('test desc', updated_original.Description__c);
        
        Relationship__c updated_mirror = [select id, Type__c, Description__c, ReciprocalRelationship__c
                                              from Relationship__c where ReciprocalRelationship__c = :relList[0].Id limit 1];
        //mirror should have relationship set right
        System.assertEquals('Colleague', updated_mirror.Type__c);   
        //mirror should have updated notes
        System.assertEquals('test desc', updated_mirror.Description__c);
    
        // test deleting the rel
        delete updated_original;
        Relationship__c[] mirror_after_original_deleted = [select id 
                                                           from Relationship__c 
                                                           where ReciprocalRelationship__c = :rel.Id];
        //mirror should be deleted as well
        System.assertEquals(0, mirror_after_original_deleted.size());
    }
    
    /*********************************************************************************************************
    * @description Test method for relationships and deleting the mirror record
    */
    @isTest 
    public static void testOrphanedRelDelete() {
    	if (strTestOnly != '*' && strTestOnly != 'testOrphanedRelDelete') return;
    	    
        setupRelationshipTestData(null);

        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = c1.id, Relatedcontact__c = c2.id, Type__c='Buddies')
        };
        insert crel;
        
        // check that rel gets created
        Relationship__c crel_original = [select id, Description__c,Type__c,reciprocalrelationship__c from Relationship__c where id=:crel[0].Id];
        //relationship should be set right
        System.assertEquals(crel_original.Type__c, 'Buddies');

        // check for mirror rel
        Relationship__c crel_mirror = [select id, Description__c, reciprocalrelationship__c, Type__c from Relationship__c where reciprocalrelationship__c=:crel_original.Id];
        //mirror should reference the original
        System.assertEquals(crel_mirror.reciprocalrelationship__c, crel_original.Id);
        Contact secondContactForDelete = [select id from contact where id=:c2.id];
        Test.startTest();
        delete secondContactForDelete;
        Test.stopTest();
        // test change to the rel
        Relationship__c[] orphanedCrel = [select id from Relationship__c where id = :crel_original.Id];
        //original should have updated relationship
        System.assertEquals(0, orphanedCrel.size());
    }
    
    /*********************************************************************************************************
    * @description Test method for deleting the original, should delete the reciprocal
    */ 
    @isTest 
    public static void testRelationshipDelete(){
    	if (strTestOnly != '*' && strTestOnly != 'testRelationshipDelete') return;
    	
        setupRelationshipTestData(null);
        Relationship__c crel_original = new Relationship__c(contact__c = c1.id, Relatedcontact__c = c2.id, 
                                                                Type__c='Buddies');
        insert crel_original;
        
        crel_original = [select id, Description__c, reciprocalrelationship__c, Type__c 
                                            from Relationship__c where Id=:crel_original.Id];
        UTIL_Debug.debug('****Original relationship: ' + crel_original);

        // check mirror rel got created
        Relationship__c crel_mirror = [select id, Description__c, reciprocalrelationship__c, Type__c 
                                            from Relationship__c where reciprocalrelationship__c=:crel_original.Id];

        UTIL_Debug.debug('****Mirror relationship: ' + crel_mirror);
                                        
        //mirror should reference the original
        System.assertEquals(crel_original.Id, crel_mirror.reciprocalrelationship__c);        
        
        //original should reference mirror
        System.assertEquals(crel_mirror.Id, crel_original.reciprocalrelationship__c);  
        UTIL_Debug.debug('***Original successfully references mirror');
        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;
        
        Test.startTest();
        delete crel_original;
        Test.stopTest();        
        system.assertEquals(0, [select count() from Relationship__c where id = :crel_mirror.id]);
    }
    
    /*********************************************************************************************************
    * @description Test method for campaign member auto create relationships
    */
    @isTest 
    public static void testAutoCreateCampaignMemberInsert(){
    	if (strTestOnly != '*' && strTestOnly != 'testAutoCreateCampaignMemberInsert') return;
    	
        setupRelationshipTestData(null);
        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;
        
        //Insert a campaign
        Campaign campaign = new Campaign(Name='TestCampaign', isActive=true, Type='Other');
        insert campaign;
        
        //Insert a campaign member
        CampaignMember cm = new CampaignMember(ContactId = c2.id, CampaignId = campaign.id);
        Test.startTest();        
        insert cm;
        Test.stopTest();
        
        //Verify a relationship was automatically created when the campaign member was created 
        List<Relationship__c> relationships = [select id, Type__c from Relationship__c 
                                        where Contact__c = :c2.id];
        UTIL_Debug.debug('****Number of relationships after creating campaign member: ' + relationships.size());
        system.assertEquals(2, relationships.size());
        system.assertEquals('TestType', relationships[0].Type__c);
        
        //Verify a reciprocal relationship was also automatically created when the campaign member was created 
        List<Relationship__c> reciprocalRelationships = [select id, Type__c from Relationship__c 
                                        where ReciprocalRelationship__c = :relationships[0].id];
        UTIL_Debug.debug('****Number of reciprocal relationships: ' + reciprocalRelationships);
        system.assertEquals(1, reciprocalRelationships.size());
        system.assertEquals('TestType', reciprocalRelationships[0].Type__c);
        
    }  
     
    //test the synchronous process as well
    @isTest 
    public static void testAutoCreateCampaignMemberInsertSynch(){
    	if (strTestOnly != '*' && strTestOnly != 'testAutoCreateCampaignMemberInsertSynch') return;
    	
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));
        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;
        
        //insert a campaignmember
        Campaign c = new Campaign(Name='TestCampaign', isActive=true, Type='Other');
        insert c;
        CampaignMember cm = new CampaignMember(ContactId = c2.id, CampaignId = c.id);
        
        Test.startTest();        
        insert cm;
        Test.stopTest();
         
        Relationship__c rel = [select id, Type__c from Relationship__c where Contact__c = :c2.id limit 1];
        system.assertEquals('TestType', rel.Type__c);
        Relationship__c recRel = [select id, Type__c from Relationship__c where ReciprocalRelationship__c = :rel.id];
        system.assertEquals('TestType', recRel.Type__c);
    }

    /*********************************************************************************************************
    * @description Test method for campaign member auto create relationships on update. 
    * We can't do a true test as ContactId is not updatable, but we'll hit the update for coverage.
    */    
    @isTest 
    public static void testAutoCreateCampaignMemberUpdate(){
    	if (strTestOnly != '*' && strTestOnly != 'testAutoCreateCampaignMemberUpdate') return;
    	
        setupRelationshipTestData(null);        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;        
        //insert a campaignmember
        Campaign c = new Campaign(Name='TestCampaign', isActive=true);
        insert c;
        CampaignMember cm = new CampaignMember(ContactId = c2.id, CampaignId = c.id);
        insert cm;        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;        
        //do an update and check that a second relationship set is created for the new Contact
        cm.Status = 'SomethingDifferentForUpdate';        
        Test.startTest();        
        update cm;
        Test.stopTest();        
    }
    
    /*********************************************************************************************************
    * @description Test method for auto creating relationships based on contact fields on contact insert.
    */
    @isTest 
    public static void testAutoCreateContactInsert(){
    	if (strTestOnly != '*' && strTestOnly != 'testAutoCreateContactInsert') return;
    	
        setupRelationshipTestData(null);
        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;
        
        //insert a new Contact
        Contact c = new Contact(LastName='ReportingIn', ReportsToId = c1.id);        
        
        Test.startTest();        
        insert c;
        Test.stopTest();
         
        Relationship__c rel = [select id, Type__c, RelatedContact__c from Relationship__c where Contact__c = :c.id limit 1];
        system.assertEquals('TestType', rel.Type__c);
        system.assertEquals(c1.id, rel.RelatedContact__c);
        
        Relationship__c recRel = [select id, Type__c, RelatedContact__c, Contact__c from Relationship__c where ReciprocalRelationship__c = :rel.id];
        system.assertEquals('TestType', recRel.Type__c);
        system.assertEquals(c.id, recRel.RelatedContact__c);
    }
    
    @isTest 
    public static void testAutoCreateContactInsertSynch(){
    	if (strTestOnly != '*' && strTestOnly != 'testAutoCreateContactInsertSynch') return;
    	
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));
        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;
        
        //insert a new Contact
        Contact c = new Contact(LastName='ReportingIn', ReportsToId = c1.id);        
        
        Test.startTest();        
        insert c;
        Test.stopTest();
         
        Relationship__c rel = [select id, Type__c, RelatedContact__c from Relationship__c where Contact__c = :c.id limit 1];
        system.assertEquals('TestType', rel.Type__c);
        system.assertEquals(c1.id, rel.RelatedContact__c);
        
        Relationship__c recRel = [select id, Type__c, RelatedContact__c, Contact__c from Relationship__c where ReciprocalRelationship__c = :rel.id];
        system.assertEquals('TestType', recRel.Type__c);
        system.assertEquals(c.id, recRel.RelatedContact__c);
    }
    
    /*********************************************************************************************************
    * @description Test method for auto creating relationships based on contact fields on contact update.
    */
    @isTest 
    public static void testAutoCreateContactUpdate(){
    	if (strTestOnly != '*' && strTestOnly != 'testAutoCreateContactUpdate') return;
    	
        setupRelationshipTestData(null);
        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;
        
        //insert a new Contact
        Contact c = new Contact(LastName='ReportingIn', ReportsToId = c1.id);        
        insert c;
        //Relationships_ProcessControl.hasRun = false;
        c.ReportsToId = c2.id;
        
        Test.startTest();        
        update c;
        Test.stopTest();
         
        Relationship__c rel = [select id, Type__c, RelatedContact__c from Relationship__c where Contact__c = :c.id and RelatedContact__c = :c2.id limit 1];
        system.assertEquals('TestType', rel.Type__c);
        system.assertEquals(c2.id, rel.RelatedContact__c);
    }
    
    /*********************************************************************************************************
    * @description Test value inversion reciprocal method, verify type.
    */
    @isTest 
    public static void testInversionSettingsHaveType(){
    	if (strTestOnly != '*' && strTestOnly != 'testInversionSettingsHaveType') return;
    	
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'Value Inversion'));
        
        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = c1.id, Relatedcontact__c = c2.id, Type__c='Buddies-Friends')
        };
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;
        
        Test.startTest();
        insert crel;
        Test.stopTest();
        
        // check that rel gets created
        Relationship__c crel_original = [select id, Description__c,Type__c,reciprocalrelationship__c from Relationship__c where id=:crel[0].Id];
        //relationship should be set right
        system.assertEquals(crel_original.Type__c, 'Buddies-Friends');

        // check for mirror rel
        Relationship__c crel_mirror = [select id, Description__c, reciprocalrelationship__c, Type__c from Relationship__c where reciprocalrelationship__c=:crel_original.Id];
        //mirror should reference the original
        system.assertEquals(crel_mirror.reciprocalrelationship__c, crel_original.Id);
        system.assertEquals('Friends-Buddies', crel_mirror.Type__c);        
    }
    
    /*********************************************************************************************************
    * @description Test value inversion reciprocal method, verify type.
    */
    @isTest 
    public static void testInversionSettingsNoType(){
    	if (strTestOnly != '*' && strTestOnly != 'testInversionSettingsNoType') return;
    	
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'Value Inversion'));
        
        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = c1.id, Relatedcontact__c = c2.id, Type__c='BuddiesFriends')
        };
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;
        
        Test.startTest();
        insert crel;
        Test.stopTest();
        
        // check that rel gets created
        Relationship__c crel_original = [select id, Description__c,Type__c,reciprocalrelationship__c from Relationship__c where id=:crel[0].Id];
        //relationship should be set right
        system.assertEquals(crel_original.Type__c, 'BuddiesFriends');

        // check for mirror rel
        Relationship__c crel_mirror = [select id, Description__c, reciprocalrelationship__c, Type__c from Relationship__c where reciprocalrelationship__c=:crel_original.Id];
        //mirror should reference the original
        system.assertEquals(crel_mirror.reciprocalrelationship__c, crel_original.Id);
        system.assertEquals('BuddiesFriends', crel_mirror.Type__c);
    }
    
    /*********************************************************************************************************
    * @description Test invalid settings config, verify mirror relationship works correctly
    */
    @isTest 
    public static void testNoValidSettingsConfig(){
    	if (strTestOnly != '*' && strTestOnly != 'testNoValidSettingsConfig') return;
    	
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'BAD_VALUE'));
        
        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = c1.id, Relatedcontact__c = c2.id, Type__c='BuddiesFriends')
        };
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;
        
        Test.startTest();
        insert crel;
        Test.stopTest();
        
        // check that rel gets created
        Relationship__c crel_original = [select id, Description__c,Type__c,reciprocalrelationship__c from Relationship__c where id=:crel[0].Id];
        //relationship should be set right
        system.assertEquals(crel_original.Type__c, 'BuddiesFriends');

        // check for mirror rel
        Relationship__c crel_mirror = [select id, Description__c, reciprocalrelationship__c, Type__c from Relationship__c where reciprocalrelationship__c=:crel_original.Id];
        //mirror should reference the original
        system.assertEquals(crel_mirror.reciprocalrelationship__c, crel_original.Id);
        system.assertEquals('BuddiesFriends', crel_mirror.Type__c);
    }
    
    /*********************************************************************************************************
    * @description Test male contact (by salutation) gets male relationship type
    */
    @isTest 
    public static void testMaleSalutationReciprocal(){
    	if (strTestOnly != '*' && strTestOnly != 'testMaleSalutationReciprocal') return;
    	
        setupRelationshipTestData(null);
        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = c1.id, Relatedcontact__c = c2.id, Type__c='TestLookupType')
        };        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;      
        
        Test.startTest();
        insert crel;
        Test.stopTest();      
        
        Relationship__c recRel = [select id, Type__c from Relationship__c where ReciprocalRelationship__c = :crel[0].id];
        system.assertEquals('TestMaleType', recRel.Type__c);
    }
    
    /*********************************************************************************************************
    * @description Test female contact (by salutation) gets female relationship type
    */
    @isTest 
    public static void testFemaleSalutationReciprocal(){
    	if (strTestOnly != '*' && strTestOnly != 'testFemaleSalutationReciprocal') return;
    	
        setupRelationshipTestData(null);
        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = c2.id, Relatedcontact__c = c1.id, Type__c='TestLookupType')
        };        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;        
        
        Test.startTest();
        insert crel;
        Test.stopTest();      
        
        Relationship__c recRel = [select id, Type__c from Relationship__c where ReciprocalRelationship__c = :crel[0].id];
        system.assertEquals('TestFemaleType', recRel.Type__c);
    }
    
    /*********************************************************************************************************
    * @description Test neutral contact (by salutation) gets neutral relationship type
    */
    @isTest 
    public static void testNeutralSalutationReciprocal(){
    	if (strTestOnly != '*' && strTestOnly != 'testNeutralSalutationReciprocal') return;
    	
        setupRelationshipTestData(null);
        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = c3.id, Relatedcontact__c = c2.id, Type__c='TestLookupType')
        };        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;        
        
        Test.startTest();
        insert crel;
        Test.stopTest();      
        
        Relationship__c recRel = [select id, Type__c from Relationship__c where ReciprocalRelationship__c = :crel[0].id];
        system.assertEquals('TestNeutralType', recRel.Type__c);
    }
    
    /*********************************************************************************************************
    * @description Test neutral contact (by gender field) gets neutral relationship type
    */
    @isTest 
    public static void testNeutralGenderFieldReciprocal(){
    	if (strTestOnly != '*' && strTestOnly != 'testNeutralGenderFieldReciprocal') return;
    	
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));
        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = c3.id, Relatedcontact__c = c2.id, Type__c='TestLookupType')
        };                
        c3.Gender__c = 'Neutral';
        update c3;
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;        
        
        Test.startTest();
        insert crel;
        Test.stopTest();      
        
        Relationship__c recRel = [select id, Type__c from Relationship__c where ReciprocalRelationship__c = :crel[0].id];
        system.assertEquals('TestNeutralType', recRel.Type__c);
    }
    
    /*********************************************************************************************************
    * @description Test male contact (by gender field) gets male relationship type
    */
    @isTest 
    public static void testMaleGenderFieldReciprocal(){
    	if (strTestOnly != '*' && strTestOnly != 'testMaleGenderFieldReciprocal') return;
    	
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));
        c1.Gender__c = 'Male';
        update c1;
        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = c1.id, Relatedcontact__c = c2.id, Type__c='TestLookupType')
        };        
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;        
        
        Test.startTest();
        insert crel;
        Test.stopTest();      
        
        Relationship__c recRel = [select id, Type__c from Relationship__c where ReciprocalRelationship__c = :crel[0].id];
        system.assertEquals('TestMaleType', recRel.Type__c);
    }
    
    /*********************************************************************************************************
    * @description Test female contact (by gender field) gets female relationship type
    */
    @isTest 
    public static void testFemaleGenderFieldReciprocal(){
    	if (strTestOnly != '*' && strTestOnly != 'testFemaleGenderFieldReciprocal') return;
    	
        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));
        c2.Gender__c = 'Female';
        update c2;
        
        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = c2.id, Relatedcontact__c = c2.id, Type__c='TestLookupType')
        };
        //reset the process controller to mimic a second user action
        //Relationships_ProcessControl.hasRun = false;        
        
        Test.startTest();
        insert crel;
        Test.stopTest();      
        
        Relationship__c recRel = [select id, Type__c from Relationship__c where ReciprocalRelationship__c = :crel[0].id];
        system.assertEquals('TestFemaleType', recRel.Type__c);
    }
    
    /*********************************************************************************************************
    * @description For two contacts with no gender, manually set a gendered relationship. Verify that it stays
    * and that the reciprocal gets the neutral type by default.
    */
    static testMethod void testNoGenderManualRel(){
        if (strTestOnly != '*' && strTestOnly != 'testNoGenderManualRel') return;

        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));

        list<Contact> conList = new list<Contact>{
            new Contact(LastName='foo'),
            new Contact(LastName='foo2')
        };
        insert conList;

        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = conList[0].id, Relatedcontact__c = conList[1].id, Type__c='TestLookupType')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();      

        Relationship__c recRel = [select id, Type__c from Relationship__c where ReciprocalRelationship__c = :crel[0].id];
        system.assertEquals('TestNeutralType', recRel.Type__c);

        recRel = [select id, Type__c from Relationship__c where id = :crel[0].id];
        system.assertEquals('TestLookupType', recRel.Type__c);
    }
    
    /*********************************************************************************************************
    * @description For two contacts with no gender, manually set a gendered relationship. Change the status,
    * verify gendered relationship type hasn't changed, but that the status has changed.
    */
    static testMethod void testNoGenderManualRelStatusChange(){
        if (strTestOnly != '*' && strTestOnly != 'testNoGenderManualRelStatusChange') return;

        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));

        list<Contact> conList = new list<Contact>{
            new Contact(LastName='foo'),
            new Contact(LastName='foo2')
        };
        insert conList;

        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = conList[0].id, Relatedcontact__c = conList[1].id, Type__c='TestMaleType')
        };

        Test.startTest();
        insert crel;
        Test.stopTest();

        Relationship__c recRel = [select id, Type__c from Relationship__c where id = :crel[0].id];
        system.assertEquals('TestMaleType', recRel.Type__c);

        crel[0].Status__c = 'Former';
        update crel;

        recRel = [select id, Type__c from Relationship__c where id = :crel[0].id];
        system.assertEquals('TestMaleType', recRel.Type__c);

        recRel = [select id, Status__c from Relationship__c where ReciprocalRelationship__c = :crel[0].id];
        system.assertEquals('Former', recRel.Status__c);

        crel[0].Status__c = 'Current';
        update crel;

        recRel = [select id, Type__c from Relationship__c where id = :crel[0].id];
        system.assertEquals('TestMaleType', recRel.Type__c);

        recRel = [select id, Status__c from Relationship__c where ReciprocalRelationship__c = :crel[0].id];
        system.assertEquals('Current', recRel.Status__c);
    }
    
    /*********************************************************************************************************
    * @description For two contacts with an established relationship, change the gender field of one of the
    * contacts. Verify the relationship's type has changed per the changed gender, and that the reciprocal 
    * hasn't changed.
    */
    static testMethod void testGenderChange(){
        if (strTestOnly != '*' && strTestOnly != 'testGenderChange') return;

        setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));

        list<Contact> conList = new list<Contact>{
            new Contact(LastName='foo', Gender__c='Female'),
            new Contact(LastName='foo2', Gender__c='Male')
        };
        insert conList;

        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = conList[0].id, Relatedcontact__c = conList[1].id, Type__c='TestLookupType')
        };

        insert crel;

        Relationship__c recRel = [select id, Type__c from Relationship__c where id = :crel[0].id];
        system.assertEquals('TestLookupType', recRel.Type__c);

        recRel = [select id, Type__c from Relationship__c where ReciprocalRelationship__c = :crel[0].id];
        system.assertEquals('TestFemaleType', recRel.Type__c);

        conList[1].Gender__c='Female';
        
        Test.startTest();
        update conList[1];
        Test.stopTest();

        recRel = [select id, Type__c from Relationship__c where id = :crel[0].id];
        system.assertEquals('TestFemaleType', recRel.Type__c);

        recRel = [select id, Type__c from Relationship__c where ReciprocalRelationship__c = :crel[0].id];
        system.assertEquals('TestFemaleType', recRel.Type__c);
    }

    /*********************************************************************************************************
    * @description Test error record creation when inserting a relationship with a required field missing.
    */
    @isTest 
    public static void testErrorRecordCreation() {
    	if (strTestOnly != '*' && strTestOnly != 'testErrorRecordCreation') return;
    	    	
        setupRelationshipTestData(null);
        
        Relationship__c[] relationships = new Relationship__c[]{
            new Relationship__c(contact__c = c2.id, Type__c='TestLookupType')
        };

        Test.startTest();
        Database.SaveResult[] insertResults = Database.insert(relationships, false);
        Test.stopTest();
        //assert an error - Required fields are missing: [Contact__c]
        //Contact__c is missing from the reciprocal relationship that gets automatically created.
        system.assertEquals(1, [select count() from Error__c]);
        
        //update relationship - this will create the missing Contact__c field
        relationships[0].RelatedContact__c = c1.id;
        Database.SaveResult[] updateResults = Database.update(relationships, false);   
        system.assertNotEquals(null, relationships[0].Contact__c);
        
        //get errors
        ERR_Handler.Errors errors = ERR_Handler.getErrors(updateResults, (List<SObject>)relationships);
        //we still get an error, because of the Related_Contact_Do_Not_Change validation rule on Relationship
        system.assertEquals(true, errors.errorsExist);
        system.assertEquals(1, errors.errorRecords.size());

        //assert no additional error record was created on update
        system.assertEquals(1, [select count() from Error__c]);
    }
    
    /*********************************************************************************************************
    * @description Test method throws an exception for relationships and verifies an error is logged.
    */
    @isTest 
    public static void testExceptionRecordCreation(){
    	if (strTestOnly != '*' && strTestOnly != 'testExceptionRecordCreation') return;
    	
        setupRelationshipTestData(null);
        
        ERR_Handler.processError(new MyException('TestException'), ERR_Handler.Context.REL);
        List<Error__c> errors = [select Full_Message__c from Error__c];
        System.assertEquals(1, errors.size());
        System.assertEquals('TestException', errors[0].Full_Message__c);       
    }
    
    /*********************************************************************************************************
    * @description Test method for verifying automatic relationship creation won't create a duplicate.
    */
    @isTest 
    public static void testAutoCreateDupePrevention(){
    	if (strTestOnly != '*' && strTestOnly != 'testAutoCreateDupePrevention') return;
    	
        setupRelationshipTestData(null);
        
        Relationship__c[] crel = new Relationship__c[]{
            new Relationship__c(contact__c = c1.id, Relatedcontact__c = c2.id, Type__c='TestType')
        };
        crel.add(new Relationship__c(contact__c = c1.id, Relatedcontact__c = c2.id, Type__c='TestType2'));
        insert crel;
        
        //update the ReportsToId to trigger autocreation 
        c1.ReportsToId = c2.id;
        //Relationships_ProcessControl.hasRun = false;
                
        Test.startTest();        
        update c1;
        Test.stopTest();
        
        //assert we only have one relationship since we've deduped the auto-created one   
        Relationship__c[] rel = [select id, Type__c, RelatedContact__c from Relationship__c where Contact__c = :c1.id and Type__c = 'TestType'];
        system.assertEquals('TestType', rel[0].Type__c);
        system.assertEquals(rel.size(), 1);     
    }
    
    /*********************************************************************************************************
    * @description Method to test the UTIL_CustomSettingsFacade class as a different user
    */
    @isTest 
    public static void testRelationshipUTILS(){
    	if (strTestOnly != '*' && strTestOnly != 'testRelationshipUTILS') return;
    	
        //to test the Relationship_Utils class      
        System.runAs(new User(id = UserInfo.getUserId())){
           delete [select id from Hierarchy_Settings__c];
           Hierarchy_Settings__c rs = UTIL_CustomSettingsFacade.getSettings();
           Boolean cAuto = REL_Utils.hasContactAutoCreate;
           Boolean cmAuto = REL_Utils.hasCMAutoCreate;
        }
    }  
    
    /*********************************************************************************************************
    * @description Test method for inserting two relationships in a single transaction.
    */
    @isTest 
    public static void test2Rels1Transaction_v2() {
    	if (strTestOnly != '*' && strTestOnly != 'test2Rels1Transaction_v2') return;
    	
         // Create three contacts
        Contact mainClient = new Contact(FirstName='Main',LastName='AAAClient');
        Contact friend = new Contact(FirstName='Test',LastName='AAAFriend');
        Contact coworker = new Contact(FirstName='Test',LastName='AAACoworker');
        insert new Contact[] {mainClient, friend, coworker};
        
        // Create two relationships
        Relationship__c r1 = new Relationship__c(Contact__c=mainClient.Id, RelatedContact__c=friend.Id, Type__c='Friend');
        Relationship__c r2 = new Relationship__c(Contact__c=mainClient.Id, RelatedContact__c=coworker.Id, Type__c='Coworker');
        
        Test.startTest();
        insert new Relationship__c[] {r1, r2};
        Test.stopTest();
        
        Relationship__c nr = [select id, ReciprocalRelationship__c from Relationship__c where Id = :r1.id];      
        system.assert(nr.ReciprocalRelationship__c != null);        
               
        Relationship__c nr2 = [select id, ReciprocalRelationship__c from Relationship__c where Id = :r2.id];
        system.assert(nr2.ReciprocalRelationship__c != null);       
        
        list<Relationship__c> rels = new list<Relationship__c>(); 
        rels.add(new Relationship__c(Contact__c=mainClient.Id,RelatedContact__c=friend.Id,Type__c='Friend2'));
        rels.add(new Relationship__c(Contact__c=mainClient.Id,RelatedContact__c=coworker.Id,Type__c='Coworker2'));
        insert rels;
        list<Relationship__c> rels2 = [select id, ReciprocalRelationship__c from Relationship__c where Id = :rels[0].Id or Id = :rels[1].Id];
        system.assertEquals(2, rels2.size());
        system.assert(rels2[0].ReciprocalRelationship__c != null);      
        system.assert(rels2[1].ReciprocalRelationship__c != null);     
        
    }  
  
    /*********************************************************************************************************
    * @description Exception 
    */
    public class MyException extends Exception{}
}