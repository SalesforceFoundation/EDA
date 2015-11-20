/*
    Copyright (c) 2014, Salesforce.org
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
* @description Handles changes to the deceased and do not contact fields on Contact.
*/
@isTest
private class CON_DoNotContact_TEST {

    /*******************************************************************************************************
    * @description Marks a contact as Deceased, verifies DoNotCall, HasOptedOutOfEmail, and naming 
    * exclusions are set. Removes deceased flag, verifies DoNotCall, HasOptedOutOfEmail, and naming 
    * exclusion have been removed.
    */
    static testMethod void testDeceased() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c (Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));    
        
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

    /*******************************************************************************************************
    * @description Marks a contact as Do Not Contact, verifies DoNotCall and HasOptedOutOfEmail are set.
    * Removes Do Not Contact flag, verifies DoNotCall and HasOptedOutOfEmail are no longer set.
    */
    static testMethod void testDoNotContact() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c (Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR));
        
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