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
* @group
* @group-content ../../ApexDocContent/Contacts.htm
* @description Test class for SRVC_Contact_PreferredEmail.cls
*/
@isTest
private class SRVC_Contact_PreferredEmail_TEST {

    /**************************************************************************************************************************
    *********************************************** TESTS FOR getInstance() ***************************************************
    **************************************************************************************************************************/

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns a new instance of the 
    * SRVC_Contact_PreferredEmail class when one does not already exist.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceNew() {
        SRVC_Contact_PreferredEmail preferredEmailSRVCInstance = SRVC_Contact_PreferredEmail.getInstance();
        System.assertEquals(SRVC_Contact_PreferredEmail.instance, preferredEmailSRVCInstance, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(true, preferredEmailSRVCInstance != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the getInstance method returns the existing instance of the 
    * SRVC_Contact_PreferredEmail class when one already exists.
    ***************************************************************************************************************************/
    @isTest
    private static void getInstanceExisting() {
        SRVC_Contact_PreferredEmail preferredEmailSRVCInstance1 = SRVC_Contact_PreferredEmail.getInstance();
        SRVC_Contact_PreferredEmail preferredEmailSRVCInstance2 = SRVC_Contact_PreferredEmail.getInstance();

        System.assertEquals(SRVC_Contact_PreferredEmail.instance, preferredEmailSRVCInstance1, 'Instance of service class returned should match static instance variable.');
        System.assertEquals(preferredEmailSRVCInstance1, preferredEmailSRVCInstance2, 'Subsequent retrievals of service class instance should return existing instance.');
        System.assertEquals(true, preferredEmailSRVCInstance1 != null, 'Instance of service class should not be null.');
    }

    /**************************************************************************************************************************
    *********************************************** TESTS FOR processPreferredEmailForInsert() ********************************
    **************************************************************************************************************************/

    /**************************************************************************************************************************
    * @description Test method to verify that the processPreferredEmailForInsert returns null when the Contact has Email fields
    * no values.
    ***************************************************************************************************************************/
    @isTest
    private static void processPreferredEmailForInsertWithEmptyEmailFields() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().processPreferredEmailForInsert(testContact, MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel());
        Test.stopTest();

        System.assertEquals(null, returnedContact);
    }

    /**************************************************************************************************************************
    * @description Test method to verify that the processPreferredEmailForInsert adds error to the Contact when there are
    * more than 1 email fields with values and when preferred email is not set.
    **************************************************************************************************************************/
    @isTest
    private static void processPreferredEmailForInsertWithErrors() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = null;
        testContact.AlternateEmail__c = 'test@gmail.com';
        testContact.WorkEmail__c = 'test@gmail.com';
        Contact returnedContact;

        Test.startTest();
            returnedContact = SRVC_Contact_PreferredEmail.getInstance().processPreferredEmailForInsert(testContact, MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel());
        Test.stopTest();

        System.assertNotEquals(null, returnedContact);
        System.assertEquals(true, returnedContact.hasErrors());
        System.assertEquals(Label.PreferredEmailRequiredError, returnedContact.getErrors()[0].getMessage());

    }

    /**************************************************************************************************************************
    * @description Test method to verify that the processPreferredEmailForInsert updates Preferred_Email__c to the label that
    * has a value and sets Email to the value containing in the Custom Email field 
    ***************************************************************************************************************************/
    @isTest
    private static void processPreferredEmailForInsertWithNonEmptyEmailFields() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.AlternateEmail__c = 'test@sf.org';

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().processPreferredEmailForInsert(testContact, MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel());
        Test.stopTest();

        System.assertNotEquals(null, returnedContact);
        System.assertEquals('Alternate Email', returnedContact.Preferred_Email__c);
        System.assertEquals(testContact.AlternateEmail__c, returnedContact.Email);
    }

    /**************************************************************************************************************************
    ******************************************** TESTS FOR processPreferredEmailForUpdate() ***********************************
    **************************************************************************************************************************/

    /**************************************************************************************************************************
    * @description Test method to verify that the processPreferredEmailForUpdate adds error to the Contact when Preferred Email
    * is set and corresponding Email field is not set
    **************************************************************************************************************************/
    @isTest
    private static void processPreferredEmailForUpdateWithEmptyEmailFieldsAndErrors() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact oldContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        oldContact.Email = null;

