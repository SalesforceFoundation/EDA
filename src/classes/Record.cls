/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
R
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
* @description 
*/
public virtual with sharing class Record {

    private Schema.SobjectType objectType;
    private Id recordId;
    private Map<String, Object> values;
    private Map<Schema.SObjectField, Object> tokenValues;

    public Record(Schema.SobjectType objectType) {
        this.objectType = objectType;
        this.values = new Map<String, Object>();
        this.tokenValues = new Map<Schema.SObjectField, Object>();
    }

    public Record(Id recordId) {
        this.objectType = getObjectType(recordId);
        this.recordId = recordId;
        this.values = new Map<String, Object>();
        this.tokenValues = new Map<Schema.SObjectField, Object>();
    }

    public void put(Schema.SObjectField field, Object value) {
        this.tokenValues.put(field, value);
    }

    public void put(String key, Object value) {
        this.values.put(key, value);
    }

    public Object get(String key) {
        return this.values.get(key);
    }

    public Object get(Schema.SObjectField key) {
        return this.tokenValues.get(key);
    }

    public Id getId() {
        return this.recordId;
    }

    protected void setId(Id recordId) {
        this.recordId = recordId;
    }

    public Schema.SObjectType getObjectType() {
        return this.objectType;
    }

    public Set<Schema.SObjectField> getFieldTokens() {
        return this.tokenValues.keySet();
    }

    public SObject toSObjectForUpdate() {
        SObject so = this.objectType.newSObject(this.recordId);

        for (String key : this.values.keySet()) {
            try {
                so.put(key, this.values.get(key));
            } catch (Exception e) {}
        }

        return so;
    }

    private Schema.SObjectType getObjectType(Id rId) {
        try {
            return rId.getSobjectType();
        } catch (Exception e) {
            return null;
        }
    }
}