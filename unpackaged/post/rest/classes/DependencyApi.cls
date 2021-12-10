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
@RestResource(urlMapping='/EDA-Dependency')
global with sharing class DependencyApi {
    @HttpGet
    global static List<Item> doGet() {
        Map<String, List<String>> metadataMapping = new Map<String, List<String>>();
        metadataMapping.put('HEAD->', new List<String>());

        List<FieldDefinition> fields = getFieldDefinitions();
        Map<String, Meta> fieldEntityMapping = recordFieldMetadata(metadataMapping, fields);

        List<ComponentDependencyItem> metadata = new ComponentDependencyService().getComponentDependency();
        recordComponentMetadata(metadataMapping, metadata, fieldEntityMapping);

        return buildOutputStructure(metadataMapping);
    }

    static List<Item> buildOutputStructure(Map<String, List<String>> metadataMapping) {
        List<Item> output = new List<Item>();
        for (String i : metadataMapping.get('HEAD->')) {
            List<String> mappings = metadataMapping.get(i);
            if (mappings != null && mappings.size() > 0) {
                Item item = new Item(i, i, true);
                output.add(item);
                dfs(item, metadataMapping);
            }
        }
        // Filter down results to only those which have dependencies
        List<Item> clone = new List<Item>();
        for (Item o : output) {
            if (o.items.size() > 0) {
                clone.add(o);
            }
        }
        return clone;
    }

    static void dfs(Item head, Map<String, List<String>> metadataMapping) {
        if (!metadataMapping.containsKey(head.label))
            return;
        for (String i : metadataMapping.get(head.label)) {
            Item item = new Item(i, i);
            List<String> mappings = metadataMapping.get(item.label);
            if (
                (item.label.contains('Entity:') &&
                mappings != null &&
                mappings.size() > 0) ||
                (item.label.contains('Field:') &&
                mappings != null &&
                mappings.size() > 0) ||
                (!item.label.contains('Entity:') && !item.label.contains('Field:'))
            ) {
                head.items.add(item);
                dfs(item, metadataMapping);
            }
        }
    }

    static List<FieldDefinition> getFieldDefinitions() {
        String prefix = '';
        List<Publisher> packages = [SELECT Id FROM Publisher WHERE NamespacePrefix = 'hed'];
        if (packages.size() == 1) {
            prefix = 'hed__';
        }

        List<String> entitiesToQuery = new List<String> {
            prefix + 'Academic_Certification__c',
            'Account',
            prefix + 'Address__c',
            prefix + 'Affiliation__c',
            prefix + 'Affl_Mappings__c',
            prefix + 'Application__c',
            prefix + 'Attendance_Event__c',
            prefix + 'Attribute__c',
            prefix + 'Behavior_Involvement__c',
            prefix + 'Behavior_Response__c',
            'Case',
            'Contact',
            prefix + 'Contact_Language__c',
            prefix + 'Course__c',
            prefix + 'Course_Enrollment__c',
            prefix + 'Course_Offering__c',
            prefix + 'Course_Offering_Schedule__c',
            prefix + 'Credential__c',
            prefix + 'Education_History__c',
            prefix + 'Error__c',
            prefix + 'Facility__c',
            prefix + 'Hierarchy_Settings__c',
            prefix + 'Language__c',
            'Lead',
            'Opportunity',
            prefix + 'Plan_Requirement__c',
            prefix + 'Product_Registry__mdt',
            prefix + 'Program_Enrollment__c',
            prefix + 'Program_Plan__c',
            prefix + 'Relationship__c',
            prefix + 'Relationship_Auto_Create__c',
            prefix + 'Relationship_Lookup__c',
            prefix + 'Term__c',
            prefix + 'Term_Grade__c',
            prefix + 'Test__c',
            prefix + 'Test_Definition__mdt',
            prefix + 'Test_Score__c',
            prefix + 'Test_Score_Definition__mdt',
            prefix + 'Time_Block__c'
        };

        return [
            SELECT
                EntityDefinition.NamespacePrefix,
                EntityDefinition.QualifiedApiName,
                EntityDefinition.KeyPrefix,
                NamespacePrefix,
                QualifiedApiName,
                DurableId
            FROM FieldDefinition
            WHERE
                EntityDefinition.QualifiedApiName IN :entitiesToQuery
        ];
    }

    static Map<String, Meta> recordFieldMetadata(
        Map<String, List<String>> metadataMapping,
        List<FieldDefinition> fields
    ) {
        Map<String, Meta> fieldEntityMapping = new Map<String, Meta>();
        for (FieldDefinition field : fields) {
            Meta m = new Meta(
                field.EntityDefinition.NamespacePrefix,
                field.EntityDefinition.QualifiedApiName,
                'Entity'
            );
            if (!metadataMapping.containsKey(m.toKey())) {
                metadataMapping.put(m.toKey(), new List<String>());
                metadataMapping.get('HEAD->').add(m.toKey());
            }
            String name = field.EntityDefinition.QualifiedApiName + '.' + field.QualifiedApiName;
            Meta fieldM = new Meta(field.NamespacePrefix, name, 'Field');
            metadataMapping.get(m.toKey()).add(fieldM.toKey());
            metadataMapping.put(fieldM.toKey(), new List<String>());

            fieldEntityMapping.put(
                field.QualifiedApiName + field.DurableId.substring(field.DurableId.indexOf('.')),
                fieldM
            );
        }
        return fieldEntityMapping;
    }

    static void recordComponentMetadata(
        Map<String, List<String>> metadataMapping,
        List<ComponentDependencyItem> metadata,
        Map<String, Meta> fieldEntityMapping
    ) {
        for (ComponentDependencyItem m : metadata) {
            Meta fieldMeta = null;
            if (m.refMetadataComponentType.equals('CustomField')) {
                fieldMeta = fieldEntityMapping.get(
                    m.refMetadataComponentName +
                    '__c.' +
                    m.refMetadataComponentId.substring(0, 15)
                );
                if (fieldMeta == null) {
                    fieldMeta = new Meta(
                        m.refMetadataComponentNamespace,
                        m.refMetadataComponentName,
                        m.refMetadataComponentType
                    );
                }
                System.debug(fieldMeta);
            } else {
                fieldMeta = new Meta(
                    m.refMetadataComponentNamespace,
                    m.refMetadataComponentName,
                    m.refMetadataComponentType
                );
            }

            if (!metadataMapping.containsKey(fieldMeta.toKey())) {
                metadataMapping.put(fieldMeta.toKey(), new List<String>());
            }
            metadataMapping.get(fieldMeta.toKey())
                .add(new Meta(m.metadataComponentNamespace, m.metadataComponentName, m.metadataComponentType).toKey());
        }
    }
}
