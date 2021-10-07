/*
    Copyright (c) 2014 Salesforce.org
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
/**
* @author Salesforce Foundation
* @date 2014
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description This class allows easy access to object and field description information from within other classes.
*
* It is called statically, and therefore will supply the same information to all calls made from
* within one transaction, or set of trigger calls. This is beneficial because this info should
* be the same for all calls in a transaction, and by calling it statically we reduce the calls
* that are made, making the total transaction more efficient.
*/
@isTest
public with sharing class UTIL_Describe_TEST {
    // TEST
    static testMethod void testDescribe() {
        string s;

        Schema.DescribeSObjectResult res = UTIL_Describe_API.getObjectDescribe('Contact');
        System.assertEquals(res.getName(), 'Contact');
        s = UTIL_Describe_API.getObjectLabel('Contact');
        System.assertEquals(s, res.getLabel());

        account a = new account(name = 'Test');
        insert a;
        System.assert(UTIL_Describe_API.isObjectIdThisType(a.id, 'Account'));

        s = UTIL_Describe_API.getFieldLabelSafe('Account', 'LastModifiedDate');

        Schema.DescribeFieldResult fr = UTIL_Describe_API.getFieldDescribe('Account', 'CreatedDate');
        s = UTIL_Describe_API.getFieldLabelSafe('Account', 'CreatedDate');
        System.assertEquals(s, fr.getLabel());

        Map<String, Schema.DescribeFieldResult> afd = UTIL_Describe_API.getAllFieldsDescribe('Account');
        System.assertEquals('BillingCity', afd.get('billingcity').getName());
        afd = UTIL_Describe_API.getAllFieldsDescribe('Account');

        SObject acctObj = UTIL_Describe_API.getPrototypeObject('Account');
        // should be able to cast to account
        account acct = (account) (acctObj);

        s = UTIL_Describe_API.getFieldType('Account', 'CreatedDate');
        System.assertEquals('DATETIME', s);

        try {
            s = UTIL_Describe_API.getObjectLabel('sdlkfjsdlkfjsldkfjlsdkfj');
        } catch (exception e) {
            System.assertEquals('Invalid object name \'sdlkfjsdlkfjsldkfjlsdkfj\'', e.getMessage());
        }
        try {
            s = UTIL_Describe_API.getFieldLabel('Opportunity', 'sdlkfjsdlkfjsldkfjlsdkfj');
        } catch (exception e) {
            System.assertEquals('Invalid field name \'sdlkfjsdlkfjsldkfjlsdkfj\'', e.getMessage());
        }

        System.assertEquals(
            true,
            UTIL_Describe_API.canDisplaytypesCopy(Schema.Displaytype.DATE, Schema.Displaytype.DATETIME)
        );

        Map<String, Id> acctTypesMap = UTIL_Describe_API.getRecTypesMapByName('Account');
        System.assertEquals(true, acctTypesMap.size() > 1);

        System.assertEquals(
            Schema.Displaytype.DATETIME,
            UTIL_Describe_API.getFieldDisplaytype('Account', 'CreatedDate')
        );

        Map<String, Schema.DescribeFieldResult> acctIdFieldMap = UTIL_Describe_API.getFieldsOfType('Account', 'ID');
        System.assertEquals(1, acctIdFieldMap.size());

        Map<String, String> picklistEntries = UTIL_Describe_API.getPicklistActiveValuesMap('Account', 'AccountSource');
        System.assert(picklistEntries.size() > 0);

        try {
            picklistEntries = UTIL_Describe_API.getPicklistActiveValuesMap('Account', 'id');
        } catch (UTIL_Describe.SchemaDescribeException sde) {
        }
    }

    // Test for childRelationshipNamesService functionality
    @isTest
    private static void childRelationshipNamesServiceTest() {
        // Insert Account
        Account adminAccount = UTIL_UnitTestData_API.getMultipleTestAccounts(
            1,
            UTIL_Describe_API.getAdminAccRecTypeID()
        )[0];
        adminAccount.Name = 'Test Account 000';
        insert adminAccount;

        Test.startTest();
        Schema.SObjectType sObjectTypeAcc = adminAccount.getSObjectType();
        List<String> allChildRelationshipNames = UTIL_Describe.getAllChildRelationshipNames(sObjectTypeAcc);
        Test.stopTest();

        System.assertNotEquals(null, allChildRelationshipNames);
        System.assertNotEquals(0, allChildRelationshipNames.size());
        System.assert(allChildRelationshipNames.contains('Contacts'));
    }

    // NPE Test for childRelationshipNamesService functionality
    @isTest
    private static void childRelationshipNamesNPETest() {
        try {
            Test.startTest();
            List<String> allChildRelationshipNames = UTIL_Describe.getAllChildRelationshipNames(null);
            Test.stopTest();
            System.assert(false, 'Always throw an exception when NULL is passed as a parameter');
        } catch (System.NullPointerException npe) {
        }
    }

    //Test for getCustomAdminAccRecTypeId if the value of Administrative Account Record Type is empty
    @isTest
    private static void getCustomAdminAccRecTypeIdEmptyTest() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Administrative_Account_Record_Type__c = null)
        );

        Test.startTest();
        Id testCustomAdminAccRecTypeId = Util_Describe.getCustomAdminAccRecTypeId();
        Test.stopTest();

        System.assertEquals(Util_Describe.getAdminAccRecTypeID(), testCustomAdminAccRecTypeId);
    }

    //Test for getCustomAdminAccRecTypeId if the value of Administrative Account Record Type is not empty but the record type does not exist
    @isTest
    private static void getCustomAdminAccRecTypeIdNotEmptyNotExistTest() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Administrative_Account_Record_Type__c = '000000000000000000')
        );

        Test.startTest();
        Id testCustomAdminAccRecTypeId = Util_Describe.getCustomAdminAccRecTypeId();
        Test.stopTest();

        System.assertEquals(Util_Describe.getAdminAccRecTypeID(), testCustomAdminAccRecTypeId);
    }

    //Test for getCustomAdminAccRecTypeId if the value of Administrative Account Record Type is not empty and the record type exists
    @isTest
    private static void getCustomAdminAccRecTypeIdNotEmptyExistsTest() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Administrative_Account_Record_Type__c = Util_Describe_API.getRecTypesMapByDevName('Account').values()[1]
            )
        );

        Test.startTest();
        Id testCustomAdminAccRecTypeId = Util_Describe.getCustomAdminAccRecTypeId();
        Test.stopTest();

        System.assertEquals(
            Util_Describe_API.getRecTypesMapByDevName('Account').values()[1],
            testCustomAdminAccRecTypeId
        );
    }

    //Test for getCustomHHAccRecTypeId if the value of Household Account Record Type is empty
    @isTest
    private static void getCustomHHAccRecTypeIdEmptyTest() {
        UTIL_CustomSettings_API.getSettingsForTests(new Hierarchy_Settings__c(Household_Addresses_RecType__c = null));

        Test.startTest();
        Id testCustomHHAccRecTypeId = Util_Describe.getCustomHHAccRecTypeId();
        Test.stopTest();

        System.assertEquals(Util_Describe.getHHAccRecTypeID(), testCustomHHAccRecTypeId);
    }

    //Test for getCustomHHAccRecTypeId if the value of Household Account Record Type is not empty but the record type does not exist
    @isTest
    private static void getCustomHHAccRecTypeIdNotEmptyNotExistTest() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(Household_Addresses_RecType__c = '000000000000000000')
        );

        Test.startTest();
        Id testCustomHHAccRecTypeId = Util_Describe.getCustomHHAccRecTypeId();
        Test.stopTest();

        System.assertEquals(Util_Describe.getHHAccRecTypeID(), testCustomHHAccRecTypeId);
    }

    //Test for getCustomHHAccRecTypeId if the value of Household Account Record Type is not empty and the record type exists
    @isTest
    private static void getCustomHHAccRecTypeIdNotEmptyExistsTest() {
        UTIL_CustomSettings_API.getSettingsForTests(
            new Hierarchy_Settings__c(
                Household_Addresses_RecType__c = Util_Describe.getRecTypesMapByDevName('Account').values()[0]
            )
        );

        Test.startTest();
        Id testCustomHHAccRecTypeId = Util_Describe.getCustomHHAccRecTypeId();
        Test.stopTest();

        System.assertEquals(Util_Describe_API.getRecTypesMapByDevName('Account').values()[0], testCustomHHAccRecTypeId);
    }

    /***********************************************************************************************
     * @description Test to verify that getRecordTypeInfoByDeveloperName() does not return null when
     * there are no Account record types assigned and a valid Record Type is used.
     ***********************************************************************************************/
    @isTest
    private static void getRecordTypeInfoByDevNameStandardUserPositive() {
        User stdUser = UTIL_UnitTestData_TEST.getStandardUser();

        System.runAs(stdUser) {
            Test.startTest();
            Schema.RecordTypeInfo recTypeInfo = Util_Describe.getRecordTypeInfoByDeveloperName(
                'Account',
                'Academic_Program'
            );
            Test.stopTest();

            System.assertEquals(
                true,
                recTypeInfo != null,
                'Should retrieve record type info for valid record type even when Account record types are not assigned.'
            );
        }
    }

    /***********************************************************************************************
     * @description Test to verify that getRecordTypeInfoByDeveloperName() returns null when
     * there are no Account record types assigned and an invalid Record Type is used.
     ***********************************************************************************************/
    @isTest
    private static void getRecordTypeInfoByDevNameStandardUserNegative() {
        User stdUser = UTIL_UnitTestData_TEST.getStandardUser();

        System.runAs(stdUser) {
            Test.startTest();
            Schema.RecordTypeInfo recTypeInfo = Util_Describe.getRecordTypeInfoByName('Account', 'test only rec type');
            Test.stopTest();

            System.assertEquals(
                true,
                recTypeInfo == null,
                'Should not retrieve record type info for invalid record type when Account record types are not assigned.'
            );
        }
    }

    // Positive test for getRecordTypeInfoByDevName
    @isTest
    private static void getRecordTypeInfoByDevNamePositiveTest() {
        Test.startTest();
        Schema.RecordTypeInfo recTypeInfo = Util_Describe.getRecordTypeInfoByDeveloperName(
            'Account',
            'Academic_Program'
        );
        Test.stopTest();
        System.assert(recTypeInfo != null);
    }

    // Negative test for getRecordTypeInfoByDevName
    @isTest
    private static void getRecordTypeInfoByDevNameNegativeTest() {
        Test.startTest();
        Schema.RecordTypeInfo recTypeInfo = Util_Describe.getRecordTypeInfoByDeveloperName(
            'Account',
            'test only rec type..'
        );
        Test.stopTest();
        System.assert(recTypeInfo == null);
    }

    /***********************************************************************************************
     * @description Test to verify that getRecordTypeInfoByName() does not return null when
     * there are no Account record types assigned and an invalid Record Type is used.
     ***********************************************************************************************/
    @isTest
    private static void getRecordTypeInfoByNameStandardUserPositive() {
        User stdUser = UTIL_UnitTestData_TEST.getStandardUser();

        System.runAs(stdUser) {
            Test.startTest();
            Schema.RecordTypeInfo recTypeInfo = Util_Describe.getRecordTypeInfoByName('Account', 'Academic Program');
            Test.stopTest();

            System.assertEquals(
                true,
                recTypeInfo != null,
                'Should retrieve record type info for valid record type even if not assigned.'
            );
        }
    }

    /***********************************************************************************************
     * @description Test to verify that getRecordTypeInfoByName() returns null when
     * there are no Account record types assigned and an invalid Record Type is used.
     ***********************************************************************************************/
    @isTest
    private static void getRecordTypeInfoByNameStandardUserNegative() {
        User stdUser = UTIL_UnitTestData_TEST.getStandardUser();

        System.runAs(stdUser) {
            Test.startTest();
            Schema.RecordTypeInfo recTypeInfo = Util_Describe.getRecordTypeInfoByName('Account', 'test only rec type');
            Test.stopTest();
            System.assertEquals(
                true,
                recTypeInfo == null,
                'Should not retrieve record type info for invalid record type even if not assigned.'
            );
        }
    }

    // Positive test for getRecordTypeInfoByName
    @isTest
    private static void getRecordTypeInfoByNamePositiveTest() {
        Test.startTest();
        Schema.RecordTypeInfo recTypeInfo = Util_Describe.getRecordTypeInfoByName('Account', 'Academic Program');
        Test.stopTest();
        System.assert(recTypeInfo != null);
    }

    // Negative test for getRecordTypeInfoByName
    @isTest
    private static void getRecordTypeInfoByNameNegativeTest() {
        Test.startTest();
        Schema.RecordTypeInfo recTypeInfo = Util_Describe.getRecordTypeInfoByName('Account', 'test only rec type');
        Test.stopTest();
        System.assert(recTypeInfo == null);
    }

    @isTest
    private static void populateRecordTypeInfoForSObjectStandardUser() {
        User stdUser = UTIL_UnitTestData_TEST.getStandardUser();

        System.runAs(stdUser) {
            Test.startTest();
            Util_Describe.populateRecordTypeInfoForSObject('Contact');
            Test.stopTest();

            Schema.RecordTypeInfo recTypeInfoByDevName = Util_Describe.getRecordTypeInfoByDeveloperName(
                'Account',
                'Academic_Program'
            );
            Schema.RecordTypeInfo recTypeInfoByName = Util_Describe.getRecordTypeInfoByName(
                'Account',
                'Academic Program'
            );
            System.assertEquals(
                true,
                recTypeInfoByDevName != null,
                'Should retrieve info for valid record type even when Account Record Types not assigned to profile.'
            );
            System.assertEquals(
                true,
                recTypeInfoByName != null,
                'Should retrieve info for valid record type even when Account Record Types not assigned to profile.'
            );
        }
    }

    // Test method for populateRecordTypeInfoForSObject
    @isTest
    private static void populateRecordTypeInfoForSObjectTest() {
        Test.startTest();
        Util_Describe.populateRecordTypeInfoForSObject('Contact');
        Test.stopTest();

        Schema.RecordTypeInfo recTypeInfoByDevName = Util_Describe.getRecordTypeInfoByDeveloperName(
            'Account',
            'Academic_Program'
        );
        Schema.RecordTypeInfo recTypeInfoByName = Util_Describe.getRecordTypeInfoByName('Account', 'Academic Program');
        System.assert(recTypeInfoByDevName != null);
        System.assert(recTypeInfoByName != null);
    }

    // Positive test for cacheDescribeSObjectResult
    @isTest
    private static void cacheDescribeSObjectResultPositive() {
        try {
            Test.startTest();
            Util_Describe.cacheDescribeSObjectResult(Account.SObjectType.getDescribe());
            Test.stopTest();
        } catch (UTIL_Describe.SchemaDescribeException ex) {
            System.assert(false, 'Valid object should not throw an error');
        }
    }

    // Negative test for cacheDescribeSObjectResult
    @isTest
    private static void cacheDescribeSObjectResultNegativeTest() {
        try {
            Test.startTest();
            Util_Describe.cacheDescribeSObjectResult(UTIL_Describe_API.getObjectDescribe('TestOnlyObj'));
            Test.stopTest();
            System.assert(false, 'Invalid object should throw an error');
        } catch (UTIL_Describe.SchemaDescribeException ex) {
        }
    }

    // Positive test for getFieldDescribeByLabel
    @isTest
    private static void getFieldDescribeByLabelPositiveTest() {
        Test.startTest();
        Schema.DescribeFieldResult contactFieldDesc = Util_Describe.getFieldDescribeByLabel('Contact', 'First Name');
        Test.stopTest();

        System.assertEquals('FirstName', contactFieldDesc.getname());
    }

    // Negative test for getFieldDescribeByLabel
    @isTest
    private static void getFieldDescribeByLabelNegativeTest() {
        try {
            Test.startTest();
            Schema.DescribeFieldResult contactFieldDesc = Util_Describe.getFieldDescribeByLabel(
                'Contact',
                'First Name testing'
            );
            Test.stopTest();
            System.assert(false, 'Invalid field label should throw an error');
        } catch (UTIL_Describe.SchemaDescribeException ex) {
        }
    }

    // Test for getPicklistEntriesApiToLabelMap
    @isTest
    private static void getPicklistEntriesApiToLabelMap() {
        Test.startTest();
        Map<String, String> picklistEntriesApiToLabel = Util_Describe.getPicklistEntriesApiToLabelMap(
            'Account',
            'Type'
        );
        Test.stopTest();

        System.assertNotEquals(0, picklistEntriesApiToLabel.size());
    }

    /**
     * @description Test to ensure isLookupFieldTo() returns true when a specified field is of type lookup to the
     * specified SObject type.
     */
    @isTest
    private static void isLookupToAccountTrue() {
        Schema.DescribeFieldResult acctFieldDesc = UTIL_Describe_API.getFieldDescribe('Contact', 'AccountId');

        Test.startTest();
        Boolean isLookupResult = UTIL_Describe.isLookupFieldTo(acctFieldDesc, Account.SObjectType);
        Test.stopTest();

        System.assertEquals(
            true,
            isLookupResult,
            'Should return true since Account field on Contact is lookup to Account.'
        );
    }

    /**
     * @description Test to ensure isLookupFieldTo() returns false when a specified field is of type lookup, but does not
     * lookup to the specified SObject type.
     */
    @isTest
    private static void isLookupToAccountFalse() {
        Schema.DescribeFieldResult reportsToFieldDesc = UTIL_Describe_API.getFieldDescribe('Contact', 'ReportsToId');

        Test.startTest();
        Boolean isLookupResult = UTIL_Describe.isLookupFieldTo(reportsToFieldDesc, Account.SObjectType);
        Test.stopTest();

        System.assertEquals(
            false,
            isLookupResult,
            'Should return false since reportsToFieldDesc field on contact is lookup to Contact, not Account.'
        );
    }

    /**
     * @description Test to ensure isLookupFieldTo() returns false when a specified field is not of type lookup.
     */
    @isTest
    private static void isLookupToWithNonLookupField() {
        Schema.DescribeFieldResult firstNameFieldDesc = UTIL_Describe_API.getFieldDescribe('Contact', 'FirstName');

        Test.startTest();
        Boolean isLookupResult = UTIL_Describe.isLookupFieldTo(firstNameFieldDesc, Account.SObjectType);
        Test.stopTest();

        System.assertEquals(
            false,
            isLookupResult,
            'Should return false since FirstName field on Contact is not a lookup field.'
        );
    }

    /**
     * @description Test to ensure getCertificateAcademicCertificationRecTypeId returns the Certificate Record Type
     * of the Academic Certification object
     */
    @isTest
    private static void getCertificateAcademicCertificationRecTypeIdTest() {
        Test.startTest();
        Id certificateAcademicCertificationRecTypeId = Util_Describe.getCertificateAcademicCertificationRecTypeId();
        Test.stopTest();

        System.assertNotEquals(null, certificateAcademicCertificationRecTypeId);

        RecordType rt = [SELECT DeveloperName FROM Recordtype WHERE Id = :certificateAcademicCertificationRecTypeId];
        System.assertEquals('Certificate', rt.DeveloperName);
    }

    /**
     * @description Test to ensure getDegreeAcademicCertificationRecTypeId returns the Degree Record Type
     * of the Academic Certification object
     */
    @isTest
    private static void getDegreeAcademicCertificationRecTypeIdTest() {
        Test.startTest();
        Id degreeAcademicCertificationRecTypeId = Util_Describe.getDegreeAcademicCertificationRecTypeId();
        Test.stopTest();

        System.assertNotEquals(null, degreeAcademicCertificationRecTypeId);

        RecordType rt = [SELECT DeveloperName FROM Recordtype WHERE Id = :degreeAcademicCertificationRecTypeId];
        System.assertEquals('Degree', rt.DeveloperName);
    }

    /**
     * @description Test to ensure getDiplomaAcademicCertificationRecTypeId returns the Diploma Record Type
     * of the Academic Certification object
     */
    @isTest
    private static void getDiplomaAcademicCertificationRecTypeIdTest() {
        Test.startTest();
        Id diplomaAcademicCertificationRecTypeId = Util_Describe.getDiplomaAcademicCertificationRecTypeId();
        Test.stopTest();

        System.assertNotEquals(null, diplomaAcademicCertificationRecTypeId);

        RecordType rt = [SELECT DeveloperName FROM Recordtype WHERE Id = :diplomaAcademicCertificationRecTypeId];
        System.assertEquals('Diploma', rt.DeveloperName);
    }

    /**
     * @description Test to ensure getBadgeCredentialRecTypeId returns the Badge Record Type
     * of the Credential object
     */
    @isTest
    private static void getBadgeCredentialRecTypeIdTest() {
        Test.startTest();
        Id badgeCredentialRecTypeId = Util_Describe.getBadgeCredentialRecTypeId();
        Test.stopTest();

        System.assertNotEquals(null, badgeCredentialRecTypeId);

        RecordType rt = [SELECT DeveloperName FROM Recordtype WHERE Id = :badgeCredentialRecTypeId];
        System.assertEquals('Badge', rt.DeveloperName);
    }

    /**
     * @description Test to ensure getCertificationCredentialRecTypeId returns the Certificate Record Type
     * of the Credential object
     */
    @isTest
    private static void getCertificationCredentialRecTypeIdTest() {
        Test.startTest();
        Id certificationCredentialRecTypeId = Util_Describe.getCertificationCredentialRecTypeId();
        Test.stopTest();

        System.assertNotEquals(null, certificationCredentialRecTypeId);

        RecordType rt = [SELECT DeveloperName FROM Recordtype WHERE Id = :certificationCredentialRecTypeId];
        System.assertEquals('Certification', rt.DeveloperName);
    }

    /**
     * @description Test to ensure getLicenseCredentialRecTypeId returns the License Record Type
     * of the Credential object
     */
    @isTest
    private static void getLicenseCredentialRecTypeIdTest() {
        Test.startTest();
        Id licenseCredentialRecTypeId = Util_Describe.getLicenseCredentialRecTypeId();
        Test.stopTest();

        System.assertNotEquals(null, licenseCredentialRecTypeId);

        RecordType rt = [SELECT DeveloperName FROM Recordtype WHERE Id = :licenseCredentialRecTypeId];
        System.assertEquals('License', rt.DeveloperName);
    }
}