        Contact newContact = oldContact.clone(false);
        newContact.Preferred_Email__c = 'Alternate Email';

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().processPreferredEmailForUpdate(newContact, oldContact, MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel());
        Test.stopTest();

        System.assertNotEquals(null, returnedContact);
        System.assertEquals(true, returnedContact.hasErrors());
        System.assertEquals(Label.PreferredEmailMatchNotNull, returnedContact.getErrors()[0].getMessage());

    }
    
    /****************************************************************************************************************************
    * @description Test method to verify that the processPreferredEmailForUpdate, updates Preferred_Email__c to 'Alternate Email'
    * and sets AlternateEmail__c to the value in 'Email' when only Email is set
    *****************************************************************************************************************************/
    @isTest
    private static void processPreferredEmailForUpdateWithNonEmptyEmailFields() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        Contact oldContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        oldContact.Email = null;

        Contact newContact = oldContact.clone(false);
        newContact.Email = 'test@sf.org';
        
        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().processPreferredEmailForUpdate(newContact, oldContact, MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel());
        Test.stopTest();

        System.assertEquals('Alternate Email', returnedContact.Preferred_Email__c);
        System.assertEquals(returnedContact.AlternateEmail__c, newContact.Email);

    }

    /**************************************************************************************************************************
    *************************************** TESTS FOR handleEmptyContactEmailFieldsForInsert() ********************************
    **************************************************************************************************************************/

    /***************************************************************************************************************************************
    * @description Test method to verify that the handleEmptyContactEmailFieldsForInsert, returns a Contact with PreferredEmailMatchNotNull
    * error when Preferred Email is set, and corresponding Email field is not set.
    ***************************************************************************************************************************************/
    @isTest
    private static void handleEmptyContactEmailFieldsForInsertPrefEmailNotBlank() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.Preferred_Email__c = 'TestEmail@sf.org';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleEmptyContactEmailFieldsForInsert(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertNotEquals(null, returnedContact);
        System.assertEquals(true, returnedContact.hasErrors());
        System.assertEquals(Label.PreferredEmailMatchNotNull, returnedContact.getErrors()[0].getMessage());

    }

    /***************************************************************************************************************************************
    * @description Test method to verify that the handleEmptyContactEmailFieldsForInsert, returns null when Preferred Email is and all other
    * Email fields are not set when Preferred Email Enforcement is disabled
    ***************************************************************************************************************************************/
    @isTest
    private static void handleEmptyContactEmailFieldsForInsertWithValidationDisabled() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.Preferred_Email__c = '';

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleEmptyContactEmailFieldsForInsert(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals(null, returnedContact);
    }

    /***************************************************************************************************************************************
    * @description Test method to verify that the handleEmptyContactEmailFieldsForInsert, returns null when Preferred Email is and all other
    * Email fields are not set when Preferred Email Enforcement is enabled
    ***************************************************************************************************************************************/

    @isTest
    private static void handleEmptyContactEmailFieldsForInsertWithEmailBlank() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.Preferred_Email__c = '';

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleEmptyContactEmailFieldsForInsert(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals(null, returnedContact);
    }

    /*****************************************************************************************************************************************
    * @description Test method to verify that the handleEmptyContactEmailFieldsForInsert, returns a Contact with Alternate Email and Preferred
    * Email fields populated when only standard Email field had a value set
    ******************************************************************************************************************************************/
    @isTest
    private static void handleEmptyContactEmailFieldsForInsertWithPopulateAlternateEmail() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = 'test@sf.org';
        testContact.Preferred_Email__c = '';

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
        );

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleEmptyContactEmailFieldsForInsert(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals(testContact.Email, returnedContact.AlternateEmail__c);
        System.assertEquals('Alternate Email', returnedContact.Preferred_Email__c);
    }

    /**************************************************************************************************************************
    *************************************** TESTS FOR handleEmptyContactEmailFieldsForUpdate() ********************************
    **************************************************************************************************************************/

    /*****************************************************************************************************************************************
    * @description Test method to verify that the handleEmptyContactEmailFieldsForUpdate, returns a Contact with PreferredEmailMatchNotNull
    * error when Preferred Email is set and its corresponding Email field is not set.
    ******************************************************************************************************************************************/
    @isTest
    private static void handleEmptyContactEmailFieldsForUpdatePrefEmailNotBlank() {

        Contact oldContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        oldContact.Email = '';

        Contact newContact = oldContact.clone(false);
        newContact.Preferred_Email__c = 'TestEmail@sf.org';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(newContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleEmptyContactEmailFieldsForUpdate(contactModel, oldContact, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertNotEquals(null, returnedContact);
        System.assertEquals(true, returnedContact.hasErrors());
        System.assertEquals(Label.PreferredEmailMatchNotNull, returnedContact.getErrors()[0].getMessage());

    }

    /*****************************************************************************************************************************************
    * @description Test method to verify that the handleEmptyContactEmailFieldsForUpdate, returns null when Preferred Email and no other Email
    * type fields have a value when Preferred Email Enforcement is disabled
    ******************************************************************************************************************************************/
    @isTest
    private static void handleEmptyContactEmailFieldsForUpdateWithValidationDisabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact oldContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        oldContact.Email = '';

        Contact newContact = oldContact.clone(false);
        newContact.Preferred_Email__c = '';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(newContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleEmptyContactEmailFieldsForUpdate(contactModel, oldContact, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals(null, returnedContact);

    }

    /*****************************************************************************************************************************************
    * @description Test method to verify that the handleEmptyContactEmailFieldsForUpdate, returns null when Preferred Email and no other Email
    * type fields have a value
    ******************************************************************************************************************************************/  
    @isTest
    private static void handleEmptyContactEmailFieldsForUpdateWithStandardEmailBlank() {

        Contact oldContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        oldContact.Email = '';

        Contact newContact = oldContact.clone(false);
        newContact.Preferred_Email__c = '';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(newContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleEmptyContactEmailFieldsForUpdate(contactModel, oldContact, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals(null, returnedContact);

    }

    /*****************************************************************************************************************************************
    * @description Test method to verify that the handleEmptyContactEmailFieldsForUpdate, handleEmptyContactEmailFieldsForUpdate returns
    * null when Email fields and Preferred Email is cleared
    ******************************************************************************************************************************************/
    @isTest
    private static void handleEmptyContactEmailFieldsForUpdateWithEmptyModel() {

        Contact oldContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        oldContact.Email = 'Test@sf.org';
        oldContact.AlternateEmail__c = 'Test@sf.org';
        oldContact.Preferred_Email__c = 'Alternate Email';

        Contact newContact = oldContact.clone(false);
        newContact.Preferred_Email__c = '';
        newContact.AlternateEmail__c = '';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(newContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleEmptyContactEmailFieldsForUpdate(contactModel, oldContact, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals(null, returnedContact.Email);

    }

    /*******************************************************************************************************************************************
    * @description Test method to verify that the handleEmptyContactEmailFieldsForUpdate, sets Preferred Email and Alternate Email to the value
    * in the Email field
    ********************************************************************************************************************************************/
    @isTest
    private static void handleEmptyContactEmailFieldsForUpdateWithPopulateAlternateEmail() {

        Contact oldContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        oldContact.Email = '';
        oldContact.Preferred_Email__c = '';

        Contact newContact = oldContact.clone(false);
        newContact.Email = 'Test@sf.org';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(newContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleEmptyContactEmailFieldsForUpdate(contactModel, oldContact, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals('Alternate Email', returnedContact.preferred_Email__c);
        System.assertEquals(newContact.Email, returnedContact.AlternateEmail__c);

    }

    /**************************************************************************************************************************
    *************************************** TESTS FOR handleContactEmailFields() **********************************************
    **************************************************************************************************************************/
 
    /*******************************************************************************************************************************************
    * @description Test method to verify that the handleContactEmailFields, returns null when Preferred Email Enforcement is Disabled and 
    * when only Preferred Email is set
    ********************************************************************************************************************************************/
    @isTest
    private static void handleContactEmailFieldsWithValidationDisabled() {

        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = 'Email';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

         Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleContactEmailFields(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals(null, returnedContact); 

    }
    
    /*******************************************************************************************************************************************
    * @description Test method to verify that the handleContactEmailFields, returns a Contact with PreferredEmailRequiredError when more than
    * 1 Email fields are set and Preferred Email is not set 
    ********************************************************************************************************************************************/
    @isTest
    private static void handleContactEmailFieldsWithMultipleEmailError() {
 
        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = '';
        testContact.UniversityEmail__c = 'test@sf.org';
        testContact.WorkEmail__c = 'test@sf.org';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleContactEmailFields(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertNotEquals(null, returnedContact);
        System.assertEquals(true, returnedContact.hasErrors());
        System.assertEquals(Label.PreferredEmailRequiredError, returnedContact.getErrors()[0].getMessage());

    }

    /*******************************************************************************************************************************************
    * @description Test method to verify that the handleContactEmailFields, returns a Contact with PreferredEmailMatchMustExist Error when 
    * Preferred Email is set and no other Email fields are set
    ********************************************************************************************************************************************/
    @isTest
    private static void handleContactEmailFieldsWithPreferredEmailNotFoundError() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = 'Test Email';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleContactEmailFields(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertNotEquals(null, returnedContact);
        System.assertEquals(true, returnedContact.hasErrors());
        System.assertEquals(Label.PreferredEmailMatchMustExist, returnedContact.getErrors()[0].getMessage());

    }

    /*******************************************************************************************************************************************
    * @description Test method to verify that the handleContactEmailFields, returns a Contact with Preferred Email and  Email set when only
    * one other Custom Email field is set
    ********************************************************************************************************************************************/
    @isTest
    private static void handleContactEmailFieldsWithSetPreferredEmail() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.UniversityEmail__c = 'Test Email';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleContactEmailFields(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

		System.assertEquals('University Email', testContact.Preferred_Email__c);
        System.assertEquals(testContact.UniversityEmail__c, testContact.Email);

    }

    /**************************************************************************************************************************
    *************************************** TESTS FOR handleContactEmailFieldsForInsertAndUpdate() ***********************************
    **************************************************************************************************************************/

    /**************************************************************************************************************************
    * @description Test method to verify that the handleContactEmailFieldsForInsertAndUpdate method returns null when Preferred Email 
    * and all other Email type fields are not set
    ***************************************************************************************************************************/
    @isTest
    private static void handleContactEmailFieldsForInsertAndUpdateWithPrefEmailBlank() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleContactEmailFieldsForInsertAndUpdate(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals(null, returnedContact);

    }

    /**************************************************************************************************************************
    * @description Test method to verify that the handleContactEmailFieldsForInsertAndUpdate method returns null when Preferred Email 
    * is set to preferredBatchDefaultEmail and all other Email type fields are not set
    ***************************************************************************************************************************/
    @isTest
    private static void handleContactEmailFieldsForInsertAndUpdateWithDefaultBatch() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = Label.preferredBatchDefaultEmail;

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleContactEmailFieldsForInsertAndUpdate(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals(null, returnedContact);

    }

    /**************************************************************************************************************************
    * @description Test method to verify that the handleContactEmailFieldsForInsertAndUpdate method returns null when Preferred Email 
    * is set to 'Email' and all other Email type fields are not set
    ***************************************************************************************************************************/
    @isTest
    private static void handleContactEmailFieldsForInsertAndUpdateWithStandardEmail() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = 'Email';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleContactEmailFieldsForInsertAndUpdate(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals(null, returnedContact);

    }
    
    /********************************************************************************************************************************************
    * @description Test method to verify that the handleContactEmailFieldsForInsertAndUpdate method returns a Contact with PreferredEmailMatchMustExist
    * error when the value in Preferred Email doesn't match with any of the Email type fields
    *********************************************************************************************************************************************/
    @isTest
    private static void handleContactEmailFieldsForInsertAndUpdateWithNonExistingField() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = 'Testing Email';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleContactEmailFieldsForInsertAndUpdate(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertNotEquals(null, returnedContact);
        System.assertEquals(true, returnedContact.hasErrors());
        System.assertEquals(Label.PreferredEmailMatchMustExist, returnedContact.getErrors()[0].getMessage());
    }

    /********************************************************************************************************************************************
    * @description Test method to verify that the handleContactEmailFieldsForInsertAndUpdate method returns a Contact with PreferredEmailMatchNotNull
    * error when there is a value in Preferred Email, and the corresponding email type field is blank
    *********************************************************************************************************************************************/
    @isTest
    private static void handleContactEmailFieldsForInsertAndUpdateWithValueCorrespondingToPrefEmailBlank() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = 'University Email';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleContactEmailFieldsForInsertAndUpdate(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertNotEquals(null, returnedContact);
        System.assertEquals(true, returnedContact.hasErrors());
        System.assertEquals(Label.PreferredEmailMatchNotNull, returnedContact.getErrors()[0].getMessage());

    }

    /********************************************************************************************************************************************
    * @description Test method to verify that the handleContactEmailFieldsForInsertAndUpdate method copies the value from email type field corresponding
    * to Preferred Email
    *********************************************************************************************************************************************/
    @isTest
    private static void handleContactEmailFieldsForInsertAndUpdateWCopyValueToStandardEmail() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = 'University Email';
        testContact.UniversityEmail__c = 'University Email';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().handleContactEmailFieldsForInsertAndUpdate(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals(testContact.UniversityEmail__c, returnedContact.Email); 

    }

    /**************************************************************************************************************************
    *************************************** TESTS FOR populateAlternateEmailAndSetAsPreferred() *******************************
    **************************************************************************************************************************/

    /**************************************************************************************************************************
    * @description Test method to verify populateAlternateEmailAndSetAsPreffered sets Preferred Email to 'Alternate Email'
    * and Alternate Email to the value in the standard email field
    ***************************************************************************************************************************/
    @isTest
    private static void populateAlternateEmailAndSetAsPreferred() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = 'test@sf.org';

        MODL_PreferredEmailSettings preferredEmailSettingsModel = MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel();
        SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, preferredEmailSettingsModel);

        Test.startTest();
            Contact returnedContact = SRVC_Contact_PreferredEmail.getInstance().populateAlternateEmailAndSetAsPreffered(contactModel, preferredEmailSettingsModel);
        Test.stopTest();

        System.assertEquals('Alternate Email', returnedContact.Preferred_Email__c);
        System.assertEquals(testContact.Email, returnedContact.AlternateEmail__c);
    }

    /**************************************************************************************************************************
    ******************************** TESTS FOR getModelFromContactWithNoPreferredEmailAndNoEmailFields() **********************
    **************************************************************************************************************************/

    /**************************************************************************************************************************
    * @description Test method to verify getModelFromContact returns a Contact model with No Email field models when Preferred
    * Email is not set and all other custom email field types are null
    ***************************************************************************************************************************/
    @isTest
    private static void getModelFromContactWithNoPreferredEmailAndNoEmailFields() {
 
        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = null;

        Test.startTest();
            SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel());
        Test.stopTest();

        System.assertEquals(false, contactModel.hasPrefEmailField);
        System.assertEquals(null, contactModel.prefEmailFieldValue);
        System.assertEquals(0, contactModel.contactEmailFieldModels.size());
        System.assertEquals(null, contactModel.currentEmailModel);

    }

    /**************************************************************************************************************************
    * @description Test method to verify getModelFromContact returns a Contact model with 1 Email field models, prefEmailFieldValue
    * set when Preferred Email is set and all other custom email field types are null
    ***************************************************************************************************************************/
    @isTest
    private static void getModelFromContactWithPreferredEmail() {

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Preferred_Email__c = 'Alternate Email';
        testContact.AlternateEmail__c = 'test@sf.org';

        Test.startTest();
            SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel());
        Test.stopTest();

        System.assertEquals(true, contactModel.hasPrefEmailField);
        System.assertEquals(testContact.AlternateEmail__c, contactModel.prefEmailFieldValue);
        System.assertEquals(1, contactModel.contactEmailFieldModels.size());
        System.assertEquals(null, contactModel.currentEmailModel);

    }

    /******************************************************************************************************************************
    * @description Test method to verify getModelFromContact returns a Contact model with 1 Email field models
    * when Preferred Email is not set and only 1 custom email field types is set
    ******************************************************************************************************************************/
    @isTest
    private static void getModelFromContactWithNoPreferredEmail() {
 
        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.AlternateEmail__c = 'test@sf.org';

        Test.startTest();
            SRVC_Contact_PreferredEmail.MODL_Contact contactModel = SRVC_Contact_PreferredEmail.getInstance().getModelFromContact(testContact, MAPR_CON_PreferredEmailFields.getInstance().getPreferredEmailSettingsModel());
        Test.stopTest();

        System.assertEquals(false, contactModel.hasPrefEmailField);
        System.assertEquals(null, contactModel.prefEmailFieldValue);
        System.assertEquals(1, contactModel.contactEmailFieldModels.size());
        System.assertEquals(null, contactModel.currentEmailModel);

    }
}