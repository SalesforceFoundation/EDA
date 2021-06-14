/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
 * @date 2021
 * @group
 * @group-content ../../ApexDocContent/Tests.htm
 * @description Test class for LookupResult.
 */
@isTest
private with sharing class LookupResult_TEST {
    /***********************************************************************************
     * @description Test to verify that the 2 argument constructor generates a model
     * with all properties populated as expected.
     ***********************************************************************************/
    @isTest
    private static void twoArgumentConstructorValid() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        Test.startTest();
        LookupResult lookupResult = new LookupResult('User Name', userId);
        Test.stopTest();

        System.assertEquals('User Name', lookupResult.label, 'Model label should match provided value.');
        System.assertEquals(userId, lookupResult.value, 'Model value should match provided value.');
    }

    /***********************************************************************************
     * @description Test to verify that the 6 argument constructor generates a model
     * with all properties populated as expected.
     ***********************************************************************************/
    @isTest
    private static void sixArgumentConstructorValid() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        Test.startTest();
        LookupResult lookupResult = new LookupResult(
            'User Name',
            userId,
            'standard:avatar',
            'https://example.com/test.png',
            'User',
            'Meta'
        );
        Test.stopTest();

        System.assertEquals('User Name', lookupResult.label, 'Model label should match provided value.');
        System.assertEquals(userId, lookupResult.value, 'Model value should match provided value.');
        System.assertEquals('standard:avatar', lookupResult.icon, 'Model icon should match provided value.');
        System.assertEquals(
            'https://example.com/test.png',
            lookupResult.imageUrl,
            'Model image url should match provided value.'
        );
        System.assertEquals(
            'User',
            lookupResult.alternativeText,
            'Model alternative text should match provided value.'
        );
        System.assertEquals('Meta', lookupResult.meta, 'Model meta should match provided value.');
    }

    /***********************************************************************************
     * @description Test to verify that the 1 argument constructor generates a model
     * with all properties populated as expected.
     ***********************************************************************************/
    @isTest
    private static void reflectiveConstructorValid() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        LookupResult lookupResult1 = new LookupResult(
            'User Name',
            userId,
            'standard:avatar',
            'https://example.com/test.png',
            'User',
            'Meta'
        );

        Test.startTest();
        LookupResult lookupResult2 = new LookupResult(lookupResult1);
        Test.stopTest();

        System.assert(
            lookupResult1.equals(lookupResult2),
            'Model produced by constructor should match provided value.'
        );
    }

    /***********************************************************************************
     * @description Test to verify that the 1 argument constructor generates a model
     * with all properties populated as expected.
     ***********************************************************************************/
    @isTest
    private static void sObjectConstructorValid() {
        Contact contact = UTIL_UnitTestData_TEST.getContact();
        String expectedLabel = contact.getSObjectType().getDescribe().getLabel();

        Test.startTest();
        LookupResult lookupResult = new LookupResult(contact);
        Test.stopTest();

        System.assertEquals(expectedLabel, lookupResult.label, 'Model label should match SObject type label.');
        System.assertEquals(contact.Id, lookupResult.value, 'Model value should match provided SObject id.');
    }

    /***********************************************************************************
     * @description Test to verify that the get initials method is valid.
     ***********************************************************************************/
    @isTest
    private static void getInitials() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        LookupResult lookupResult = new LookupResult('User Name', userId);

        Test.startTest();
        String initials = lookupResult.getInitials();
        Test.stopTest();

        System.assertEquals('UN', initials, 'Initials retrieved should match the first letter of every word.');
    }

    /***********************************************************************************
     * @description Test to verify that getting the label's lowercase is functional
     ***********************************************************************************/
    @isTest
    private static void getLabelLower() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        LookupResult lookupResult = new LookupResult('User Name', userId);

        Test.startTest();
        String lowercase = lookupResult.getLabelLower();
        Test.stopTest();

        System.assertEquals(
            lookupResult.label.toLowerCase(),
            lowercase,
            'Model label should be converted to lowercase.'
        );
    }

    /***********************************************************************************
     * @description Test to verify that compareTo is functional on labels when they are
     * equal
     ***********************************************************************************/
    @isTest
    private static void compareToEquals() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        LookupResult lookupResult1 = new LookupResult('User Name', userId);
        LookupResult lookupResult2 = new LookupResult(lookupResult1);

        Test.startTest();
        Integer compareTo = lookupResult1.compareTo(lookupResult2);
        Test.stopTest();

        System.assertEquals(0, compareTo, 'Object comparison should match label comparison');
    }

    /***********************************************************************************
     * @description Test to verify that compareTo is functional on labels when they are
     * equal not case sensitive
     ***********************************************************************************/
    @isTest
    private static void compareToEqualsNotCaseSensitive() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        String lookupLabel1 = 'User Name';
        String lookupLabel2 = lookupLabel1.toLowerCase();

        LookupResult lookupResult1 = new LookupResult(lookupLabel1, userId);
        LookupResult lookupResult2 = new LookupResult(lookupResult1);
        lookupResult2.label = lookupLabel2;

        Test.startTest();
        Integer compareTo = lookupResult1.compareTo(lookupResult2);
        Test.stopTest();

        System.assertEquals(
            0,
            compareTo,
            'Object comparison should match label comparison when they are the same, ignoring case'
        );
    }

    /***********************************************************************************
     * @description Test to verify that compareTo is functional on labels when they
     * are not equal
     ***********************************************************************************/
    @isTest
    private static void compareToNotEquals() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        String lookupLabel1 = 'User Name';
        String lookupLabel2 = 'User Name 2';

        LookupResult lookupResult1 = new LookupResult(lookupLabel1, userId);
        LookupResult lookupResult2 = new LookupResult(lookupResult1);
        lookupResult2.label = lookupLabel2;

        Test.startTest();
        Integer compareTo = lookupResult1.compareTo(lookupResult2);
        Test.stopTest();

        System.assertEquals(
            lookupLabel1.compareTo(lookupLabel2),
            compareTo,
            'Object comparison should match label comparison when they are not the same.'
        );
    }

    /***********************************************************************************
     * @description Test to verify that compareTo is functional on labels
     ***********************************************************************************/
    @isTest
    private static void compareToDifferentObject() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        String lookupLabel1 = 'User Name';

        LookupResult lookupResult1 = new LookupResult(lookupLabel1, userId);
        Contact notALookupResult = new Contact(LastName = 'Test');

        try {
            Test.startTest();
            Integer compareTo = lookupResult1.compareTo(notALookupResult);
            Test.stopTest();
            System.assert(false, 'The type exception should always be thrown.');
        } catch (System.TypeException ste) {
            System.assert(true, 'The type exception should always be thrown.');
        } catch (Exception e) {
            System.assert(false, 'Only a type exception should be thrown.');
        }
    }

    /***********************************************************************************
     * @description Test to verify that the equals method resolves appropriately
     ***********************************************************************************/
    @isTest
    private static void equals() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        LookupResult lookupResult1 = new LookupResult(
            'User Name',
            userId,
            'standard:avatar',
            'https://example.com/test.png',
            'User',
            'Meta'
        );
        LookupResult lookupResult2 = new LookupResult(lookupResult1);

        Test.startTest();
        Boolean lookupsEqual = lookupResult1.equals(lookupResult2);
        Test.stopTest();

        System.assert(lookupsEqual, 'Models should be equal');
    }

    /***********************************************************************************
     * @description Test to verify that the equals method resolves appropriately for
     * the negative case on a label difference
     ***********************************************************************************/
    @isTest
    private static void equalsNegativeOnLabel() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        LookupResult lookupResult1 = new LookupResult(
            'User Name',
            userId,
            'standard:avatar',
            'https://example.com/test.png',
            'User',
            'Meta'
        );
        LookupResult lookupResult2 = new LookupResult(lookupResult1);
        lookupResult2.label = 'Different';

        Test.startTest();
        Boolean lookupsEqual = !lookupResult1.equals(lookupResult2);
        Test.stopTest();

        System.assert(lookupsEqual, 'Models should not be equal when the label is different.');
    }

    /***********************************************************************************
     * @description Test to verify that the equals method resolves appropriately for
     * the negative case on a value difference
     ***********************************************************************************/
    @isTest
    private static void equalsNegativeOnValue() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        LookupResult lookupResult1 = new LookupResult(
            'User Name',
            userId,
            'standard:avatar',
            'https://example.com/test.png',
            'User',
            'Meta'
        );
        LookupResult lookupResult2 = new LookupResult(lookupResult1);
        lookupResult2.value = 'Different';

        Test.startTest();
        Boolean lookupsEqual = !lookupResult1.equals(lookupResult2);
        Test.stopTest();

        System.assert(lookupsEqual, 'Models should not be equal when the value is different.');
    }

    /***********************************************************************************
     * @description Test to verify that the equals method resolves appropriately for
     * the negative case on a icon difference
     ***********************************************************************************/
    @isTest
    private static void equalsNegativeOnIcon() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        LookupResult lookupResult1 = new LookupResult(
            'User Name',
            userId,
            'standard:avatar',
            'https://example.com/test.png',
            'User',
            'Meta'
        );
        LookupResult lookupResult2 = new LookupResult(lookupResult1);
        lookupResult2.icon = 'Different';

        Test.startTest();
        Boolean lookupsEqual = !lookupResult1.equals(lookupResult2);
        Test.stopTest();

        System.assert(lookupsEqual, 'Models should not be equal when the icon is different.');
    }

    /***********************************************************************************
     * @description Test to verify that the equals method resolves appropriately for
     * the negative case on an image url difference
     ***********************************************************************************/
    @isTest
    private static void equalsNegativeOnImageUrl() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        LookupResult lookupResult1 = new LookupResult(
            'User Name',
            userId,
            'standard:avatar',
            'https://example.com/test.png',
            'User',
            'Meta'
        );
        LookupResult lookupResult2 = new LookupResult(lookupResult1);
        lookupResult2.imageUrl = 'Different';

        Test.startTest();
        Boolean lookupsEqual = !lookupResult1.equals(lookupResult2);
        Test.stopTest();

        System.assert(lookupsEqual, 'Models should not be equal when the image url is different.');
    }

    /***********************************************************************************
     * @description Test to verify that the equals method resolves appropriately for
     * the negative case on an alternative text difference
     ***********************************************************************************/
    @isTest
    private static void equalsNegativeOnAlternativeText() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        LookupResult lookupResult1 = new LookupResult(
            'User Name',
            userId,
            'standard:avatar',
            'https://example.com/test.png',
            'User',
            'Meta'
        );
        LookupResult lookupResult2 = new LookupResult(lookupResult1);
        lookupResult2.alternativeText = 'Different';

        Test.startTest();
        Boolean lookupsEqual = !lookupResult1.equals(lookupResult2);
        Test.stopTest();

        System.assert(lookupsEqual, 'Models should not be equal when the alternative text is different.');
    }

    /***********************************************************************************
     * @description Test to verify that the equals method resolves appropriately for
     * the negative case on an meta difference
     ***********************************************************************************/
    @isTest
    private static void equalsNegativeOnMeta() {
        Id userId = UTIL_UnitTestData_TEST.getFakeId(User.SObjectType);
        LookupResult lookupResult1 = new LookupResult(
            'User Name',
            userId,
            'standard:avatar',
            'https://example.com/test.png',
            'User',
            'Meta'
        );
        LookupResult lookupResult2 = new LookupResult(lookupResult1);
        lookupResult2.meta = 'Different';

        Test.startTest();
        Boolean lookupsEqual = !lookupResult1.equals(lookupResult2);
        Test.stopTest();

        System.assert(lookupsEqual, 'Models should not be equal when the meta is different.');
    }
}
