/*
    Copyright (c) 2018, Salesforce.org
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
* @date 2018
* @group Program Plan
* @group-content ../../ApexDocContent/ProgramEnrollments.htm
* @description Testing for handling program enrollment with program plan.
*/

@IsTest
private class PREN_ProgramPlan_TEST {

    @IsTest
    static void createProgramEnrollmentPrimaryProgramPlanExist() {
        //Set up test data
        List<Account> testAccts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getAcademicAccRecTypeID());
        insert testAccts;

        List<Program_Plan__c> testPPs = UTIL_UnitTestData_TEST.getMultipleTestProgramPlans(2);
        for (Program_Plan__c testPP : testPPs) {
            testPP.Account__c = testAccts[0].Id;
        }
        testPPs[0].Is_Primary__c = true;
        insert testPPs;

        //Run the test
        Test.startTest();
        Program_Enrollment__c testPe = UTIL_UnitTestData_TEST.getProgramEnrollment(testAccts[0].Id);
        insert testPe;
        Test.stopTest();

        //Assert the test
        List<Program_Enrollment__c> resultPes = [SELECT Id, Program_Plan__c
                                                    FROM Program_Enrollment__c];
        //Make sure there is only one program enrollment created
        System.assertEquals(1, resultPes.size());
        //Make sure the program plan is automatically populated for new program enrollment
        System.assertEquals(testPPs[0].Id, resultPes[0].Program_Plan__c);
    }

    @IsTest
    static void createProgramEnrollmentPrimaryProgramPlanNotExist() {
        //Set up test data
        List<Account> testAccts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe.getAcademicAccRecTypeID());
        insert testAccts;

        //Run the test
        Test.startTest();
        Program_Enrollment__c testPe = UTIL_UnitTestData_TEST.getProgramEnrollment(testAccts[0].Id);
        insert testPe;
        Test.stopTest();

        //Assert the test
        List<Program_Enrollment__c> resultPes = [SELECT Id, Program_Plan__c
                                                    FROM Program_Enrollment__c];
        //Make sure there is only one program enrollment created
        System.assertEquals(1, resultPes.size());
        //Make sure the program plan is empty for new program enrollment
        System.assertEquals(null, resultPes[0].Program_Plan__c);
    }
}