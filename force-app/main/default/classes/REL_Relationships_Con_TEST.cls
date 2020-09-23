/*
    Copyright (c) 2020 Salesforce.org
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
* @date 2020
* @group Contact Relationships
* @group-content ../../ApexDocContent/Relationships.htm
* @description Testing for the Contact Relationship trigger functionality.
*/
@isTest
public with sharing class REL_Relationships_Con_TEST {

    /*********************************************************************************************************
    ********************************** AFTER INSERT - FUNCTIONAL TESTS ***************************************
    *********************************************************************************************************/

    // /*********************************************************************************************************
    // * @description Test method for campaign member auto create relationships
    // */
    // @isTest
    // public static void testAutoCreateCampaignMemberInsert() {
    //     setupRelationshipTestData(null);

    //     //Insert a campaign
    //     Campaign campaign = new Campaign(Name = 'TestCampaign', IsActive = true, Type = 'Other');
    //     insert campaign;

    //     //Insert a campaign member
    //     CampaignMember cm = new CampaignMember(ContactId = c2.Id, CampaignId = campaign.Id);
    //     Test.startTest();
    //     insert cm;
    //     Test.stopTest();

    //     //Verify a relationship was automatically created when the campaign member was created
    //     List<Relationship__c> relationships = [SELECT Id, Type__c FROM Relationship__c
    //                                     WHERE Contact__c = :c2.Id];
    //     UTIL_Debug.debug('****Number of relationships after creating campaign member: ' + relationships.size());
    //     system.assertEquals(2, relationships.size());
    //     system.assertEquals('TestType', relationships[0].Type__c);

    //     //Verify a reciprocal relationship was also automatically created when the campaign member was created
    //     List<Relationship__c> reciprocalRelationships = [SELECT Id, Type__c FROM Relationship__c
    //                                     WHERE ReciprocalRelationship__c = :relationships[0].Id];
    //     UTIL_Debug.debug('****Number of reciprocal relationships: ' + reciprocalRelationships);
    //     system.assertEquals(1, reciprocalRelationships.size());
    //     system.assertEquals('TestType', reciprocalRelationships[0].Type__c);
    // }

    // /*********************************************************************************************************
    // * @description Test method for campaign member auto create relationships - synchronous
    // */
    // @isTest
    // public static void testAutoCreateCampaignMemberInsertSynch() {
    //     setupRelationshipTestData(new Hierarchy_Settings__c(Reciprocal_Method__c = 'List Setting'));

    //     //insert a campaignmember
    //     Campaign c = new Campaign(Name = 'TestCampaign', IsActive = true, Type = 'Other');
    //     insert c;
    //     CampaignMember cm = new CampaignMember(ContactId = c2.Id, CampaignId = c.Id);

    //     Test.startTest();
    //     insert cm;
    //     Test.stopTest();

    //     Relationship__c rel = [SELECT Id, Type__c FROM Relationship__c WHERE Contact__c = :c2.Id LIMIT 1];
    //     system.assertEquals('TestType', rel.Type__c);
    //     Relationship__c recRel = [SELECT Id, Type__c FROM Relationship__c WHERE ReciprocalRelationship__c = :rel.Id];
    //     system.assertEquals('TestType', recRel.Type__c);
    // }

    // /*********************************************************************************************************
    // * @description Test method for verifying automatic relationship creation won't create a duplicate.
    // */
    // @isTest
    // public static void testAutoCreateDupePrevention() {
    //     setupRelationshipTestData(null);

    //     List<Relationship__c> crel = new List<Relationship__c>{
    //         new Relationship__c(Contact__c = c1.Id, RelatedContact__c = c2.Id, Type__c = 'TestType')
    //     };
    //     crel.add(new Relationship__c(Contact__c = c1.Id, RelatedContact__c = c2.Id, Type__c = 'TestType2'));
    //     insert crel;

    //     //update the ReportsToId to trigger autocreation
    //     c1.ReportsToId = c2.Id;

    //     Test.startTest();
    //     update c1;
    //     Test.stopTest();

    //     //assert we only have one relationship since we've deduped the auto-created one
    //     List<Relationship__c> rel = [SELECT Id, Type__c, RelatedContact__c FROM Relationship__c WHERE Contact__c = :c1.Id AND Type__c = 'TestType'];
    //     system.assertEquals('TestType', rel[0].Type__c);
    //     system.assertEquals(rel.size(), 1);
    // }

    // /*********************************************************************************************************
    // * @description Test method for REL_Utils class when auto create settings exist
    // */
    // @isTest
    // public static void testRelationshipUTILSAutoCreate() {
    //     System.runAs(new User(Id = UserInfo.getUserId())) {
    //         insert new Relationship_Auto_Create__c(Name = 'contacttest'+ system.now(),
    //                                                 Object__c = 'Contact', Field__c = 'coworker__c',
    //                                                 Relationship_Type__c = 'coworker',
    //                                                 Campaign_Types__c = 'fun event');
    //         insert new Relationship_Auto_Create__c(Name = 'membertest'+ system.now(),
    //                                                 Object__c = 'CampaignMember', Field__c = 'member__c',
    //                                                 Relationship_Type__c = 'member',
    //                                                 Campaign_Types__c = 'fun event');

    //         Boolean cAuto = REL_Utils.hasContactAutoCreate;
    //         Boolean cmAuto = REL_Utils.hasCMAutoCreate;
    //         System.assertEquals(true, cAuto);
    //         System.assertEquals(true, cmAuto);
    //     }
    // }
}
