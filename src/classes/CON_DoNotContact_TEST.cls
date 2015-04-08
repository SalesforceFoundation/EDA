@isTest
private class CON_DoNotContact_TEST {

    static testMethod void testDeceased() {
        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));    
        
        Contact con = new Contact(LastName = CAO_Constants.CONTACT_LASTNAME_FOR_TESTS);
        insert con;

        list<Contact> queryCon = [SELECT Id, HasOptedOutOfEmail, DoNotCall, Naming_Exclusions__c FROM Contact WHERE Id = :con.id];
        system.assertEquals(null, queryCon[0].Naming_Exclusions__c, 'Naming Exclusions field should be null.');
        system.assert(!queryCon[0].HasOptedOutOfEmail, 'Contact should not be opted out of email.');

        //RIP
        queryCon[0].Deceased__c = true;
        //verify that checking both in one transaction won't change behavior
        queryCon[0].Do_Not_Contact__c = true;
        update queryCon[0];

        queryCon = [SELECT Id, HasOptedOutOfEmail, DoNotCall, Naming_Exclusions__c FROM Contact WHERE Id = :con.id];
        system.assert(queryCon[0].Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
        system.assert(queryCon[0].Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
        system.assert(queryCon[0].Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');
        system.assert(queryCon[0].HasOptedOutOfEmail, 'Contact should be opted out of email.');

        //he is risen
        queryCon[0].Deceased__c = false;
        update queryCon[0];

        queryCon = [SELECT Id, HasOptedOutOfEmail, DoNotCall, Naming_Exclusions__c FROM Contact WHERE Id = :con.id];
        system.assertEquals(null, queryCon[0].Naming_Exclusions__c, 'Naming Exclusions field should be null.');
        system.assert(!queryCon[0].HasOptedOutOfEmail, 'Contact should not be opted out of email.');
    }

    static testMethod void testDoNotContact() {
        UTIL_CustomSettingsFacade.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
        
        Contact con = new Contact(LastName = CAO_Constants.CONTACT_LASTNAME_FOR_TESTS);
        insert con;

        list<Contact> queryCon = [SELECT Id, HasOptedOutOfEmail, DoNotCall, Naming_Exclusions__c FROM Contact WHERE Id = :con.id];
        system.assert(!queryCon[0].DoNotCall, 'Contact should not be opted out of phone calls.');
        system.assert(!queryCon[0].HasOptedOutOfEmail, 'Contact should not be opted out of email.');

        queryCon[0].Do_Not_Contact__c = true;
        update queryCon[0];

        queryCon = [SELECT Id, HasOptedOutOfEmail, DoNotCall, Naming_Exclusions__c FROM Contact WHERE Id = :con.id];
        system.assert(queryCon[0].DoNotCall, 'Contact should be opted out of phone calls.');
        system.assert(queryCon[0].HasOptedOutOfEmail, 'Contact should be opted out of email.');

        queryCon[0].Do_Not_Contact__c = false;
        update queryCon[0];

        queryCon = [SELECT Id, HasOptedOutOfEmail, DoNotCall, Naming_Exclusions__c FROM Contact WHERE Id = :con.id];
        system.assert(!queryCon[0].DoNotCall, 'Contact should not be opted out of phone calls.');
        system.assert(!queryCon[0].HasOptedOutOfEmail, 'Contact should not be opted out of email.');
    }	
}