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
* @group Utilities
* @description Test class for Query class
*/
@isTest
private class Query_TEST {

    @ isTest
    private static void testRunQuery() {
        Account a = new Account(
            Name = 'Test Account',
            Industry = 'Test Industry',
            NumberOfEmployees = 10
        );

        insert a;

        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            AccountId = a.Id
        );

        insert c;

        Test.startTest();

        Query q = new Query(Account.SObjectType)
            .addField(new Query.SimpleField(Account.Name))
            .addField(new Query.SimpleField(Account.Industry))
            .addField(new Query.SubQueryField('Contacts')
                .addField(new Query.SimpleField(Contact.FirstName)))
            .addCondition(new Query.SimpleCondition('Id', '=', a.Id));

        List<Record> accounts = q.runQuery();

        System.assertEquals(1, accounts.size());

        Record testAccount = accounts[0];

        System.assertEquals(a.Id, testAccount.getId());
        System.assertEquals(a.Name, testAccount.get('Name'));
        System.assertEquals(a.Industry, testAccount.get('Industry'));
        System.assertEquals(null, testAccount.get('NumberOfEmployees'));

        List<Record> childContacts = (List<Record>) testAccount.get('Contacts');

        System.assertEquals(1, childContacts.size());

        Record testContact = childContacts[0];

        System.assertEquals(c.Id, testContact.getId());
        System.assertEquals('Test', testContact.get('FirstName'));
        System.assertEquals(null, testContact.get('LastName'));

