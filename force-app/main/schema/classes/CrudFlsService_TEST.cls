@isTest
public class CrudFlsService_TEST {
    @isTest
    private static void testFieldsAreAddedFromSObjectType() {
        // does not test that ALL fields are added, just that at least some are

        CrudFlsService.Fields fields = new CrudFlsService.Fields(Contact.sObjectType);

        System.assert(containsFieldNamed(fields, 'Id'));
        System.assert(containsFieldNamed(fields, 'LastName'));
    }

    @isTest
    private static void testFieldsAreAddedFromList() {
        List<Schema.SObjectField> fieldTokens = new List<Schema.SObjectField>{
            Contact.Id,
            Contact.LastName
        };

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldTokens);

        System.assert(containsFieldNamed(fields, 'Id'));
        System.assert(containsFieldNamed(fields, 'LastName'));
    }

    private static Boolean containsFieldNamed(CrudFlsService.Fields fields, String name) {
        for (CrudFlsService.Field field : fields.fields) {
            if (field.name == name) {
                return true;
            }
        }
        return false;
    }

    @isTest
    private static void testFieldsAreAddedFromFieldList() {
        List<CrudFlsService.Field> fieldList = new List<CrudFlsService.Field>{
            new FieldStub('foo', 'foo'),
            new FieldStub('bar', 'bar'),
            new FieldStub('baz', 'baz')
        };

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        System.assertEquals(fieldList, fields.fields);
    }

    @isTest
    private static void testFilterReturnsMatchingFields() {
        List<FieldStub> fieldList = new List<FieldStub>{
            new FieldStub('foo', 'foo'),
            new FieldStub('bar', 'bar'),
            new FieldStub('baz', 'baz')
        };

        List<FieldStub> expectedFields = new List<FieldStub>{
            new FieldStub('foo', 'foo'),
            new FieldStub('baz', 'baz')
        };

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        CrudFlsService.Fields filtered = fields.filter(
            new Set<String>{'foo', 'baz'}
        );

        System.assertEquals(expectedFields, filtered.fields);
    }

    @isTest
    private static void testFilterPrefersCurrentNamespaceFields() {
        List<FieldStub> fieldList = new List<FieldStub>{
            new FieldStub('quux__foo', 'foo'),
            new FieldStub('foo', 'foo'),
            new FieldStub('bar', 'bar'),
            new FieldStub('baz', 'baz')
        };

        List<FieldStub> expectedFields = new List<FieldStub>{
            new FieldStub('quux__foo', 'foo'),
            new FieldStub('baz', 'baz')
        };

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        CrudFlsService.Fields filtered = fields.filter(
            new Set<String>{'foo', 'baz'}
        );

        System.assertEquals(expectedFields, filtered.fields);
    }

    @isTest
    private static void testFilterThrowsExceptionForMissingFields() {
        List<FieldStub> fieldList = new List<FieldStub>{
            new FieldStub('foo', 'foo'),
            new FieldStub('bar', 'bar')
        };

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        Boolean exceptionThrown = false;

        try {
            fields.filter(new Set<String>{'foo', 'baz'});
        } catch (CrudFlsService.UnknownFieldException e) {
            exceptionThrown = true;
        }

        System.assert(exceptionThrown);
    }

    @isTest
    private static void testEmptyListIsAccessible() {
        CrudFlsService.Fields fields = new CrudFlsService.Fields(
            new List<CrudFlsService.Field>()
        );

        System.assertEquals(true, fields.isAccessible());
    }

    @isTest
    private static void testEmptyListIsCreatable() {
        CrudFlsService.Fields fields = new CrudFlsService.Fields(
            new List<CrudFlsService.Field>()
        );

        System.assertEquals(true, fields.isCreateable());
    }

    @isTest
    private static void testEmptyListIsUpdateable() {
        CrudFlsService.Fields fields = new CrudFlsService.Fields(
            new List<CrudFlsService.Field>()
        );

        System.assertEquals(true, fields.isUpdateable());
    }

    @isTest
    private static void testAccessibleFieldsAreAccessible() {
        FieldStub field1 = new FieldStub('foo', 'foo');
        field1.isAccessible = true;

        FieldStub field2 = new FieldStub('bar', 'bar');
        field2.isAccessible = true;

        List<FieldStub> fieldList = new List<FieldStub>{field1, field2};

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        System.assertEquals(true, fields.isAccessible());

        Boolean exceptionThrown = false;

        try {
            CrudFlsService.getInstance().assertAccessible(fields);
        } catch (CrudFlsService.UnknownFieldException e) {
            exceptionThrown = true;
        }

        System.assert(!exceptionThrown);
    }

    @isTest
    private static void testUpdateableFieldsAreUpdateable() {
        FieldStub field1 = new FieldStub('foo', 'foo');
        field1.isUpdateable = true;

        FieldStub field2 = new FieldStub('bar', 'bar');
        field2.isUpdateable = true;

        List<FieldStub> fieldList = new List<FieldStub>{field1, field2};

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        System.assertEquals(true, fields.isUpdateable());

        Boolean exceptionThrown = false;

        try {
            CrudFlsService.getInstance().assertUpdateable(fields);
        } catch (CrudFlsService.UnknownFieldException e) {
            exceptionThrown = true;
        }

        System.assert(!exceptionThrown);
    }

    @isTest
    private static void testCreateableFieldsAreCreateable() {
        FieldStub field1 = new FieldStub('foo', 'foo');
        field1.isCreateable = true;

        FieldStub field2 = new FieldStub('bar', 'bar');
        field2.isCreateable = true;

        List<FieldStub> fieldList = new List<FieldStub>{field1, field2};

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        System.assertEquals(true, fields.isCreateable());

        Boolean exceptionThrown = false;

        try {
            CrudFlsService.getInstance().assertCreatable(fields);
        } catch (CrudFlsService.UnknownFieldException e) {
            exceptionThrown = true;
        }

        System.assert(!exceptionThrown);
    }

    @isTest
    private static void testInaccessableFieldsAreInaccessible() {
        FieldStub field1 = new FieldStub('foo', 'foo');
        field1.isAccessible = false;

        FieldStub field2 = new FieldStub('bar', 'bar');
        field2.isAccessible = false;

        List<FieldStub> fieldList = new List<FieldStub>{field1, field2};

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        System.assertEquals(false, fields.isAccessible());

        Boolean exceptionThrown = false;

        try {
            CrudFlsService.getInstance().assertAccessible(fields);
        } catch (CrudFlsService.CrudFlsException e) {
            exceptionThrown = true;
        }

        System.assert(exceptionThrown);
    }

    @isTest
    private static void testUnupdateableFieldsAreUnupdateable() {
        FieldStub field1 = new FieldStub('foo', 'foo');
        field1.isUpdateable = false;

        FieldStub field2 = new FieldStub('bar', 'bar');
        field2.isUpdateable = false;

        List<FieldStub> fieldList = new List<FieldStub>{field1, field2};

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        System.assertEquals(false, fields.isUpdateable());

        Boolean exceptionThrown = false;

        try {
            CrudFlsService.getInstance().assertUpdateable(fields);
        } catch (CrudFlsService.CrudFlsException e) {
            exceptionThrown = true;
        }

        System.assert(exceptionThrown);
    }

    @isTest
    private static void testUncreatableFieldsAreUncreatable() {
        FieldStub field1 = new FieldStub('foo', 'foo');
        field1.isCreateable = false;

        FieldStub field2 = new FieldStub('bar', 'bar');
        field2.isCreateable = false;

        List<FieldStub> fieldList = new List<FieldStub>{field1, field2};

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        System.assertEquals(false, fields.isCreateable());

        Boolean exceptionThrown = false;

        try {
            CrudFlsService.getInstance().assertCreatable(fields);
        } catch (CrudFlsService.CrudFlsException e) {
            exceptionThrown = true;
        }

        System.assert(exceptionThrown);
    }

    @isTest
    private static void testMixedFieldsAreInaccessible() {
        FieldStub field1 = new FieldStub('foo', 'foo');
        field1.isAccessible = true;

        FieldStub field2 = new FieldStub('bar', 'bar');
        field2.isAccessible = false;

        List<FieldStub> fieldList = new List<FieldStub>{field1, field2};

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        System.assertEquals(false, fields.isAccessible());
    }

    @isTest
    private static void testMixedFieldsAreUnupdateable() {
        FieldStub field1 = new FieldStub('foo', 'foo');
        field1.isUpdateable = true;

        FieldStub field2 = new FieldStub('bar', 'bar');
        field2.isUpdateable = false;

        List<FieldStub> fieldList = new List<FieldStub>{field1, field2};

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        System.assertEquals(false, fields.isUpdateable());
    }

    @isTest
    private static void testMixedFieldsAreUncreatable() {
        FieldStub field1 = new FieldStub('foo', 'foo');
        field1.isCreateable = true;

        FieldStub field2 = new FieldStub('bar', 'bar');
        field2.isCreateable = false;

        List<FieldStub> fieldList = new List<FieldStub>{field1, field2};

        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        System.assertEquals(false, fields.isCreateable());
    }

    @isTest
    private static void testGetInaccessibleFieldsWithoutObjects() {
        FieldStub accessibleField = new FieldStub('foo', 'foo');
        accessibleField.isAccessible = true;
        accessibleField.isCreateable = true;
        accessibleField.isUpdateable = true;

        FieldStub missingAccessField = new FieldStub('bar', 'bar');
        missingAccessField.isAccessible = false;
        missingAccessField.isCreateable = false;
        missingAccessField.isUpdateable = false;

        CrudFlsService.Fields fields = new CrudFlsService.Fields(new List<FieldStub>{accessibleField, missingAccessField});

        for (CrudFlsService.CRUDAccessType accessLevel : CrudFlsService.CRUDAccessType.values()) {
            Map<String, List<String>> missingAccess = fields.getMissingAccessFieldsByObject(accessLevel);
            System.assertEquals(1, missingAccess.size(), 'There should be one bucket');
            System.assertEquals(1, missingAccess.get('None Provided').size(), 'There should be one field missing access with a null object');
        }
    }

    @isTest
    private static void testGetInaccessibleFieldsByObject() {
        FieldStub field1a = new FieldStub('foo', 'foo');
        field1a.isAccessible = true;
        field1a.isCreateable = true;
        field1a.isUpdateable = true;
        field1a.objectName = 'One';

        FieldStub field1b = new FieldStub('bar', 'bar');
        field1b.isAccessible = false;
        field1b.isCreateable = false;
        field1b.isUpdateable = false;
        field1b.objectName = 'One';

        FieldStub field2a = new FieldStub('foo', 'bar');
        field2a.isAccessible = false;
        field2a.isCreateable = false;
        field2a.isUpdateable = false;
        field2a.objectName = 'Two';

        FieldStub field2b = new FieldStub('bar', 'foo');
        field2b.isAccessible = false;
        field2b.isCreateable = false;
        field2b.isUpdateable = false;
        field2b.objectName = 'Two';

        List<FieldStub> fieldList = new List<FieldStub>{field1a, field1b, field2a, field2b};
        CrudFlsService.Fields fields = new CrudFlsService.Fields(fieldList);

        for (CrudFlsService.CRUDAccessType accessLevel : CrudFlsService.CRUDAccessType.values()) {
            Map<String, List<String>> missingAccess = fields.getMissingAccessFieldsByObject(accessLevel);
            System.assertEquals(2, missingAccess.size(), 'Two objects should have fields missing access');
            System.assertEquals(1, missingAccess.get('One').size(), 'Object One should have 1 field missing access');
            System.assertEquals(2, missingAccess.get('Two').size(), 'Object Two should have 2 fields missing access');
        }
    }

    @IsTest
    private static void testMissingObjectAccessMessage() {
        CrudFlsService crud = CrudFlsService.getInstance();
        Schema.SObjectType objType = Availability__c.SObjectType;
        String message = crud.notifyMissingObjectAccess(objType, Label.errorInsufficientObjectReadAccess);

        System.assert(message.contains('Availability__c'));
        System.assert(message.contains(UserInfo.getUserId()));
        System.assert(message.contains(Label.errorInsufficientObjectReadAccess));
        System.assert(message.contains(Label.errorObjectPermDetails));
    }

    @IsTest
    private static void testMissingFieldAccessMessage() {
        CrudFlsService crud = CrudFlsService.getInstance();
        List<String> missingFields = new List<String>{'Name', 'CreatedDate'};
        String message = crud.notifyMissingFieldAccess('Availability__c', missingFields, Label.errorInsufficientFieldCreateAccess);

        System.assert(message.contains(UserInfo.getUserId()));
        System.assert(message.contains(missingFields[0]));
        System.assert(message.contains(missingFields[1]));
        System.assert(message.contains(Label.errorInsufficientFieldCreateAccess));
        System.assert(message.contains(Label.errorFieldPermDetails));

        //Message should not contain the Object Name yet; that's saved for a larger refactor
        System.assert(!message.contains('Availability__c'));
    }

    private class FieldStub extends CrudFlsService.Field {
        private FieldStub() {}

        private FieldStub(String name, String localName) {
            this.name = name;
            this.localName = localName;
        }

        public Boolean equals(Object o) {
            FieldStub that = (FieldStub) o;
            return (name == that.name && localName == that.localName);
        }
    }
}