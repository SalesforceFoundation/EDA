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
* @group Cases
* @group-content ../../ApexDocContent/Case.htm
* @description Unit tests for CASE_CannotDelete_TDTM. These tests
* make sure Cases cannot be deleted when they have Behavior Involvement Associations.
*/

@isTest
private class CASE_CannotDelete_TEST {

    @testSetup
    static void dataSetup() {
        
        // Insert Contacts
        List<Contact> students = new List<Contact>();
        
        Contact student1 = UTIL_UnitTestData_TEST.getContact();
        Contact student2 = UTIL_UnitTestData_TEST.getContact();
        
        students.add(student1);
        students.add(student2);

        insert students;

        // Insert Cases
        List<Case> cases = new List<Case>();
        Case case1 = UTIL_UnitTestData_TEST.getCase(student1.Id, 'School Violation', 'New');
        Case case2 = UTIL_UnitTestData_TEST.getCase(student2.Id, 'School Violation', 'New');

        cases.add(case1);
        cases.add(case2);

        insert cases;

        // Insert Behavior Involvement records
        List<Behavior_Involvement__c> behaviorRecords = new List<Behavior_Involvement__c>();

        Behavior_Involvement__c behavInvolRec1 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(student1.Id, case1.Id, 'Victim');
        Behavior_Involvement__c behavInvolRec2 = UTIL_UnitTestData_TEST.getBehaviorInvolvementRecord(student2.Id, case2.Id, 'Witness');

        behaviorRecords.add(behavInvolRec1);
        behaviorRecords.add(behavInvolRec2);

        insert behaviorRecords;
    }


    /*************************************************************************************************************
    * @description Test deletion of Cases with Behavior Involvement and preventing deletion setting is turned On
    */
    @isTest
    static void testCaseDeleteSettingOn() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Case_Deletion__c = TRUE));

        Test.startTest();
            List<Case> casesToDelete = [SELECT Id FROM Case];
            Database.DeleteResult[] results = Database.delete(casesToDelete, FALSE);
        Test.stopTest();

        // Ensure no Cases are deleted
        List<Case> casesAfterDelete = [SELECT Id FROM Case];
        System.assertEquals(2, casesAfterDelete.size());
    }

    /*************************************************************************************************************
    * @description Test deletion of Cases with Behavior Involvement and preventing deletion setting is turned Off
    */
    @isTest
    static void testCaseDeleteSettingOff() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Prevent_Case_Deletion__c = FALSE));

        Test.startTest();
            List<Case> casesToDelete = [SELECT Id FROM Case];
            Database.DeleteResult[] results = Database.delete(casesToDelete, FALSE);
        Test.stopTest();

        // Ensure all Cases are deleted
        List<Case> casesAfterDelete = [SELECT Id FROM Case];
        System.assertEquals(0, casesAfterDelete.size());
    }
}