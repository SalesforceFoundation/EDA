/*
    Copyright (c) 2019, Salesforce.org
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
 * @date 2019
 * @group Contacts
 * @group-content ../../ApexDocContent/Contacts.htm
 * @description Unit tests for Preferred Phone
 */
@isTest
private class CON_PreferredPhone_TEST {
    private static Hierarchy_Settings__c enablePreferredPhone() {
        return UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Disable_Preferred_Phone_Enforcement__c = false,
                Enable_New_Preferred_Phone_Sync__c = true
            )
        );
    }

    private static Hierarchy_Settings__c disablePreferredPhone() {
        return UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(
                Disable_Preferred_Phone_Enforcement__c = true,
                Enable_New_Preferred_Phone_Sync__c = false
            )
        );
    }

    /* When Preferred Phone is blank and the count of valued phone fields is one
        update Preferred Phone to label of valued phone and copy the value to 
        standard Phone.
    */
    @isTest
    static void testSinglePhoneSmartSet() {
        enablePreferredPhone();

        Contact newCont = new Contact(FirstName = 'JohnnyTest1', LastName = 'JohnnyTest', WorkPhone__c = '1234567890');

        Test.startTest();
        insert newCont;
        Test.stopTest();

        Contact newContAfter = [
            SELECT Id, FirstName, LastName, Name, WorkPhone__c, Phone, PreferredPhone__c
            FROM Contact
        ];

        System.assertEquals(newContAfter.Phone, newContAfter.WorkPhone__c);
        System.assertEquals('Work Phone', newContAfter.PreferredPhone__c);
    }

    /* When Preferred Phone is defined and the count of valued phone fields is more
        then one, the Preferred Phone field will be used.
        Test Scenario: T-3903365
    */
    @isTest
    static void testMultiplePhoneSmartSetEnforced() {
        enablePreferredPhone();

        Test.startTest();
        insert new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            WorkPhone__c = '1234567890',
            HomePhone = '2345678901',
            OtherPhone = '3456789012',
            PreferredPhone__c = 'Work Phone'
        );
        Test.stopTest();

        Contact newContAfter = getCurrentContact();
        System.assertEquals(newContAfter.Phone, newContAfter.WorkPhone__c);
        System.assertEquals('Work Phone', newContAfter.PreferredPhone__c);
    }

    /*
     * When Preferred Phone is blank and the count of valued phone fields is one
     * update Preferred Phone to label of valued phone and copy the value to
     * standard Phone.
     * Test Scenario: T-3903367
     */
    @isTest
    static void testMultiplePhoneSmartSetUnenforced() {
        disablePreferredPhone();

        Test.startTest();
        insert new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            HomePhone = '2345678901',
            WorkPhone__c = '1234567890',
            OtherPhone = '3456789012',
            PreferredPhone__c = 'Other Phone'
        );
        Test.stopTest();

        Contact newContAfter = getCurrentContact();
        System.assertEquals(newContAfter.Phone, newContAfter.OtherPhone);

        newContAfter.PreferredPhone__c = 'Work Phone';
        update newContAfter;
        newContAfter = getCurrentContact();

        System.assertEquals(newContAfter.Phone, newContAfter.WorkPhone__c);
    }

    /* When Standard Phone is not null and Preferred Phone is enforced update Preferred Phone
       to Other and update Other Phone to the value of Standard Phone.
    */
    @isTest
    static void testUpdatePrefPhoneToOther() {
        enablePreferredPhone();

        Contact newCont = new Contact(FirstName = 'JohnnyTest1', LastName = 'JohnnyTest');
        insert newCont;

        Test.startTest();
        newCont.Phone = '0000000000';
        update newCont;
        Test.stopTest();

        Contact newContAfter = getCurrentContact();
        System.assertEquals('0000000000', newContAfter.OtherPhone);
        System.assertEquals('Other Phone', newContAfter.PreferredPhone__c);
    }

    /* Clear the value in Standard Phone when the other valued Phone is cleared
     *  Test Scenario: T-3903368
     */
    @isTest
    static void testClearPhoneValue() {
        enablePreferredPhone();

        insert new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            Phone = '111111111',
            HomePhone = '2345678901',
            WorkPhone__c = '1234567890',
            OtherPhone = '3456789012',
            PreferredPhone__c = 'Work Phone'
        );

        Contact newContAfter = getCurrentContact();
        Test.startTest();
        newContAfter.WorkPhone__c = 'JJJJJ';
        update newContAfter;
        Test.stopTest();

        newContAfter = getCurrentContact();
        System.assertEquals('JJJJJ', newContAfter.Phone);
    }

    /* Update standard Phone's value to another valued phone's and update Preferred Phone to
     the label of another Phone.  */
    @isTest
    static void testOnClearOther() {
        enablePreferredPhone();

        Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            WorkPhone__c = '111111111',
            PreferredPhone__c = 'Work Phone',
            OtherPhone = '0000000000'
        );
        insert newCont;

        Contact newContAfter = getCurrentContact();
        Test.startTest();
        newContAfter.WorkPhone__c = '';
        newContAfter.PreferredPhone__c = '';
        update newContAfter;
        Test.stopTest();

        newContAfter = getCurrentContact();
        System.assertEquals('Other Phone', newContAfter.PreferredPhone__c);
        System.assertEquals('0000000000', newContAfter.Phone);
    }

    /*
     Update Preferred Phone to 'Phone (Standard)' when standard Phone's value is not same as 
     any other Phone values and when Preferred Phone is Blank and the Context is batch.
    */
    @isTest
    static void testBatchPhoneNull() {
        disablePreferredPhone();

        insert new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            Phone = '111111111',
            OtherPhone = '0000000000'
        );

        Test.startTest();
        enablePreferredPhone();
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Database.executeBatch(batch);
        Test.stopTest();

        System.assertEquals('Phone (standard)', getCurrentContact().PreferredPhone__c);
    }

    /* 
     Updates Preferred Phone to the label of the Phone field that has a value which is not same as 
     standard phone
    */
    @isTest
    static void testBatchOther() {
        disablePreferredPhone();

        insert new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            Phone = '111111111',
            OtherPhone = '111111111'
        );

        Test.startTest();
        enablePreferredPhone();
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Database.executeBatch(batch);
        Test.stopTest();

        System.assertEquals('Other Phone', getCurrentContact().PreferredPhone__c);
    }

    /* Validation when there are more than one phone fields but not Preferred Phone
     * Test Scenario: T-3903371
     */
    @isTest
    static void testErrorPrefPhoneAmbiguous() {
        enablePreferredPhone();
        Contact newCont = new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            WorkPhone__c = '111111111',
            OtherPhone = '0000000000'
        );

        try {
            Test.startTest();
            insert newCont;
            Test.stopTest();
            System.assert(false, 'Multiple phones without preference specified should error out - when enforced');
        } catch (Exception error) {
            System.assert(error.getMessage().contains(Label.PreferredPhoneRequiredError));
        }

        disablePreferredPhone();
        insert newCont;
        System.assert(true, 'Multiple phones without preference specified should not error out - when unenforced');
    }

    /* Ensure contact edits validate against missing specififed preferred phone(home phone)
     *  Test Scenario: T-3903370
     */
    @isTest
    static void testcontactUpdatePrefPhoneNotBlankUponSettingUpdate() {
        enablePreferredPhone();

        Contact newCont = new Contact(FirstName = 'JohnnyTest1', LastName = 'JohnnyTest', OtherPhone = '0000000000');
        insert newCont;

        Hierarchy_Settings__c settings = enablePreferredPhone();
        settings.Preferred_Phone_Selection__c = 'homePhone';
        UTIL_CustomSettingsFacade.getSettingsForTests(settings);

        newCont.PreferredPhone__c = 'Home phone';
        try {
            Test.startTest();
            update newCont;
            Test.stopTest();
            System.assert(false, 'Missing preferred phone should error out.');
        } catch (Exception error) {
            System.assert(error.getMessage().contains(Label.PreferredPhoneMatchNotNull));
        }

        newCont.HomePhone = '0000000000';
        update newCont;
    }

    /* Validation when Preferred Phone is selected but no other Phone Fields have a value
     *  Test Scenario: T-3903364
     */
    @isTest
    static void testPrefPhoneNotBlankEnforced() {
        enablePreferredPhone();
        try {
            Test.startTest();
            testPrefPhoneNotBlank();
            Test.stopTest();
            System.assert(false, 'Should error out when no phone is indicated.');
        } catch (Exception error) {
            System.assert(error.getMessage().contains(Label.PreferredPhoneMatchNotNull));
        }
    }

    /* Validation when Preferred Phone is unenforced and no phone fields are populated value
     *  Test Scenario: T-3903366
     */
    @isTest
    static void testPrefPhoneNotBlankUnenforced() {
        disablePreferredPhone();
        try {
            Test.startTest();
            insert new Contact(
                FirstName = 'JohnnyTest1',
                LastName = 'JohnnyTest',
                WorkPhone__c = '1234567890',
                HomePhone = '2345678901',
                OtherPhone = '3456789012',
                PreferredPhone__c = 'NONE'
            );
            Test.stopTest();
        } catch (Exception error) {
            System.assert(
                false,
                'When preferred phone is unenforced, contact without specified phone insertion should persist.'
            );
        }
    }

    private static void testPrefPhoneNotBlank() {
        insert new Contact(FirstName = 'JohnnyTest1', LastName = 'JohnnyTest', PreferredPhone__c = 'Work');
    }

    /* Validation when Preferred Phone label doesn't match any of the other fields
     *  Test Scenario: T-3903363
     */
    @isTest
    static void testPrefDiffValue() {
        enablePreferredPhone();

        try {
            Test.startTest();
            insert new Contact(
                FirstName = 'JohnnyTest1',
                LastName = 'JohnnyTest',
                WorkPhone__c = '111111111',
                PreferredPhone__c = 'ForTestingPurposes'
            );
            Test.stopTest();
        } catch (Exception error) {
            System.assert(error.getMessage().contains(Label.PreferredPhoneMatchMustExist));
        }
    }

    /*
    Update Preferred Phone when Phone Clean Up batch job is run. 
    */
    @isTest
    static void testBatchWPreferredPhoneSelection() {
        disablePreferredPhone();

        insert new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            OtherPhone = '0000000000',
            HomePhone = '111111111'
        );

        Test.startTest();
        Hierarchy_Settings__c settings = enablePreferredPhone();
        settings.Preferred_Phone_Selection__c = 'homePhone';
        UTIL_CustomSettingsFacade.getSettingsForTests(settings);

        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Database.executeBatch(batch);
        Test.stopTest();

        Contact newContAfter = getCurrentContact();
        System.assertEquals('Home Phone', newContAfter.PreferredPhone__c);
        System.assertEquals('111111111', newContAfter.Phone);
    }

    /*
    Update Preferred Phone and Phone when Phone Clean Up batch job is run with no selection done in EDA Settings. 
    */
    @isTest
    static void testBatchWNoPreferredPhoneSelection() {
        disablePreferredPhone();

        insert new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            OtherPhone = '0000000000',
            HomePhone = '111111111'
        );

        Test.startTest();
        enablePreferredPhone();
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Database.executeBatch(batch);
        Test.stopTest();

        Contact newContAfter = getCurrentContact();
        System.assert(newContAfter.PreferredPhone__c != null);
        System.assert(newContAfter.Phone != null);
    }

    /*
    Update Preferred Phone and Phone when Phone Clean Up batch job is run with selection done in EDA Settings
    but value null on contact record.
    */

    @isTest
    static void testBatchWPreferredPhoneSelectionMisMatch() {
        disablePreferredPhone();

        insert new Contact(
            FirstName = 'JohnnyTest1',
            LastName = 'JohnnyTest',
            OtherPhone = '0000000000',
            MobilePhone = '0000000000'
        );

        Test.startTest();
        Hierarchy_Settings__c settings = enablePreferredPhone();
        settings.Preferred_Phone_Selection__c = 'homePhone';
        UTIL_CustomSettingsFacade.getSettingsForTests(settings);

        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Database.executeBatch(batch);
        Test.stopTest();

        Contact newContAfter = getCurrentContact();
        System.assert(newContAfter.PreferredPhone__c != null);
        System.assert(newContAfter.Phone == '0000000000');
    }

    /*
     Copy value of Standard Phone Field to Other when Preferred Phone is Null, Standard Phone is not null and
     all other phones are null.
    */
    @isTest
    static void testCopyStdPhoneToOther() {
        enablePreferredPhone();

        Test.startTest();
        insert new Contact(FirstName = 'JohnnyTest1', LastName = 'JohnnyTest', Phone = '0000000000');
        Test.stopTest();

        Contact newContAfter = getCurrentContact();
        System.assertEquals('Other Phone', newContAfter.PreferredPhone__c);
        System.assert(newContAfter.OtherPhone == '0000000000');
    }

    /* When Standard Phone is not null and Preferred Phone is enforced update Preferred Phone
       to Other and update Other Phone to the value of Standard Phone.
    */
    @isTest
    static void testUpdatePrefPhoneTOtherBulk() {
        enablePreferredPhone();

        List<Contact> contactsToInsert = new List<Contact>();
        for (Integer i = 0; i < 100; i++) {
            Contact a = new Contact(FirstName = 'TestAccount' + i, LastName = 'JohnnyTest' + i);
            contactsToInsert.add(a);
        }
        insert contactsToInsert;

        Test.startTest();
        for (Contact each : contactsToInsert) {
            each.Phone = '0000000000';
        }
        update contactsToInsert;
        Test.stopTest();

        List<Contact> newContAfterList = [
            SELECT Id, FirstName, LastName, Name, OtherPhone, Phone, PreferredPhone__c
            FROM Contact
        ];

        for (Contact each : newContAfterList) {
            System.assertEquals('0000000000', each.OtherPhone);
            System.assertEquals('Other Phone', each.PreferredPhone__c);
        }
    }

    private static Contact getCurrentContact() {
        return [
            SELECT Id, FirstName, LastName, Name, Phone, WorkPhone__c, OtherPhone, PreferredPhone__c
            FROM Contact
            LIMIT 1
        ];
    }
}
