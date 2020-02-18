@isTest	
public class ADDR_Addresses_TEST {
	@isTest
    public static void deleteAddress() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID(),
                                                                               Contacts_Addresses_Enabled__c = true));
        
        //Create the triggerHandler record with no filter value 
        Trigger_Handler__c th = new Trigger_Handler__c(
            Class__c = 'ADDR_Addresses_TDTM', 
            Trigger_Action__c = 'BeforeInsert; BeforeUpdate; AfterInsert; AfterUpdate; AfterDelete',
            Active__c = TRUE,
            Object__c = 'Address__c',
            Load_Order__c = 1,
            Owned_by_Namespace__c = 'hed'
        ); 
        
        insert th; 
 
        Contact con = UTIL_UnitTestData_API.getContact();
        insert con;
        
        Address__c address = new Address__c (Parent_Contact__c = con.Id, Default_Address__c = true, MailingStreet__c = '1 Summer St', MailingCity__c = 'Brooklyn'); 
        insert address; 
        
        con.MailingCity = address.MailingCity__c;
        con.Current_Address__c = address.Id; 
        update con; 
        
        Contact c = [SELECT Id, Current_Address__c, MailingCity FROM Contact WHERE Id = :con.Id]; 
        System.assertEquals(address.Id, c.Current_Address__c);
        System.assertEquals(address.MailingCity__c, c.MailingCity);
        
        //Update the triggerHandler filter value 
        th.Filter_Field__c = 'MailingCity__c';
        th.Filter_Value__c = 'Brooklyn';
        update th; 
        
        Trigger_Handler__c returnTH = [SELECT Id, Filter_Value__c, Filter_Field__c FROM Trigger_Handler__c WHERE Id = :th.Id]; 
        System.assertNOTEquals(NULL, returnTH.Filter_Field__c);
        System.assertNOTEquals(NULL, returnTH.Filter_Value__c);
        System.debug('returnTH -->' + returnTH); 
        
        Test.startTest();
        delete address; 
        Test.stopTest(); 
        
        Contact returnCon = [SELECT Id, Current_Address__c, MailingCity, MailingAddress FROM Contact WHERE Id = :con.Id];
        System.debug('returnCon -->' + returnCon);
        System.assertNOTEquals(NULL, returnCon.MailingAddress);
        System.assertEquals(NULL, returnCon.Current_Address__c);

    }
}