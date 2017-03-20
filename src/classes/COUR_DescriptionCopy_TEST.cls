/*
    Copyright (c) 2017, Salesforce.org
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
* @date 2017
* @group Courses
* @group-content ../../ApexDocContent/Courses.htm
* @description Tests COUR_DescriptionCopy_BATCH
*/
@isTest
private class COUR_DescriptionCopy_TEST {

	@testSetup
	static void dataSetup() {

        // Create university
        Account university = new Account(Name = 'Advanced University');
        insert university;

		// How many courses to insert
		Integer count = 10;

		List<Course__c> courses = new List<Course__c>();
       
        for (Integer i = 0; i < count; i++) {
        	courses.add(
        		new Course__c(
        			Name = 'Course ' + i,
        			Account__c = university.Id,
        			Description__c = 'Course ' + i + ' Description'
        		)
        	);
        }

        // add one extended description
        courses[0].Extended_Description__c = 'Exteded Description';

        insert courses;
	}

	@isTest
	static void testCOurseDescriptionCopyBatch() {
		// Run Batch
		Test.startTest();
	    COUR_DescriptionCopy_BATCH cbatch = new COUR_DescriptionCopy_BATCH();
	    Database.executeBatch( cbatch );
		Test.stopTest();

		// We cant query against Extended Description because it is a long textarea field.
		List<Course__c> coursesAfter = [SELECT Id, Name, Description__c, Extended_Description__c FROM Course__c];

        for (Integer i = 0; i < coursesAfter.size(); i++) {
        	// Isolate the one different Course already with an extended description 
        	if(coursesAfter[i].Description__c != coursesAfter[i].Extended_Description__c) {
        		// Make sure the extended description was not overridden
				System.assertEquals( coursesAfter[i].Extended_Description__c , 'Exteded Description' );
        	} else {
				System.assertEquals( coursesAfter[i].Extended_Description__c, coursesAfter[i].Description__c );
        	}
        }
	}
}