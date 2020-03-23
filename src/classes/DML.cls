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