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
* @description Utility class that checks if a user has CRUD access to an object or field. 
*/
public virtual with sharing class CrudFlsService {
    @TestVisible
    private static CrudFlsService instance;

    protected CrudFlsService() {}

    public static CrudFlsService getInstance() {
        if (instance == null) {
            instance = new CrudFlsService();
        }
        return instance;
    }

    public virtual Map<Id, Boolean> getHasEditAccessMap(Id userId, Set<Id> recordIds) {
        Map<Id, Boolean> hasAccess = new Map<Id, Boolean>();

        for (UserRecordAccess ura : [
            SELECT
                RecordId,
                HasEditAccess
            FROM UserRecordAccess
            WHERE UserId = :userId
            AND RecordId in :recordIds
        ]) {
            hasAccess.put(ura.RecordId, ura.HasEditAccess);
        }

        return hasAccess;
    }

    public virtual Map<Id, Boolean> getHasReadAccessMap(Id userId, Set<Id> recordIds) {
        Map<Id, Boolean> hasAccess = new Map<Id, Boolean>();

        for (UserRecordAccess ura : [
            SELECT
                RecordId,
                HasReadAccess
             FROM UserRecordAccess
             WHERE UserId = :userId
             AND RecordId in :recordIds
        ]) {
            hasAccess.put(ura.RecordId, ura.HasReadAccess);
        }

        return hasAccess;
    }

    public virtual void assertAccessible(Schema.SObjectField field) {
        assertAccessible(new List<Schema.SObjectField> { field });
    }

    public virtual Boolean canAccessField(Schema.SObjectField field) {
        return isAccessible(new List<Schema.SObjectField> {
            field
        });
    }

    public virtual void checkAccess(Schema.SObjectType objectType, List<Schema.SObjectField> fields) {
        assertObjectAccessible(objectType);
        assertAccessible(fields);
    }

    public virtual Boolean canAccess(Schema.SObjectType objectType, List<Schema.SObjectField> fields) {
        return (isObjectAccessible(objectType) && isAccessible(fields));

    }

    public virtual void assertObjectAccessible(Schema.SObjectType objectType) {
        if (!isObjectAccessible(objectType)) {
            CrudOlsException e = new CrudOlsException();
            e.setMessage(Label.errorInsufficientObjectReadAccess);
            throw e;
        }
    }

    public virtual Boolean isObjectAccessible(Schema.SObjectType objectType) {
        return objectType.getDescribe().isAccessible();
    }

    public virtual void assertObjectUpdateable(Schema.SObjectType objectType) {
        if (!objectType.getDescribe().isUpdateable()) {
            CrudOlsException e = new CrudOlsException();
            e.setMessage(Label.errorInsufficientObjectEditAccess);
            throw e;
        }
    }

    public virtual void assertObjectCreateable(Schema.SObjectType objectType) {
        if (!objectType.getDescribe().isCreateable()) {
            CrudOlsException e = new CrudOlsException();
            e.setMessage(Label.errorInsufficientObjectCreateAccess);
            throw e;
        }
    }

    public virtual void assertObjectDeletable(Schema.SObjectType objectType) {
        if (!objectType.getDescribe().isDeletable()) {
            CrudOlsException e = new CrudOlsException();
            e.setMessage(Label.errorInsufficientObjectDeleteAccess);
            throw e;
        }
    }

    public virtual void assertAccessible(List<Schema.SObjectField> fieldTokens) {
        assertAccessible(new Fields(fieldTokens));
    }

    public virtual void assertAccessible(Fields fieldTokens) {
        if (!fieldTokens.isAccessible()) {
            CrudFlsException e = new CrudFlsException();
            e.setMessage(Label.errorInsufficientFieldReadAccess);
            throw e;
        }
    }

    public virtual Boolean isAccessible(List<Schema.SObjectField> fieldTokens) {
        return (new Fields(fieldTokens)).isAccessible();
    }

    public virtual void assertUpdateable(List<Schema.SObjectField> fieldTokens) {
        Fields fields = new Fields(fieldTokens);
        if (!fields.isUpdateable()) {
            CrudFlsException e = new CrudFlsException();
            e.setMessage(Label.errorInsufficientFieldUpdateAccess);
            throw e;
        }
    }

    public virtual void assertCreateable(List<Schema.SObjectField> fieldTokens) {
        Fields fields = new Fields(fieldTokens);
        if (!fields.isCreateable()) {
            CrudFlsException e = new CrudFlsException();
            e.setMessage(Label.errorInsufficientFieldCreateAccess);
            throw e;
        }
    }

    public virtual Set<String> getFieldListFromObject(SObject so) {
        Map<String, Object> genericObject = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(so));
        return genericObject.keySet();
    }

    @TestVisible
    public with sharing class Fields {
        @TestVisible
        private List<Field> fields;

        public Fields(List<Field> fields) {
            this.fields = fields;
        }

        public Fields(List<Schema.SObjectField> fieldTokens) {
            fields = new List<Field>();
            for (Schema.SObjectField field : fieldTokens) {
                fields.add(new Field(field));
            }
        }

        public Fields(Schema.SObjectType sot) {
            this(sot.getDescribe().fields.getMap().values());
        }

        public Fields filter(Set<String> names) {
            Map<String, Field> filtered = new Map<String, Field>();

            for (Field field : fields) {
                if (names.contains(field.localName)) {
                    filtered.put(field.localName, field);
                }
            }

            /*
              second pass to replace fields that have the same localName as
              fields in our namespace.  Our fields shadow same named fields in
              dynamic SOQL, so if filtering for a field by name, we want to
              make sure we prefer our fields.
            */

            for (Field field : fields) {
                if (field.isCurrentNamespace() && names.contains(field.localName)) {
                    filtered.put(field.localName, field);
                }
            }

            if (filtered.keySet() != names) {
                throw new UnknownFieldException();
            }

            return new Fields(filtered.values());
        }

        public Boolean isAccessible() {
            Boolean isAccessible = true;
            for (Field field : fields) {
                isAccessible &= field.isAccessible;
            }
            return isAccessible;
        }

        public Boolean isUpdateable() {
            Boolean isUpdateable = true;
            for (Field field : fields) {
                isUpdateable &= field.isUpdateable;
            }
            return isUpdateable;
        }

        public Boolean isCreateable() {
            Boolean isCreateable = true;
            for (Field field : fields) {
                isCreateable &= field.isCreateable;
            }
            return isCreateable;
        }
    }

    @TestVisible
    private virtual with sharing class Field {
        public String name;
        public String localName;
        public Boolean isAccessible;
        public Boolean isUpdateable;
        public Boolean isCreateable;
        public Boolean isCurrentNamespace;

        protected Field() {}

        public Field(Schema.SObjectField sof) {
            Schema.DescribeFieldResult dfr = sof.getDescribe();
            name = dfr.getName();
            localName = dfr.getLocalName();
            isAccessible = dfr.isAccessible();
            isUpdateable = dfr.isUpdateable();
            isCreateable = dfr.isCreateable();
            isCurrentNamespace = (name != localName);
        }

        public Boolean isCurrentNamespace() {
            return (name != localName);
        }
    }

    /**
     * @description A test only stub class for CrudFlsService that does not
     * perform any CRUD/FLS checks (i.e. all assertions pass without throwing
     * an exception).  This is used in test methods to override CRUD/FLS checks
     * when running tests in orgs where the running user's profile has not been
     * granted all necessary access.
     */
    @TestVisible
    private virtual with sharing class Stub extends CrudFlsService {
        public Map<Id, Boolean> hasReadAccessMap;
        public Set<String> fieldListFromObject;

        public override Map<Id, Boolean> getHasReadAccessMap(Id userId, Set<Id> recordIds) {
            // for testing purposes, all records are considered accessible

            Map<Id, Boolean> hasReadAccessMap = new Map<Id, Boolean>();

            for (Id recordId : recordIds) {
                hasReadAccessMap.put(recordId, true);
            }

            return hasReadAccessMap;
        }

        public override void checkAccess(Schema.SObjectType objectType, List<Schema.SObjectField> fields) {
            // do not check crud/fls in this test only stub
        }

        public override Boolean canAccessField(Schema.SObjectField field) {
            return true;
        }

        public override Boolean canAccess(Schema.SObjectType objectType, List<Schema.SObjectField> fields) {
            // do not check crud/fls in this test only stub
            return true;
        }

        public override void assertObjectAccessible(Schema.SObjectType objectType) {
            // do not check crud/fls in this test only stub
        }

        public override Boolean isObjectAccessible(Schema.SObjectType objectType) {
            // do not check crud/fls in this test only stub
            return true;
        }

        public override void assertObjectCreateable(Schema.SObjectType objectType) {
            // do not check crud/fls in this test only stub
        }

        public override void assertObjectDeletable(Schema.SObjectType objectType) {
            // do not check crud/fls in this test only stub
        }

        public override void assertAccessible(Schema.SObjectField field) {
            // do not check crud/fls in this test only stub
        }

        public override void assertAccessible(List<Schema.SObjectField> fieldTokens) {
            // do not check crud/fls in this test only stub
        }

        public override void assertAccessible(Fields fieldTokens) {
            // do not check crud/fls in this test only stub
        }

        public virtual override Boolean isAccessible(List<Schema.SObjectField> fieldTokens) {
            // do not check crud/fls in this test only stub
            return true;
        }

        public override void assertUpdateable(List<Schema.SObjectField> fieldTokens) {
            // do not check crud/fls in this test only stub
        }

        public override void assertCreateable(List<Schema.SObjectField> fieldTokens) {
            // do not check crud/fls in this test only stub
        }
    }

    public with sharing class UnknownFieldException extends Exception {}
    public virtual with sharing class CrudException extends Exception {}
    public with sharing class CrudFlsException extends CrudException {}
    public with sharing class CrudOlsException extends CrudException {}
}