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
* @description Tests Email Management Classes
*/
@isTest
private class CON_Email_TEST {

	@testSetup
	static void dataSetup() {
		UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
            );

		// Get contacts set up
        List<Contact> listCon = UTIL_UnitTestData_API.getMultipleTestContacts(10);
        for (Integer i = 0; i < 10; i++) {

            listCon[i].LastName = 'ToAvoidDupeRule' + i;//Avoid duplicate matching
            listCon[i].WorkEmail__c = ''; // clear email field set in getMultipleTestContacts
            listCon[i].Preferred_Email__c = ''; // clear preferred field set in getMultipleTestContacts
        }

        insert listCon;
	}

	@isTest static void testLeadConversion() {
		// create a Lead
		Lead tLead = new Lead(
			FirstName='Joshua',
			LastName='McTesterman',
			Email='mctesterman@mctesersite.com',
			Company='Test',
			Status='Inquiry'
		);

		insert tLead;

		Database.LeadConvert lc = new Database.LeadConvert();
		lc.setLeadId(tLead.Id);

		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
		lc.setConvertedStatus(convertStatus.MasterLabel);

		Test.startTest();		
		Database.LeadConvertResult lcr = Database.convertLead(lc);
		Test.stopTest();

		String contId = lcr.getContactId();
		Contact c = [SELECT Id, Name, Email FROM Contact WHERE Id =:contId LIMIT 1];

		System.assertEquals(c.Email,tLead.Email );
	}

	@isTest static void testSingleEmailSmartSet() {

		Contact newCont = new Contact(
			FirstName = 'JohnnyTest',
			LastName = 'JohnnyTest',
			WorkEmail__c = 'workit@test.com'
		);

		Test.startTest();
        insert newCont;
		Test.stopTest();

		Contact newContAfter = [SELECT Id, Name, WorkEmail__c, Email, Preferred_Email__c FROM Contact WHERE Name = 'JohnnyTest JohnnyTest' LIMIT 1];

        System.assertEquals(newContAfter.Email, newContAfter.WorkEmail__c);
        System.assertEquals('Work', newContAfter.Preferred_Email__c);
	}

	@isTest static void testPrefferedEmailInsertNoStd() {
		List<Contact> allContacts = [SELECT Id, Name, Email FROM Contact];
		System.assert(allContacts.size() > 0);
		List<Contact> contacts = new List<Contact>();
		for(Contact c : allContacts) {
			if(c.Email != '' && contacts.size() < 2) {
				contacts.add(c);
			}
		}
		System.assertEquals(2, contacts.size());
		//List<Contact> contacts = [SELECT Id, Name, Email FROM Contact WHERE Email != null LIMIT 2];
		List<String> contIds = new List<String>();

        for (Integer i = 0; i < contacts.size(); i++) {
			contacts[i].Preferred_Email__c = 'Alternate';
			contacts[i].AlternateEmail__c = 'alternetemailtest' + i + '@domainemail.com';
			contIds.add(contacts[i].Id);
        }

		Test.startTest();
        update contacts;
		Test.stopTest();

		contacts = [SELECT Id, Name, AlternateEmail__c, Email FROM Contact WHERE Id in:contIds LIMIT 2];

        if(contacts.size() > 0) {
	        for(Contact c : contacts) {
	        	// Make sure the new values were copies to the standard email field
	            System.assertEquals(c.Email, c.AlternateEmail__c);
            }
        }
	}

	@isTest static void testPrefferedEmailDeleting() {

		List<Contact> contacts = [SELECT Id, Name, Preferred_Email__c, Email, AlternateEmail__c,UniversityEmail__c, WorkEmail__c FROM Contact LIMIT 1];

		// Process the contact for testing
        if(contacts.size()>0) {
        	contacts[0].WorkEmail__c = 'testworkemail@domain.com';
        	contacts[0].Preferred_Email__c = 'Work';
	        update contacts;

	        Contact contactOne = [SELECT Id, Name, Preferred_Email__c, Email, AlternateEmail__c,UniversityEmail__c, WorkEmail__c FROM Contact WHERE Id =:contacts[0].Id LIMIT 1];
			System.assertEquals('testworkemail@domain.com', contactOne.Email); // make sure the email is copied for the test

        	contacts[0].Preferred_Email__c = null;
        	contacts[0].AlternateEmail__c = null;
        	contacts[0].UniversityEmail__c = null;
        	contacts[0].WorkEmail__c = null;
        }

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);

		Test.startTest();
        update contacts;
		Test.stopTest();

		contacts = [SELECT Id, Name, Preferred_Email__c, Email, AlternateEmail__c,UniversityEmail__c, WorkEmail__c FROM Contact WHERE id =: contacts[0].Id LIMIT 1];

		System.assertEquals(null, contacts[0].Email); // Contact email should be null because all other emails fields were deleted.
	}

	// Test the batch Class
	@isTest static void testContactEmailBatch() {

		List<String> contIds = new List<String>();

		List<Contact> contacts = [SELECT Id, Name, Preferred_Email__c, Email, AlternateEmail__c,UniversityEmail__c, WorkEmail__c FROM Contact];

		String caseOneId;
		String caseTwoId;

		// Process the contact for testing
        if(contacts.size()>0) {

	        for (Integer i = 0; i < contacts.size(); i++) {

	        	// Setup special Case 1
	        	if(i==5) {
					contacts[5].Email = 'uniquwemailtest5nomatch@domainemail.com';
					contacts[5].AlternateEmail__c = 'alternate5@domainemail.com';
		        	contacts[5].UniversityEmail__c = null;
		        	contacts[5].WorkEmail__c = null;
					contacts[5].Preferred_Email__c = '';
					caseOneId = contacts[5].Id;

        		// Setup special Case 2
				} else if (i==6) {
					contacts[6].AlternateEmail__c = 'alternate6@domainemail.com';
					contacts[6].Email = '';
					contacts[6].WorkEmail__c = null;
					contacts[6].Preferred_Email__c = '';
					caseTwoId = contacts[6].Id;

				} else {
					contacts[i].Email = 'emailtest' + i + '@domainemail.com';
		        	contacts[i].UniversityEmail__c = null;
		        	contacts[i].WorkEmail__c = null;
					contacts[i].AlternateEmail__c = null;
					contacts[i].Preferred_Email__c = null;
					contIds.add(contacts[i].Id);
				}
	        }

            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);
	        update contacts;
        }

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);
		// Run Batch
		Test.startTest();
	    CON_Email_BATCH contbatch = new CON_Email_BATCH(null);
	    Database.executeBatch( contbatch );
		Test.stopTest();

		// After batch run assert leaving off the two contacts for special cases
		contacts = [SELECT Id, Name, Email, AlternateEmail__c FROM Contact WHERE Id in: contIds AND Id!=:caseOneId AND Id !=: caseTwoId];
		for(Contact c : contacts) {
			System.assertEquals( c.AlternateEmail__c , c.Email );
		}

	    // Check special Case 1
		Contact contactOne = [SELECT Id, Name, Email, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE Id =:caseOneId LIMIT 1];
		System.assertEquals('uniquwemailtest5nomatch@domainemail.com', contactOne.Email);
		System.assertEquals('Email (standard)', contactOne.Preferred_Email__c);

	    // Check special Case 2
		Contact contactTwo = [SELECT Id, Name, Email, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE Id =:caseTwoId LIMIT 1];
		System.assertEquals(contactTwo.Email, contactTwo.AlternateEmail__c);
		System.assertEquals('Alternate', contactTwo.Preferred_Email__c);

	}

}