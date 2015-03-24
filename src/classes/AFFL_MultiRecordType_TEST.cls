@isTest
public with sharing class AFFL_MultiRecordType_TEST {
	
	@isTest
	public static void createPrimaryAffl() {
		UTIL_CustomSettingsFacade.getAffiliationsSettingsForTests(new Affiliations_Settings__c(Automatic_Affiliation_Creation_Turned_On__c = true));
		
		List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
    	mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));	
    	mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
    	insert mappings;
    	
    	ID orgRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
    	ID householdRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
    	
    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	
    	contact = [select Account.ID, Primary_Household__c from Contact where ID =:Contact.ID];
    	
    	//Verify default household account has been created for the contact
    	System.assertNotEquals(null, contact.Account.ID);
    	
    	//Verify the primary household field was populated
    	System.assertEquals(contact.Account.ID, contact.Primary_Household__c);
    	
    	Account acc1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
    	insert acc1;
    	
    	//Create primary affiliation
		Affiliation__c affl1 = new Affiliation__c(Contact__c = contact.ID, Organization__c = acc1.ID, Primary__c = true);
		insert affl1;
		
		//The business organization lookup should point to the account that is part of the affiliation we created
		affl1 = [select Affiliation_Type__c from Affiliation__c where ID = :affl1.ID];
		System.assertEquals('Business Organization', affl1.Affiliation_Type__c);
		
		contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(acc1.ID, Contact.Primary_Organization__c);
		
		//Create second account of the same record type
		Test.startTest();
		AFFL_MultiRecordType_TDTM.afflMultiHasRun = false;
		
		Account acc2 = new Account(Name='Toys Inc', RecordTypeId = orgRecTypeID);
    	insert acc2;
		
		//Create second primary affiliation
		Affiliation__c affl2 = new Affiliation__c(Contact__c = contact.ID, Organization__c = acc2.ID, Primary__c = true);
		insert affl2;
		Test.stopTest();
		
		//The previous affiliation should not be the primary any more
		affl1 = [select Primary__c from Affiliation__c where ID = :affl1.ID];
		System.assertEquals(false, affl1.Primary__c);
		
		//The business organization lookup should point to the account that is part of the second affiliation we created
		contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(acc2.ID, Contact.Primary_Organization__c);
	}
}