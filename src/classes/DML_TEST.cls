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
* @description Test class for DML class.
*/
@isTest
private with sharing class DML_Test {

    @ isTest
    private static void testDelete() {
        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i < 201; i++) {
            accounts.add(new Account(
                Name = 'Test Account'
            ));
        }

        insert accounts;

        Test.startTest();

        DML.DMLDelete d = new DML.DMLDelete(Account.SObjectType);

        List<Record> toDelete = new List<Record>();

        for (Account a : accounts) {
            toDelete.add(new Record(a.Id));
        }

        toDelete = d.run(toDelete);

        System.assertEquals(null, toDelete);

        accounts = [
            SELECT Id
            FROM Account
        ];

        System.assertEquals(true, accounts.isEmpty());

        Test.stopTest();
    }

    @ isTest
    private static void testInsert() {
        Test.startTest();

        List<Record> accounts = new List<Record>();

        for (Integer i = 0; i < 201; i++) {
            Record r = new Record(Account.SObjectType);

            r.put(Account.Name, 'Test Account');
            accounts.add(r);
        }

        DML.DMLInsert i = new DML.DMLInsert(Account.SObjectType);

        accounts = i.run(accounts);

        for (Record r : accounts) {
            System.assertNotEquals(null, r.getId());
        }

        Test.stopTest();
    }

    @ isTest
    private static void testUpdate() {
        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i < 201; i++) {
            accounts.add(new Account(
                Name = 'Test Account'
            ));
        }

        insert accounts;

        Test.startTest();

        List<Record> toUpdate = new List<Record>();

        for (Account a : accounts) {
            Record r = new Record(a.Id);

            r.put(Account.Name, 'Updated Name');
            toUpdate.add(r);
        }

        DML.DMLUpdate u = new DML.DMLUpdate(Account.SObjectType);

        toUpdate = u.run(toUpdate);

        for (Record r : toUpdate) {
            System.assertEquals('Updated Name', r.get(Account.Name));
        }

        accounts = [
            SELECT Id,
                   Name
            FROM Account
        ];

        for (Account a : accounts) {
            System.assertEquals('Updated Name', a.Name);
        }

        Test.stopTest();
    }
}