        Test.stopTest();
    }

    @ isTest
    private static void testRunUnscrubbedQuery() {
        Account a = new Account(
            Name = 'Test Account',
            Industry = 'Test Industry',
            NumberOfEmployees = 10
        );

        insert a;

        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            AccountId = a.Id
        );

        insert c;

        Test.startTest();

        Query q = new Query(Account.SObjectType)
            .addField(new Query.SimpleField(Account.Name))
            .addField(new Query.SimpleField(Account.Industry))
            .addField(new Query.SubQueryField('Contacts')
                .addField(new Query.SimpleField(Contact.FirstName)))
            .addCondition(new Query.SimpleCondition('Id', '=', a.Id));

        List<SObject> records = q.runUnscrubbedQuery();
        List<Account> accounts = new List<Account>{};
        accounts = records;

        System.assertEquals(1, accounts.size());

        Account testAccount = accounts[0];

        System.assertEquals(a.Id, testAccount.Id);
        System.assertEquals(a.Name, testAccount.Name);
        System.assertEquals(a.Industry, testAccount.Industry);

        List<Contact> childContacts = testAccount.Contacts;

        System.assertEquals(1, childContacts.size());

        Contact testContact = childContacts[0];

        System.assertEquals(c.Id, testContact.Id);
        System.assertEquals('Test', testContact.FirstName);

        Test.stopTest();
    }

    @ isTest
    private static void testSubQuery() {
        Test.startTest();

        Query.SubQuery subQuery = new Query.SubQuery('RelationshipName');

        System.assertEquals('RelationshipName', subQuery.generateObjectName());

        Test.stopTest();
    }

    @ isTest
    private static void testOrderBySObjectField() {
        Test.startTest();

        Query.OrderBy ob = new Query.OrderBy(Account.Name);

        System.assertEquals('ASC', ob.orderDirection);
        System.assertEquals('Name', ob.fieldName);

        System.assertEquals(Account.Name.getDescribe().getName() + ' ASC', ob.generateString());

        Test.stopTest();
    }

    @ isTest
    private static void testOrderByString() {
        Test.startTest();

        String field = 'Account.Name';

        Query.OrderBy ob = new Query.OrderBy(field);

        System.assertEquals('ASC', ob.orderDirection);
        System.assertEquals('Account.Name', ob.fieldName);

        System.assertEquals(field + ' ASC', ob.generateString());

        Test.stopTest();
    }

    @ isTest
    private static void testToLabelField() {
        Test.startTest();

        Query.ToLabelField tlf = new Query.ToLabelField('Status', Case.Status);

        System.assertEquals('toLabel(' + Case.Status.getDescribe().getName() + ') Status',
            tlf.generateString(null, null));

        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Test Status'
        );

        CrudFlsService.instance = new CrudStub(false);

        String testStatus = (String) tlf.getFieldValue(testCase);

        System.assertEquals(null, testStatus);

        CrudFlsService.instance = new CrudStub(true);

        testStatus = (String) tlf.getFieldValue(testCase);

        System.assertEquals('Test Status', testStatus);

        Test.stopTest();
    }

    @ isTest
    private static void testSubQueryField() {

        Account a = new Account(
            Name = 'Test'
        );

        insert a;

        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            AccountId = a.Id
        );

        insert c;

        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = a.Id
        );

        insert testCase;

        a = [
            SELECT Id,
                   Name,
                   (
                       SELECT Id,
                              FirstName
                       FROM Contacts
                   )
            FROM Account
            WHERE Id = :a.Id
        ];

        Test.startTest();

        Query.SubQueryField sqf = new Query.SubQueryField('Contacts');

        System.assertNotEquals(null, sqf.q);

        sqf.addField(new Query.SimpleField(Contact.Id));
        sqf.addField(new Query.SimpleField(Contact.FirstName));

        System.assertEquals(2, sqf.q.fields.size());

        sqf.addCondition(new Query.SimpleCondition(
            'Id',
            '=',
            c.Id
        ));

        System.assertEquals(1, sqf.q.conditions.size());

        sqf.setLimit(10);

        System.assertEquals(10, sqf.q.queryLimit);

        sqf.addOrderBy(new Query.OrderBy(
            Contact.Id
        ));

        System.assertEquals('(SELECT Id,FirstName FROM Contacts WHERE Id = :tmp0 ORDER BY Id ASC LIMIT 10)',
            sqf.generateString(null,  null));

        CrudFlsService.instance = new CrudStub(false);

        List<Record> contacts = (List<Record>) sqf.getFieldValue(a);

        for (Record childContact : contacts) {
            System.assertEquals(null, childContact.get('FirstName'));
        }

        CrudFlsService.instance = new CrudStub(true);

        contacts = (List<Record>) sqf.getFieldValue(a);

        for (Record childContact : contacts) {
            System.assertEquals('Test', childContact.get('FirstName'));
        }

        Test.stopTest();
    }

    @ isTest
    private static void testSimpleField() {
        Test.startTest();

        Query.SimpleField sf = new Query.SimpleField(Case.Status);

        System.assertEquals('Status', sf.generateString(null, null));

        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Test Status'
        );

        CrudFlsService.instance = new CrudStub(false);

        String testStatus = (String) sf.getFieldValue(testCase);

        System.assertEquals(null, testStatus);

        CrudFlsService.instance = new CrudStub(true);

        testStatus = (String) sf.getFieldValue(testCase);

        System.assertEquals('Test Status', testStatus);

        Test.stopTest();
    }

    @ isTest
    private static void testRelationship() {
        Account a = new Account(
            Name = 'Test Account',
            Industry = 'Test Industry'
        );

        insert a;

        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            AccountId = a.Id
        );

        insert c;

        c = [
            SELECT Id,
                   Account.Name,
                   Account.Industry
            FROM Contact
            WHERE Id = :c.Id
        ];

        CrudFlsService.instance = new CrudFlsService.Stub();

        Test.startTest();

        Query.Relationship r = new Query.Relationship(Contact.AccountId);

        r.addField(new Query.SimpleField(Account.Name));
        r.addField(new Query.SimpleField(Account.Industry));

        System.assertEquals('Account.Name,Account.Industry', r.generateString(null, null));

        Object fieldValue = r.getFieldValue(c);

        System.assertEquals(true, fieldValue instanceof Record);

        Record testAccount = (Record) fieldValue;

        System.assertEquals(a.Id, testAccount.getId());

        System.assertEquals('Test Account', testAccount.get('Name'));
        System.assertEquals('Test Industry', testAccount.get('Industry'));

        Test.stopTest();
    }

    @ isTest
    private static void testSimpleCondition() {
        Test.startTest();

        Query testQuery = new Query(Contact.SObjectType);
        Query.SimpleCondition sc = new Query.SimpleCondition(
            'FirstName',
            '=',
            'Evan'
        );

        System.assertEquals('FirstName', sc.field);
        System.assertEquals('=', sc.operator);
        System.assertEquals('Evan', sc.comparisonValue);

        System.assertEquals('FirstName = :tmp0', sc.generateString(testQuery));

        System.assertEquals('Evan', testQuery.tmpList[0]);

        Test.stopTest();
    }

    @ isTest
    private static void testConditionList() {
        Test.startTest();

        Query q = new Query(Contact.SObjectType);
        Query.ConditionList cl = new Query.ConditionList();

        System.assertEquals('AND', cl.booleanOperator);

        cl.addCondition(new Query.SimpleCondition(
            'FirstName',
            '=',
            'Evan'
        ))
        .addCondition(new Query.SimpleCondition(
            'LastName',
            '=',
            'Test'
        ));

        System.assertEquals(' ( FirstName = :tmp0 AND LastName = :tmp1 ) ', cl.generateString(q));

        System.assertEquals('Evan', q.tmpList[0]);
        System.assertEquals('Test', q.tmpList[1]);

        Test.stopTest();
    }

    @ isTest
    private static void testSubQueryCondition() {
        Test.startTest();

        Query q = new Query(Account.SObjectType);
        Query subQuery = new Query(Contact.SObjectType);

        subQuery.addField(new Query.SimpleField(Contact.AccountId));

        Query.SubQueryCondition sqc = new Query.SubQueryCondition(
            'Id',
            'IN',
            subQuery
        );

        System.assertEquals('Id IN (' + subQuery.generateQueryString(null).trim() + ')', sqc.generateString(q));

        Test.stopTest();
    }

    private with sharing class CrudStub extends CrudFlsService {

        private Boolean accessible;

        public CrudStub(Boolean accessible) {
            this.accessible = accessible;
        }

        public override Boolean isAccessible(List<Schema.SObjectField> fieldTokens) {
            return this.accessible;
        }
    }
}