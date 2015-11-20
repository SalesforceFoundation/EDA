/*
    Copyright (c) 2015, Salesforce.org
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
@isTest
public with sharing class CON_Preferred_TEST {

	@isTest
	public static void preferredEmailPhoneInsert() {
		
		Contact contact1 = new Contact(LastName = 'TestersonA', UniversityEmail__c = 'fake@test.com', Preferred_Email__c = 'University', 
			HomePhone = '555-432-4433', PreferredPhone__c = 'Home');
		Contact contact2 = new Contact(LastName = 'TestersonB', WorkEmail__c = 'fake@test.com', Preferred_Email__c = 'Work', 
			WorkPhone__c = '555-432-4433', PreferredPhone__c = 'Work');
		Contact contact3 = new Contact(LastName = 'TestersonC', AlternateEmail__c = 'fake@test.com', Preferred_Email__c = 'Alternate', 
			OtherPhone = '555-432-4433', PreferredPhone__c = 'Other');
		Contact contact4 = new Contact(LastName = 'TestersonD', AlternateEmail__c = 'fake@test.com',
			MobilePhone = '555-432-4433', PreferredPhone__c = 'Mobile');
			
		List<Contact> contacts = new Contact[]{contact1, contact2, contact3, contact4};
		Test.startTest();
		insert contacts;
		Test.stopTest();
		
		contacts = [select Email, Phone, UniversityEmail__c, WorkEmail__c, AlternateEmail__c, HomePhone, WorkPhone__c, OtherPhone, MobilePhone 
					from Contact where ID in :contacts order by LastName];
		contact1 = contacts[0];
		contact2 = contacts[1];
		contact3 = contacts[2];
		contact4 = contacts[3];
		
		System.assertEquals(contact1.UniversityEmail__c, contact1.Email);
		System.assertEquals(contact2.WorkEmail__c, contact2.Email);
		System.assertEquals(contact3.AlternateEmail__c, contact3.Email);
		
		System.assertEquals(contact1.HomePhone, contact1.Phone);
		System.assertEquals(contact2.WorkPhone__c, contact2.Phone);
		System.assertEquals(contact3.OtherPhone, contact3.Phone);
		System.assertEquals(contact4.MobilePhone, contact4.Phone);
	}
	
	@isTest
	public static void preferredEmailPhoneUpdate() {
		
		Contact contact1 = new Contact(LastName = 'TestersonA', UniversityEmail__c = 'fake@test.com', HomePhone = '555-432-4433');
		Contact contact2 = new Contact(LastName = 'TestersonB', WorkEmail__c = 'fake@test.com', WorkPhone__c = '555-432-4433');
		Contact contact3 = new Contact(LastName = 'TestersonC', AlternateEmail__c = 'fake@test.com', OtherPhone = '555-432-4433');
		Contact contact4 = new Contact(LastName = 'TestersonD', MobilePhone = '555-432-4433');
			
		List<Contact> contacts = new Contact[]{contact1, contact2, contact3, contact4};
		insert contacts;

		contact1.Preferred_Email__c = 'University'; 
		contact1.PreferredPhone__c = 'Home';
		contact2.Preferred_Email__c = 'Work';
		contact2.PreferredPhone__c = 'Work';
		contact3.Preferred_Email__c = 'Alternate';
		contact3.PreferredPhone__c = 'Other';
		contact4.PreferredPhone__c = 'Mobile';
		
		Test.startTest();
		update contacts;
		Test.stopTest();
				
		contacts = [select Email, Phone, UniversityEmail__c, WorkEmail__c, AlternateEmail__c, HomePhone, WorkPhone__c, OtherPhone, MobilePhone 
					from Contact where ID in :contacts order by LastName];
		contact1 = contacts[0];
		contact2 = contacts[1];
		contact3 = contacts[2];
		contact4 = contacts[3];
		
		System.assertEquals(contact1.UniversityEmail__c, contact1.Email);
		System.assertEquals(contact2.WorkEmail__c, contact2.Email);
		System.assertEquals(contact3.AlternateEmail__c, contact3.Email);
		
		System.assertEquals(contact1.HomePhone, contact1.Phone);
		System.assertEquals(contact2.WorkPhone__c, contact2.Phone);
		System.assertEquals(contact3.OtherPhone, contact3.Phone);
		System.assertEquals(contact4.MobilePhone, contact4.Phone);
	}
}