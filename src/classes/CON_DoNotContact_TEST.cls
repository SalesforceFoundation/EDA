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

    /**************************************************************************************************************************
    * Tests inserting a Contact as deceased to verify DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax and naming 
    * exclusions are set.
    */

    @isTest
    private static void insertDeceasedContact() {

        Contact contact = UTIL_UnitTestData_TEST.getContact();
        contact.Deceased__c = true;

        Test.startTest();
            insert contact;
        Test.stopTest();

        Contact contactAfterInserted = [SELECT Do_Not_Contact__c, Exclude_from_Household_Name__c, Exclude_from_Household_Formal_Greeting__c,
                                        Exclude_from_Household_Informal_Greeting__c, HasOptedOutOfEmail, DoNotCall, HasOptedOutOfFax, 
                                        Naming_Exclusions__c FROM CONTACT WHERE Id =: contact.Id];

        System.assertEquals(true, contactAfterInserted.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
        System.assertEquals(true, contactAfterInserted.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(true, contactAfterInserted.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(true, contactAfterInserted.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
        System.assertEquals(true, contactAfterInserted.HasOptedOutOfEmail, 'Contact should be opted out of fax.');
        System.assertEquals(true, contactAfterInserted.HasOptedOutOfFax, 'Contact should be opted out of fax.');
        System.assertEquals(true, contactAfterInserted.DoNotCall, 'Contact should be opted out of phone calls.');
        System.assertEquals(true, contactAfterInserted.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
        System.assertEquals(true, contactAfterInserted.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
        System.assertEquals(true, contactAfterInserted.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');

    }

    /**************************************************************************************************************************
    * Tests Updating a deceased Contact as False to verify DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax and naming 
    * exclusions are re-set.
    */

    @isTest
    private static void updateContactDeceasedToFalse() {

        Contact contact = UTIL_UnitTestData_TEST.getContact();
        contact.Deceased__c = true;

        insert contact;

        Contact contactAfterInserted = [SELECT Do_Not_Contact__c, Exclude_from_Household_Name__c, Exclude_from_Household_Formal_Greeting__c,
                                        Exclude_from_Household_Informal_Greeting__c, HasOptedOutOfEmail, HasOptedOutOfFax, DoNotCall, Naming_Exclusions__c 
                                        FROM CONTACT WHERE Id =: contact.Id];

        System.assertEquals(true, contactAfterInserted.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
        System.assertEquals(true, contactAfterInserted.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(true, contactAfterInserted.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(true, contactAfterInserted.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
        System.assertEquals(true, contactAfterInserted.HasOptedOutOfEmail, 'Contact should be opted out of email.');
        System.assertEquals(true, contactAfterInserted.DoNotCall, 'Contact should be opted out of phone calls.');
        System.assertEquals(true, contactAfterInserted.HasOptedOutOfFax, 'Contact should be opted out of fax.');
        System.assertEquals(true, contactAfterInserted.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
        System.assertEquals(true, contactAfterInserted.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
        System.assertEquals(true, contactAfterInserted.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');

        Test.startTest();
            contactAfterInserted.Deceased__c = false;
            update contactAfterInserted;
        Test.stopTest();

        Contact contactAfterUpdate = [SELECT Do_Not_Contact__c, Exclude_from_Household_Name__c, Exclude_from_Household_Formal_Greeting__c,
                                      Exclude_from_Household_Informal_Greeting__c, HasOptedOutOfEmail, DoNotCall, HasOptedOutOfFax, Naming_Exclusions__c 
                                      FROM CONTACT WHERE Id =: contactAfterInserted.Id];

        System.assertEquals(false, contactAfterUpdate.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
        System.assertEquals(false, contactAfterUpdate.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
        System.assertEquals(false, contactAfterUpdate.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
        System.assertEquals(false, contactAfterUpdate.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
        System.assertEquals(false, contactAfterUpdate.HasOptedOutOfEmail, 'ontact should not be opted out of email.');
        System.assertEquals(false, contactAfterUpdate.DoNotCall, 'Contact should not be opted out of phone calls.');
        System.assertEquals(false, contactAfterUpdate.HasOptedOutOfFax, 'Contact should not be opted out of fax.');
        System.assertEquals(null, contactAfterUpdate.Naming_Exclusions__c, 'Naming Exclusion field should be cleared.');

    }

    /**************************************************************************************************************************
    * Tests Updating a Contact to deceased to verify DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax and naming 
    * exclusions are set.
    */

    @isTest
    private static void updateContactDeceasedToTrue() {

        Contact contact = UTIL_UnitTestData_TEST.getContact();
        insert contact;

        Contact contactAfterInserted = [SELECT Do_Not_Contact__c, Exclude_from_Household_Name__c, Exclude_from_Household_Formal_Greeting__c,
                                        Exclude_from_Household_Informal_Greeting__c, HasOptedOutOfEmail, HasOptedOutOfFax, DoNotCall, Naming_Exclusions__c 
                                        FROM CONTACT WHERE Id =: contact.Id];

        System.assertEquals(false, contactAfterInserted.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
        System.assertEquals(false, contactAfterInserted.Exclude_from_Household_Name__c, 'Contact should not be excluded from Household Naming.');
        System.assertEquals(false, contactAfterInserted.Exclude_from_Household_Formal_Greeting__c, 'Contact should not be excluded from Household Formal Greeting.');
        System.assertEquals(false, contactAfterInserted.Exclude_from_Household_Informal_Greeting__c, 'Contact should not be excluded from Household Informal Greeting.');
        System.assertEquals(false, contactAfterInserted.HasOptedOutOfEmail, 'Contact should not be opted out of email.');
        System.assertEquals(false, contactAfterInserted.HasOptedOutOfFax, 'Contact should not be opted out of fax.');
        System.assertEquals(false, contactAfterInserted.DoNotCall, 'Contact should not be opted out of phone calls.');
        System.assertEquals(null, contactAfterInserted.Naming_Exclusions__c, 'Naming Exclusion field should be blank.');

        Test.startTest();
            contactAfterInserted.Deceased__c = true;
            update contactAfterInserted;
        Test.stopTest();

        Contact contactAfterUpdate = [SELECT Do_Not_Contact__c, Exclude_from_Household_Name__c, Exclude_from_Household_Formal_Greeting__c,
                                      Exclude_from_Household_Informal_Greeting__c, HasOptedOutOfEmail, HasOptedOutOfFax, DoNotCall, Naming_Exclusions__c 
                                      FROM CONTACT WHERE Id =: contactAfterInserted.Id];

        System.assertEquals(true, contactAfterUpdate.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
        System.assertEquals(true, contactAfterUpdate.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(true, contactAfterUpdate.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(true, contactAfterUpdate.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Informal Greeting.');
        System.assertEquals(true, contactAfterUpdate.HasOptedOutOfEmail, 'Contact should not be opted out of email.');
        System.assertEquals(true, contactAfterUpdate.HasOptedOutOfFax, 'Contact should be opted out of fax.');
        System.assertEquals(true, contactAfterUpdate.DoNotCall, 'Contact should be opted out of phone calls.');
        System.assertEquals(true, contactAfterUpdate.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
        System.assertEquals(true, contactAfterUpdate.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
        System.assertEquals(true, contactAfterUpdate.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');

    }

    /**************************************************************************************************************************
    * Tests Inserting a deceased Contact to verify DoNotCall, HasOptedOutOfEmail and HasOptedOutOfFax are set
    */

    @isTest
    private static void doNotContactOnInsert() {

        Contact contact = UTIL_UnitTestData_TEST.getContact();
        contact.do_not_contact__c = true;

        Test.startTest();
            insert contact;
        Test.stopTest();

        Contact contactAfterInsert = [SELECT DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax FROM Contact WHERE Id =: contact.Id];
        System.assertEquals(true, contactAfterInsert.DoNotCall, 'Contact should be opted out of phone calls.');
        System.assertEquals(true, contactAfterInsert.HasOptedOutOfEmail, 'Contact should be opted out of email.');
        System.assertEquals(true, contactAfterInsert.HasOptedOutOfFax, 'Contact should be opted out of fax.');
    }

    /**************************************************************************************************************************
    * Tests Updating a Contact to Do Not Contact to verify DoNotCall, HasOptedOutOfEmail and HasOptedOutOfFax are set
    */

    @isTest
    private static void updateDoNotContactTotrue() {

        Contact contact = UTIL_UnitTestData_TEST.getContact();
        insert contact;

        Test.startTest();
            contact.do_not_contact__c = true;
            update contact;
        Test.stopTest();

        Contact contactAfterUpdate = [SELECT DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax FROM Contact WHERE Id =: contact.Id];
        System.assertEquals(true, contactAfterUpdate.DoNotCall, 'Contact should be opted out of phone calls.');
        System.assertEquals(true, contactAfterUpdate.HasOptedOutOfEmail, 'Contact should  be opted out of email.');
        System.assertEquals(true, contactAfterUpdate.HasOptedOutOfFax, 'Contact should be opted out of fax.');
    }

    /****************************************************************************************************************************
    * Tests Updating a Contact's Do Not Contact to False, to verify DoNotCall, HasOptedOutOfEmail and HasOptedOutOfFax are re-set
    */

    @isTest
    private static void updateDoNotContactToFalse() {

        Contact contact = UTIL_UnitTestData_TEST.getContact();
        contact.do_not_contact__c = true;

        insert contact;

        Contact contactAfterInsert = [SELECT DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax FROM Contact WHERE Id =: contact.Id];

        System.assertEquals(true, contactAfterInsert.DoNotCall, 'Contact should be opted out of phone calls.');
        System.assertEquals(true, contactAfterInsert.HasOptedOutOfEmail, 'Contact should  be opted out of fax.');
        System.assertEquals(true, contactAfterInsert.HasOptedOutOfFax, 'Contact should be opted out of fax.');

        Test.startTest();
            contactAfterInsert.do_not_contact__c = false;
            update contactAfterInsert;
        Test.stopTest();

        Contact contactAfterUpdate = [SELECT DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax FROM Contact WHERE Id =: contactAfterInsert.Id];
        System.assertEquals(false, contactAfterUpdate.DoNotCall, 'Contact should not be opted out of phone calls.');
        System.assertEquals(false, contactAfterUpdate.HasOptedOutOfFax, 'Contact should not be opted out of fax.');
        System.assertEquals(false, contactAfterUpdate.HasOptedOutOfEmail, 'Contact should not be opted out of email.');
    }

    /**************************************************************************************************************************************
    * Tests Updating a Deceased Contact's Do Not Contact to False, to verify DoNotCall, HasOptedOutOfEmail and HasOptedOutOfFax are re-set
    */

    @isTest
    private static void updateDoNotContactToFalseOnADeceasedContact() {

        Contact contact = UTIL_UnitTestData_TEST.getContact();
        contact.Deceased__c = true;

        insert contact;

        Contact contactAfterInserted = [SELECT Do_Not_Contact__c, Exclude_from_Household_Name__c, Exclude_from_Household_Formal_Greeting__c,
                                        Exclude_from_Household_Informal_Greeting__c, HasOptedOutOfEmail, HasOptedOutOfFax, DoNotCall, Naming_Exclusions__c 
                                        FROM CONTACT WHERE Id =: contact.Id];

        System.assertEquals(true, contactAfterInserted.Do_Not_Contact__c, 'Contact should be marked as Do Not Contact.');
        System.assertEquals(true, contactAfterInserted.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(true, contactAfterInserted.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(true, contactAfterInserted.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household InFormal Greeting.');
        System.assertEquals(true, contactAfterInserted.HasOptedOutOfEmail, 'Contact should be opted out of Email.');
        System.assertEquals(true, contactAfterInserted.HasOptedOutOfEmail, 'Contact should be opted out of Fax.');
        System.assertEquals(true, contactAfterInserted.DoNotCall, 'Contact should be opted out of phone calls.');
        System.assertEquals(true, contactAfterInserted.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
        System.assertEquals(true, contactAfterInserted.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
        System.assertEquals(true, contactAfterInserted.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Naming Exclusions field should include Household Informal Greeting.');

        Test.startTest();
            contactAfterInserted.do_not_contact__c = false;
            update contactAfterInserted;
        Test.stopTest();

        Contact contactAfterUpdate = [SELECT DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax,Do_Not_Contact__c, Exclude_from_Household_Name__c,
                                      Exclude_from_Household_Formal_Greeting__c, Exclude_from_Household_Informal_Greeting__c,
                                      Naming_Exclusions__c FROM Contact WHERE Id =: contactAfterInserted.Id];

        System.assertEquals(false, contactAfterUpdate.Do_Not_Contact__c, 'Contact should not be marked as Do Not Contact.');
        System.assertEquals(false, contactAfterUpdate.DoNotCall, 'Contact should not be opted out of phone calls.');
        System.assertEquals(false, contactAfterUpdate.HasOptedOutOfEmail, 'Contact should not be opted out of Email.');
        System.assertEquals(false, contactAfterUpdate.HasOptedOutOfFax, 'Contact should not be opted out of Fax.');
        System.assertEquals(true, contactAfterUpdate.Exclude_from_Household_Name__c, 'Contact should be excluded from Household Naming.');
        System.assertEquals(true, contactAfterUpdate.Exclude_from_Household_Formal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(true, contactAfterUpdate.Exclude_from_Household_Informal_Greeting__c, 'Contact should be excluded from Household Formal Greeting.');
        System.assertEquals(true, contactAfterUpdate.Naming_Exclusions__c.contains('Household__c.Name'), 'Naming Exclusions field should include Household Name.');
        System.assertEquals(true, contactAfterUpdate.Naming_Exclusions__c.contains('Household__c.Formal_Greeting__c'), 'Naming Exclusions field should include Household Formal Greeting.');
        System.assertEquals(true, contactAfterUpdate.Naming_Exclusions__c.contains('Household__c.Informal_Greeting__c'), 'Contact should be excluded from Household Informal Greeting.');
    }
}