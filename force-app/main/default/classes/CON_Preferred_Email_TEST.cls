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
* @description Test class for CON_Preferred_TDTM - Preferred Email functionality.
*/
@isTest
private class CON_Preferred_Email_TEST {

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
    
        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = 'Alternate Email';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = 'Alternate Email';

        try {
            Test.startTest();
                insert testContactList;
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = 'Alternate Email';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = 'Alternate Email';

        try {
            Test.startTest();
                insert testContactList;
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        
        insert testContactList;
        testContactList[0].Preferred_Email__c = 'Alternate';
        testContactList[1].Preferred_Email__c = 'Alternate';
        try {
            Test.startTest();
                update testContactList;
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        
        insert testContactList;
        testContactList[0].Preferred_Email__c = 'Alternate';
        testContactList[1].Preferred_Email__c = 'Alternate';
        try {
            Test.startTest();
                update testContactList;
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].Email = 'test@sf.org';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].Email = 'test@sf.org';

        Test.startTest();
            insert testContactList;
        Test.stopTest();

        List<Contact> updatedContact = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact];

        System.assertEquals('test@sf.org', updatedContact[0].AlternateEmail__c, 'Alternate Email should be same as standard email');
        System.assertEquals('Alternate Email', updatedContact[0].Preferred_Email__c, 'Preferred Email should be set to Alternate Email');
        System.assertEquals('test@sf.org', updatedContact[1].AlternateEmail__c, 'Alternate Email should be same as standard email');
        System.assertEquals('Alternate Email', updatedContact[1].Preferred_Email__c, 'Preferred Email should be set to Alternate Email');
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].Email = 'test@sf.org';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].Email = 'test@sf.org';

        Test.startTest();
            insert testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact];

        System.assertEquals(null, updatedContactList[0].AlternateEmail__c, 'Alternate Email should be cleared');
        System.assertEquals(null, updatedContactList[0].Preferred_Email__c, 'Preferred Email should be cleared');
        System.assertEquals(null, updatedContactList[1].AlternateEmail__c, 'Alternate Email should be cleared');
        System.assertEquals(null, updatedContactList[1].Preferred_Email__c, 'Preferred Email should be cleared');
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].Email = 'test@sf.org';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].Email = 'test@sf.org';
        
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);
        insert testContactList;
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact];

        System.assertEquals('test@sf.org', updatedContactList[0].AlternateEmail__c, 'Alternate Email should be same as standard email');
        System.assertEquals('Alternate Email', updatedContactList[0].Preferred_Email__c, 'Preferred Email should be alternate email');
        System.assertEquals('test@sf.org', updatedContactList[1].AlternateEmail__c, 'Alternate Email should be same as standard email');
        System.assertEquals('Alternate Email', updatedContactList[1].Preferred_Email__c, 'Preferred Email should be alternate email');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].Email = 'test@sf.org';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].Email = 'test@sf.org';
        
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);
        insert testContactList;
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);
        CON_Email_BATCH batch = new CON_Email_BATCH(null);

        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM COntact];

        System.assertEquals(null, updatedContactList[0].AlternateEmail__c, 'Alternate Email should be cleared');
        System.assertEquals(null, updatedContactList[0].Preferred_Email__c , 'Preferred Email should be cleared');
        System.assertEquals(null, updatedContactList[1].AlternateEmail__c, 'Alternate Email should be cleared');
        System.assertEquals(null, updatedContactList[1].Preferred_Email__c , 'Preferred Email should be cleared');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        
        insert testContactList;
        testContactList[0].Email = 'test@sf.org';
        testContactList[1].Email = 'test@sf.org';
        Test.startTest();
            update testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact];

        System.assertEquals('test@sf.org', updatedContactList[0].AlternateEmail__c, 'Alternate Email should be same as standard email');
        System.assertEquals('Alternate Email', updatedContactList[0].Preferred_Email__c, 'Preferred Email should be alternate email');
        System.assertEquals('test@sf.org', updatedContactList[1].AlternateEmail__c, 'Alternate Email should be same as standard email');
        System.assertEquals('Alternate Email', updatedContactList[1].Preferred_Email__c, 'Preferred Email should be alternate email');
        
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        
        insert testContactList;
        testContactList[0].Email = 'test@sf.org';
        testContactList[1].Email = 'test@sf.org';

        Test.startTest();
            update testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, AlternateEmail__c, Preferred_Email__c FROM Contact];

        System.assertEquals(null, updatedContactList[0].AlternateEmail__c, 'Alternate Email should be cleared');
        System.assertEquals(null, updatedContactList[0].Preferred_Email__c, 'Preferred Email should be cleared');
        System.assertEquals(null, updatedContactList[1].AlternateEmail__c, 'Alternate Email should be cleared');
        System.assertEquals(null, updatedContactList[1].Preferred_Email__c, 'Preferred Email should be cleared');
        
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].AlternateEmail__c = 'test@sf.org';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].AlternateEmail__c = 'test@sf.org';
        insert testContactList;

        List<Contact> insertedContactList = [SELECT Id, Email, AlternateEmail__c, Preferred_Email__c FROM Contact];

        System.assertEquals('test@sf.org', insertedContactList[0].Email);
        System.assertEquals('Alternate Email', insertedContactList[0].Preferred_Email__c);
        System.assertEquals('test@sf.org', insertedContactList[1].Email);
        System.assertEquals('Alternate Email', insertedContactList[1].Preferred_Email__c);

        insertedContactList[0].AlternateEmail__c = '';
        insertedContactList[0].Preferred_Email__c = null;
        insertedContactList[1].AlternateEmail__c = '';
        insertedContactList[1].Preferred_Email__c = null;
        
        Test.startTest();
            update insertedContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, AlternateEmail__c, Preferred_Email__c, Email FROM Contact];

        System.assertEquals(null, updatedContactList[0].AlternateEmail__c, 'Alternate Email should be cleared');
        System.assertEquals(null, updatedContactList[0].Preferred_Email__c, 'Preferred Email should be cleared');
        System.assertEquals(null, updatedContactList[0].Email, 'Standard Email should be cleared');
        System.assertEquals(null, updatedContactList[1].AlternateEmail__c, 'Alternate Email should be cleared');
        System.assertEquals(null, updatedContactList[1].Preferred_Email__c, 'Preferred Email should be cleared');
        System.assertEquals(null, updatedContactList[1].Email, 'Standard Email should be cleared');
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].AlternateEmail__c = 'test@sf.org';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].AlternateEmail__c = 'test@sf.org';
        insert testContactList;

        List<Contact> insertedContactList = [SELECT Id, Email, AlternateEmail__c, Preferred_Email__c FROM Contact];

        System.assertEquals('test@sf.org', insertedContactList[0].Email);
        System.assertEquals('Alternate Email', insertedContactList[0].Preferred_Email__c);
        System.assertEquals('test@sf.org', insertedContactList[1].Email);
        System.assertEquals('Alternate Email', insertedContactList[1].Preferred_Email__c);

        MAPR_CON_PreferredEmailFields.preferredEmailFieldSettingsModel = null;
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );        


        insertedContactList[0].AlternateEmail__c = '';
        insertedContactList[0].Preferred_Email__c = null;
        insertedContactList[1].AlternateEmail__c = '';
        insertedContactList[1].Preferred_Email__c = null;
        
        Test.startTest();
            update insertedContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, AlternateEmail__c, Preferred_Email__c, Email FROM Contact];

        System.assertEquals(null, updatedContactList[0].AlternateEmail__c, 'Alternate Email should be cleared');
        System.assertEquals(null, updatedContactList[0].Preferred_Email__c, 'Preferred Email should be cleared');
        System.assertEquals('test@sf.org', updatedContactList[0].Email, 'Standard Email should not be cleared');
        System.assertEquals(null, updatedContactList[1].AlternateEmail__c, 'Alternate Email should be cleared');
        System.assertEquals(null, updatedContactList[1].Preferred_Email__c, 'Preferred Email should be cleared');
        System.assertEquals('test@sf.org', updatedContactList[1].Email, 'Standard Email should not be cleared');

    }

    /*********************************************************************************************************************************
    * @description Tests Updating a Contact by clearing Preferred Email and other custom email fields, leaving one email field populated
    * will not repopule values in Standard Email and Preferred Email when Preferred Email Enforcement is disabled
    *********************************************************************************************************************************/
    @isTest 
    static void clearStandEmailAndSomeEmailFieldsOnUpdateTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
            );

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = 'demo@sf.org';
        testContactList[0].Preferred_Email__c = 'Work Email';
        testContactList[0].AlternateEmail__c = 'test@sf.org';
        testContactList[1].WorkEmail__c = 'demo@sf.org';
        testContactList[1].Preferred_Email__c = 'Work Email';
        testContactList[1].AlternateEmail__c = 'test@sf.org';
        insert testContactList;

        List<Contact> insertedContactList = [SELECT Id, Email, AlternateEmail__c, Preferred_Email__c FROM Contact];

        System.assertEquals('demo@sf.org', insertedContactList[0].Email, 'Standard Email should be same as Work Email');
        System.assertEquals('demo@sf.org', insertedContactList[1].Email, 'Standard Email should be same as Work Email');

        MAPR_CON_PreferredEmailFields.preferredEmailFieldSettingsModel = null;
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );        

        // Clear Alternate Email, Preferred Email and Standard Email leaving only work email populated
        insertedContactList[0].AlternateEmail__c = '';
        insertedContactList[0].Preferred_Email__c = null;
        insertedContactList[0].Email = null;
        insertedContactList[1].AlternateEmail__c = '';
        insertedContactList[1].Preferred_Email__c = null;
        insertedContactList[1].Email = null;

        Test.startTest();
            update insertedContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, AlternateEmail__c, Preferred_Email__c, WorkEmail__c, Email FROM Contact];

        System.assertEquals('demo@sf.org', updatedContactList[0].WorkEmail__c, 'Work Email should not be cleared');
        System.assertEquals('demo@sf.org', updatedContactList[1].WorkEmail__c, 'Work Email should not be cleared');
        System.assertEquals(null, updatedContactList[0].AlternateEmail__c, 'Alternate Email should not be re-populated');
        System.assertEquals(null, updatedContactList[0].Preferred_Email__c, 'Preferred Email should not be re-populated');
        System.assertEquals(null, updatedContactList[0].Email, 'Standard Email should not not be re-populated');
        System.assertEquals(null, updatedContactList[1].AlternateEmail__c, 'Alternate Email should not be re-populated');
        System.assertEquals(null, updatedContactList[1].Preferred_Email__c, 'Preferred Email should not be re-populated');
        System.assertEquals(null, updatedContactList[1].Email, 'Standard Email should not be re-populated');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].AlternateEmail__c = 'test@sf.org';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].AlternateEmail__c = 'test@sf.org';

        Test.startTest();
            insert testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, Email, Preferred_Email__c FROM Contact];
        System.assertEquals('test@sf.org', updatedContactList[0].Email, 'Email should be populated with Alternate Email value');
        System.assertEquals('Alternate Email', updatedContactList[0].Preferred_Email__c, 'Preferred Email shoule be Alternate Email');
        System.assertEquals('test@sf.org', updatedContactList[1].Email, 'Email should be populated with Alternate Email value');
        System.assertEquals('Alternate Email', updatedContactList[1].Preferred_Email__c, 'Preferred Email shoule be Alternate Email');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].AlternateEmail__c = 'test@sf.org';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].AlternateEmail__c = 'test@sf.org';

        Test.startTest();
            insert testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, Email, Preferred_Email__c FROM Contact];
        System.assertEquals(null, updatedContactList[0].Email, 'Standard Email should not be popualted');
        System.assertEquals(null, updatedContactList[0].Preferred_Email__c, 'Preferred Email should not be popualted');
        System.assertEquals(null, updatedContactList[1].Email, 'Standard Email should not be popualted');
        System.assertEquals(null, updatedContactList[1].Preferred_Email__c, 'Preferred Email should not be popualted');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        insert testContactList;

        testContactList[0].AlternateEmail__c = 'test@sf.org';
        testContactList[1].AlternateEmail__c = 'test@sf.org';
        
        Test.startTest();
            update testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, Email, Preferred_Email__c FROM Contact];
        System.assertEquals('test@sf.org', updatedContactList[0].Email,  'Email should be populated with Alternate Email value');
        System.assertEquals('Alternate Email', updatedContactList[0].Preferred_Email__c, 'Preferred Email should not be popualted');
        System.assertEquals('test@sf.org', updatedContactList[1].Email, 'Email should be populated with Alternate Email value');
        System.assertEquals('Alternate Email', updatedContactList[1].Preferred_Email__c, 'Preferred Email should not be popualted');

    }
    
    /*************************************************************************************************************************
    * @description Tests Updating a Contact with only one custom Email field will not set Preferred Email and will not copy 
    * the value to standard the Email field when Preferred Email Enforcement is disbaled
    **************************************************************************************************************************/
    @isTest 
    static void singleEmailSmartSetOnUpdateNegativeTest() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        insert testContactList;

        testContactList[0].AlternateEmail__c = 'test@sf.org';
        testContactList[1].AlternateEmail__c = 'test@sf.org';
        Test.startTest();
            update testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, Email, Preferred_Email__c FROM Contact];
        System.assertEquals(null, updatedContactList[0].Email, 'Standard Email should not be popualted');
        System.assertEquals(null, updatedContactList[0].Preferred_Email__c, 'Preferred Email should not be popualted');
        System.assertEquals(null, updatedContactList[1].Email, 'Standard Email should not be popualted');
        System.assertEquals(null, updatedContactList[1].Preferred_Email__c, 'Preferred Email should not be popualted');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].AlternateEmail__c = 'test@sf.org';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].AlternateEmail__c = 'test@sf.org';
        testContactList[1].WorkEmail__c = 'test@sf.org';

        try {
            Test.startTest();
                insert testContactList;
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].AlternateEmail__c = 'test@sf.org';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].AlternateEmail__c = 'test@sf.org';
        testContactList[1].WorkEmail__c = 'test@sf.org';

        Test.startTest();
            insert testContactList;
        Test.stopTest();

        List<Contact> insertedContactList = [SELECT Id, Email, Preferred_Email__c FROM Contact];
        System.assertEquals(null, insertedContactList[0].Preferred_Email__c, 'Preferred Email should not be popualted');
        System.assertEquals(null, insertedContactList[0].Email, 'Standard Email should not be popualted');
        System.assertEquals(null, insertedContactList[1].Preferred_Email__c, 'Preferred Email should not be popualted');
        System.assertEquals(null, insertedContactList[1].Email, 'Standard Email should not be popualted');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        insert testContactList;

        try {
            testContactList[0].AlternateEmail__c = 'test@sf.org';
            testContactList[0].WorkEmail__c = 'test@sf.org';
            testContactList[1].AlternateEmail__c = 'test@sf.org';
            testContactList[1].WorkEmail__c = 'test@sf.org';
            Test.startTest();
                update testContactList;
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        insert testContactList;

        testContactList[0].AlternateEmail__c = 'test@sf.org';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].AlternateEmail__c = 'test@sf.org';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        
        Test.startTest();
            update testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, preferred_Email__c, Email FROM Contact];
        System.assertEquals(null, updatedContactList[0].preferred_Email__c, 'Preferred Email should not be popualted');
        System.assertEquals(null, updatedContactList[0].Email, 'Standard Email should not be popualted');
        System.assertEquals(null, updatedContactList[1].preferred_Email__c, 'Preferred Email should not be popualted');
        System.assertEquals(null, updatedContactList[1].Email, 'Standard Email should not be popualted');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = '';
        testContactList[0].Preferred_Email__c = 'Alternate Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Email = '';
        testContactList[1].Preferred_Email__c = 'Alternate Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';

        try {
            Test.startTest();
                insert testContactList;
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = '';
        testContactList[0].Preferred_Email__c = 'Alternate Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Email = '';
        testContactList[1].Preferred_Email__c = 'Alternate Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';

        try {
            Test.startTest();
                insert testContactList;
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].WorkEmail__c = '';
        testContactList[1].Email = '';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].WorkEmail__c = '';
        insert testContactList;

        testContactList[0].Preferred_Email__c = 'Alternate Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = 'Alternate Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        
        try {
            Test.startTest();
                update testContactList;
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[0].WorkEmail__c = '';
        testContactList[1].Email = '';
        testContactList[1].Preferred_Email__c = '';
        testContactList[1].WorkEmail__c = '';
        insert testContactList;

        testContactList[0].Preferred_Email__c = 'Alternate Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = 'Alternate Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        
        try {
            Test.startTest();
                update testContactList;
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Preferred_Email__c = 'Work Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[0].Email = '';
        testContactList[1].Preferred_Email__c = 'Work Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        testContactList[1].Email = '';

        Test.startTest();
            insert testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, Email FROM Contact];
        System.assertEquals(testContactList[0].WorkEmail__c, updatedContactList[0].Email);
        System.assertEquals(testContactList[1].WorkEmail__c, updatedContactList[1].Email);

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Preferred_Email__c = 'Work Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[0].Email = '';
        testContactList[1].Preferred_Email__c = 'Work Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        testContactList[1].Email = '';

        Test.startTest();
            insert testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, Email FROM Contact];
        System.assertEquals('test@sf.org', updatedContactList[0].Email, 'Email should be same as Work Email');
        System.assertEquals('test@sf.org', updatedContactList[1].Email, 'Email should be same as Work Email');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = '';
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[1].Email = '';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        insert testContactList;

        testContactList[0].Preferred_Email__c = 'Work Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = 'Work Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        Test.startTest();
            update testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, Email FROM Contact];
        System.assertEquals('test@sf.org', updatedContactList[0].Email, 'Email should be same as Work Email');
        System.assertEquals('test@sf.org', updatedContactList[1].Email, 'Email should be same as Work Email');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = '';
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = '';
        testContactList[1].Email = '';
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = '';
        insert testContactList;

        testContactList[0].Preferred_Email__c = 'Work Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = 'Work Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        Test.startTest();
            update testContactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, Email FROM Contact];
        System.assertEquals('test@sf.org', updatedContactList[0].Email, 'Email should be same as Work Email');
        System.assertEquals('test@sf.org', updatedContactList[1].Email, 'Email should be same as Work Email');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Preferred_Email__c = 'Test sf Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = 'Test sf Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';

        try {
        Test.startTest();
            insert testContactList;
        Test.stopTest();
        System.assert(false, 'Always throw an error when the field corresponding to Preferred Email is not found.');
        } catch (DmlException error) {
             System.assert(error.getMessage().contains(Label.PreferredEmailMatchMustExist));
        }
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Preferred_Email__c = 'Test sf Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = 'Test sf Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';

        try {
        Test.startTest();
            insert testContactList;
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = null; 
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = null; 
        insert testContactList;

        testContactList[0].Preferred_Email__c = 'Test sf Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = 'Test sf Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';

        try {
            Test.startTest();
                update  testContactList[0];
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
        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].WorkEmail__c = '';
        testContactList[0].Preferred_Email__c = null; 
        testContactList[1].WorkEmail__c = '';
        testContactList[1].Preferred_Email__c = null; 
        insert testContactList;

        testContactList[0].Preferred_Email__c = 'Test sf Email';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = 'Test sf Email';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        
        try {
            Test.startTest();
                update  testContactList[0];
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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = 'TestingEmail@sf.org';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[0].Preferred_Email__c = null;
        testContactList[1].Email = 'TestingEmail@sf.org';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = null;
        insert testContactList;

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);  
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Contact> contactAfterBatchUpdateList = [SELECT Id, Preferred_Email__c FROM Contact];

        System.assertEquals(Label.preferredBatchDefaultEmail, contactAfterBatchUpdateList[0].Preferred_Email__c, 'Email should be populated with default email');
        System.assertEquals(Label.preferredBatchDefaultEmail, contactAfterBatchUpdateList[1].Preferred_Email__c, 'Email should be populated with default email');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = 'TestingEmail@sf.org';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[0].Preferred_Email__c = null;
        testContactList[1].Email = 'TestingEmail@sf.org';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = null;
        insert testContactList;

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Contact> contactAfterBatchUpdateList = [SELECT Id, Preferred_Email__c FROM Contact];

        System.assertEquals(null, contactAfterBatchUpdateList[0].Preferred_Email__c, 'Preferred Email should be null');
        System.assertEquals(null, contactAfterBatchUpdateList[1].Preferred_Email__c, 'Preferred Email should be null');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = 'test@sf.org';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[0].UniversityEmail__c = 'testUniv@sf.org';
        testContactList[0].Preferred_Email__c = null;
        testContactList[1].Email = 'test@sf.org';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        testContactList[1].UniversityEmail__c = 'testUniv@sf.org';
        testContactList[1].Preferred_Email__c = null;
        insert testContactList;

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);  
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Contact> contactAfterBatchUpdateList = [SELECT Id, Preferred_Email__c FROM Contact];

        System.assertEquals('Work Email', contactAfterBatchUpdateList[0].Preferred_Email__c, 'Preferred Email should be Work Email');
        System.assertEquals('Work Email', contactAfterBatchUpdateList[1].Preferred_Email__c, 'Preferred Email should be Work Email');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = 'test@sf.org';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[0].UniversityEmail__c = 'testUniv@sf.org';
        testContactList[0].Preferred_Email__c = null;
        testContactList[1].Email = 'test@sf.org';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        testContactList[1].UniversityEmail__c = 'testUniv@sf.org';
        testContactList[1].Preferred_Email__c = null;
        insert testContactList;

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Contact> contactAfterBatchUpdateList = [SELECT Id, Preferred_Email__c FROM Contact];

        System.assertEquals(null, contactAfterBatchUpdateList[0].Preferred_Email__c, 'Preferred Email should be null');
        System.assertEquals(null, contactAfterBatchUpdateList[1].Preferred_Email__c, 'Preferred Email should be null');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = '';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[0].Preferred_Email__c = null;
        testContactList[1].Email = '';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = null;
        insert testContactList;

        List<Contact> contactAfterInsertList = [SELECT Id, Preferred_Email__c, Email FROM Contact];

        System.assertEquals(null, contactAfterInsertList[0].Preferred_Email__c);
        System.assertEquals(null, contactAfterInsertList[0].Email);
        System.assertEquals(null, contactAfterInsertList[1].Preferred_Email__c);
        System.assertEquals(null, contactAfterInsertList[1].Email);

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);  
        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Contact> contactAfterBatchUpdateList = [SELECT Id, Preferred_Email__c, Email FROM Contact];

        System.assertEquals('Work Email', contactAfterBatchUpdateList[0].Preferred_Email__c, 'Preferred Email should work email');
        System.assertEquals('test@sf.org', contactAfterBatchUpdateList[0].Email, 'Standard Email should be same as work email');
        System.assertEquals('Work Email', contactAfterBatchUpdateList[1].Preferred_Email__c, 'Preferred Email should work email');
        System.assertEquals('test@sf.org', contactAfterBatchUpdateList[1].Email, 'Standard Email should be same as work email');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = '';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[0].Preferred_Email__c = null;
        testContactList[1].Email = '';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = null;
        insert testContactList;

        List<Contact> contactAfterInsert = [SELECT Id, Preferred_Email__c, Email FROM Contact];

        System.assertEquals(null, contactAfterInsert[0].Preferred_Email__c);
        System.assertEquals(null, contactAfterInsert[0].Email);
        System.assertEquals(null, contactAfterInsert[1].Preferred_Email__c);
        System.assertEquals(null, contactAfterInsert[1].Email);

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Contact> contactAfterBatchUpdateList = [SELECT Id, Preferred_Email__c, Email FROM Contact];

        System.assertEquals(null, contactAfterBatchUpdateList[0].Preferred_Email__c, 'Preferred Email should be null');
        System.assertEquals(null, contactAfterBatchUpdateList[0].Email, 'Standard Email is null');
        System.assertEquals(null, contactAfterBatchUpdateList[1].Preferred_Email__c, 'Preferred Email should be null');
        System.assertEquals(null, contactAfterBatchUpdateList[1].Email, 'Standard Email is null');

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

        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = '';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[0].UniversityEmail__c = 'test@sf.org';
        testContactList[0].Preferred_Email__c = null;
        testContactList[1].Email = '';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        testContactList[1].UniversityEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = null;
        insert testContactList;

        List<Contact> contactAfterInsertList = [SELECT Id, Preferred_Email__c, Email FROM Contact];

        System.assertEquals(null, contactAfterInsertList[0].Preferred_Email__c);
        System.assertEquals(null, contactAfterInsertList[0].Email);
        System.assertEquals(null, contactAfterInsertList[1].Preferred_Email__c);
        System.assertEquals(null, contactAfterInsertList[1].Email);

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);  
        CON_Email_BATCH batch = new CON_Email_BATCH(null);

        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Contact> contactAfterBatchUpdateList = [SELECT Id, Preferred_Email__c, Email FROM Contact];

        System.assertNotEquals(null, contactAfterBatchUpdateList[0].Preferred_Email__c, 'Preferred Email should be null');
        System.assertEquals('test@sf.org', contactAfterBatchUpdateList[0].Email, 'Standard Email should be same as work email');
        System.assertNotEquals(null, contactAfterBatchUpdateList[1].Preferred_Email__c, 'Preferred Email should be null');
        System.assertEquals('test@sf.org', contactAfterBatchUpdateList[1].Email, 'Standard Email should be same as work email');

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
        List<Contact> testContactList = UTIL_UnitTestData_TEST.getMultipleTestContacts(2);
        testContactList[0].Email = '';
        testContactList[0].WorkEmail__c = 'test@sf.org';
        testContactList[0].UniversityEmail__c = 'test@sf.org';
        testContactList[0].Preferred_Email__c = null;
        testContactList[1].Email = '';
        testContactList[1].WorkEmail__c = 'test@sf.org';
        testContactList[1].UniversityEmail__c = 'test@sf.org';
        testContactList[1].Preferred_Email__c = null;
        insert testContactList;

        List<Contact> contactAfterInsertList = [SELECT Id, Preferred_Email__c, Email FROM Contact];

        System.assertEquals(null, contactAfterInsertList[0].Preferred_Email__c);
        System.assertEquals(null, contactAfterInsertList[0].Email);
        System.assertEquals(null, contactAfterInsertList[1].Preferred_Email__c);
        System.assertEquals(null, contactAfterInsertList[1].Email);


         UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        CON_Email_BATCH batch = new CON_Email_BATCH(null);
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();

        List<Contact> contactAfterBatchUpdateList = [SELECT Id, Preferred_Email__c, Email FROM Contact];

        System.assertEquals(null, contactAfterBatchUpdateList[0].Preferred_Email__c, 'Preferred Email should be null');
        System.assertEquals(null, contactAfterBatchUpdateList[0].Email, 'Standard Email should be null');
        System.assertEquals(null, contactAfterBatchUpdateList[1].Preferred_Email__c, 'Preferred Email should be null');
        System.assertEquals(null, contactAfterBatchUpdateList[1].Email, 'Standard Email should be null');

    }

    /**************************************************************************************************************************
    ******************************************* BULK FUNCTIONAL TESTS *********************************************************
    **************************************************************************************************************************/

    /*****************************************************************************************************************************
    * @description Bulk test for Preferred Email in Insert context when Preferred Email Enforcement is enabled 
    *****************************************************************************************************************************/
    @isTest 
    static void bulkTestToCoverAllPreferredEmailBeforeInsertScenariosWithEnforcementEnabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact1 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact1.Email = '';
        testContact1.Preferred_Email__c = 'Alternate Email';

        Contact testContact2 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact2.Email = 'test@sf.org';

        Contact testContact3 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact3.Email = '';
        testContact3.AlternateEmail__c = 'test@sf.org';

        Contact testContact4 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact4.Email = '';
        testContact4.AlternateEmail__c = 'test@sf.org';
        testContact4.WorkEmail__c = 'test@sf.org';

        Contact testContact5 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact5.Email = '';
        testContact5.Preferred_Email__c = 'Alternate Email';
        testContact5.WorkEmail__c = 'test@sf.org';

        Contact testContact6 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact6.Preferred_Email__c = 'Alternate Email';
        testContact6.AlternateEmail__c = 'test@sf.org';
        testContact6.Email = '';

        Contact testContact7 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact7.Preferred_Email__c = 'Test sf Email';
        testContact7.WorkEmail__c = 'test@sf.org';

        Contact testContact8 = testContact6.clone(false);
        Contact testContact9 = testContact2.clone(false);

        List<Contact> contactsToBeInserted = new List<Contact> {
            testContact1, testContact2, testContact3, testContact4, testContact5, testContact6, testContact7, testContact8, testContact9
                };
    
        List<Database.saveResult> results = Database.insert(contactsToBeInserted, false);

        System.assertEquals(true, results[1].success);
        System.assertEquals(true, results[2].success);
        System.assertEquals(true, results[5].success);
        System.assertEquals(true, results[7].success);
        System.assertEquals(true, results[8].success);
        System.assertEquals(Label.PreferredEmailMatchNotNull, results[0].errors[0].message);
        System.assertEquals(Label.PreferredEmailRequiredError, results[3].errors[0].message);
        System.assertEquals(Label.PreferredEmailMatchNotNull, results[4].errors[0].message);
        System.assertEquals(Label.PreferredEmailMatchMustExist, results[6].errors[0].message);

        for (Contact contact : [SELECT Id, Preferred_Email__c, Email, AlternateEmail__c FROM Contact WHERE 
                                Id =: results[1].getId() OR 
                                Id =: results[2].getId() OR
                                Id =: results[5].getId()]) {
                                    
           System.assertEquals(contact.AlternateEmail__c, contact.Email);
           System.assertEquals('Alternate Email', contact.Preferred_Email__c);
        }

    }   

    /*****************************************************************************************************************************
    * @description Bulk test for Preferred Email in Insert context when Preferred Email Enforcement is disabled 
    *****************************************************************************************************************************/
    @isTest 
    static void bulkTestToCoverAllPreferredEmailBeforeInsertScenariosWithEnforcementDisbaled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact1 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact1.Email = '';
        testContact1.Preferred_Email__c = 'Alternate Email';

        Contact testContact2 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact2.Email = 'test@sf.org';

        Contact testContact3 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact3.Email = '';
        testContact3.AlternateEmail__c = 'test@sf.org';

        Contact testContact4 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact4.Email = '';
        testContact4.AlternateEmail__c = 'test@sf.org';
        testContact4.WorkEmail__c = 'test@sf.org';

        Contact testContact5 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact5.Email = '';
        testContact5.Preferred_Email__c = 'Alternate Email';
        testContact5.WorkEmail__c = 'test@sf.org';

        Contact testContact6 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact6.Preferred_Email__c = 'Alternate Email';
        testContact6.AlternateEmail__c = 'test@sf.org';
        testContact6.Email = '';

        Contact testContact7 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact7.Preferred_Email__c = 'Test sf Email';
        testContact7.WorkEmail__c = 'test@sf.org';

        List<Contact> contactsToBeInserted = new List<Contact> {
            testContact1, testContact2, testContact3, testContact4, testContact5, testContact6, testContact7
                };
       
        List<Database.saveResult> results = Database.insert(contactsToBeInserted, false);

        for (Database.saveResult eachResult: results) {
            if (eachResult != results[0] && eachResult != results[4] && eachResult != results[6]) {
                System.assertEquals(true, eachResult.success);   
            } else if (eachResult == results[0] || eachResult == results[4]) {
                System.assertEquals(Label.PreferredEmailMatchNotNull, results[0].errors[0].message);
                System.assertEquals(Label.PreferredEmailMatchNotNull, results[4].errors[0].message);
            } else {
                System.assertEquals(Label.PreferredEmailMatchMustExist, results[6].errors[0].message);
            }
        }
    }

    /*****************************************************************************************************************************
    * @description Bulk test for Preferred Email in Update context when Preferred Email Enforcement is enabled 
    *****************************************************************************************************************************/
    @isTest 
    static void bulkTestToCoverAllPreferredEmailBeforeUpdateScenariosWithEnforcementEnabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact1 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact1.Email = '';

        Contact testContact2 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact2.Email = '';

        Contact testContact3 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact3.Email = '';

        Contact testContact4 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact4.Email = '';

        Contact testContact5 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact5.Email = '';

        Contact testContact6 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact6.Email = '';

        Contact testContact7 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact7.Email = '';

        Contact testContact8 = testContact6.clone(false);
        Contact testContact9 = testContact2.clone(false);

        List<Contact> contactsToBeInserted = new List<Contact> {
            testContact1, testContact2, testContact3, testContact4, testContact5, testContact6, testContact7, testContact8, testContact9
                };

        insert contactsToBeInserted;

        List<Contact> insertedContactList = [SELECT Id FROM Contact];
        System.assertEquals(9, insertedContactList.size());

        testContact1.Preferred_Email__c = 'Alternate Email';
        testContact2.Email = 'test@sf.org';
        testContact3.AlternateEmail__c = 'test@sf.org';
        testContact4.AlternateEmail__c = 'test@sf.org';
        testContact4.WorkEmail__c = 'test@sf.org';
        testContact5.Preferred_Email__c = 'Alternate Email';
        testContact5.WorkEmail__c = 'test@sf.org';
        testContact6.Preferred_Email__c = 'Alternate Email';
        testContact6.AlternateEmail__c = 'test@sf.org';
        testContact7.Preferred_Email__c = 'Test sf Email';
        testContact7.WorkEmail__c = 'test@sf.org';
        testContact8.Preferred_Email__c = 'Alternate Email';
        testContact8.AlternateEmail__c = 'test@sf.org';
        testContact9.Email = 'test@sf.org';

        List<Contact> contactsToBeUpdated = new List<Contact> {
            testContact1, testContact2, testContact3, testContact4, testContact5, testContact6, testContact7, testContact8, testContact9
                };

        List<Database.saveResult> results = Database.update(contactsToBeUpdated, false);

        System.assertEquals(true, results[1].success);
        System.assertEquals(true, results[2].success);
        System.assertEquals(true, results[5].success);
        System.assertEquals(true, results[7].success);
        System.assertEquals(true, results[8].success);
        System.assertEquals(Label.PreferredEmailMatchNotNull, results[0].errors[0].message);
        System.assertEquals(Label.PreferredEmailRequiredError, results[3].errors[0].message);
        System.assertEquals(Label.PreferredEmailMatchNotNull, results[4].errors[0].message);
        System.assertEquals(Label.PreferredEmailMatchMustExist, results[6].errors[0].message);

        for (Contact contact : [SELECT Id, Preferred_Email__c, Email, AlternateEmail__c FROM Contact WHERE 
                                Id =: results[1].getId() OR 
                                Id =: results[2].getId() OR
                                Id =: results[5].getId()]) {
                                    
           System.assertEquals(contact.AlternateEmail__c, contact.Email);
           System.assertEquals('Alternate Email', contact.Preferred_Email__c);
        }

    }

    /*****************************************************************************************************************************
    * @description Bulk test for Preferred Email in Update context when Preferred Email Enforcement is disabled 
    *****************************************************************************************************************************/
    @isTest 
    static void bulkTestToCoverAllPreferredEmailBeforeUpdateScenariosWithEnforcementDisabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact1 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact1.Email = '';
        
        Contact testContact2 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact2.Email = '';

        Contact testContact3 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact3.Email = '';

        Contact testContact4 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact4.Email = '';

        Contact testContact5 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact5.Email = '';

        Contact testContact6 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact6.Email = '';

        Contact testContact7 = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact7.Email = '';

        List<Contact> contactsToBeInserted = new List<Contact> {
            testContact1, testContact2, testContact3, testContact4, testContact5, testContact6, testContact7
                };

        insert contactsToBeInserted;

        List<Contact> insertedContactList = [SELECT Id FROM Contact];
        System.assertEquals(7, insertedContactList.size());

        testContact1.Preferred_Email__c = 'Alternate Email';
        testContact2.Email = 'test@sf.org';
        testContact3.AlternateEmail__c = 'test@sf.org';
        testContact4.AlternateEmail__c = 'test@sf.org';
        testContact4.WorkEmail__c = 'test@sf.org';
        testContact5.Preferred_Email__c = 'Alternate Email';
        testContact5.WorkEmail__c = 'test@sf.org';
        testContact6.Preferred_Email__c = 'Alternate Email';
        testContact6.AlternateEmail__c = 'test@sf.org';
        testContact7.Preferred_Email__c = 'Test sf Email';
        testContact7.WorkEmail__c = 'test@sf.org';

        List<Contact> contactsToBeUpdated = new List<Contact> {
            testContact1, testContact2, testContact3, testContact4, testContact5, testContact6, testContact7
                };

        List<Database.saveResult> results = Database.update(contactsToBeUpdated, false);

        for (Database.saveResult eachResult: results) {
            if (eachResult != results[0] && eachResult != results[4] && eachResult != results[6]) {
                System.assertEquals(true, eachResult.success);   
            } else if (eachResult == results[0] || eachResult == results[4]) {
                System.assertEquals(Label.PreferredEmailMatchNotNull, results[0].errors[0].message);
                System.assertEquals(Label.PreferredEmailMatchNotNull, results[4].errors[0].message);
            } else {
                System.assertEquals(Label.PreferredEmailMatchMustExist, results[6].errors[0].message);
            }
        }
        
    }

    /*****************************************************************************************************************************
    * @description Bulk test for Preferred Email in Batch context when Preferred Email Enforcement is enabled 
    *****************************************************************************************************************************/
    @isTest 
    static void preferredEMailBatchBulkTest() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        // Get contacts set up
        List<Contact> contactList = UTIL_UnitTestData_API.getMultipleTestContacts(10);
        for (Integer i = 0; i < 10; i++) {

            contactList[i].LastName = 'ToAvoidDupeRule' + i;//Avoid duplicate matching
            contactList[i].WorkEmail__c = ''; // clear email field set in getMultipleTestContacts
            contactList[i].Preferred_Email__c = ''; // clear preferred field set in getMultipleTestContacts
            System.assert(contactList[i].email == null);
        }

        insert contactList;

        List<String> contIds = new List<String>();

        List<Contact> contacts = [SELECT Id, Name, Preferred_Email__c, Email, AlternateEmail__c,UniversityEmail__c, WorkEmail__c FROM Contact];

        String caseOneId;
        String caseTwoId;

        // Process the contact for testing
        if(contacts.size() > 0) {

            for (Integer i = 0; i < contacts.size(); i++) {

                // Setup special Case 1
                if(i==5) {
                    contacts[5].Email = 'uniquwemailtest5nomatch@domainemail.com';
                    contacts[5].AlternateEmail__c = 'alternate5@domainemail.com';
                    contacts[5].UniversityEmail__c = null;
                    contacts[5].WorkEmail__c = null;
                    contacts[5].Preferred_Email__c = '';
                    caseOneId = contacts[5].Id;

                // Setup special Case 2
                } else if (i==6) {
                    contacts[6].AlternateEmail__c = 'alternate6@domainemail.com';
                    contacts[6].Email = '';
                    contacts[6].WorkEmail__c = null;
                    contacts[6].Preferred_Email__c = '';
                    caseTwoId = contacts[6].Id;

                } else {
                    contacts[i].Email = 'emailtest' + i + '@domainemail.com';
                    contacts[i].UniversityEmail__c = null;
                    contacts[i].WorkEmail__c = null;
                    contacts[i].AlternateEmail__c = null;
                    contacts[i].Preferred_Email__c = null;
                    contIds.add(contacts[i].Id);
                }
            }

            TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);
            update contacts;
        }

        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);
        // Run Batch
        Test.startTest();
            CON_Email_BATCH contbatch = new CON_Email_BATCH(null);
        Database.executeBatch( contbatch );
        Test.stopTest();

        // After batch run assert leaving off the two contacts for special cases
        contacts = [SELECT Id, Name, Email, AlternateEmail__c FROM Contact WHERE Id in: contIds AND Id!=:caseOneId AND Id !=: caseTwoId];
        for(Contact contact : contacts) {
            System.assertEquals(contact.AlternateEmail__c , contact.Email );
        }

        // Check special Case 1
        Contact contactOne = [SELECT Id, Name, Email, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE Id =:caseOneId LIMIT 1];
        System.assertEquals('uniquwemailtest5nomatch@domainemail.com', contactOne.Email);
        System.assertEquals(Label.preferredBatchDefaultEmail, contactOne.Preferred_Email__c);

        // Check special Case 2
        Contact contactTwo = [SELECT Id, Name, Email, AlternateEmail__c, Preferred_Email__c FROM Contact WHERE Id =:caseTwoId LIMIT 1];
        System.assertEquals(contactTwo.Email, contactTwo.AlternateEmail__c);
        System.assertEquals('Alternate Email', contactTwo.Preferred_Email__c);

    }

    /**************************************************************************************************************************
    ******************************************* LEAD CONVERSION TEST *********************************************************
    **************************************************************************************************************************/
    @isTest 
    static void testLeadConversion() {
        // create a Lead
        Lead testLead = new Lead(
            FirstName='Joshua',
            LastName='McTesterman',
            Email='mctesterman@mctesersite.com',
            Company='Test',
            Status='Inquiry'
        );

        insert testLead;

        Database.LeadConvert convertedLead = new Database.LeadConvert();
        convertedLead.setLeadId(testLead.Id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        convertedLead.setConvertedStatus(convertStatus.MasterLabel);

        Test.startTest();		
            Database.LeadConvertResult convertedLeadResult = Database.convertLead(convertedLead);
        Test.stopTest();

        Contact contact = [SELECT Id, Name, Email FROM Contact WHERE Id =:convertedLeadResult.getContactId() LIMIT 1];

        System.assertEquals(contact.Email, testLead.Email);
    }
}