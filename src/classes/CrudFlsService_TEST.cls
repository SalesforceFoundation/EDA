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
* @description Test class for CrudFlsService class.
*/
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