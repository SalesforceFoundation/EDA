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
 * @description Test for Contact primary affilation fields functionality.
 */
@isTest
private with sharing class CON_PrimaryAffls_TEST {
    private static Integer contactCount = 100; // used to determine number of test contact records to create

    /**************************************************************************************************************************
     ****************************************************** UNIT TESTS *********************************************************
     **************************************************************************************************************************/

    /********************************************************
     * @description Tests setAffiliationUpdateRecursion method
     *********************************************************/
    @isTest
    static void setAffiliationUpdateRecursion() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();

        Test.startTest();
        tdtmClass.setAffiliationUpdateRecursion();
        Test.stopTest();

        Boolean keyLookupUpdated = TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated
        );

        System.assertEquals(true, keyLookupUpdated, 'keyLookupUpdated should be active for CON_PrimaryAffls_TDTM');
    }

    /******************************************************
     * @description Tests setInsertRecursion method
     *******************************************************/
    @isTest
    static void setInsertRecursion() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();

        Test.startTest();
        tdtmClass.setInsertRecursion();
        Test.stopTest();

        Boolean afterInsert = TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert
        );

        System.assertEquals(true, afterInsert, 'afterInsert should be active for CON_PrimaryAffls_TDTM');
    }

    /*******************************************************
     * @description Tests setUpdateRecursion method
     ********************************************************/
    @isTest
    static void setUpdateRecursion() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();

        Test.startTest();
        tdtmClass.setUpdateRecursion();
        Test.stopTest();

        Boolean afterUpdate = TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update
        );

        System.assertEquals(true, afterUpdate, 'afterUpdate should be active for CON_PrimaryAffls_TDTM');
    }

    /*******************************************************
     * @description Tests unsetInsertRecursion method
     ********************************************************/
    @isTest
    static void unsetInsertRecursion() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        tdtmClass.setInsertRecursion();

        Test.startTest();
        tdtmClass.unsetInsertRecursion();
        Test.stopTest();

        Boolean isInsertRecursion = TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert
        );

        System.assertEquals(
            false,
            isInsertRecursion,
            'Insert recursion should not be active for CON_PrimaryAffls_TDTM'
        );
    }

    /*******************************************************
     * @description Tests unsetInsert recursion method
     *******************************************************/
    @isTest
    static void unsetUpdateRecursion() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        tdtmClass.setUpdateRecursion();

        Test.startTest();
        tdtmClass.unsetUpdateRecursion();
        Test.stopTest();

        Boolean isUpdateRecursion = TDTM_ProcessControl.getRecursionFlag(
            TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert
        );

        System.assertEquals(
            false,
            isUpdateRecursion,
            'Update recursion should not be active for CON_PrimaryAffls_TDTM'
        );
    }

    /*******************************************************
     * @description Tests isInsertRecursion method
     *******************************************************/
    @isTest
    static void isInsertRecursion() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        tdtmClass.setInsertRecursion();

        Test.startTest();
        Boolean isInsertRecursion = tdtmClass.isInsertRecursion();
        Test.stopTest();

        System.assertEquals(true, isInsertRecursion, 'Insert recursion should not be active for CON_PrimaryAffls_TDTM');
    }

    /*******************************************************
     * @description Tests IsUpdateRecursion method for
     * CON_PrimaryAffls_TDTM_After_Update flag
     *******************************************************/
    @isTest
    static void isupdateRecursionForAfterUpdate() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        tdtmClass.setUpdateRecursion();

        Test.startTest();
        Boolean isUpdateRecursion = tdtmClass.isUpdateRecursion();
        Test.stopTest();

        System.assertEquals(true, isUpdateRecursion, 'Update recursion should not be active for CON_PrimaryAffls_TDTM');
    }

    /*******************************************************
     * @description Tests IsUpdateRecursion method for
     * AFFL_AccRecordType_TDTM flag
     *******************************************************/
    @isTest
    static void isupdateRecursionForAfflAccRecType() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.AFFL_AccRecordType_TDTM, true);

        Test.startTest();
        Boolean isUpdateRecursion = tdtmClass.isUpdateRecursion();
        Test.stopTest();

        System.assertEquals(true, isUpdateRecursion, 'Update recursion should not be active for CON_PrimaryAffls_TDTM');
    }

    /*******************************************************
     * @description Tests isAffiliationUpdateRecursion method
     *******************************************************/
    @isTest
    static void isAffiliationUpdateRecursion() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        tdtmClass.setUpdateRecursion();

        Test.startTest();
        Boolean isAffiliationUpdateRecursion = tdtmClass.isAffiliationUpdateRecursion();
        Test.stopTest();

        System.assertEquals(
            true,
            isAffiliationUpdateRecursion,
            'Update recursion should not be active for CON_PrimaryAffls_TDTM'
        );
    }

    /*******************************************************
     * @description Tests resetAffiliationUpdateRecursion will
     * reset CON_PrimaryAffls_TDTM_keyAfflLookupUpdated flag
     *******************************************************/
    @isTest
    static void resetAffiliationUpdateRecursion() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        tdtmClass.setAffiliationUpdateRecursion();

        System.assertEquals(
            true,
            TDTM_ProcessControl.getRecursionFlag(
                TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated
            ),
            'update recurssion should be true'
        );

        Test.startTest();
        tdtmClass.resetAffiliationUpdateRecursion();
        Test.stopTest();

        System.assertEquals(
            false,
            TDTM_ProcessControl.getRecursionFlag(
                TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_keyAfflLookupUpdated
            ),
            'Update recursion should be reset'
        );
    }

    /*************************************************************************************************************
     * @description Tests locateAffiliationSettingMapper method of CON_PrimaryAffls_TDTM
     *************************************************************************************************************/
    @isTest
    private static void locateAffiliationSettingMapperTest() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        Test.startTest();
        MAPR_PrimaryAffiliations primaryAfflInstance = tdtmClass.locateAffiliationSettingMapper();
        Test.stopTest();

        MAPR_PrimaryAffiliations maprInstance = MAPR_PrimaryAffiliations.getInstance();

        System.assertEquals(maprInstance, primaryAfflInstance);
    }

    /*************************************************************************************************************
     * @description Tests locateContactAffiliationService method of CON_PrimaryAffls_TDTM
     **************************************************************************************************************/
    @isTest
    private static void locateContactAffiliationService() {
        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        Test.startTest();
        SRVC_Contact_PrimaryAffiliations primaryAfflInstance = tdtmClass.locateContactAffiliationService();
        Test.stopTest();

        SRVC_Contact_PrimaryAffiliations srvcInstance = SRVC_Contact_PrimaryAffiliations.getInstance();

        System.assertEquals(srvcInstance, primaryAfflInstance);
    }

    /*************************************************************************************************************
     * @description NULL test for run method to verify new DmlWrapper(); is returned when newList is null
     *************************************************************************************************************/
    @isTest
    private static void runMethodNULLTest() {
        TDTM_Runnable.Action testAction = TDTM_Runnable.Action.AfterUpdate;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;

        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        Test.startTest();
        TDTM_Runnable.DmlWrapper dmlWrapperReturned = tdtmClass.run(null, null, testAction, objResult);
        Test.stopTest();

        System.assertEquals(0, dmlWrapperReturned.objectsToInsert.size());
    }

    /*************************************************************************************************************
     * @description Test for run method to verify new DmlWrapper(); is returned when newList is empty
     *************************************************************************************************************/
    @isTest
    private static void runMethodEmptyTest() {
        List<Contact> newContactsList = new List<Contact>();
        List<SObject> oldContactList = new List<SObject>();

        TDTM_Runnable.Action testAction = TDTM_Runnable.Action.AfterUpdate;
        Schema.DescribeSObjectResult objResult = Schema.SObjectType.Contact;

        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        Test.startTest();
        TDTM_Runnable.DmlWrapper dmlWrapperReturned = tdtmClass.run(
            newContactsList,
            oldContactList,
            testAction,
            objResult
        );
        Test.stopTest();

        System.assertEquals(0, dmlWrapperReturned.objectsToInsert.size());
    }

    /*************************************************************************************************************
     * @description Positive test method for run method afterInsert to ensure affiliations are created on insert
     *************************************************************************************************************/
    @isTest
    static void runMethodTestForAfterInsert() {
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = prefix + 'Primary_Organization__c'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = prefix + 'Primary_Household__c'
            )
        );
        insert mappings;

        Account businessAccount1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount1;

        Schema.DescribeSObjectResult contactDescribeResult = UTIL_Describe.getObjectDescribe('Contact');

        List<Contact> newContactList = new List<Contact>();

        for (integer i = 0; i < 5; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactWithPrimaryBusinessOrg.Primary_Organization__c = businessAccount1.Id;
            newContactList.add(contactWithPrimaryBusinessOrg);
        }

        insert newContactList;

        List<Affiliation__c> affiliationAfterInsertList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(5, affiliationAfterInsertList.size());

        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();

        Test.startTest();
        TDTM_Runnable.DmlWrapper dmlWrapper = tdtmClass.run(
            (List<SObject>) newContactList,
            null,
            TDTM_Runnable.Action.AfterInsert,
            contactDescribeResult
        );
        Test.stopTest();

        List<Affiliation__c> affiliationList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(10, affiliationList.size(), '5 more affiliation records should be inserted');
    }

    /*************************************************************************************************************
     * @description Positive test method for run method afterUpdate to ensure affiliations are created
     * when contact is updated with Primary Field
     **************************************************************************************************************/
    @isTest
    static void runMethodTestForAfterUpdate() {
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = prefix + 'Primary_Organization__c'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = prefix + 'Primary_Household__c'
            )
        );
        insert mappings;

        Account businessAccount1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount1;

        Schema.DescribeSObjectResult contactDescribeResult = UTIL_Describe.getObjectDescribe('Contact');

        List<Contact> oldContactList = new List<Contact>();

        for (integer i = 0; i < 5; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            oldContactList.add(contactWithPrimaryBusinessOrg);
        }

        insert oldContactList;

        List<Contact> newContactList = new List<Contact>();
        for (Contact eachContact : oldContactList) {
            Contact newContact = eachContact.Clone(false);
            newContact.Id = eachContact.Id;
            newContact.Primary_organization__c = businessAccount1.Id;
            newContactList.add(newContact);
        }

        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();

        Test.startTest();
        TDTM_Runnable.DmlWrapper dmlWrapper = tdtmClass.run(
            (List<SObject>) newContactList,
            (List<SObject>) oldContactList,
            TDTM_Runnable.Action.Afterupdate,
            contactDescribeResult
        );
        Test.stopTest();

        List<Affiliation__c> affiliationList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(5, affiliationList.size());
    }

    /*************************************************************************************************************
     * @description Positive test method for handleAfterInsertMethod to ensure affiliations are inserted when
     * Primary field is populated
     *************************************************************************************************************/
    @isTest
    static void handleAfterInsertWithPrimaryBusinessOrg() {
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = prefix + 'Primary_Organization__c'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = prefix + 'Primary_Household__c'
            )
        );
        insert mappings;

        List<Account> businessAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert businessAccounts;

        Schema.DescribeSObjectResult contactDescribeResult = UTIL_Describe.getObjectDescribe('Contact');

        List<Contact> oldContactList = new List<Contact>();

        for (integer i = 0; i < 5; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactWithPrimaryBusinessOrg.Primary_organization__c = businessAccounts[0].Id;
            oldContactList.add(contactWithPrimaryBusinessOrg);
        }

        insert oldContactList;

        List<Affiliation__c> affiliationList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(5, affiliationList.size());

        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();

        Test.startTest();
        tdtmClass.handleAfterInsert(oldContactList);
        Test.stopTest();

        List<Affiliation__c> affiliationAfterCallList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(10, affiliationAfterCallList.size());
        System.assertEquals(
            false,
            TDTM_ProcessControl.getRecursionFlag(
                TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert
            ),
            'Recursion flag should be unset.'
        );
    }

    /*************************************************************************************************************
     * @description Negative test method for run method afterUpdate to ensure no affiliatons are inserted when
     * Primary field is not populated
     **************************************************************************************************************/
    @isTest
    static void handleAfterInsertWithNoPrimaryField() {
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = prefix + 'Primary_Organization__c'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = prefix + 'Primary_Household__c'
            )
        );
        insert mappings;

        List<Account> businessAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert businessAccounts;

        Schema.DescribeSObjectResult contactDescribeResult = UTIL_Describe.getObjectDescribe('Contact');

        List<Contact> oldContactList = new List<Contact>();

        for (integer i = 0; i < 5; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            oldContactList.add(contactWithPrimaryBusinessOrg);
        }

        insert oldContactList;

        List<Affiliation__c> affiliationList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(0, affiliationList.size());

        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();

        Test.startTest();
        tdtmClass.handleAfterInsert(oldContactList);
        Test.stopTest();

        List<Affiliation__c> affiliationAfterCallList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(0, affiliationAfterCallList.size());
        System.assertEquals(
            false,
            TDTM_ProcessControl.getRecursionFlag(
                TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Insert
            ),
            'Recursion flag should be unset.'
        );
    }

    /*************************************************************************************************************
     * @description Test method for run method afterUpdate doesn't create affiliations when flag is on
     **************************************************************************************************************/
    @isTest
    static void handleAfterInsertWithFlagOn() {
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = prefix + 'Primary_Organization__c'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = prefix + 'Primary_Household__c'
            )
        );
        insert mappings;

        List<Account> businessAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert businessAccounts;

        Schema.DescribeSObjectResult contactDescribeResult = UTIL_Describe.getObjectDescribe('Contact');

        List<Contact> oldContactList = new List<Contact>();

        for (integer i = 0; i < 5; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactWithPrimaryBusinessOrg.Primary_Organization__c = businessAccounts[0].Id;
            oldContactList.add(contactWithPrimaryBusinessOrg);
        }

        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        tdtmClass.setInsertRecursion();

        Test.startTest();
        tdtmClass.handleAfterInsert(oldContactList);
        Test.stopTest();

        List<Affiliation__c> affiliationAfterCallList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(0, affiliationAfterCallList.size());
    }

    /*************************************************************************************************************
     * @description Positive test method for run method after Update to ensure affiliations are not created when
     * flag is on
     **************************************************************************************************************/
    @isTest
    static void handleAfterUpdateWithFlagOn() {
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = prefix + 'Primary_Organization__c'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = prefix + 'Primary_Household__c'
            )
        );
        insert mappings;

        List<Account> businessAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert businessAccounts;

        Schema.DescribeSObjectResult contactDescribeResult = UTIL_Describe.getObjectDescribe('Contact');

        List<Contact> oldContactList = new List<Contact>();

        for (integer i = 0; i < 5; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            oldContactList.add(contactWithPrimaryBusinessOrg);
        }

        List<Contact> newContactsList = new List<Contact>();
        for (Contact oldContact : oldContactList) {
            Contact newContact = oldContact.Clone(false);
            newContact.Id = oldContact.Id;
            newContact.Primary_Organization__c = businessAccounts[0].Id;
            newContactsList.add(newContact);
        }

        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();
        tdtmClass.setUpdateRecursion();

        Test.startTest();
        tdtmClass.handleAfterUpdate(oldContactList, newContactsList);
        Test.stopTest();

        List<Affiliation__c> affiliationAfterCallList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(0, affiliationAfterCallList.size());
    }

    /*************************************************************************************************************
     * @description Positive test method for run method afterUpdate to ensure affiliations are created when
     * Contacts are updated with Primary field
     **************************************************************************************************************/
    @isTest
    static void handleAfterUpdateInsertOnly() {
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = prefix + 'Primary_Organization__c'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = prefix + 'Primary_Household__c'
            )
        );
        insert mappings;

        List<Account> businessAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert businessAccounts;

        Schema.DescribeSObjectResult contactDescribeResult = UTIL_Describe.getObjectDescribe('Contact');

        List<Contact> oldContactList = new List<Contact>();

        for (integer i = 0; i < 5; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            oldContactList.add(contactWithPrimaryBusinessOrg);
        }

        insert oldContactList;

        List<Affiliation__c> affiliationList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(0, affiliationList.size());

        List<Contact> newContactsList = new List<Contact>();
        for (Contact oldContact : oldContactList) {
            Contact newContact = oldContact.Clone(false);
            newContact.Id = oldContact.Id;
            newContact.Primary_Organization__c = businessAccounts[0].Id;
            newContactsList.add(newContact);
        }

        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();

        Test.startTest();
        tdtmClass.handleAfterUpdate(oldContactList, newContactsList);
        Test.stopTest();

        List<Affiliation__c> affiliationAfterCallList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(5, affiliationAfterCallList.size());

        System.assertEquals(
            false,
            TDTM_ProcessControl.getRecursionFlag(
                TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update
            ),
            'Recursion flag should be unset.'
        );
    }

    /*************************************************************************************************************
     * @description Positive test method for run method afterUpdate to ensure affiliations are updated when
     * Contacts are cleared with Primary fields
     **************************************************************************************************************/
    @isTest
    static void handleAfterUpdateUpdatesOnly() {
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = prefix + 'Primary_Organization__c'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = prefix + 'Primary_Household__c'
            )
        );
        insert mappings;

        List<Account> businessAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert businessAccounts;

        Schema.DescribeSObjectResult contactDescribeResult = UTIL_Describe.getObjectDescribe('Contact');

        List<Contact> oldContactList = new List<Contact>();

        for (integer i = 0; i < 5; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactWithPrimaryBusinessOrg.Primary_Organization__c = businessAccounts[0].Id;
            oldContactList.add(contactWithPrimaryBusinessOrg);
        }

        insert oldContactList;

        List<Affiliation__c> affiliationList = [SELECT Id FROM Affiliation__c WHERE Primary__c = TRUE];

        System.assertEquals(5, affiliationList.size());

        List<Contact> newContactsList = new List<Contact>();
        for (Contact oldContact : oldContactList) {
            Contact newContact = oldContact.Clone(false);
            newContact.Id = oldContact.Id;
            newContact.Primary_Organization__c = null;
            newContactsList.add(newContact);
        }

        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();

        Test.startTest();
        tdtmClass.handleAfterUpdate(oldContactList, newContactsList);
        Test.stopTest();

        List<Affiliation__c> affiliationAfterCallList = [SELECT Id, Primary__c FROM Affiliation__c];

        System.assertEquals(5, affiliationAfterCallList.size());

        for (Affiliation__c each : affiliationAfterCallList) {
            System.assertEquals(false, each.Primary__c);
        }

        System.assertEquals(
            false,
            TDTM_ProcessControl.getRecursionFlag(
                TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update
            ),
            'Recursion flag should be unset.'
        );
    }

    /*************************************************************************************************************
     * @description Positive test method for run method afterUpdate to test inserts and updates of affiliations
     **************************************************************************************************************/
    @isTest
    static void handleAfterUpdateInsertAndUpdates() {
        String namespace = UTIL_Namespace.getNamespace();
        String prefix = (String.isNotBlank(namespace)) ? namespace + '__' : '';

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = prefix + 'Primary_Organization__c'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = prefix + 'Primary_Household__c'
            )
        );
        insert mappings;

        List<Account> businessAccounts = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert businessAccounts;

        Schema.DescribeSObjectResult contactDescribeResult = UTIL_Describe.getObjectDescribe('Contact');

        List<Contact> oldContactList = new List<Contact>();

        for (integer i = 0; i < 5; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactWithPrimaryBusinessOrg.Primary_Organization__c = businessAccounts[0].Id;
            oldContactList.add(contactWithPrimaryBusinessOrg);
        }

        insert oldContactList;

        List<Affiliation__c> affiliationList = [SELECT Id FROM Affiliation__c WHERE Primary__c = TRUE];

        System.assertEquals(5, affiliationList.size());

        List<Contact> newContactsList = new List<Contact>();
        for (Contact oldContact : oldContactList) {
            Contact newContact = oldContact.Clone(false);
            newContact.Id = oldContact.Id;
            newContact.Primary_Organization__c = businessAccounts[1].Id;
            newContactsList.add(newContact);
        }

        CON_PrimaryAffls_TDTM tdtmClass = new CON_PrimaryAffls_TDTM();

        Test.startTest();
        tdtmClass.handleAfterUpdate(oldContactList, newContactsList);
        Test.stopTest();

        List<Contact> contactList = [
            SELECT Id, (SELECT Id, Contact__c, Account__c, Primary__c FROM Affl_Accounts__r)
            FROM Contact
        ];
        System.assertEquals(5, contactList.size());
        for (Contact eachContact : contactList) {
            System.assertEquals(2, eachContact.Affl_Accounts__r.size());
            for (Affiliation__c affiliation : eachContact.Affl_Accounts__r) {
                if (affiliation.Account__c == businessAccounts[1].Id) {
                    System.assertEquals(true, affiliation.Primary__c);
                }
                System.assertEquals(eachContact.Id, affiliation.Contact__c);
            }
        }

        System.assertEquals(
            false,
            TDTM_ProcessControl.getRecursionFlag(
                TDTM_ProcessControl.registeredTrigger.CON_PrimaryAffls_TDTM_After_Update
            ),
            'Recursion flag should be unset.'
        );
    }

    /**************************************************************************************************************************
     ****************************************************** FUNCTIONAL TESTS ***************************************************
     **************************************************************************************************************************/

    /**************************************************************************************************************************************
     * @description Helper method to generate error message associated with a mapping to a field that does not lookup to Account.
     * @param  affiliationMapping An affiliation mapping with an invalid lookup field mapping.
     * @return The expected error message associated with the generated model.
     **************************************************************************************************************************************/
    private static String getExpectedInvalidFieldMappingErrorMessage(Affl_Mappings__c affiliationMapping) {
        List<String> params = new List<String>{
            Label.stgColContactPrimaryAfflField,
            affiliationMapping.Primary_Affl_Field__c
        };

        return StringHandlingService.getInstance()
            .formatStringWithApostrophesAndParameters(label.invalidContactFieldInAffiliationMapping, params);
    }

    /**************************************************************************************************************************************
     * @description Helper method to generate error message associated with a mapping to an invalid record type.
     * @param  affiliationMapping An affiliation mapping with an invalid record type mapping.
     * @return The expected error message associated with the generated model.
     **************************************************************************************************************************************/
    private static String getExpectedInvalidRTMappingErrorMessage(Affl_Mappings__c affiliationMapping) {
        List<String> params = new List<String>{
            Label.stgColAccountRecordType,
            affiliationMapping.Account_Record_Type__c
        };

        return StringHandlingService.getInstance()
            .formatStringWithApostrophesAndParameters(Label.invalidRecordTypeInAffiliationMapping, params);
    }

    /*************************************************************************************************************
     * @description Test case to verify that inserting a contact with a primary affiliation field populated with record type
     * validation enabled, a valid Contact field mapping and invalid Record Type mapping throws an error.
     **************************************************************************************************************/
    @isTest
    private static void insertContactAfflInvalidRecordTypeError() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);

        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Not a Valid RecordType',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        // insert business account
        Account businessAccount1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount1;

        for (Contact con : testContactsList) {
            con.Primary_Organization__c = businessAccount1.Id;
        }

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.insert(testContactsList, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                CON_PrimaryAffls_TEST.getExpectedInvalidRTMappingErrorMessage(mappings[0]),
                saveResult.getErrors()[0].getMessage(),
                'Invalid Record Type mapping should throw an error when validation is enabled.'
            );
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that inserting a Contact with a primary affiliation field populated with record type
     * validation enabled, a valid Contact field mapping that is not a lookup to Account and valid Record Type mapping throws an error.
     **************************************************************************************************************/
    @isTest
    private static void insertContactAfflInvalidFieldMappingError() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);
        for (Contact con : testContactsList) {
            con.Gender__c = 'Decline to State';
        }

        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Gender__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        String errorMessageText = CON_PrimaryAffls_TEST.getExpectedInvalidFieldMappingErrorMessage(mappings[0]);

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.insert(testContactsList, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'Invalid Record Type mapping should throw an error when validation is enabled.'
            );
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that inserting a Contact with a primary affiliation field populated with record type
     * validation enabled, a valid Contact field mapping to a non-lookup field and invalid Record Type mapping throws
     * an error when the mapped field is populated.
     **************************************************************************************************************/
    @isTest
    private static void insertContactAfflInvalidRTAndInvalidFieldMappingFieldPopulatedInvalidRecordTypeError() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);

        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Not a Valid RecordType',
                Primary_Affl_Field__c = 'FirstName'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        String errorMessageText = CON_PrimaryAffls_TEST.getExpectedInvalidRTMappingErrorMessage(mappings[0]);

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.insert(testContactsList, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'Invalid Record Type mapping should throw an error when validation is enabled.'
            );
        }
    }

    /*************************************************************************************************************
     * @description Ensure affiliations are created on Contact insert.
     **************************************************************************************************************/
    @isTest
    private static void insertContactPrimaryAfflWAccRecTypeUnenforced_English() {
        Test.startTest();
        createAffiliationsOnBulkContactInsert();
        Test.stopTest();
    }

    /*************************************************************************************************************
     * @description For a spanish user, ensure affiliations are created on Contact insert.
     * Test Scenario: T-3939029
     **************************************************************************************************************/
    @isTest
    private static void insertContactPrimaryAfflWAccRecTypeUnenforced_Spanish() {
        Profile systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        System.runAs(UTIL_UnitTestData_TEST.createNewUserForTests(
            System.now().getTime() + '@testerson.com',
            systemAdministratorProfile.Id,
            'es'
        )) {
            Test.startTest();
            createAffiliationsOnBulkContactInsert();
            Test.stopTest();
        }
    }

    /*************************************************************************************************************
     * @description Test case to for a spanish user, verify that updating a primary affiliation field on Contact
     * with record type validation disabled, a valid Contact field mapping to a lookup field and invalid Record
     * Type mapping does not throw an error when the mapped field is not populated.
     * Test Scenario: T-3939030
     **************************************************************************************************************/
    @isTest
    private static void updateContactPrimaryAfflWAccRecTypeUnenforced_Spanish() {
        Profile systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        System.runAs(UTIL_UnitTestData_TEST.createNewUserForTests(
            System.now().getTime() + '@testerson.com',
            systemAdministratorProfile.Id,
            'es'
        )) {
            updateContactAfflInvalidRTAndValidFieldMappingFieldNotPopulatedNoValidationPositive();
        }
    }

    /*************************************************************************************************************
     * @description For a spanish user, ensure affiliations are created on Contact insert, additionally
     * ensure affiliations are updated upon contact primary affiliation reassignment.
     * Test Scenario: T-3939026
     **************************************************************************************************************/
    @isTest
    private static void updateMultipleContactPrimaryAfflWAccRecTypeUnenforced_Spanish() {
        Profile systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        System.runAs(UTIL_UnitTestData_TEST.createNewUserForTests(
            System.now().getTime() + '@testerson.com',
            systemAdministratorProfile.Id,
            'es'
        )) {
            createAffiliationsOnBulkContactInsert();

            // insert secondary business account
            Account businessAccount2 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
                1,
                UTIL_Describe_API.getBizAccRecTypeID()
            )[0];
            insert businessAccount2;

            List<Contact> contactsList = [
                SELECT Id, Primary_Organization__c, (SELECT Account__c, Contact__c, Primary__c FROM Affl_Accounts__r)
                FROM Contact
            ];

            System.assertEquals(100, contactsList.size());
            // Reassign the primary business accounts.
            for (Contact currentContact : contactsList) {
                currentContact.Primary_Organization__c = businessAccount2.Id;
            }

            Test.startTest();
            update contactsList;
            Test.stopTest();

            //Ensure Affiliations appropriately reflect new mapping.
            Integer activeAffiliations = [SELECT COUNT() FROM Affiliation__c WHERE Primary__c = TRUE];
            Integer inactiveAffiliations = [SELECT COUNT() FROM Affiliation__c WHERE Primary__c = FALSE];

            System.assertEquals(100, activeAffiliations);
            System.assertEquals(100, inactiveAffiliations);
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that insert a Contact with primary affiliation field populated with record type
     * validation disabled, a valid Contact field mapping to a non-lookup field and invalid Record Type mapping throws
     * an error when the mapped field is populated.
     **************************************************************************************************************/
    @isTest
    private static void insertContactAfflInvalidRTAndInvalidFieldMappingFieldPopulatedInvalidValidationOffFieldError() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);

        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Not a Valid RecordType',
                Primary_Affl_Field__c = 'FirstName'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        String errorMessageText = CON_PrimaryAffls_TEST.getExpectedInvalidFieldMappingErrorMessage(mappings[0]);

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.insert(testContactsList, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'Invalid Record Type mapping should throw an error when validation is enabled.'
            );
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that inserting a Contact where the mapped primary affiliation field is not
     * populated, with record type validation is disabled, a valid Contact field mapped to a non-lookup field, and an
     * invalid Record Type mapping does not throw an error and does not create an affiliation record.
     **************************************************************************************************************/
    @isTest
    private static void insertContactAfflInvalidRTAndInvalidFieldMappingFieldNotPopulatedNoError() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);

        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Not a Valid RecordType',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Gender__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        Test.startTest();
        insert testContactsList;
        Test.stopTest();

        List<Contact> testContactResultsList = [
            SELECT Id, Primary_Organization__c, (SELECT Id FROM Contact.Affl_Accounts__r)
            FROM Contact
            WHERE Id IN :testContactsList
        ];

        System.assertEquals(100, testContactResultsList.size(), 'Contact records should be created.');

        for (Contact contact : testContactResultsList) {
            System.assertEquals(
                true,
                String.isBlank(contact.Primary_Organization__c),
                'Primary Organization field should be blank.'
            );
            System.assertEquals(
                0,
                contact.Affl_Accounts__r.size(),
                'No related affiliation records should be created.'
            );
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that updating a primary affiliation field on Contact with record type
     * validation disabled, a valid Contact field mapping to a non-lookup field and invalid Record Type mapping does not
     * throw an error when the mapped field is not populated.
     **************************************************************************************************************/
    @isTest
    private static void insertContactAfflInvalidRTAndInvalidFieldMappingFieldNotPopulatedPositive() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);

        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Not a Valid RecordType',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Gender__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        Test.startTest();
        insert testContactsList;
        Test.stopTest();

        List<Contact> testContactResultsList = [
            SELECT Id, Primary_Organization__c, (SELECT Id FROM Contact.Affl_Accounts__r)
            FROM Contact
            WHERE Id IN :testContactsList
        ];

        System.assertEquals(100, testContactResultsList.size());

        for (Contact contact : testContactResultsList) {
            System.assertEquals(
                true,
                String.isBlank(contact.Primary_Organization__c),
                'Primary Organization field should be blank.'
            );
            System.assertEquals(
                0,
                contact.Affl_Accounts__r.size(),
                'No related affiliation records should be created.'
            );
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that updating a primary affiliation field on Contact with record type
     * validation enabled, a valid Contact field mapping and invalid Record Type mapping throws an error.
     **************************************************************************************************************/
    @isTest
    private static void updateContactAfflInvalidRecordTypeError() {
        Hierarchy_Settings__c hs = UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Not a Valid RecordType',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        // insert business account
        Account businessAccount1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount1;

        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);
        insert testContactsList;

        for (Contact con : testContactsList) {
            con.Primary_Organization__c = businessAccount1.Id;
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getExpectedInvalidRTMappingErrorMessage(mappings[0]);

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.update(testContactsList, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'Invalid Record Type mapping should throw an error when validation is enabled.'
            );
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that updating a primary affiliation field on Contact with record type
     * validation enabled, a valid Contact field mapping that is not a lookup to Account and valid Record Type mapping throws an error.
     **************************************************************************************************************/
    @isTest
    private static void updateContactAfflInvalidFieldMappingError() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Gender__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        // insert business account
        Account businessAccount1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount1;

        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);
        insert testContactsList;

        for (Contact con : testContactsList) {
            con.Primary_Organization__c = businessAccount1.Id;
            con.Gender__c = 'Decline to State';
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getExpectedInvalidFieldMappingErrorMessage(mappings[0]);

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.update(testContactsList, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'Invalid Record Type mapping should throw an error when validation is enabled.'
            );
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that updating a primary affiliation field on Contact with record type
     * validation enabled, a valid Contact field mapping to a non-lookup field and invalid Record Type mapping throws
     * an error when the mapped field is populated.
     **************************************************************************************************************/
    @isTest
    private static void updateContactAfflInvalidRTAndInvalidFieldMappingFieldPopulatedInvalidRecordTypeError() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Not a Valid RecordType',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Gender__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);
        insert testContactsList;

        for (Contact con : testContactsList) {
            con.Gender__c = 'Decline to State';
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getExpectedInvalidRTMappingErrorMessage(mappings[0]);

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.update(testContactsList, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'Invalid Record Type mapping should throw an error when validation is enabled.'
            );
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that updating a primary affiliation field on Contact with record type
     * validation enabled, a valid Contact field mapping to a non-lookup field and invalid Record Type mapping does not
     * throw an error when the mapped field is not populated.
     **************************************************************************************************************/
    @isTest
    private static void updateContactAfflInvalidRTAndInvalidFieldMappingFieldNotPopulatedPositive() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);
        for (Contact con : testContactsList) {
            con.FirstName = '';
        }
        insert testContactsList;

        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Not a Valid RecordType',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('FirstName')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        // insert business account
        Account businessAccount1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount1;

        for (Contact con : testContactsList) {
            con.Primary_Organization__c = businessAccount1.Id;
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact> testContactResultsList = [
            SELECT Id, Primary_Organization__c
            FROM Contact
            WHERE Id IN :testContactsList
        ];

        for (Contact con : testContactResultsList) {
            System.assertEquals(businessAccount1.Id, con.Primary_Organization__c);
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that updating a primary affiliation field on Contact with record type
     * validation disabled, a valid Contact field mapping to a lookup field and invalid Record Type mapping does not
     * throw an error when the mapped field is not populated.
     * Test Scenario: T-3939018
     **************************************************************************************************************/
    @isTest
    private static void updateContactAfflInvalidRTAndValidFieldMappingFieldNotPopulatedNoValidationPositive() {
        User u = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id = :UserInfo.getUserId()];
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100, u.LanguageLocaleKey);
        insert testContactsList;

        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Not a Valid RecordType',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        // insert business account
        Account businessAccount1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount1;

        for (Contact con : testContactsList) {
            con.Primary_Organization__c = businessAccount1.Id;
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact> testContactResultsList = [
            SELECT Id, Primary_Organization__c
            FROM Contact
            WHERE Id IN :testContactsList
        ];

        for (Contact con : testContactResultsList) {
            System.assertEquals(businessAccount1.Id, con.Primary_Organization__c);
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that updating a primary affiliation field on Contact with record type
     * validation disabled, a valid Contact field mapping to a lookup field and invalid Record Type mapping does not
     * throw an error when the mapped field is not populated.
     **************************************************************************************************************/
    @isTest
    private static void updateContactAfflInvalidRTAndInValidFieldMappingFieldNotPopulatedNoValidationPositive() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Not a Valid RecordType',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Gender__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);
        insert testContactsList;

        for (Contact con : testContactsList) {
            con.Gender__c = 'Decline to State';
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getExpectedInvalidFieldMappingErrorMessage(mappings[0]);

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.update(testContactsList, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'Invalid Record Type mapping should throw an error when validation is enabled.'
            );
        }
    }

    /*************************************************************************************************************
     * @description Test case to verify that updating a primary affiliation field on Contact with record type
     * validation disabled, a valid Contact field mapping to a lookup field and invalid Record Type mapping does not
     * throw an error when the mapped field is not populated.
     **************************************************************************************************************/
    @isTest
    private static void updateContactAfflValidRTAndValidFieldMappingFieldPopulatedNoValidationPositive() {
        List<Contact> testContactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(100);
        insert testContactsList;

        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false)
        );

        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        Account businessAccount = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount;

        for (Contact con : testContactsList) {
            con.Primary_Organization__c = businessAccount.Id;
        }

        Test.startTest();
        update testContactsList;
        Test.stopTest();

        List<Contact> testContactResultsList = [
            SELECT Id, Primary_Organization__c
            FROM Contact
            WHERE Id IN :testContactsList
        ];

        for (Contact con : testContactResultsList) {
            System.assertEquals(businessAccount.Id, con.Primary_Organization__c);
        }
    }

    private static void createAffiliationsOnBulkContactInsert() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false)
        );

        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        // insert business account
        Account businessAccount1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount1;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactWithPrimaryBusinessOrg.Primary_Organization__c = businessAccount1.Id;
            contactsToBeInserted.add(contactWithPrimaryBusinessOrg);
        }

        insert contactsToBeInserted;
        Map<Id, Contact> ContactsById = new Map<Id, Contact>(contactsToBeInserted);

        //Ensure Primary Business Organization affiliations are created for each Contact
        List<Contact> updatedContactList = [
            SELECT Id, Primary_Organization__c, (SELECT Account__c, Contact__c, Primary__c FROM Affl_Accounts__r)
            FROM Contact
            WHERE Id IN :ContactsById.keySet()
        ];

        System.assertEquals(100, updatedContactList.size());
        for (Contact eachUpdatedContact : updatedContactList) {
            System.assertEquals(1, eachUpdatedContact.Affl_Accounts__r.size());
            for (Affiliation__c affiliation : eachUpdatedContact.Affl_Accounts__r) {
                System.assertEquals(businessAccount1.Id, affiliation.Account__c);
                System.assertEquals(eachUpdatedContact.Id, affiliation.Contact__c);
                System.assertEquals(true, affiliation.Primary__c);
            }
        }
    }

    /*************************************************************************************************************
     * @description Positive bulk test to ensure affiliations are created on Contact update
     **************************************************************************************************************/
    @isTest
    private static void createAffiliationsOnBulkContactupdate() {
        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        // insert business account
        Account businessAccount1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount1;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactsToBeInserted.add(contactWithPrimaryBusinessOrg);
        }

        insert contactsToBeInserted;

        List<Contact> contactToBeUpdatedList = new List<Contact>();

        for (Contact contactToBeUpdated : contactsToBeInserted) {
            contactToBeUpdated.Primary_Organization__c = businessAccount1.Id;
            contactToBeUpdatedList.add(contactToBeUpdated);
        }

        Test.startTest();
        update contactToBeUpdatedList;
        Test.stopTest();
        Map<Id, Contact> ContactsById = new Map<Id, Contact>(contactToBeUpdatedList);

        //Ensure Primary Business Organization affiliations are created for each Contact
        List<Contact> updatedContactList = [
            SELECT Id, Primary_Organization__c, (SELECT Account__c, Contact__c, Primary__c FROM Affl_Accounts__r)
            FROM Contact
            WHERE Id IN :ContactsById.keySet()
        ];

        System.assertEquals(100, updatedContactList.size());
        for (Contact eachUpdatedContact : updatedContactList) {
            System.assertEquals(1, eachUpdatedContact.Affl_Accounts__r.size());
            for (Affiliation__c affiliation : eachUpdatedContact.Affl_Accounts__r) {
                System.assertEquals(businessAccount1.Id, affiliation.Account__c);
                System.assertEquals(eachUpdatedContact.Id, affiliation.Contact__c);
                System.assertEquals(true, affiliation.Primary__c);
            }
        }
    }

    /****************************************************************************************************************
     * @description Tests to ensure that when a Contact is inserted with a primary affiliation field populated, the
     * Contact is created, but no associated affiliation record is inserted when Record Type validation is On with
     * an invalid contact field mapping and valid Record Type mapping.
     **************************************************************************************************************/
    @isTest
    private static void createAffiliationsOnBulkContactInsertWithWrongMappingsWithValidationOn() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c' + 'test')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        // insert business account
        Account businessAccount1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount1;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactWithPrimaryBusinessOrg.Primary_Organization__c = businessAccount1.Id;
            contactsToBeInserted.add(contactWithPrimaryBusinessOrg);
        }

        Test.startTest();
        insert contactsToBeInserted;
        Test.stopTest();

        List<Contact> conList = [
            SELECT Id, (SELECT Id FROM Affl_Accounts__r)
            FROM Contact
            WHERE Id IN :contactsToBeInserted
        ];

        System.assertEquals(100, conList.size(), 'Five Contacts should be created.');

        for (Contact con : conList) {
            System.assertEquals(
                true,
                con.Affl_Accounts__r.isEmpty(),
                'Enabling record type validation with invalid mapping should prevent creation of affiliation records.'
            );
        }
    }

    /****************************************************************************************************************
     * @description Tests to ensure that when a Contact is inserted with a primary affiliation field populated, but the
     * mapping is to a field that is not of type lookup to Account, an invalidContactFieldInAffiliationMapping error is thrown.
     **************************************************************************************************************/
    @isTest
    private static void insertContactWithValidRecordTypeMappingAndInvalidFieldMappingToAccountLookup() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = 'ReportsToId'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        Contact reportToContact = UTIL_UnitTestData_TEST.getUniqueContact(contactCount + 5);
        insert reportToContact;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact con = UTIL_UnitTestData_TEST.getUniqueContact(i);
            con.ReportsToId = reportToContact.Id;
            contactsToBeInserted.add(con);
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getinvalidContactFieldInAffiliationMappingMessage(
            'ReportsToId'
        );

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.insert(contactsToBeInserted, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'An invalidContactFieldInAffiliationMapping error should be thrown.'
            );
        }
    }

    /****************************************************************************************************************
     * @description Tests to ensure that when a Contact is inserted with a primary affiliation field populated, the
     * mapping is to a field that is not of type lookup to Account, Record Type mapping is invalid and validation is
     * enabled, an invalidRecordTypeInAffiliationMapping error is thrown.
     **************************************************************************************************************/
    @isTest
    private static void insertContactWithInvalidRTMappingAndInvalidFieldMappingToAccountLookupValidationOn() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization_Invalid',
                Primary_Affl_Field__c = 'ReportsToId'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        Contact reportToContact = UTIL_UnitTestData_TEST.getUniqueContact(contactCount + 5);
        insert reportToContact;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact con = UTIL_UnitTestData_TEST.getUniqueContact(i);
            con.ReportsToId = reportToContact.Id;
            contactsToBeInserted.add(con);
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getInvalidRecordTypeInAffiliationMappingMessage(
            'Business_Organization_Invalid'
        );

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.insert(contactsToBeInserted, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'An invalidRecordTypeInAffiliationMapping error should be thrown.'
            );
        }
    }

    /****************************************************************************************************************
     * @description Tests to ensure that when a Contact is inserted with a primary affiliation field populated,  the
     * mapping is to a field that is not of type lookup to Account, Record Type mapping is invalid and validation is
     * disabled, an invalidContactFieldInAffiliationMapping error is thrown.
     **************************************************************************************************************/
    @isTest
    private static void insertContactWithInvalidRTMappingAndInvalidFieldMappingToAccountLookupValidationOff() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false)
        );

        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization_Invalid',
                Primary_Affl_Field__c = 'ReportsToId'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        Contact reportToContact = UTIL_UnitTestData_TEST.getUniqueContact(contactCount + 5);
        insert reportToContact;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact con = UTIL_UnitTestData_TEST.getUniqueContact(i);
            con.ReportsToId = reportToContact.Id;
            contactsToBeInserted.add(con);
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getinvalidContactFieldInAffiliationMappingMessage(
            'ReportsToId'
        );

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.insert(contactsToBeInserted, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'An invalidContactFieldInAffiliationMapping error should be thrown.'
            );
        }
    }

    /****************************************************************************************************************
     * @description Tests to ensure that when a Contact is inserted without a primary affiliation field populated,  the
     * mapping is to a field that is not of type lookup to Account, Record Type mapping is invalid and validation is
     * disabled, no error is thrown and the insert completes as expected.
     **************************************************************************************************************/
    @isTest
    private static void insertContactWithNoPrimaryAfflFieldPopulated() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false)
        );

        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization_Invalid',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('ReportsToId')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact con = UTIL_UnitTestData_TEST.getUniqueContact(i);
            con.Gender__c = 'Decline to State';
            contactsToBeInserted.add(con);
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getinvalidContactFieldInAffiliationMappingMessage(
            'ReportsToId'
        );

        Test.startTest();
        insert contactsToBeInserted;
        Test.stopTest();

        List<Contact> contactResultsList = [SELECT Id, Gender__c FROM Contact WHERE Id IN :contactsToBeInserted];

        System.assertEquals(contactCount, contactResultsList.size(), 'Contacts should insert successfully.');

        for (Contact con : contactResultsList) {
            System.assertEquals(
                'Decline to State',
                con.Gender__c,
                'Gender__c field should be set to \'Decline to State\'.'
            );
        }
    }

    /****************************************************************************************************************
     * @description Tests to ensure that when a Contact is updated with a primary affiliation field populated, but the
     * mapping is to a field that is not of type lookup to Account, an invalidContactFieldInAffiliationMapping error is thrown.
     **************************************************************************************************************/
    @isTest
    private static void updateContactWithValidRecordTypeMappingAndInvalidFieldMappingToAccountLookup() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = 'ReportsToId'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        Contact reportToContact = UTIL_UnitTestData_TEST.getUniqueContact(contactCount + 5);
        insert reportToContact;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact con = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactsToBeInserted.add(con);
        }

        insert contactsToBeInserted;

        for (Contact con : contactsToBeInserted) {
            con.ReportsToId = reportToContact.Id;
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getinvalidContactFieldInAffiliationMappingMessage(
            'ReportsToId'
        );

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.update(contactsToBeInserted, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'An invalidContactFieldInAffiliationMapping error should be thrown.'
            );
        }
    }

    /****************************************************************************************************************
     * @description Tests to ensure that when a Contact is updated with a primary affiliation field populated, the
     * mapping is to a field that is not of type lookup to Account, Record Type mapping is invalid and validation is
     * enabled, an invalidRecordTypeInAffiliationMapping error is thrown.
     **************************************************************************************************************/
    @isTest
    private static void updateContactWithInvalidRTMappingAndInvalidFieldMappingToAccountLookupValidationOn() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = true)
        );

        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization_Invalid',
                Primary_Affl_Field__c = 'ReportsToId'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        Contact reportToContact = UTIL_UnitTestData_TEST.getUniqueContact(contactCount + 5);
        insert reportToContact;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact con = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactsToBeInserted.add(con);
        }

        insert contactsToBeInserted;

        for (Contact con : contactsToBeInserted) {
            con.ReportsToId = reportToContact.Id;
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getInvalidRecordTypeInAffiliationMappingMessage(
            'Business_Organization_Invalid'
        );

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.update(contactsToBeInserted, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'An invalidRecordTypeInAffiliationMapping error should be thrown.'
            );
        }
    }

    /****************************************************************************************************************
     * @description Tests to ensure that when a Contact is updated with a primary affiliation field populated,  the
     * mapping is to a field that is not of type lookup to Account, Record Type mapping is invalid and validation is
     * disabled, an invalidContactFieldInAffiliationMapping error is thrown.
     **************************************************************************************************************/
    @isTest
    private static void updateContactWithInvalidRTMappingAndInvalidFieldMappingToAccountLookupValidationOff() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false)
        );

        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization_Invalid',
                Primary_Affl_Field__c = 'ReportsToId'
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        Contact reportToContact = UTIL_UnitTestData_TEST.getUniqueContact(contactCount + 5);
        insert reportToContact;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact con = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactsToBeInserted.add(con);
        }

        insert contactsToBeInserted;

        for (Contact con : contactsToBeInserted) {
            con.ReportsToId = reportToContact.Id;
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getinvalidContactFieldInAffiliationMappingMessage(
            'ReportsToId'
        );

        Test.startTest();
        Database.SaveResult[] saveResultsList = Database.update(contactsToBeInserted, false);
        Test.stopTest();

        for (Database.SaveResult saveResult : saveResultsList) {
            System.assertEquals(
                errorMessageText,
                saveResult.getErrors()[0].getMessage(),
                'An invalidContactFieldInAffiliationMapping error should be thrown.'
            );
        }
    }

    /****************************************************************************************************************
     * @description Tests to ensure that when a Contact is updated without a primary affiliation field populated,  the
     * mapping is to a field that is not of type lookup to Account, Record Type mapping is invalid and validation is
     * disabled, no error is thrown and the update completes as expected.
     **************************************************************************************************************/
    @isTest
    private static void updateContactWithNoPrimaryAfflFieldPopulated() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Affiliation_Record_Type_Enforced__c = false)
        );

        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization_Invalid',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('ReportsToId')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        Contact reportToContact = UTIL_UnitTestData_TEST.getUniqueContact(contactCount + 5);
        insert reportToContact;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact con = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactsToBeInserted.add(con);
        }

        insert contactsToBeInserted;

        for (Contact con : contactsToBeInserted) {
            con.Gender__c = 'Decline to State';
        }

        String errorMessageText = CON_PrimaryAffls_TEST.getinvalidContactFieldInAffiliationMappingMessage(
            'ReportsToId'
        );

        Test.startTest();
        update contactsToBeInserted;
        Test.stopTest();

        List<Contact> contactResultsList = [SELECT Id, Gender__c FROM Contact WHERE Id IN :contactsToBeInserted];

        for (Contact con : contactResultsList) {
            System.assertEquals(
                'Decline to State',
                con.Gender__c,
                'Gender__c field should be updated to \'Decline to State\'.'
            );
        }
    }

    /*************************************************************************************************************************
     * @description Test to ensure Contacts are not created created when mappings have incorrect values and validation is off
     *************************************************************************************************************************/
    @isTest
    private static void createAffiliationsOnBulkContactInsertWithWrongMappingsWithValidationOff() {
        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c' + 'test')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        // insert business account
        Account businessAccount1 = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getBizAccRecTypeID()
        )[0];
        insert businessAccount1;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactWithPrimaryBusinessOrg.Primary_Organization__c = businessAccount1.Id;
            contactsToBeInserted.add(contactWithPrimaryBusinessOrg);
        }

        Test.startTest();
        insert contactsToBeInserted;
        Test.stopTest();

        List<Contact> conList = [SELECT Id FROM Contact];
        List<Affiliation__c> afflList = [SELECT Id FROM Affiliation__c];

        System.assertEquals(100, conList.size());
        System.assertEquals(true, afflList.isEmpty());
    }

    /********************************************************************************************************************************
     * @description Test to ensure new Primary affiliations are created and old ones become non-primary when Primary affiliation field
     * is updated in a Contact record.
     ********************************************************************************************************************************/
    @isTest
    private static void createAffiliationsOnBulkContactupdates() {
        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        // insert business account
        List<Account> businessAccountList = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert businessAccountList;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < contactCount; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactWithPrimaryBusinessOrg.Primary_Organization__c = businessAccountList[0].Id;
            contactsToBeInserted.add(contactWithPrimaryBusinessOrg);
        }

        insert contactsToBeInserted;

        List<Affiliation__c> afflList = [
            SELECT Id
            FROM Affiliation__c
            WHERE Account__c = :businessAccountList[0].Id AND Primary__c = TRUE
        ];
        System.assertEquals(100, afflList.size());

        List<Contact> contactToBeUpdatedList = new List<Contact>();

        for (Contact contactToBeUpdated : contactsToBeInserted) {
            contactToBeUpdated.Primary_Organization__c = businessAccountList[1].Id;
            contactToBeUpdatedList.add(contactToBeUpdated);
        }

        Test.startTest();
        update contactToBeUpdatedList;
        Test.stopTest();
        Map<Id, Contact> ContactsById = new Map<Id, Contact>(contactToBeUpdatedList);

        List<Affiliation__c> afflListWithBizOrg1AsPrimary = [
            SELECT Id
            FROM Affiliation__c
            WHERE Account__c = :businessAccountList[0].Id AND Primary__c = TRUE
        ];
        System.assertEquals(0, afflListWithBizOrg1AsPrimary.size());

        List<Affiliation__c> afflListWithBizOrg2AsPrimary = [
            SELECT Id
            FROM Affiliation__c
            WHERE Account__c = :businessAccountList[1].Id AND Primary__c = TRUE
        ];
        System.assertEquals(100, afflListWithBizOrg2AsPrimary.size());
    }

    /*************************************************************************************************************
     * @description Test to ensure Primary Affiliations are made non-primary when Primary field is cleared on
     * update of a Contact record.
     **************************************************************************************************************/
    @isTest
    private static void makeAffiliationNonPrimaryByClearingField() {
        // insert mappings
        List<Affl_Mappings__c> mappings = new List<Affl_Mappings__c>();
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Business Organization',
                Account_Record_Type__c = 'Business_Organization',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Organization__c')
            )
        );
        mappings.add(
            new Affl_Mappings__c(
                Name = 'Household Account',
                Account_Record_Type__c = 'HH_Account',
                Primary_Affl_Field__c = UTIL_Namespace.StrTokenNSPrefix('Primary_Household__c')
            )
        );
        insert mappings;

        // insert business account
        List<Account> businessAccountList = UTIL_UnitTestData_TEST.getMultipleTestAccounts(
            2,
            UTIL_Describe_API.getBizAccRecTypeID()
        );
        insert businessAccountList;

        List<Contact> contactsToBeInserted = new List<Contact>();
        for (integer i = 0; i < 5; i++) {
            Contact contactWithPrimaryBusinessOrg = UTIL_UnitTestData_TEST.getUniqueContact(i);
            contactWithPrimaryBusinessOrg.Primary_Organization__c = businessAccountList[0].Id;
            contactsToBeInserted.add(contactWithPrimaryBusinessOrg);
        }

        insert contactsToBeInserted;

        List<Affiliation__c> afflList = [
            SELECT Id
            FROM Affiliation__c
            WHERE Account__c = :businessAccountList[0].Id AND Primary__c = TRUE
        ];
        System.assertEquals(5, afflList.size());

        List<Contact> contactToBeUpdatedList = new List<Contact>();

        for (Contact contactToBeUpdated : contactsToBeInserted) {
            contactToBeUpdated.Primary_Organization__c = null;
            contactToBeUpdatedList.add(contactToBeUpdated);
        }

        Test.startTest();
        update contactToBeUpdatedList;
        Test.stopTest();
        Map<Id, Contact> ContactsById = new Map<Id, Contact>(contactToBeUpdatedList);

        List<Affiliation__c> afflListWithBizOrg1AsPrimary = [SELECT Id FROM Affiliation__c WHERE Primary__c = TRUE];
        System.assertEquals(0, afflListWithBizOrg1AsPrimary.size());
    }

    /**************************************************************************************************************
     * @description Helper method to generate invalidRecordTypeInAffiliationMapping with appropriate
     * substitutions.
     * @param  invalidRTName Name of invalid Record Type in affiliation mapping
     * @return A string containing invalidRecordTypeInAffiliationMapping message text with appropriate
     * substitutions.
     **************************************************************************************************************/
    private static String getInvalidRecordTypeInAffiliationMappingMessage(String invalidRTName) {
        List<String> params = new List<String>{ Label.stgColAccountRecordType, invalidRTName };

        return StringHandlingService.getInstance()
            .formatStringWithApostrophesAndParameters(label.invalidRecordTypeInAffiliationMapping, params);
    }

    /**************************************************************************************************************
     * @description Helper method to generate invalidContactFieldInAffiliationMapping with appropriate
     * substitutions.
     * @param  invalidRTName Name of invalid Contact field in affiliation mapping
     * @return A string containing invalidContactFieldInAffiliationMapping message text with appropriate
     * substitutions.
     **************************************************************************************************************/
    private static String getinvalidContactFieldInAffiliationMappingMessage(String invalidContactFieldName) {
        List<String> params = new List<String>{ Label.stgColContactPrimaryAfflField, invalidContactFieldName };

        return StringHandlingService.getInstance()
            .formatStringWithApostrophesAndParameters(label.invalidContactFieldInAffiliationMapping, params);
    }
}
