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
 * @group EDA Settings
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description Test class for CrudFlsService.
 */
public virtual with sharing class CrudFlsService {
    @TestVisible
    private static CrudFlsService instance;

    protected CrudFlsService() {
    }

    public static CrudFlsService getInstance() {
        if (instance == null) {
            instance = new CrudFlsService();
        }
        return instance;
    }

    public enum CRUDAccessType {
        CREATEABLE,
        READABLE,
        UPDATEABLE
    }

    public virtual Map<Id, Boolean> getHasEditAccessMap(Id userId, Set<Id> recordIds) {
        Map<Id, Boolean> hasAccess = new Map<Id, Boolean>();

        for (UserRecordAccess ura : [
            SELECT RecordId, HasEditAccess
            FROM UserRecordAccess
            WHERE UserId = :userId AND RecordId IN :recordIds
        ]) {
            hasAccess.put(ura.RecordId, ura.HasEditAccess);
        }

        return hasAccess;
    }

    public virtual Map<Id, Boolean> getHasReadAccessMap(Id userId, Set<Id> recordIds) {
        Map<Id, Boolean> hasAccess = new Map<Id, Boolean>();

        for (UserRecordAccess ura : [
            SELECT RecordId, HasReadAccess
            FROM UserRecordAccess
            WHERE UserId = :userId AND RecordId IN :recordIds
        ]) {
            hasAccess.put(ura.RecordId, ura.HasReadAccess);
        }

        return hasAccess;
    }

    public virtual void assertAccessible(Schema.SObjectField field) {
        assertAccessible(new List<Schema.SObjectField>{ field });
    }

    public virtual Boolean canAccessField(Schema.SObjectField field) {
        return isAccessible(new List<Schema.SObjectField>{ field });
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
            throwObjectAccessException(Label.errorInsufficientObjectReadAccess);
        }
    }

    public virtual Boolean isObjectAccessible(Schema.SObjectType objectType) {
        if (objectType.getDescribe().isAccessible()) {
            return true;
        } else {
            //calling this method externally allows for a silent access failure, but here ensure it's still logged
            String missingAccessMessage = Label.errorInsufficientObjectReadAccess;
            notifyMissingObjectAccess(objectType, missingAccessMessage);
            return false;
        }
    }

    public virtual void assertObjectUpdateable(Schema.SObjectType objectType) {
        if (!objectType.getDescribe().isUpdateable()) {
            String missingAccessMessage = Label.errorInsufficientObjectEditAccess;
            notifyMissingObjectAccess(objectType, missingAccessMessage);
            throwObjectAccessException(missingAccessMessage);
        }
    }

    public virtual void assertObjectCreateable(Schema.SObjectType objectType) {
        if (!objectType.getDescribe().isCreateable()) {
            String missingAccessMessage = Label.errorInsufficientObjectCreateAccess;
            notifyMissingObjectAccess(objectType, missingAccessMessage);
            throwObjectAccessException(missingAccessMessage);
        }
    }

    public virtual void assertObjectDeletable(Schema.SObjectType objectType) {
        if (!objectType.getDescribe().isDeletable()) {
            String missingAccessMessage = Label.errorInsufficientObjectDeleteAccess;
            notifyMissingObjectAccess(objectType, missingAccessMessage);
            throwObjectAccessException(missingAccessMessage);
        }
    }

    //todo: retire me! -> refactor to use assertAccessibleBySObject
    //OR figure out how to get sObjectName from Schema.SObjectField
    public virtual void assertAccessible(List<Schema.SObjectField> fieldTokens) {
        Map<String, List<Schema.SObjectField>> fieldTokensBySObjectName = new Map<String, List<Schema.SObjectField>>();
        //object name TBD
        fieldTokensBySObjectName.put(null, fieldTokens);
        assertAccessibleBySObject(fieldTokensBySObjectName);
    }

    public virtual void assertAccessibleBySObject(Map<String, List<Schema.SObjectField>> fieldTokensBySObjectName) {
        assertAccessible(new Fields(fieldTokensBySObjectName));
    }

    public virtual void assertAccessible(Fields fieldTokens) {
        if (!fieldTokens.isAccessible()) {
            String missingAccessMessage = Label.errorInsufficientFieldReadAccess;
            Map<String, List<String>> inaccessibleFields = fieldTokens.getMissingAccessFieldsByObject(
                CRUDAccessType.READABLE
            );
            for (String objectName : inaccessibleFields.keySet()) {
                notifyMissingFieldAccess(objectName, inaccessibleFields.get(objectName), missingAccessMessage);
            }
            throwFieldAccessException(missingAccessMessage);
        }
    }

    public virtual Boolean isAccessible(List<Schema.SObjectField> fieldTokens) {
        Fields fields = new Fields(fieldTokens);
        if (fields.isAccessible()) {
            return true;
        } else {
            //calling this method externally allows for a silent access failure, but here ensure it's still logged
            String missingAccessMessage = Label.errorInsufficientFieldReadAccess;
            Map<String, List<String>> inaccessibleFields = fields.getMissingAccessFieldsByObject(
                CRUDAccessType.READABLE
            );
            for (String objectName : inaccessibleFields.keySet()) {
                notifyMissingFieldAccess(objectName, inaccessibleFields.get(objectName), missingAccessMessage);
            }
            return false;
        }
    }

    //todo: retire me! -> refactor to use assertUpdateableBySObject everywhere
    //OR figure out how to get sObjectName from Schema.SObjectField
    public virtual void assertUpdateable(List<Schema.SObjectField> fieldTokens) {
        Map<String, List<Schema.SObjectField>> fieldTokensBySObjectName = new Map<String, List<Schema.SObjectField>>();
        //object name TBD
        fieldTokensBySObjectName.put(null, fieldTokens);
        assertUpdateableBySObject(fieldTokensBySObjectName);
    }

    public virtual void assertUpdateableBySObject(Map<String, List<Schema.SObjectField>> fieldTokensBySObjectName) {
        assertUpdateable(new Fields(fieldTokensBySObjectName));
    }

    @TestVisible
    private void assertUpdateable(Fields fields) {
        if (!fields.isUpdateable()) {
            String missingAccessMessage = Label.errorInsufficientFieldUpdateAccess;
            Map<String, List<String>> inaccessibleFields = fields.getMissingAccessFieldsByObject(
                CRUDAccessType.UPDATEABLE
            );
            for (String objectName : inaccessibleFields.keySet()) {
                notifyMissingFieldAccess(objectName, inaccessibleFields.get(objectName), missingAccessMessage);
            }
            throwFieldAccessException(missingAccessMessage);
        }
    }

    //todo: retire me! -> refactor to use assertCreateableBySObject everywhere
    //OR figure out how to get sObjectName from Schema.SObjectField
    public virtual void assertCreateable(List<Schema.SObjectField> fieldTokens) {
        Map<String, List<Schema.SObjectField>> fieldTokensBySObjectName = new Map<String, List<Schema.SObjectField>>();
        //object name TBD
        fieldTokensBySObjectName.put(null, fieldTokens);
        assertCreateableBySObject(fieldTokensBySObjectName);
    }

    public virtual void assertCreateableBySObject(Map<String, List<Schema.SObjectField>> fieldTokensBySObjectName) {
        assertCreatable(new Fields(fieldTokensBySObjectName));
    }

    @TestVisible
    private void assertCreatable(Fields fields) {
        if (!fields.isCreateable()) {
            String missingAccessMessage = Label.errorInsufficientFieldCreateAccess;
            Map<String, List<String>> inaccessibleFields = fields.getMissingAccessFieldsByObject(
                CRUDAccessType.CREATEABLE
            );
            for (String objectName : inaccessibleFields.keySet()) {
                notifyMissingFieldAccess(objectName, inaccessibleFields.get(objectName), missingAccessMessage);
            }
            throwFieldAccessException(missingAccessMessage);
        }
    }

    public virtual Set<String> getFieldListFromObject(SObject so) {
        Map<String, Object> genericObject = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(so));
        return genericObject.keySet();
    }

    private void throwObjectAccessException(String errorMessage) {
        CrudOlsException e = new CrudOlsException();
        e.setMessage(errorMessage);
        throw e;
    }

    private void throwFieldAccessException(String errorMessage) {
        CrudFlsException e = new CrudFlsException();
        e.setMessage(errorMessage);
        throw e;
    }

    @TestVisible
    private String notifyMissingObjectAccess(Schema.SObjectType objectType, String missingAccessMessage) {
        String objectName = objectType.getDescribe().getName();
        return logMissingAccess(objectName, new List<String>(), missingAccessMessage);
    }

    @TestVisible
    private String notifyMissingFieldAccess(String objectName, List<String> fieldLabels, String missingAccessMessage) {
        return logMissingAccess(objectName, fieldLabels, missingAccessMessage);
    }

    private String logMissingAccess(String objectName, List<String> fieldLabels, String missingAccessMessage) {
        Boolean isObjectOnlyError = fieldLabels.isEmpty();
        List<String> lines = new List<String>();

        if (isObjectOnlyError) {
            lines.add(Label.errorObjectPermDetails);
        } else {
            lines.add(Label.errorFieldPermDetails);
        }

        lines.add(String.format(Label.errorUserId, new List<String>{ UserInfo.getUserId() }));
        lines.add(missingAccessMessage);

        if (isObjectOnlyError) {
            //todo: add the objectName back once we have it for the list of fields
            lines.add(String.format(Label.errorObjectName, new List<String>{ objectName }));
        } else {
            lines.add(String.format(Label.errorFieldName, new List<String>{ String.join(fieldLabels, ', ') }));
        }

        String textBody = String.join(lines, '\n');
        System.debug(textBody);
        return textBody;
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

        public Fields(Map<String, List<Schema.SObjectField>> fieldTokensByObjectName) {
            fields = new List<Field>();
            for (String sObjectName : fieldTokensByObjectName.keySet()) {
                for (Schema.SObjectField field : fieldTokensByObjectName.get(sObjectName)) {
                    fields.add(new Field(field, sObjectName));
                }
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

        public Map<String, List<String>> getMissingAccessFieldsByObject(CrudFlsService.CRUDAccessType accessLevel) {
            Map<String, List<String>> fieldsByObject = new Map<String, List<String>>();
            for (Field field : fields) {
                if (!field.getAccessLevel(accessLevel)) {
                    String objectName = field.objectName != null ? field.objectName : 'None Provided';
                    if (fieldsByObject.get(objectName) != null) {
                        fieldsByObject.get(objectName).add(field.name);
                    } else {
                        fieldsByObject.put(objectName, new List<String>{ field.name });
                    }
                }
            }
            return fieldsByObject;
        }
    }

    @TestVisible
    private virtual with sharing class Field {
        public String name;
        public String localName;
        public String objectName;
        public Boolean isAccessible;
        public Boolean isUpdateable;
        public Boolean isCreateable;
        public Boolean isCurrentNamespace;

        protected Field() {
        }

        public Field(Schema.SObjectField sof) {
            Schema.DescribeFieldResult dfr = sof.getDescribe();
            name = dfr.getName();
            localName = dfr.getLocalName();
            isAccessible = dfr.isAccessible();
            isUpdateable = dfr.isUpdateable();
            isCreateable = dfr.isCreateable();
            isCurrentNamespace = (name != localName);
        }

        public Field(Schema.SObjectField sof, String sObjectName) {
            this(sof);
            objectName = sObjectName;
        }

        public Boolean isCurrentNamespace() {
            return (name != localName);
        }

        public Boolean getAccessLevel(CrudFlsService.CRUDAccessType accessType) {
            switch on accessType {
                when CREATEABLE {
                    return isCreateable;
                }
                when READABLE {
                    return isAccessible;
                }
                when UPDATEABLE {
                    return isUpdateable;
                }
                when else {
                    return false;
                }
            }
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

        public virtual override Map<Id, Boolean> getHasEditAccessMap(Id userId, Set<Id> recordIds) {
            // for testing purposes, all records are considered editable

            Map<Id, Boolean> hasEditAccessMap = new Map<Id, Boolean>();

            for (Id recordId : recordIds) {
                hasEditAccessMap.put(recordId, true);
            }

            return hasEditAccessMap;
        }

        public virtual override Map<Id, Boolean> getHasReadAccessMap(Id userId, Set<Id> recordIds) {
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

        public override void assertAccessibleBySObject(
            Map<String, List<Schema.SObjectField>> fieldTokensBySObjectName
        ) {
            // do not check crud/fls in this test only stub
        }

        public override void assertUpdateableBySObject(
            Map<String, List<Schema.SObjectField>> fieldTokensBySObjectName
        ) {
            // do not check crud/fls in this test only stub
        }

        public override void assertCreateableBySObject(
            Map<String, List<Schema.SObjectField>> fieldTokensBySObjectName
        ) {
            // do not check crud/fls in this test only stub
        }
    }

    @TestVisible
    public with sharing class UnknownFieldException extends Exception {
    }

    public virtual with sharing class CrudException extends Exception {
    }
    public with sharing class CrudFlsException extends CrudException {
    }
    public with sharing class CrudOlsException extends CrudException {
    }
}
