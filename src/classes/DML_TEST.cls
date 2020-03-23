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