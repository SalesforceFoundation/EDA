@isTest
public with sharing class CON_PrimaryAffls_TEST {
    
    private static ID orgRecTypeID;
    private static ID householdRecTypeID;
    
    // if you only want to run one test in this class, fill in its name here.
    // if you want to run all tests, then use '*'
    private static string strTestOnly = '*';
    
    public static void setup() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR, 
                                                                                Automatic_Affiliation_Creation_Turned_On__c = true));
                
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', Primary_Affl_Field__c = 'Primary Business Organization'));  
        mappings.add(new Affl_Mappings__c(Name = 'Household Account', Account_Record_Type__c = 'Household Account', Primary_Affl_Field__c = 'Primary Household'));
        insert mappings;
        
        orgRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
        householdRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
    }
    
    @isTest
    public static void newContactWithPrimaryAfflField() {
        if (strTestOnly != '*' && strTestOnly != 'newContactWithPrimaryAfflField') return;
        
        setup();
        
        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        //Create contact with value in Primary Business Organization field
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson', Primary_Organization__c = bizOrg1.ID);
        Test.startTest();
        insert contact;
        Test.stopTest();
        
        //Verify key business affiliation has been automatically created
        List<Affiliation__c> affls = [select Affiliation_Type__c, Account__c, Primary__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Business Organization', affls[0].Affiliation_Type__c);
        System.assertEquals(true, affls[0].Primary__c);
    }
    
    @isTest
    public static void addingValToExistingPrimaryAfflField() {
        if (strTestOnly != '*' && strTestOnly != 'addingValToExistingPrimaryAfflField') return;
        
        setup();
        
        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        //Create contact without value in Primary Business Organization field
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson');
        insert contact;
        
        //No business affiliation should have been created
        List<Affiliation__c> affls = [select Affiliation_Type__c, Account__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        
        //Set primary affl field
        Test.startTest();
        contact.Primary_Organization__c = bizOrg1.ID;
        Test.startTest();
        
        //Verify key business affiliation has been automatically created
        affls = [select Affiliation_Type__c, Account__c, Primary__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Business Organization', affls[0].Affiliation_Type__c);
        System.assertEquals(true, affls[0].Primary__c);
    }
    
    @isTest
    public static void changingPrimaryAfflField() {
        if (strTestOnly != '*' && strTestOnly != 'changingPrimaryAfflField') return;
        
        setup();
        
        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        //Create contact with value in Primary Business Organization field
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson', Primary_Organization__c = bizOrg1.ID);
        insert contact;
        
        //Verify key business affiliation has been automatically created
        List<Affiliation__c> affls = [select Affiliation_Type__c, Account__c, Primary__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        Affiliation__c affl1 = affls[0];
        System.assertEquals('Business Organization', affl1.Affiliation_Type__c);
        System.assertEquals(true, affl1.Primary__c);
        
        //Create second Business Organization
        Account bizOrg2 = new Account(Name='Acme 2', RecordTypeId = orgRecTypeID);
        insert bizOrg2;
        
        //update key Business Organization field in Contact
        contact.Primary_Organization__c = bizOrg2.ID;
        Test.startTest();
        update contact;
        Test.stopTest();
        
        //Verify previous Affiliation has been made non-primary
        affl1 = [select Primary__c from Affiliation__c where ID = : affl1.ID];
        System.assertEquals(false, affl1.Primary__c);
        
        //Verify new Affiliation has been created and made primary
        affls = [select Affiliation_Type__c, Account__c, Primary__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Business Organization', affls[0].Affiliation_Type__c);
        System.assertEquals(true, affls[0].Primary__c);
    }
    
    @isTest
    public static void clearingPrimaryAfflField() {
        if (strTestOnly != '*' && strTestOnly != 'clearingPrimaryAfflField') return;
        
        setup();
        
        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;

        //Create contact with value in Primary Business Organization field
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson', Primary_Organization__c = bizOrg1.ID);
        insert contact;
        
        //Verify key business affiliation has been automatically created
        List<Affiliation__c> affls = [select Affiliation_Type__c, Account__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Business Organization', affls[0].Affiliation_Type__c);
        
        //update key Business Organization field in Contact
        contact.Primary_Organization__c = null;
        Test.startTest();
        update contact;
        Test.stopTest();
        
        //Verify key business affiliation has been changed to non-primary
        affls = [select Affiliation_Type__c, Account__c, Primary__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(1, affls.size());
        System.assertEquals('Business Organization', affls[0].Affiliation_Type__c);
        System.assertEquals(false, affls[0].Primary__c);
    }
    
    @isTest
    public static void invalidFieldName() {
        if (strTestOnly != '*' && strTestOnly != 'invalidFieldName') return;
        
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR, 
                                                                                Automatic_Affiliation_Creation_Turned_On__c = true));
                
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(new Affl_Mappings__c(Name = 'Business Organization', Account_Record_Type__c = 'Business Organization', 
                                            Primary_Affl_Field__c = 'Primary Invalid Field'));  
        insert mappings;
        
        orgRecTypeID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Business Organization').getRecordTypeId();
        
        //Create account of Business Organization record type
        Account bizOrg1 = new Account(Name='Acme', RecordTypeId = orgRecTypeID);
        insert bizOrg1;
        
        //Create contact with value in Primary Business Organization field
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Testerson', Primary_Organization__c = bizOrg1.ID);
        Test.startTest();
        insert contact;
        Test.stopTest();
        
        //Verify no key business affiliation has been automatically created
        List<Affiliation__c> affls = [select Affiliation_Type__c, Account__c from Affiliation__c where Contact__c = :contact.ID 
                                        and Account__c = :bizOrg1.ID];
        System.assertEquals(0, affls.size());
    }
}