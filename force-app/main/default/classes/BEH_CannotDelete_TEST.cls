/*
    Copyright (c) 2020, Salesforce.org
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

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORSå
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
* @group Behavior Involvement 
* @group-content ../../ApexDocContent/BehaviorInvolvement.htm
* @description Tests for BEH_CannotDelete_TDTM.
*/
@isTest
public with sharing class BEH_CannotDelete_TEST {
    /*********************************************************************************************************
    * @description setting up test records for Contacts, Cases, and Behavior Involvement
    */
    @testSetup
    static void testSetup() {
        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(4); 
        insert contacts;         
        
        List<Case> cases = new List<Case>(); 
        Case c1 = UTIL_UnitTestData_TEST.getCase(contacts[0].Id, 'School Violation', 'New'); 
        Case c2 = UTIL_UnitTestData_TEST.getCase(contacts[1].Id, 'School Violation', 'New'); 
        Case c3 = UTIL_UnitTestData_TEST.getCase(contacts[2].Id, 'School Violation', 'New'); 
        Case c4 = UTIL_UnitTestData_TEST.getCase(contacts[3].Id, 'School Violation', 'New'); 
        cases.add(c1);
        cases.add(c2);
        cases.add(c3);
        cases.add(c4);
        insert cases; 
        
        List<Behavior_Involvement__c> bEHInvolvments = new List<Behavior_Involvement__c>(); 
        Behavior_Involvement__c bEH1 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(contacts[0].Id, cases[0].Id, 'Reporter');
        Behavior_Involvement__c bEH2 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(contacts[1].Id, cases[1].Id, 'Reporter');
        Behavior_Involvement__c bEH3 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(contacts[2].Id, cases[2].Id, 'Reporter');
        Behavior_Involvement__c bEH4 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(contacts[3].Id, cases[3].Id, 'Reporter');
        bEHInvolvments.add(bEH1);
        bEHInvolvments.add(bEH2);
        bEHInvolvments.add(bEH3);
        bEHInvolvments.add(bEH4);
        insert bEHInvolvments; 
        
    } 
    
    /*********************************************************************************************************
    * @description Test method to test the following:
    * (1) If Prevent_Behavior_Involvement_Deletion__c is enabled in Hierarchy Settings, and a Behavior Involvement
    * has child record(s) (Behavior Response), it cannot be deleted. 
    * (2) If Prevent_Behavior_Involvement_Deletion__c is enabled in Hierarchy Setttings, and a Behavior Involvement
    * does not have child record(s) (Behavior Response), it can be deleted. 
    */
    @isTest
    private static void testPreventBEHEnabled() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                        Prevent_Behavior_Involvement_Deletion__c = TRUE));
        List<Contact> contacts = [SELECT Id, LastName
                                  FROM Contact LIMIT 4]; 
        
        List<Case> cases = [SELECT Id 
                            FROM Case LIMIT 4]; 
        
        List<Behavior_Involvement__c> bEHInvolvments = [SELECT Id 
                                                        FROM Behavior_Involvement__c LIMIT 4]; 
        
        List<Behavior_Response__c> bEResponses = new List<Behavior_Response__c>(); 
        Behavior_Response__c bEResponses1 = new Behavior_Response__c(Behavior_Involvement__c = bEHInvolvments[0].Id, Type__c = 'Expulsion'); 
        Behavior_Response__c bEResponses2 = new Behavior_Response__c(Behavior_Involvement__c = bEHInvolvments[1].Id, Type__c = 'Expulsion'); 
        bEResponses.add(bEResponses1); 
        bEResponses.add(bEResponses2); 
        insert bEResponses; 
        
        Test.startTest(); 
        Database.DeleteResult[] results = Database.delete(bEHInvolvments, false);
        Test.stopTest(); 
        
        List<Behavior_Involvement__c> returnBEH = [SELECT Id
                                                   FROM Behavior_Involvement__c
                                                   WHERE Id IN :bEHInvolvments]; 
        
        //Verifies that only 2 Behavior Involvements were deleted 
        System.assertEquals(2, returnBEH.size()); 
        
        //Verifies that the Behavior Involvement records with Behavior Response were not deleted
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message); 
        System.assertEquals(Label.CannotDelete, results[1].errors[0].message); 
        
    }
    
    /*********************************************************************************************************
    * @description Test method to test the following:
    * (1) If Prevent_Behavior_Involvement_Deletion__c is disabled in Hierarchy Settings, and a Behavior Involvement
    * has child record(s) (Behavior Response), it can be deleted. 
    * (2) If Prevent_Behavior_Involvement_Deletion__c is disabled in Hierarchy Setttings, and a Behavior Involvement
    * does not have child record(s) (Behavior Response), it can be deleted. 
    */
    @isTest
    private static void testPreventBEHDisabled() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                        (Account_Processor__c = UTIL_Describe_API.getHhAccRecTypeID(),
                                                        Prevent_Behavior_Involvement_Deletion__c = FALSE));
        List<Contact> contacts = [SELECT Id, LastName
                                  FROM Contact LIMIT 4]; 
        
        List<Case> cases = [SELECT Id 
                            FROM Case LIMIT 4]; 
        
        List<Behavior_Involvement__c> bEHInvolvments = [SELECT Id 
                                                        FROM Behavior_Involvement__c LIMIT 4]; 
        
        List<Behavior_Response__c> bEResponses = new List<Behavior_Response__c>(); 
        Behavior_Response__c bEResponses1 = new Behavior_Response__c(Behavior_Involvement__c = bEHInvolvments[0].Id, Type__c = 'Expulsion'); 
        Behavior_Response__c bEResponses2 = new Behavior_Response__c(Behavior_Involvement__c = bEHInvolvments[1].Id, Type__c = 'Expulsion'); 
        bEResponses.add(bEResponses1); 
        bEResponses.add(bEResponses2); 
        insert bEResponses; 
        
        Test.startTest(); 
        Database.DeleteResult[] results = Database.delete(bEHInvolvments, false);
        Test.stopTest(); 
        
        List<Behavior_Involvement__c> returnBEH = [SELECT Id
                                                   FROM Behavior_Involvement__c
                                                   WHERE Id IN :bEHInvolvments]; 
        
        //Verifies that only 2 Behavior Involvements were deleted 
        System.assertEquals(0, returnBEH.size()); 
        
    }
}