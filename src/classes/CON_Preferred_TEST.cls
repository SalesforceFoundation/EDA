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