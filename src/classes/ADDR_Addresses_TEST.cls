@isTest	
public class ADDR_Addresses_TEST {
  
	@isTest
    public static void deleteAddressTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                                                                               Contacts_Addresses_Enabled__c = true));
        
        //Retrieves the defaultTDTMconfig 
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getDefaultTdtmConfig(); 
        
        UTIL_UnitTestData_TEST.ContactsWithAddrs contactsAddrs = UTIL_UnitTestData_TEST.createTestContactsAddrs(2);
        List<Contact> contacts = contactsAddrs.contacts; 
        
        //Update address
        for (Integer i = 0; i < contactsAddrs.addrs.size(); i++) {
            Address__c addr = contactsAddrs.addrs[i];
            if (i == 1) {
                addr.MailingCity__c = 'Brooklyn' + i;
            }
        }
         
        update contactsAddrs.addrs;
        
		List<Address__c> addresses = contactsAddrs.addrs;
        
        List<Contact> cons = [SELECT Id, Current_Address__c, MailingCity FROM Contact WHERE Id IN :contacts]; 
        System.assertEquals(2, cons.size()); 
        System.assertEquals(addresses[0].Id, cons[0].Current_Address__c);
        System.assertEquals(addresses[0].MailingCity__c, cons[0].MailingCity);
        
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.className == 'ADDR_Addresses_TDTM') {
		        token.filterField = 'MailingCity__c';
                token.filterValue = 'Brooklyn1';
            }
		}
        
        TDTM_Global_API.setTdtmConfig(tokens);
        
        Test.startTest();
        delete addresses; 
        Test.stopTest(); 
        
        List<Address__c> returnAddresses = [SELECT Id FROM Address__c WHERE Id IN :addresses]; 
        System.assertEquals(0, returnAddresses.size()); 
        
        List<Contact> returnCons = [SELECT Id, Current_Address__c, MailingCity, MailingAddress FROM Contact WHERE Id IN :contacts];
        System.debug('TestClass returnCon -->' + returnCons);
        System.assertNOTEquals(NULL, returnCons[1].MailingAddress);
        System.assertEquals(NULL, returnCons[1].Current_Address__c);
        
    }
}