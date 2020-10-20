/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Test class for CON_Preferred_TEDTM - Preferred Email functionality.
*/
@isTest
private class CON_PreferredEmail_TEST {

    /**************************************************************************************************************************
    ****************************************************** UNIT TESTS *********************************************************
    **************************************************************************************************************************/

    /*************************************************************************************************************
    * @description NULL test for run method to verify null is returned when newList is null
    *************************************************************************************************************/
    @isTest
    private static void runMethodNULLTest() {

        TDTM_Runnable.Action testAction = TDTM_Runnable.Action.AfterUpdate;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        Test.startTest();
            TDTM_Runnable.DmlWrapper dmlWrapperReturned = tdtmClass.run(null, null, testAction, objResult);
        Test.stopTest();

        System.assertEquals(null, dmlWrapperReturned);

    }

    /*************************************************************************************************************
    * @description Test for run method to verify null is returned when newList is empty
    *************************************************************************************************************/
    @isTest
    private static void runMethodEmptyTest() {

        List<Contact> newContactsList = new List<Contact>();
        List<SObject> oldContactList = new List<SObject>();

        TDTM_Runnable.Action testAction = TDTM_Runnable.Action.AfterUpdate;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        Test.startTest();
            TDTM_Runnable.DmlWrapper dmlWrapperReturned = tdtmClass.run(newContactsList, oldContactList, testAction, objResult);
        Test.stopTest();

        System.assertEquals(null, dmlWrapperReturned);

    }

    /*************************************************************************************************************
    * @description Tests runMethod in BeforInsert Context
    *************************************************************************************************************/
    @isTest
    private static void runMethodBeforeInsert() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        List<Contact> contactList = new List<Contact>();

        Contact contact1 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        contact1.Email = 'test@sf.org';

        Contact contact2 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        contact2.Preferred_Email__c = 'Alternate Email';

        contactList.add(contact1);
        contactList.add(contact2);

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        Test.startTest();
            tdtmClass.run(contactList, null, TDTM_Runnable.Action.BeforeInsert, Schema.SObjectType.Contact);
        Test.stopTest();

        System.assertEquals('Alternate Email', contact1.Preferred_Email__c);
        System.assertEquals(contact1.Email, contact1.AlternateEmail__c);

