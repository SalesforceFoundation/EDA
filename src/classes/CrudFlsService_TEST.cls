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