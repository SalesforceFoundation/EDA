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
/**
* @author Salesforce.org
* @date 2015
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Tests for the Preferred Contact functionality.
*/
@isTest
public with sharing class CON_Preferred_TEST {

    @isTest
    public static void preferredEmailPhoneInsert() {
    
        Test.testInstall(new STG_InstallScript(), null);
        List<trigger_handler__c> preferredPhoneHandler = [SELECT id, class__c, active__c FROM trigger_handler__c WHERE class__c = 'CON_PreferredPhone_TDTM' AND Object__c = 'Contact'];
        
        System.assertEquals(1,preferredPhoneHandler.size());
        System.assertEquals(true, preferredPhoneHandler[0].active__c);
      
        if (preferredPhoneHandler != NULL && preferredPhoneHandler.size() > 0) {
        
            preferredPhoneHandler[0].active__c = false;
            update preferredPhoneHandler[0];
        
        }
        
        Contact contact1 = new Contact(LastName = 'TestersonA', UniversityEmail__c = 'fake@test1.com', Preferred_Email__c = 'University', 
            HomePhone = '555-432-4433', PreferredPhone__c = 'Home');
        Contact contact2 = new Contact(LastName = 'TestersonB', WorkEmail__c = 'fake@test2.com', Preferred_Email__c = 'Work', 
            WorkPhone__c = '555-432-4433', PreferredPhone__c = 'Work');
        Contact contact3 = new Contact(LastName = 'TestersonC', AlternateEmail__c = 'fake@test3.com', Preferred_Email__c = 'Alternate', 
            OtherPhone = '555-432-4433', PreferredPhone__c = 'Other');
        Contact contact4 = new Contact(LastName = 'TestersonD', AlternateEmail__c = 'fake@test4.com',Preferred_Email__c = 'Alternate',
            MobilePhone = '555-432-4433', PreferredPhone__c = 'Mobile');
            
        List<Contact> contacts = new Contact[]{contact1, contact2, contact3, contact4};
        Test.startTest();
        insert contacts;
        Test.stopTest();
        
        contacts = [SELECT Email, LastName, Phone, UniversityEmail__c, WorkEmail__c, AlternateEmail__c, HomePhone, WorkPhone__c, OtherPhone, MobilePhone 
                    FROM Contact where ID in :contacts];
        
        //ensure we can retrieve the contacts in a specific order/know which contact we are comparing
        //can no longer user Name in filters if we want to be Shield compatible
        Map<String, Contact> contactsByLastName = new Map<String, Contact>();
        for(Contact c : contacts) {
            contactsByLastName.put(c.LastName, c);
        }
        contact1 = contactsByLastName.get('TestersonA');
        contact2 = contactsByLastName.get('TestersonB');
        contact3 = contactsByLastName.get('TestersonC');
        contact4 = contactsByLastName.get('TestersonD');
        
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
    
        Test.testInstall(new STG_InstallScript(), null);
        List<trigger_handler__c> preferredPhoneHandler = [SELECT id, name, active__c FROM trigger_handler__c WHERE class__c = 'CON_PreferredPhone_TDTM' AND Object__c = 'Contact'];
        
        if (preferredPhoneHandler != NULL && preferredPhoneHandler.size() > 0) {
        
            preferredPhoneHandler[0].active__c = false;
            update preferredPhoneHandler[0];
        
        }
        
        // Preferred email is required to pass checks in preferred trigger
        Contact contact1 = new Contact(LastName = 'TestersonE', UniversityEmail__c = 'fake@test5.com', HomePhone = '555-432-4433',Preferred_Email__c = 'University');
        Contact contact2 = new Contact(LastName = 'TestersonF', WorkEmail__c = 'fake@test6.com', WorkPhone__c = '555-432-4433',Preferred_Email__c = 'Work');
        Contact contact3 = new Contact(LastName = 'TestersonG', AlternateEmail__c = 'fake@test7.com', OtherPhone = '555-432-4433',Preferred_Email__c = 'Alternate');
        Contact contact4 = new Contact(LastName = 'TestersonH', MobilePhone = '555-432-4433');
            
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
                
        contacts = [SELECT Email, LastName, Phone, UniversityEmail__c, WorkEmail__c, AlternateEmail__c, HomePhone, WorkPhone__c, OtherPhone, MobilePhone 
                    FROM Contact where ID in :contacts];
        
        //ensure we can retrieve the contacts in a specific order/know which contact we are comparing
        //can no longer user Name in filters if we want to be Shield compatible
        Map<String, Contact> contactsByLastName = new Map<String, Contact>();
        for(Contact c : contacts) {
            contactsByLastName.put(c.LastName, c);
        }
        contact1 = contactsByLastName.get('TestersonE');
        contact2 = contactsByLastName.get('TestersonF');
        contact3 = contactsByLastName.get('TestersonG');
        contact4 = contactsByLastName.get('TestersonH');
        
        System.assertEquals(contact1.UniversityEmail__c, contact1.Email);
        System.assertEquals(contact2.WorkEmail__c, contact2.Email);
        System.assertEquals(contact3.AlternateEmail__c, contact3.Email);
        
        System.assertEquals(contact1.HomePhone, contact1.Phone);
        System.assertEquals(contact2.WorkPhone__c, contact2.Phone);
        System.assertEquals(contact3.OtherPhone, contact3.Phone);
        System.assertEquals(contact4.MobilePhone, contact4.Phone);
    }
}
