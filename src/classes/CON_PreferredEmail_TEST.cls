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
* @description Test class for Preferred Email functionality
*/
@isTest
private class CON_PreferredEmail_TEST {

	@isTest 
    static void preferredEmailNotBlankOnInsertWithEnforcementEnabled() {
		UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = false)
            );

        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.Preferred_Email__c = 'Alternate';

        try {
            Test.startTest();
                insert testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the value corresponding to Preferred Email is Blank.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchNotNull));
        }
    }
    
    @isTest 
    static void preferredEmailNotBlankOnInsertWithEnforcementDisabled() {
        UTIL_CustomSettingsFacade.getSettingsForTests(
            new Hierarchy_Settings__c(Disable_Preferred_Email_Enforcement__c = true)
        );
        
        Contact testContact = UTIL_UnitTestData_TEST.getUniqueContact(1);
        testContact.Email = '';
        testContact.Preferred_Email__c = 'Alternate';
        
        try {
            Test.startTest();
            insert testContact;
            Test.stopTest();
            System.assert(false, 'Always throw an error when the value corresponding to Preferred Email is Blank.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains(Label.PreferredEmailMatchNotNull));
        }
    }

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

        System.assertEquals(updatedContact.AlternateEmail__c, testContact.Email);
        System.assertEquals('Alternate Email', updatedContact.Preferred_Email__c);

    }
    
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
        
        System.assertEquals(updatedContact.AlternateEmail__c, testContact.Email);
        System.assertEquals('Alternate Email', updatedContact.Preferred_Email__c);

    }

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
        
        System.assertEquals(updatedContact.AlternateEmail__c, testContact.Email);
        System.assertEquals('Alternate Email', updatedContact.Preferred_Email__c);
        
    }

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
        System.assertEquals('test@sf.org', contactAfterBatchUpdate.Email);

    }

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
}