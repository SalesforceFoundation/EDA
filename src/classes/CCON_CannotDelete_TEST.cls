/*
	Copyright (c) 2019, Salesforce.org
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
* @date 2019
* @group Course Enrollments
* @group-content ../../ApexDocContent/CourseEnrollments.htm
* @description Tests for CCON_CannotDelete_TDTM.
*/
@isTest
private with sharing class CCON_CannotDelete_TEST {
    @isTest
    private static void cannotDelete() {
        Account acc = UTIL_UnitTestData_TEST.getMultipleTestAccounts(1, UTIL_Describe_API.getBizAccRecTypeID())[0];
        insert acc;
        
        Contact[] contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(4);
        insert contacts;
        
        Course_Offering__c courseOffering = UTIL_UnitTestData_TEST.createCourseOffering(NULL, NULL); 
        
        List<Course_Enrollment__c> courseConnections = new List<Course_Enrollment__c>{
            new Course_Enrollment__c(Contact__c = contacts[0].Id, Course_Offering__c = courseOffering.Id),
            new Course_Enrollment__c(Contact__c = contacts[1].Id, Course_Offering__c = courseOffering.Id),
            new Course_Enrollment__c(Contact__c = contacts[2].Id, Course_Offering__c = courseOffering.Id)};
        insert courseConnections; 
        
        Term_Grade__c termGrade = new Term_Grade__c(Contact__c = contacts[0].Id, Course_Offering__c = courseOffering.Id, Course_Connection__c = courseConnections[0].Id); 
        Attendance_Event__c attendanceEvent = new Attendance_Event__c(Contact__c = contacts[1].Id, Date__c = System.today(), Course_Connection__c = courseConnections[1].Id); 
        insert new SObject[]{termGrade, attendanceEvent}; 
            
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(courseConnections, false);
        Test.stopTest();
        UTIL_Debug.debug('****Delete results: ' + JSON.serializePretty(results));
        
        //Verifies only 1 Course Connection was deleted 
        List<Course_Enrollment__c> returnCourseConnections = [SELECT Id FROM Course_Enrollment__c WHERE Id in: courseConnections];
        System.assertEquals(2, returnCourseConnections.size()); 
        
        //Verifies Course Connection with Term Grade was not deleted 
        System.assertEquals(false, results[0].success);
        System.assertEquals(Label.CannotDelete, results[0].errors[0].message); 
        
        //Verifies Course Connection with Attendance Event was not deleted 
        System.assertEquals(false, results[1].success);
        System.assertEquals(Label.CannotDelete, results[1].errors[0].message);
    }
}