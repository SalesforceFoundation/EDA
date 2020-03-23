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
* @description Utility class that performs checks whether DML action for specified obect or field is permittable based on user permission. 
*/
public inherited sharing abstract class DML {

    protected Schema.SObjectType objectType;

    protected DML(Schema.SObjectType objectType) {
        this.objectType = objectType;
    }

    protected abstract void checkAccess(List<Record> records);
    protected abstract List<Record> performDML(List<Record> records);

    public List<Record> run(List<Record> records) {
        checkAccess(records);

        return performDML(records);
    }

    protected Set<Schema.SObjectField> getFieldSet(List<Record> records) {
        Set<Schema.SObjectField> fields = new Set<Schema.SObjectField>();

        for (Record r : records) {
            fields.addAll(r.getFieldTokens());
        }

        return fields;
    }

    public class DMLDelete extends DML {

        public DMLDelete(Schema.SObjectType objectType) {
            super(objectType);
        }

        protected override void checkAccess(List<Record> records) {
            CrudFlsService crudService = CrudFlsService.getInstance();

            crudService.assertObjectDeletable(this.objectType);
        }

        protected override List<Record> performDML(List<Record> records) {
            DeleteRecordList rl = new DeleteRecordList(records);
            List<SObject> sObjects = rl.getSObjects();

            delete sObjects;

            return null;
        }
    }

    public virtual class DMLUpdate extends DML {

        public DMLUpdate(Schema.SObjectType objectType) {
            super(objectType);
        }

        protected virtual override void checkAccess(List<Record> records) {
            CrudFlsService crudService = CrudFlsService.getInstance();

            crudService.assertObjectUpdateable(this.objectType);
            crudService.assertUpdateable(
                new List<Schema.SObjectField> (
                    getFieldSet(records)
                )
            );
        }

        protected override List<Record> performDML(List<Record> records) {
            RecordList rl = new RecordList(records);
            List<SObject> sObjects = rl.getSObjects();

            update sObjects;

            return rl.getUpdatedRecords();
        }
    }

    public class DMLInsert extends DML {

        public DMLInsert(Schema.SObjectType objectType) {
            super(objectType);
        }

        protected override void checkAccess(List<Record> records) {
            CrudFlsService crudService = CrudFlsService.getInstance();

            crudService.assertObjectCreateable(this.objectType);
            crudService.assertCreateable(
                new List<Schema.SObjectField> (
                    getFieldSet(records)
                )
            );
        }

        protected override List<Record> performDML(List<Record> records) {
            RecordList rl = new RecordList(records);
            List<SObject> sObjects = rl.getSObjects();

            insert sObjects;

            return rl.getUpdatedRecords();
        }
    }

    private virtual class RecordList {
        private List<DMLRecord> records;

        public RecordList() {}

        public RecordList(List<Record> records) {
            this.records = new List<DMLRecord>();

            for (Record r : records) {
                this.records.add(new DMLRecord(r));
            }
        }

        public List<Record> getUpdatedRecords() {
            List<Record> updatedRecords = new List<Record>();

            for (DMLRecord dr : this.records) {
                Record r = new Record(dr.getSObjectId());

                for (Schema.SObjectField f : dr.getFieldTokens()) {
                    r.put(f, dr.get(f));
                }

                updatedRecords.add(r);
            }

            return updatedRecords;
        }

        public virtual List<SObject> getSObjects() {
            List<SObject> sObjects = new List<SObject>();

            for (DMLRecord dr : this.records) {
                sObjects.add(dr.sObjectRecord);
            }

            return sObjects;
        }
    }

    private virtual class DMLRecord extends Record {
        public SObject sObjectRecord;

        public Id getSObjectId() {
            return this.sObjectRecord.Id;
        }

        public DMLRecord(Record r) {
            super(r.getObjectType());
            this.sObjectRecord = r.getObjectType().newSObject(r.getId());
            setId(r.getId());
            populateFields(r);
        }

        protected virtual void populateFields(Record r) {
            for (Schema.SObjectField f : r.getFieldTokens()) {
                put(f, r.get(f));
                this.sObjectRecord.put(f, r.get(f));
            }
        }
    }

    private class DeleteDMLRecord extends DMLRecord {
        public DeleteDMLRecord(Record r) {
            super(r);
        }

        protected override void populateFields(Record r) {}
    }

    private class DeleteRecordList extends RecordList {

        public DeleteRecordList(List<Record> records) {
            this.records = new List<DeleteDMLRecord>();

            for (Record r : records) {
                this.records.add(new DeleteDMLRecord(r));
            }
        }
    }
}