        System.assertEquals(true, contact2.hasErrors());
        System.assertEquals(Label.PreferredEmailMatchNotNull, contact2.getErrors()[0].getMessage());
              
    }
    
    /*************************************************************************************************************
    * @description Tests runMethod in BeforUpdate Context
    *************************************************************************************************************/
    @isTest
    private static void runMethodBeforeUpdate() {

        List<Contact> oldContactList = new List<Contact>();
        List<Contact> newContactList = new List<Contact>();

        Contact oldContact1 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        oldContact1.Email = '';
        oldContact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Contact newContact1 = oldContact1.clone(true);
        newContact1.Email = 'test@sf.org';

        Contact oldContact2 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        oldContact2.Email = '';
        oldContact2.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);

        Contact newContact2 = oldContact2.clone(true);
        newContact2.Preferred_Email__c = 'Alternate Email';

        oldContactList.add(oldContact1);
        oldContactList.add(oldContact2);
        newContactList.add(newContact1);
        newContactList.add(newContact2);

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        Test.startTest();
            tdtmClass.run(newContactList, oldContactList, TDTM_Runnable.Action.BeforeUpdate, Schema.SObjectType.Contact);
        Test.stopTest();

        System.assertEquals('Alternate Email', newContact1.Preferred_Email__c);
        System.assertEquals(newContact1.Email, newContact1.AlternateEmail__c);
        System.assertEquals(true, newContact2.hasErrors());
        System.assertEquals(Label.PreferredEmailMatchNotNull, newContact2.getErrors()[0].getMessage());

    }
    
    /*************************************************************************************************************
    * @description Tests handleBeforeInsert method under recursion to ensure no Contacts are processed
    *************************************************************************************************************/
    @isTest
    private static void handleBeforeInsertInRecursion() {

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        tdtmClass.setRecursion();
        Test.startTest();
            List<Contact> returnedContactList = tdtmClass.handleBeforeInsert(UTIL_UnitTestData_TEST.getMultipleTestContacts(5));
        Test.stopTest();

        System.assertEquals(0, returnedContactList.size());
    }
    
    /*************************************************************************************************************
    * @description Tests handleBeforeInsert method
    *************************************************************************************************************/
    @isTest
    private static void handleBeforeInsert() {

        List<Contact> contactList = new List<Contact>();

        Contact contact1 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        contact1.Email = '';
        contactList.add(contact1);

        Contact contact2 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        contact2.Email = 'test@sf.org';
        contactList.add(contact2);

        Contact contact3 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        contact3.Preferred_Email__c = 'Alternate Email';
        contactList.add(contact3);

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        Test.startTest();
            List<Contact> returnedContactList = tdtmClass.handleBeforeInsert(contactList);
        Test.stopTest();

        System.assertEquals(2, returnedContactList.size(), 'Contact1 should not be in the list');
        System.assertEquals(false, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM));
        
    }

    /*************************************************************************************************************
    * @description Tests handleBeforeInsert method with Preferred Phone
    *************************************************************************************************************/
    @isTest
    private static void handleBeforeInsertWithPreferredPhone() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Enable_New_Preferred_Phone_Sync__c = false));

        List<Contact> contactList = new List<Contact>();

        Contact contact1 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        contact1.Email = 'test@sf.org';
        contact1.Phone = '';
        contact1.HomePhone = '1234567890';
        contact1.PreferredPhone__c = 'Home Phone';

        contactList.add(contact1);

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        Test.startTest();
            List<Contact> returnedContactList = tdtmClass.handleBeforeInsert(contactList);
        Test.stopTest();

        System.assertEquals(1, returnedContactList.size());
        System.assertEquals(contact1.HomePhone, returnedContactList[0].Phone);
        System.assertEquals(contact1.Email, returnedContactList[0].AlternateEmail__c);
        System.assertEquals('Alternate Email', returnedContactList[0].Preferred_Email__c);

    }

    /*************************************************************************************************************
    * @description Tests handleBeforeUpdate method under recursion to ensure no Contacts are processed
    *************************************************************************************************************/
    @isTest
    private static void handleBeforeUpdateInRecursion() {

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        tdtmClass.setRecursion();
        Test.startTest();
            List<Contact> returnedContactList = tdtmClass.handleBeforeUpdate(UTIL_UnitTestData_TEST.getMultipleTestContacts(5), null);
        Test.stopTest();

        System.assertEquals(0, returnedContactList.size());
    }
    
    /*************************************************************************************************************
    * @description Tests handleBeforeUpdate method
    *************************************************************************************************************/
    @isTest
    private static void handleBeforeUpdate() {

        List<Contact> oldList = new List<Contact>();

        Contact contact1 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        contact1.Email = '';
        contact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        oldList.add(contact1);

        Contact contact2 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        contact2.Email = '';
        contact2.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        oldList.add(contact2);

        Contact contact3 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        contact3.Email = '';
        contact3.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        oldList.add(contact3);

        Contact newContact1 = contact1.clone(true);
        Contact newContact2 = contact2.clone(true);
        newContact2.Email = 'test@sf.org';
        Contact newContact3 = contact3.clone(true);
        newContact3.Preferred_Email__c = 'Alternate Email';

        List<Contact> newList = new List<Contact>();
        newList.add(newContact1);
        newList.add(newContact2);
        newList.add(newContact3);

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        Test.startTest();
            List<Contact> returnedContactList = tdtmClass.handleBeforeUpdate(newList, oldList);
        Test.stopTest();

        System.assertEquals(2, returnedContactList.size(), 'Contact1 should not be in the list');
        System.assertEquals(false, TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM));

    }

    /*************************************************************************************************************
    * @description Tests handleBeforeUpdate with Preferred Phone
    *************************************************************************************************************/
    @isTest
    private static void handleBeforeUpdateWithPreferredPhone() {

        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                      (Enable_New_Preferred_Phone_Sync__c = false));

        List<Contact> newContactList = new List<Contact>();
        List<Contact> oldContactList = new List<Contact>();

        Contact contact1 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        contact1.Phone = '';
        contact1.Id = UTIL_UnitTestData_TEST.getFakeId(Contact.sObjectType);
        oldContactList.add(contact1);

        Contact newContact1 = contact1.clone(true);
        contact1.Email = 'test@sf.org';
        contact1.HomePhone = '1234567890';
        contact1.PreferredPhone__c = 'Home Phone';
        newContactList.add(contact1);

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        Test.startTest();
            List<Contact> returnedContactList = tdtmClass.handleBeforeUpdate(newContactList, oldContactList);
        Test.stopTest();

        System.assertEquals(1, returnedContactList.size());
        System.assertEquals(contact1.HomePhone, returnedContactList[0].Phone);
        System.assertEquals(contact1.Email, returnedContactList[0].AlternateEmail__c);
        System.assertEquals('Alternate Email', returnedContactList[0].Preferred_Email__c);

    }

    /****************************************************************************
    * @description Tests locateContactEmailService method of CON_Preferred_TDTM
    ****************************************************************************/
    @isTest
    private static void locateContactEmailService() {

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        Test.startTest();
            SRVC_Contact_PreferredEmail preferredEmailService = tdtmClass.locateContactEmailService();
        Test.stopTest();

        SRVC_Contact_PreferredEmail srvcInstance = SRVC_Contact_PreferredEmail.getInstance();

        System.assertEquals(srvcInstance, preferredEmailService);

    }
    
    /****************************************************************************
    * @description Tests locatePreferredEmailMapper method of CON_Preferred_TDTM
    ****************************************************************************/
    @isTest
    private static void locatePreferredEmailMapper() {

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        Test.startTest();
            MAPR_CON_PreferredEmailFields preferredEmailFields = tdtmClass.locatePreferredEmailMapper();
        Test.stopTest();

        MAPR_CON_PreferredEmailFields srvcInstance = MAPR_CON_PreferredEmailFields.getInstance();

        System.assertEquals(srvcInstance, preferredEmailFields);
        
    }

    /********************************************************
    * @description Tests setRecursion method
    *********************************************************/
    @isTest
    static void setRecursion() {
        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();

        Test.startTest();
            tdtmClass.setRecursion();
        Test.stopTest();

        Boolean preferredTDTMFlag = TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM
        );

        System.assertEquals(true, preferredTDTMFlag, 'CON_Preferred_TDTM should be active');
    }

    /********************************************************
    * @description Tests unsetRecursion method
    *********************************************************/
    @isTest
    static void unsetRecursion() {

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        tdtmClass.setRecursion();

        System.assertEquals(true, TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM
        ));

        Test.startTest();
            tdtmClass.unsetRecursion();
        Test.stopTest();

        Boolean preferredTDTMFlag = TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM
        );

        System.assertEquals(false, preferredTDTMFlag, 'CON_Preferred_TDTM should be Inactive');
    }
    
    /********************************************************
    * @description Tests isRecursion method
    *********************************************************/
    @isTest
    static void isRecursion() {

        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();
        tdtmClass.setRecursion();

        System.assertEquals(true, TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM
        ));

        Test.startTest();
            tdtmClass.isRecursion();
        Test.stopTest();

        Boolean preferredTDTMFlag = TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM
        );

        System.assertEquals(true, preferredTDTMFlag, 'CON_Preferred_TDTM should be Active');
    }

    /********************************************************************
    * @description Tests isNewPreferredPhoneFunctionalityEnabled method
    ********************************************************************/
    @isTest
    static void isNewPreferredPhoneFunctionalityEnabled() {
        UTIL_CustomSettingsFacade.getSettingsForTests(new Hierarchy_Settings__c
                                                         (Enable_New_Preferred_Phone_Sync__c = true));
        
        CON_Preferred_TDTM tdtmClass = new CON_Preferred_TDTM();

        Test.startTest();
            Boolean preferredPhoneEnabled = tdtmClass.isNewPreferredPhoneFunctionalityEnabled();
        Test.stopTest();

        System.assertEquals(true, preferredPhoneEnabled, 'Preferred Phone should be enabled');
    }

    /**************************************************************************************************************************
    ****************************************************** FUNCTIONAL TESTS ***************************************************
    **************************************************************************************************************************/

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and no Email fields will throw PreferredEmailMatchNotNull Error
    * when Preferred Email Enforcement is Enabled
    *****************************************************************************************************************************/
	@isTest 
    static void preferredEmailNotBlankOnInsertWithEnforcementEnabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
            );
    
        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.Preferred_Email__c = 'Alternate Email';

        try {
            Test.startTest();
                insert testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the value corresponding to Preferred Email is Blank.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchNotNull));
        }
    }

    /*****************************************************************************************************************************
    * @description Tests inserting a Contact with Preferred Email and no Email fields will throw PreferredEmailMatchNotNull Error
    * when Preferred Email Enforcement is Disabled
    *****************************************************************************************************************************/
    @isTest 
    static void preferredEmailNotBlankOnInsertWithEnforcementDisabled() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.Preferred_Email__c = 'Alternate Email';

        try {
            Test.startTest();
                insert testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the value corresponding to Preferred Email is Blank.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchNotNull));
        }
    }

    /*****************************************************************************************************************************
    * @description Tests Updating a Contact with Preferred Email and no Email fields will throw PreferredEmailMatchNotNull Error
    * when Preferred Email Enforcement is Enabled
    *****************************************************************************************************************************/
    @isTest 
    static void preferredEmailNotBlankOnUpdateWithEnforcementEnabled() {
		UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
            );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        testContact.Preferred_Email__c = 'Alternate';
        try {
            Test.startTest();
                update testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the value corresponding to Preferred Email is Blank.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchNotNull));
        }
    }
    
    /*****************************************************************************************************************************
    * @description Tests Updating a Contact with Preferred Email and no Email fields will throw PreferredEmailMatchNotNull Error
    * when Preferred Email Enforcement is Disabled
    *****************************************************************************************************************************/
    @isTest 
    static void preferredEmailNotBlankOnUpdateWithEnforcementDisabled() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        testContact.Preferred_Email__c = 'Alternate';
        try {
            Test.startTest();
                update testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the value corresponding to Preferred Email is Blank.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchNotNull));
        }
    }

    /*********************************************************************************************************************************
    * @description Tests Inserting a Contact with standard Email field populated will update Alternate Email to the value in Standard
    * Email and update Preferred Email to 'Alternate Email' when Preferred Email Enforcement is enabled
    *********************************************************************************************************************************/
    @isTest 
    static void standardEmailNotBlankOnInsert() {
		UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
            );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = 'test@sf.org';

        Test.startTest();
            insert testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals(testContact.Email, updatedContact.AlternateEmail__c);
        System.assertEquals('Alternate Email', updatedContact.Preferred_Email__c);
    }
    
    /*********************************************************************************************************************************
    * @description Tests inserting a Contact with standard Email field populated will not update Alternate Email
    * and Preferred Email when Preferred Email Enforcement is diabled
    *********************************************************************************************************************************/
    @isTest 
    static void standardEmailNotBlankOnInsertNegativeTest() {
		UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
            );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = 'test@sf.org';

        Test.startTest();
            insert testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals(null, testContact.AlternateEmail__c);
        System.assertEquals(null, updatedContact.Preferred_Email__c);
    }

     /*********************************************************************************************************************************
    * @description Tests Updating a Contact in Batch context with standard Email field populated will update Alternate Email to the 
    * value in Standard Email and update Preferred Email to 'Alternate Email' when Preferred Email Enforcement is enabled
    *********************************************************************************************************************************/
    @isTest 
    static void standardEmailNotBlankOnBatch() {
		UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
            );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = 'test@sf.org';
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);
        insert testContact;
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        Contact updatedContact = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE ID =: testContact.Id];

        System.assertEquals(testContact.Email, updatedContact.AlternateEmail__c);
        System.assertEquals('Alternate Email', updatedContact.Preferred_Email__c);

    }
    
    /*********************************************************************************************************************************
    * @description Tests Updating a Contact in Batch context with standard Email field populated will not update Alternate Email
    * and Preferred Email when Preferred Email Enforcement is disbaled
    *********************************************************************************************************************************/
    @isTest 
    static void standardEmailNotBlankOnBatchNegativeTest() {
		UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
            );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = 'test@sf.org';
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);
        insert testContact;
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        Contact updatedContact = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE ID =: testContact.Id];

        System.assertEquals(null, testContact.AlternateEmail__c);
        System.assertEquals(null, updatedContact.Preferred_Email__c);

    }

    /*********************************************************************************************************************************
    * @description Tests Updating a Contact to populate standard Email field will update Alternate Email to the 
    * value in Standard Email and update Preferred Email to 'Alternate Email' when Preferred Email Enforcement is enabled
    *********************************************************************************************************************************/
    @isTest 
    static void standardEmailNotBlankOnUpdate() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        Test.startTest();
            testContact.Email = 'test@sf.org';
            update testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE ID =: testContact.Id];

        System.assertEquals(testContact.Email, updatedContact.AlternateEmail__c);
        System.assertEquals('Alternate Email', updatedContact.Preferred_Email__c);
        
    }
    
    /*********************************************************************************************************************************
    * @description Tests Updating a Contact's standard Email field will not update Alternate Email
    * and Preferred Email when Preferred Email Enforcement is disabled
    *********************************************************************************************************************************/
    @isTest 
    static void standardEmailNotBlankOnUpdateNegativeTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        Test.startTest();
            testContact.Email = 'test@sf.org';
            update testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE ID =: testContact.Id];

        System.assertEquals(null, updatedContact.AlternateEmail__c);
        System.assertEquals(null, updatedContact.Preferred_Email__c);
        
    }

    /*********************************************************************************************************************************
    * @description Tests Updating a Contact to clear Preferred Email and the value corresponding to the field in Preferred Email will
    * clear the value in standard Email field
    *********************************************************************************************************************************/
    @isTest 
    static void clearEmailFieldsOnUpdate() {
		UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
            );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.AlternateEmail__c = 'test@sf.org';
        insert testContact;

        Contact insertedContact = [SELECT Id, Email, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE ID =: testContact.Id];

        System.assertEquals(insertedContact.Email, testContact.AlternateEmail__c);
        System.assertEquals(insertedContact.Preferred_Email__c, 'Alternate Email');

        Test.startTest();
            testContact.AlternateEmail__c = '';
            testContact.Preferred_Email__c = null;
            update testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE ID =: testContact.Id];

        System.assertEquals('', testContact.AlternateEmail__c);
        System.assertEquals(null, updatedContact.Preferred_Email__c);
        System.assertEquals('', testContact.Email);

    } 
    
    /*********************************************************************************************************************************
    * @description Tests Updating a Contact to clear Preferred Email and all other custom email fields will not clear the value in
    * standard email field
    *********************************************************************************************************************************/
    @isTest 
    static void clearEmailFieldsOnUpdateNegative() {
		UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
            );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.AlternateEmail__c = 'test@sf.org';
        insert testContact;

        Contact insertedContact = [SELECT Id, Email, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE ID =: testContact.Id];

        System.assertEquals(insertedContact.Email, testContact.AlternateEmail__c);
        System.assertEquals(insertedContact.Preferred_Email__c, 'Alternate Email');

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );
        Test.startTest();
            testContact.AlternateEmail__c = '';
            testContact.Preferred_Email__c = null;
            update testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE ID =: testContact.Id];

        System.assertEquals('', testContact.AlternateEmail__c);
        System.assertEquals(null, updatedContact.Preferred_Email__c);
        System.assertEquals(testContact.AlternateEmail__c, testContact.Email);

    } 
    
    /*************************************************************************************************************************
    * @description Tests Inserting a Contact with only one custom Email field will set it as Preferred Email and copy the value 
    * to standard the Email field when Preferred Email Enforcement is Enabled
    **************************************************************************************************************************/
	@isTest 
    static void singleEmailSmartSetOnInsert() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.AlternateEmail__c = 'test@sf.org';

        Test.startTest();
            insert testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Email, Preferred_Email__c FROM Contact WHERE Id =: testContact.Id];
        System.assertEquals(testContact.AlternateEmail__c, updatedContact.Email);
        System.assertEquals('Alternate Email', updatedContact.Preferred_Email__c);

    }
    
    /*************************************************************************************************************************
    * @description Tests Inserting a Contact with only one custom Email field not set Preferred Email and will not copy the value 
    * to standard the Email field when Preferred Email Enforcement is disabled
    **************************************************************************************************************************/
	@isTest 
    static void singleEmailSmartSetOnInsertNegativeTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.AlternateEmail__c = 'test@sf.org';

        Test.startTest();
            insert testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Email, Preferred_Email__c FROM Contact WHERE Id =: testContact.Id];
        System.assertEquals(null, updatedContact.Email);
        System.assertEquals(null, updatedContact.Preferred_Email__c);

    }
    
    /*************************************************************************************************************************
    * @description Tests Updating a Contact with only one custom Email field will it as Preferred Email and copy the value 
    * to standard the Email field when Preferred Email Enforcement is Enabled
    **************************************************************************************************************************/
    @isTest 
    static void singleEmailSmartSetOnUpdate() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        Test.startTest();
            testContact.AlternateEmail__c = 'test@sf.org';
            update testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Email, Preferred_Email__c FROM Contact WHERE Id =: testContact.Id];
        System.assertEquals(testContact.AlternateEmail__c, updatedContact.Email);
        System.assertEquals('Alternate Email', updatedContact.Preferred_Email__c);

    }
    
    /*************************************************************************************************************************
    * @description Tests Updating a Contact with only one custom Email field will not set Preferred Email and will not copy 
    * the value to standard the Email field when Preferred Email Enforcement is disbaled
    **************************************************************************************************************************/
    @isTest 
    static void singleEmailSmartSetOnNegativeTestOnUpdate() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        Test.startTest();
            testContact.AlternateEmail__c = 'test@sf.org';
            update testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Email, Preferred_Email__c FROM Contact WHERE Id =: testContact.Id];
        System.assertEquals(null, updatedContact.Email);
        System.assertEquals(null, updatedContact.Preferred_Email__c);

    }
    
    /*************************************************************************************************************************
    * @description Tests Inserting a Contact with more than one custom Email fields will throw PreferredEmailRequiredError
    * when Preferred Email Enforcement is Enabled
    **************************************************************************************************************************/
    @isTest 
    static void multipleEmailsOnInsert() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.AlternateEmail__c = 'test@sf.org';
        testContact.WorkEmail__c = 'test@sf.org';

        try {
            Test.startTest();
                insert testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when multiple email fields have value and when Preferred Email is Blank.');
        } catch (DmlException  error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailRequiredError));
        }
    }
    
    /***********************************************************************************************************************************
    * @description Tests inserting a Contact with more than one custom Email fields will not throw any error and not set Preferred Email
    * and standard Email field when Preferred Email Enforcement is disabled
    ************************************************************************************************************************************/
    @isTest 
    static void multipleEmailsOnInsertNegativeTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.AlternateEmail__c = 'test@sf.org';
        testContact.WorkEmail__c = 'test@sf.org';

        Test.startTest();
            insert testContact;
        Test.stopTest();

        Contact insertedContact = [SELECT Id, Email, Preferred_Email__c FROM Contact];
        System.assertEquals(null, insertedContact.Preferred_Email__c);
        System.assertEquals(null, insertedContact.Email);

    }
    
    /*************************************************************************************************************************
    * @description Tests updating a Contact with more than one custom Email fields will throw PreferredEmailRequiredError
    * when Preferred Email Enforcement is Enabled
    **************************************************************************************************************************/
    @isTest 
    static void multipleEmailsOnUpdate() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        try {
            Test.startTest();
                testContact.AlternateEmail__c = 'test@sf.org';
                testContact.WorkEmail__c = 'test@sf.org';
                update testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when multiple email fields have value and when Preferred Email is Blank.');
        } catch (DmlException  error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailRequiredError));
        }
    }
    
    /*************************************************************************************************************************
    * @description Tests updating a Contact with more than one custom Email fields will not throw any Error
    * and will not set Preferred Email or standarad email when Preferred Email Enforcement is Disbaled
    **************************************************************************************************************************/
    @isTest 
    static void multipleEmailsOnUpdateNegativeTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        Test.startTest();
            testContact.AlternateEmail__c = 'test@sf.org';
            testContact.WorkEmail__c = 'test@sf.org';
            update testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, preferred_Email__c, Email FROM Contact];
        System.assertEquals(null, updatedContact.preferred_Email__c);
        System.assertEquals(null, updatedContact.Email);

    }

    /************************************************************************************************************************************
    * @description Tests inserting a Contact with one custom Email field and Preferred Email which doesn't correspond to preferred Email
    * will throw PreferredEmailMatchNotNull when Preferred Email Enforcement is Enabled
    *************************************************************************************************************************************/
    @isTest 
    static void insertWithPreferredEmailMatchNotNullErrorWithEnforcementEnabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.Preferred_Email__c = 'Alternate Email';
        testContact.WorkEmail__c = 'test@sf.org';

        try {
            Test.startTest();
                insert testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the value corresponding to Preferred Email is Blank.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchNotNull));
        }
    }

    /************************************************************************************************************************************
    * @description Tests inserting a Contact with one custom Email field and Preferred Email which doesn't correspond to preferred Email
    * will throw PreferredEmailMatchNotNull when Preferred Email Enforcement is Disabled
    *************************************************************************************************************************************/
    @isTest 
    static void insertWithPreferredEmailMatchNotNullErrorWithEnforcementDisabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.Preferred_Email__c = 'Alternate Email';
        testContact.WorkEmail__c = 'test@sf.org';

        try {
            Test.startTest();
                insert testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the value corresponding to Preferred Email is Blank.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchNotNull));
        }
    }

    /************************************************************************************************************************************
    * @description Tests upating a Contact with one custom Email field and Preferred Email which doesn't correspond to preferred Email
    * will throw PreferredEmailMatchNotNull when Preferred Email Enforcement is Enabled
    *************************************************************************************************************************************/
    @isTest 
    static void updateWithPreferredEmailMatchNotNullErrorWithEnforcementEnabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        try {
            Test.startTest();
                testContact.Preferred_Email__c = 'Alternate Email';
                testContact.WorkEmail__c = 'test@sf.org';
                update testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the value corresponding to Preferred Email is Blank.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchNotNull));
        }
    }

    /************************************************************************************************************************************
    * @description Tests upating a Contact with one custom Email field and Preferred Email which doesn't correspond to preferred Email
    * will throw PreferredEmailMatchNotNull when Preferred Email Enforcement is disabled
    *************************************************************************************************************************************/
    @isTest 
    static void updateWithPreferredEmailMatchNotNullErrorWithEnforcementDisabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        try {
            Test.startTest();
                testContact.Preferred_Email__c = 'Alternate Email';
                testContact.WorkEmail__c = 'test@sf.org';
                update testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the value corresponding to Preferred Email is Blank.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchNotNull));
        }
    }

    /************************************************************************************************************************************
    * @description Tests inserting a Contact with one custom Email field and Preferred Email which corresponds to preferred Email
    * will update Standard Email field to the value in custom Email field when Preferred Email Enforcement is enabled
    *************************************************************************************************************************************/
    @isTest 
    static void copyValueToStandardFieldOnInsertWithEnforcementEnabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = 'Work Email';
        testContact.WorkEmail__c = 'test@sf.org';
        testContact.Email = '';

        Test.startTest();
            insert testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Email FROM Contact WHERE Id =: testContact.Id];
        System.assertEquals(updatedContact.Email, testContact.WorkEmail__c);

    }

    /************************************************************************************************************************************
    * @description Tests inserting a Contact with one custom Email field and Preferred Email which corresponds to preferred Email
    * will update Standard Email field to the value in custom Email field when Preferred Email Enforcement is disabled
    *************************************************************************************************************************************/
    @isTest 
    static void copyValueToStandardFieldOnInsertWithEnforcementDisabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = 'Work Email';
        testContact.WorkEmail__c = 'test@sf.org';
        testContact.Email = '';

        Test.startTest();
            insert testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Email FROM Contact WHERE Id =: testContact.Id];
        System.assertEquals(updatedContact.Email, testContact.WorkEmail__c);

    }

    /************************************************************************************************************************************
    * @description Tests updating a Contact with one custom Email field and Preferred Email which corresponds to preferred Email
    * will update Standard Email field to the value in custom Email field when Preferred Email Enforcement is enabled
    *************************************************************************************************************************************/
    @isTest 
    static void copyValueToStandardFieldOnUpdateWithEnforcementEnabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        Test.startTest();
            testContact.Preferred_Email__c = 'Work Email';
            testContact.WorkEmail__c = 'test@sf.org';
            update testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Email FROM Contact WHERE Id =: testContact.Id];
        System.assertEquals(updatedContact.Email, testContact.WorkEmail__c);

    }

    /************************************************************************************************************************************
    * @description Tests updating a Contact with one custom Email field and Preferred Email which corresponds to preferred Email
    * will update Standard Email field to the value in custom Email field when Preferred Email Enforcement is disabled
    *************************************************************************************************************************************/
    @isTest 
    static void copyValueToStandardFieldOnUpdateWithEnforcementDisabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        insert testContact;

        Test.startTest();
            testContact.Preferred_Email__c = 'Work Email';
            testContact.WorkEmail__c = 'test@sf.org';
            update testContact;
        Test.stopTest();

        Contact updatedContact = [SELECT Id, Email FROM Contact WHERE Id =: testContact.Id];
        System.assertEquals(updatedContact.Email, testContact.WorkEmail__c);

    }

    /************************************************************************************************************************************
    * @description Tests inserting a Contact with one custom Email field and Preferred Email which doesn't corresponds to any of the
    * custom email fields will throw PreferredEmailMatchMustExist error when Preferred Email Enforcement is Disabled
    *************************************************************************************************************************************/
    @isTest 
    static void fieldNotFoundOnInsertWithEnforcementDisabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = 'Test sf Email';
        testContact.WorkEmail__c = 'test@sf.org';

        try {
        Test.startTest();
            insert testContact;
        Test.stopTest();
        System.assert(false, 'Always throw an error when the field corresponding to Preferred Email is not found.');
        } catch (DmlException error) {
             System.assert(error.getMessage().contains(Label.PreferredEmailMatchMustExist));
        }
    }

    /************************************************************************************************************************************
    * @description Tests inserting a Contact with one custom Email field and Preferred Email which doesn't corresponds to any of the
    * custom email fields will throw PreferredEmailMatchMustExist error when Preferred Email Enforcement is Enabled
    *************************************************************************************************************************************/
    @isTest 
    static void fieldNotFoundOnInsertWithEnforcementEnabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = 'Test sf Email';
        testContact.WorkEmail__c = 'test@sf.org';

        try {
            Test.startTest();
                insert testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the field corresponding to Preferred Email is not found.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchMustExist));
        }
    }

    /************************************************************************************************************************************
    * @description Tests updating  a Contact with one custom Email field and Preferred Email which doesn't corresponds to any of the
    * custom email fields will throw PreferredEmailMatchMustExist error when Preferred Email Enforcement is Enabled
    *************************************************************************************************************************************/
    @isTest 
    static void fieldNotFoundOnUpdateWithEnforcementEnabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        insert testContact;

        try {
            Test.startTest();
                testContact.Preferred_Email__c = 'Test sf Email';
                testContact.WorkEmail__c = 'test@sf.org';
                update testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the field corresponding to Preferred Email is not found.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchMustExist));
        }
    }

    /************************************************************************************************************************************
    * @description Tests updating a Contact with one custom Email field and Preferred Email which doesn't corresponds to any of the
    * custom email fields will throw PreferredEmailMatchMustExist error when Preferred Email Enforcement is Disabled
    *************************************************************************************************************************************/
    @isTest 
    static void fieldNotFoundOnUpdateWithEnforcementDisabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        insert testContact;

        try {
            Test.startTest();
                testContact.Preferred_Email__c = 'Test sf Email';
                testContact.WorkEmail__c = 'test@sf.org';
                update testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the field corresponding to Preferred Email is not found.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchMustExist));
        }
    }

    /************************************************************************************************************************************
    * @description Tests updating a Contact in Batch context with the value of standard Email field not matching with any of the values in
    * custom email fields will update Preferred Email to the label preferredBatchDefaultEmail when Preferred Email Enforcement is enabled
    *************************************************************************************************************************************/
    @isTest 
    static void updatePreferredEmailToEmailStandardBatch() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = 'TestingEmail@sf.org';
        testContact.WorkEmail__c = 'test@sf.org';
        testContact.Preferred_Email__c = null;
        insert testContact;

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);  
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        Contact contactAfterBatchUpdate = [SELECT Id, Preferred_Email__c FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals(Label.preferredBatchDefaultEmail, contactAfterBatchUpdate.Preferred_Email__c);

    }

    /************************************************************************************************************************************
    * @description Tests updating a Contact in Batch context with the value of standard Email field not matching with any of the values in
    * custom email fields will not update Preferred Email when Preferred Email Enforcement is disabled
    *************************************************************************************************************************************/
    @isTest 
    static void updatePreferredEmailToEmailStandardBatchNegativeTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = 'TestingEmail@sf.org';
        testContact.WorkEmail__c = 'test@sf.org';
        testContact.Preferred_Email__c = null;
        insert testContact;

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        Contact contactAfterBatchUpdate = [SELECT Id, Preferred_Email__c FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals(null, contactAfterBatchUpdate.Preferred_Email__c);

    }
    
    /************************************************************************************************************************************
    * @description Tests updating a Contact in Batch context with the value of standard Email field matching with any of the values in
    * custom email fields will update Preferred Email to the first available custom email field's label when Preferred Email Enforcement is enabled
    *************************************************************************************************************************************/
    @isTest 
    static void updatePreferredEmailToFirstMatchingEmailFieldBatch() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = 'test@sf.org';
        testContact.WorkEmail__c = 'test@sf.org';
        testContact.UniversityEmail__c = 'testUniv@sf.org';
        testContact.Preferred_Email__c = null;
        insert testContact;

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);  
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        Contact contactAfterBatchUpdate = [SELECT Id, Preferred_Email__c FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals('Work Email', contactAfterBatchUpdate.Preferred_Email__c);

    }

    /************************************************************************************************************************************
    * @description Tests updating a Contact in Batch context with the value of standard Email field matching with any of the values in
    * custom email fields will not update Preferred Email when Preferred Email Enforcement is disabled
    *************************************************************************************************************************************/
    @isTest 
    static void updatePreferredEmailToFirstMatchingEmailFieldBatchNegativeTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = 'test@sf.org';
        testContact.WorkEmail__c = 'test@sf.org';
        testContact.UniversityEmail__c = 'testUniv@sf.org';
        testContact.Preferred_Email__c = null;
        insert testContact;

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        Contact contactAfterBatchUpdate = [SELECT Id, Preferred_Email__c FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals(null, contactAfterBatchUpdate.Preferred_Email__c);

    }
    
    /************************************************************************************************************************************
    * @description Tests updating a Contact in Batch context with only one custom email field will update Preferred Email to the label 
    * corresponding to the custom email field with value when Standard Email field is blank and Preferred Email Enforcement is enabled
    *************************************************************************************************************************************/
    @isTest 
    static void updatePreferredEmailSmartSetBatch() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.WorkEmail__c = 'test@sf.org';
        testContact.Preferred_Email__c = null;
        insert testContact;

        Contact contactAfterInsert = [SELECT Id, Preferred_Email__c, Email FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals(null, contactAfterInsert.Preferred_Email__c);
        System.assertEquals(null, contactAfterInsert.Email);

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);  
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        Contact contactAfterBatchUpdate = [SELECT Id, Preferred_Email__c, Email FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals('Work Email', contactAfterBatchUpdate.Preferred_Email__c);
        System.assertEquals(testContact.WorkEmail__c, contactAfterBatchUpdate.Email);

    }

    /************************************************************************************************************************************
    * @description Tests updating a Contact in Batch context with only one custom email field will not update Preferred Email and 
    * standard email fields Preferred Email Enforcement is disbaled
    *************************************************************************************************************************************/
    @isTest 
    static void updatePreferredEmailSmartSetBatchNegativeTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.WorkEmail__c = 'test@sf.org';
        testContact.Preferred_Email__c = null;
        insert testContact;

        Contact contactAfterInsert = [SELECT Id, Preferred_Email__c, Email FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals(null, contactAfterInsert.Preferred_Email__c);
        System.assertEquals(null, contactAfterInsert.Email);

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        Contact contactAfterBatchUpdate = [SELECT Id, Preferred_Email__c, Email FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals(null, contactAfterBatchUpdate.Preferred_Email__c);
        System.assertEquals(null, contactAfterBatchUpdate.Email);

    }

    /***************************************************************************************************************************************************
    * @description Tests updating a Contact in Batch context with more than one custom email field will update Preferred Email to the label 
    * corresponding to the first available custom email field with value when Standard Email field is blank and Preferred Email Enforcement is enabled
    **************************************************************************************************************************************************/
    @isTest 
    static void updatePreferredEmailWhenMulitpleEmailsBatch() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.WorkEmail__c = 'test@sf.org';
        testContact.UniversityEmail__c = 'test@sf.org';
        testContact.Preferred_Email__c = null;
        insert testContact;

        Contact contactAfterInsert = [SELECT Id, Preferred_Email__c, Email FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals(null, contactAfterInsert.Preferred_Email__c);
        System.assertEquals(null, contactAfterInsert.Email);

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);  
        CON_Email_BATCH batch = new CON_Email_BATCH(null);

        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        Contact contactAfterBatchUpdate = [SELECT Id, Preferred_Email__c, Email FROM Contact WHERE Id =: testContact.Id];

        System.assertNotEquals(null, contactAfterBatchUpdate.Preferred_Email__c);
        System.assertEquals('test@sf.org', contactAfterBatchUpdate.Email);

    }
    
    /***************************************************************************************************************************************************
    * @description Tests updating a Contact in Batch context with more than one custom email field will not update Preferred Email 
    * and Standard Email fields when Preferred Email Enforcement is disabled
    **************************************************************************************************************************************************/
    @isTest 
    static void updatePreferredEmailWhenMulitpleEmailsBatchNegativeTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.WorkEmail__c = 'test@sf.org';
        testContact.UniversityEmail__c = 'test@sf.org';
        testContact.Preferred_Email__c = null;
        insert testContact;

        Contact contactAfterInsert = [SELECT Id, Preferred_Email__c, Email FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals(null, contactAfterInsert.Preferred_Email__c);
        System.assertEquals(null, contactAfterInsert.Email);

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);
        
         UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        Contact contactAfterBatchUpdate = [SELECT Id, Preferred_Email__c, Email FROM Contact WHERE Id =: testContact.Id];

        System.assertEquals(null, contactAfterBatchUpdate.Preferred_Email__c);
        System.assertEquals(null, contactAfterBatchUpdate.Email);

    }

}