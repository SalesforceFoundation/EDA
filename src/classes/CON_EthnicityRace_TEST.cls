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
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Tests Race Ethnicity Batch Class
*/
@isTest
private class CON_EthnicityRace_TEST {

	Private static List<String> races = new List<String>{
			'White',
			'Asian',
			'Hispanic or Latino',
			'Not Hispanic or Latino',
			'Black or African American',
			'American Indian or Alaskan Native',
			'Native Hawaiian or Other Pacific Islander'};

	@testSetup
	static void dataSetup() {

		// How many races to test
		Integer raceCount = races.size();

		// Get contacts that match the number ot
        List<Contact> listCon = UTIL_UnitTestData_TEST.getMultipleTestContacts(raceCount);
        for (Integer i = 0; i < raceCount; i++) {
            listCon[i].LastName = 'ToAvoidDupeRule' + i;//Avoid duplicate matching

            // Setup the Ethnicity info
            listCon[i].Ethnicity__c = races.get(i);
        }

        insert listCon;
	}

	@isTest
	static void testEthnicityRaceBatch() {
		// Run Batch
		Test.startTest();
	    CON_EthnicityRace_BATCH contbatch = new CON_EthnicityRace_BATCH();
	    Database.executeBatch( contbatch );
		Test.stopTest();

		// AFter test run assert
		//System.assertEquals( 7, contacts.size() );
		List<Contact> contacts = [SELECT Id, Name, Ethnicity__c, Race__c FROM Contact WHERE Race__c in: races];
		System.assertEquals( (races.size()-2) , contacts.size() ); // We reduce the count by two because we are explicitly trying to exclude two of the results
	}
}