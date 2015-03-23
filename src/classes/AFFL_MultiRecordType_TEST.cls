@isTest
public with sharing class AFFL_MultiRecordType_TEST {
	
	@isTest
	public static void createPrimaryAffl() {    
		List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
    	mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));	
    	mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
    	insert mappings;
    	
    	ID orgRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
    	ID householdRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
    	
    	Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
    	insert contact;
    	Account acc1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
    	insert acc1;
    	
		Affiliation__c affl1 = new Affiliation__c(Contact__c = contact.ID, Organization__c = acc1.ID, Primary__c = true);
		insert affl1;
		
		affl1 = [select Affiliation_Type__c from Affiliation__c where ID = :affl1.ID];
		System.assertEquals('Business Organization', affl1.Affiliation_Type__c);
		
		contact = [select Primary_Organization__c from Contact where ID = :contact.ID];
		System.assertEquals(acc1.ID, Contact.Primary_Organization__c);
	}
}