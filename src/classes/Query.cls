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
* @description Dynamic query class
*/
public virtual inherited sharing class Query {
    @TestVisible
    private Object tmp0, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7, tmp8, tmp9,
        tmp10, tmp11, tmp12, tmp13, tmp14, tmp15, tmp16, tmp17, tmp18, tmp19;

    @TestVisible
    private List<Object> tmpList;

    private Integer tmpCounter;

    @TestVisible
    private Integer queryLimit;

    private Schema.SObjectType objectType;

    @TestVisible
    @TestVisible
    private List<Condition> conditions;

    @TestVisible
    private List<Field> fields;

    @TestVisible
    private List<OrderBy> orderByList;

    public Query(Schema.SObjectType objectType) {
        this.objectType = objectType;
        this.tmpCounter = 0;
        initTmpList();
    }

    private void initTmpList() {
        this.tmpList = new List<Object>();

        for (Integer i = 0; i < 20; i++) {
            this.tmpList.add(null);
        }
    }

    private void setTmpVars() {
        this.tmp0 = this.tmpList.get(0);
        this.tmp1 = this.tmpList.get(1);
        this.tmp2 = this.tmpList.get(2);
        this.tmp3 = this.tmpList.get(3);
        this.tmp4 = this.tmpList.get(4);
        this.tmp5 = this.tmpList.get(5);
        this.tmp6 = this.tmpList.get(6);
        this.tmp7 = this.tmpList.get(7);
        this.tmp8 = this.tmpList.get(8);
        this.tmp9 = this.tmpList.get(9);
        this.tmp10 = this.tmpList.get(10);
        this.tmp11 = this.tmpList.get(11);
        this.tmp12 = this.tmpList.get(12);
        this.tmp13 = this.tmpList.get(13);
        this.tmp14 = this.tmpList.get(14);
        this.tmp15 = this.tmpList.get(15);
        this.tmp16 = this.tmpList.get(16);
        this.tmp17 = this.tmpList.get(17);
        this.tmp18 = this.tmpList.get(18);
        this.tmp19 = this.tmpList.get(19);
    }

    public void addTmpVar(Object o) {
        this.tmpList.set(this.tmpCounter, o);
        this.tmpCounter++;
    }

    public Integer getTmpCounter() {
        return this.tmpCounter;
    }

    protected virtual void assertAccess() {
        CrudFlsService.getInstance().assertObjectAccessible(this.objectType);
    }

    public List<Record> runQuery() {
        assertAccess();
        String queryString = generateQueryString(null);

        setTmpVars();

        return translateToRecords(Database.query(queryString));
    }

    public List<SObject> runUnscrubbedQuery() {
        CrudFlsService.getInstance().assertObjectAccessible(this.objectType);

        String queryString = generateQueryString(null);

        setTmpVars();

        return Database.query(queryString);
    }

    public virtual List<Record> translateToRecords(List<SObject> sObjects) {
        List<Record> records = new List<Record>();

        if (sObjects == null) {
            return records;
        }

        for (SObject so : sObjects) {
            Record r = new Record(so.Id);

            for (Field f : this.fields) {
                Object value = f.getFieldValue(so);
                r.put(f.getFieldName(), value);

                Schema.SObjectField schemaField = f.getField();

                if (schemaField != null) {
                    r.put(schemaField, value);
                }
            }

            records.add(r);
        }

        return records;
    }

    public Query setLimit(Integer queryLimit) {
        this.queryLimit = queryLimit;
        return this;
    }

    public Query addCondition(Condition c) {
        if (this.conditions == null) {
            this.conditions = new List<Condition>();
        }

        this.conditions.add(c);
        return this;
    }

    public Query addOrderBy(OrderBy ob) {
        if (this.orderByList == null) {
            this.orderByList = new List<OrderBy>();
        }

        this.orderByList.add(ob);
        return this;
    }

    public Query addField(Field f) {
        if (this.fields == null) {
            this.fields = new List<Field>();
        }

        this.fields.add(f);
        return this;
    }

    private String generateWhereClause(Query queryContext) {
        String whereClause = '';
        List<String> conditionStrings = new List<String>();
        if (this.conditions != null) {

            for (Condition c : this.conditions) {
                conditionStrings.add(c.generateString(queryContext));
            }

            whereClause = String.format(
                'WHERE {0}',
                new List<String> {
                    String.join(
                        conditionStrings,
                        ' AND '
                    )
                }
            );
        }

        return whereClause;
    }

    protected virtual String generateObjectName() {
        return this.objectType.getDescribe().getName();
    }

    private String generateFieldString(Query queryContext) {
        List<String> rowStrings = new List<String>();

        for (Field f : this.fields) {
            rowStrings.add(f.generateString(null, queryContext));
        }

        return String.join(
            rowStrings,
            ','
        );
    }

    private String generateOrderByClause() {
        if (this.orderByList == null) {
            return '';
        }

        List<String> orderByStrings = new List<String>();

        for (OrderBy ob : this.orderByList) {
            orderByStrings.add(ob.generateString());
        }

        return String.format(
            'ORDER BY {0}',
            new List<String> {
                String.join(orderByStrings, ',')
            }
        );
    }

    private String generateLimitString() {
        if (this.queryLimit == null) {
            return '';
        } else {
            return String.format(
                'LIMIT {0}',
                new List<String> {
                    String.valueOf(this.queryLimit)
                }
            );
        }
    }

    public String generateQueryString(Query parentQuery) {

        Query queryContext = (parentQuery == null) ?
            this : parentQuery;

        return String.format(
            'SELECT {0} FROM {1} {2} {3} {4}',
            new List<String> {
                generateFieldString(queryContext),
                generateObjectName(),
                generateWhereClause(queryContext),
                generateOrderByClause(),
                generateLimitString()
            }
        );
    }

    public class NoCrudQuery extends Query {
        public NoCrudQuery(Schema.SObjectType objectType) {
            super(objectType);
        }

        protected override void assertAccess() {}
    }

    public class SubQuery extends Query {

        private String childRelationshipName;

        public SubQuery(String childRelationshipName) {
            super(null);

            this.childRelationshipName = childRelationshipName;
        }

        @TestVisible
        protected override String generateObjectName() {
            return this.childRelationshipName;
        }
    }

    public class OrderBy {

        @TestVisible
        private String orderDirection;

        @TestVisible
        private String fieldName;

        public OrderBy(String orderDirection, String fieldName) {
            this.orderDirection = orderDirection;
            this.fieldName = fieldName;
        }

        public OrderBy(String orderDirection, Schema.SObjectField field) {
            this(orderDirection, field.getDescribe().getName());
        }

        public OrderBy(String field) {
            this('ASC', field);
        }

        public OrderBy(Schema.SObjectField field) {
            this('ASC', field);
        }

        public String generateString() {
            return String.format(
                '{0} {1}',
                new List<String> {
                    this.fieldName,
                    this.orderDirection
                }
            );
        }
    }

    public abstract class Condition {

        public abstract String generateString(Query queryInstance);
    }

    public abstract class Field {

        protected Boolean required = true;

        public abstract String generateString(String parentContext, Query queryContext);
        public abstract Object getFieldValue(SObject so);
        public abstract String getFieldName();
        public abstract Schema.SObjectField getField();

        protected abstract Boolean canAccessField();

        public void setIsRequired(Boolean required) {
            this.required = required;
        }

        public Boolean isRequired() {
            return this.required;
        }
    }

    public class ToLabelField extends SimpleField {

        private String alias;

        public ToLabelField(String alias, Schema.SObjectField field) {
            super(field);
            this.alias = alias;
        }

        public override String generateString(String parentContext, Query queryContext) {
            if (isRequired()) {
                CrudFlsService.getInstance().assertAccessible(this.field);
            }

            return String.format(
                'toLabel({0}) {1}',
                new List<String> {
                    this.field.getDescribe().getName(),
                    this.alias
                }
            );
        }

        public override Object getFieldValue(SObject so) {
            if (so == null) {
                return null;
            }

            if (!CrudFlsService.getInstance().canAccessField(this.field)) {
                return null;
            }

            return so.get(this.alias);
        }

        public override String getFieldName() {
            return this.alias;
        }

        public override Schema.SObjectField getField() {
            return null;
        }
    }

    public class SubQueryField extends Field {

        @TestVisible
        private SubQuery q;
        private String childRelationshipName;

        public SubQueryField(String childRelationshipName) {
            this.q = new SubQuery(childRelationshipName);
            this.childRelationshipName = childRelationshipName;
        }

        public SubQueryField addField(Field r) {
            this.q.addField(r);
            return this;
        }

        public SubQueryField setLimit(Integer theLimit) {
            this.q.setLimit(theLimit);
            return this;
        }

        public SubQueryField addOrderBy(OrderBy ob) {
            this.q.addOrderBy(ob);
            return this;
        }

        public SubQueryField addCondition(Condition c) {
            this.q.addCondition(c);
            return this;
        }

        public override String generateString(String parentContext, Query queryContext) {
            return String.format(
                '({0})',
                new List<String> {
                    this.q.generateQueryString(queryContext).trim()
                }
            );
        }

        public override Object getFieldValue(SObject so) {
            return this.q.translateToRecords(so.getSObjects(this.childRelationshipName));
        }

        public override String getFieldName() {
            return this.childRelationshipName;
        }

        public override Schema.SObjectField getField() {
            return null;
        }

        protected override Boolean canAccessField() {
            return true;
        }
    }

    public virtual class SimpleNoFLSField extends SimpleField {

        public SimpleNoFLSField(Schema.SobjectField field) {
            super(field);
        }

        protected override Boolean canAccessField() {
            return true;
        }
    }

    public virtual class SimpleField extends Field {

        private Schema.SObjectField field;

        public SimpleField(Schema.SobjectField field) {
            this.field = field;
        }

        public virtual override String generateString(String parentContext, Query queryContext) {
            if (isRequired()) {
                CrudFlsService.getInstance().assertAccessible(this.field);
            }

            return this.field.getDescribe().getName();
        }

        public virtual override Object getFieldValue(SObject so) {
            if (so == null) {
                return null;
            }

            if (!canAccessField()) {
                return null;
            }

            return so.get(this.getFieldName());
        }

        public virtual override String getFieldName() {
            return this.field.getDescribe().getName();
        }

        public virtual override Schema.SObjectField getField() {
            return this.field;
        }

        protected virtual override Boolean canAccessField() {
            return CrudFlsService.getInstance().canAccessField(this.field);
        }
    }

    public class RelationshipNoFLS extends Relationship {

        public RelationshipNoFLS(Schema.SObjectField field) {
            super(field);
        }

        protected override Boolean canAccessField() {
            return true;
        }
    }

    public virtual class Relationship extends Field {

        private Schema.SObjectField field;
        private List<Field> relationshipFields;

        public Relationship(Schema.SObjectField field) {
            this.field = field;
        }

        public Relationship addField(Field f) {
            if (this.relationshipFields == null) {
                this.relationshipFields = new List<Field>();
            }

            this.relationshipFields.add(f);
            return this;
        }

        public override String generateString(String parentContext, Query queryContext) {
            if (isRequired()) {
                CrudFlsService crudService = CrudFlsService.getInstance();
                crudService.assertAccessible(this.field);
                crudService.assertObjectAccessible(this.field.getDescribe().getReferenceTo()[0]);
            }

            List<String> fieldStrings = new List<String>();
            Schema.DescribeFieldResult fd = this.field.getDescribe();
            String parentRelationship = (String.isBlank(parentContext)) ?
                fd.getRelationshipName()
                :
                String.format(
                    '{0}.{1}',
                    new List<String> {
                        parentContext,
                        fd.getRelationshipName()
                    }
                );

            for (Field f : this.relationshipFields) {
                fieldStrings.add(
                    String.format(
                        '{0}.{1}',
                        new List<String> {
                            parentRelationship,
                            f.generateString(parentRelationship, queryContext)
                        }
                    )
                );
            }

            return String.join(
                fieldStrings,
                ','
            );
        }

        public override Object getFieldValue(SObject so) {
            if (!canAccessField()) {
                return null;
            }

            SObject relationshipObject = so.getSObject(this.getFieldName());

            if (relationshipObject == null) {
                return null;
            }

            Record r = new Record(relationshipObject.Id);

            for (Field f : this.relationshipFields) {
                Object value = f.getFieldValue(relationshipObject);
                r.put(f.getFieldName(), value);

                Schema.SObjectField schemaField = f.getField();

                if (schemaField != null) {
                    r.put(schemaField, value);
                }
            }

            return r;
        }

        protected virtual override Boolean canAccessField() {
            return CrudFlsService.getInstance().canAccessField(this.field);
        }

        public override String getFieldName() {
            return this.field.getDescribe().getRelationshipName();
        }

        public override Schema.SObjectField getField() {
            return null;
        }
    }

    public class SubQueryCondition extends Condition {

        private Query subQuery;
        private String operator;
        private String field;

        public SubQueryCondition(String field, String operator, Query subQuery) {
            this.field = field;
            this.operator = operator;
            this.subQuery = subQuery;
        }

        public override String generateString(Query queryInstance) {
            return String.join(new List<String>{
                this.field,
                this.operator,
                String.format(
                    '({0})',
                    new List<String>{
                        this.subQuery.generateQueryString(queryInstance).trim()
                    }
                )
            }, ' ');
        }
    }

    public class SimpleCondition extends Condition {

        @TestVisible
        private Object comparisonValue;

        @TestVisible
        private String operator;

        @TestVisible
        private String field;

        public SimpleCondition(String field, String operator, Object comparisonValue) {
            this.field = field;
            this.operator = operator;
            this.comparisonValue = comparisonValue;
        }

        public override String generateString(Query queryInstance) {
            Integer tmpCounter = queryInstance.getTmpCounter();

            queryInstance.addTmpVar(this.comparisonValue);

            return String.join(new List<String> {
                this.field,
                operator,
                String.format(
                    ':tmp{0}',
                    new List<String> {
                        String.valueOf(tmpCounter)
                    }
                )
            }, ' ');
        }
    }

    public class ConditionList extends Condition {

        @TestVisible
        private String booleanOperator;

        private List<Condition> nestedConditions;

        public ConditionList() {
            this.booleanOperator = 'AND';
        }

        public ConditionList(String booleanOperator) {
            this.booleanOperator = booleanOperator;
        }

        public ConditionList addCondition(Condition c) {
            if (this.nestedConditions == null) {
                this.nestedConditions = new List<Condition>();
            }

            this.nestedConditions.add(c);
            return this;
        }

        public override String generateString(Query queryInstance) {
            if (this.nestedConditions == null) {
                return null;
            }

            List<String> nestedStrings = new List<String>();

            for (Condition c : this.nestedConditions) {
                String generatedString = c.generateString(queryInstance);

                if (generatedString == null) {
                    continue;
                }

                nestedStrings.add(
                    String.format(
                        ' {0} ',
                        new List<String> {
                            generatedString
                        }
                    )
                );
            }

            return String.format(
                ' ({0}) ',
                new List<String> {
                    String.join(
                        nestedStrings,
                        this.booleanOperator
                    )
                }
            );
        }
    }
}