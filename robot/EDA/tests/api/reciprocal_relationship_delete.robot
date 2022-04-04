*** Settings ***
Documentation   Validates deletion of reciprocal relationships
Resource  robot/EDA/resources/EDA.robot
Suite Teardown  Delete Session Records

*** Test Cases ***

Delete Separately Reciprocal First
    [Documentation]     Deletes the reciprocal relationship and then the relationship
    &{contact1} =        API Create Contact
    &{contact2} =        API Create Contact
    ${ns} =              Get EDA namespace prefix
    ${rel_id} =          Salesforce Insert  ${ns}Relationship__c
    ...                      ${ns}Contact__c=${contact1}[Id]
    ...                      ${ns}RelatedContact__c=${contact2}[Id]
    &{rel} =             Salesforce Get  ${ns}Relationship__c  ${rel_id}
    Salesforce Delete    ${ns}Relationship__c  ${rel}[${ns}ReciprocalRelationship__c]
    Run Keyword And Expect Error  *ENTITY_IS_DELETED*
    ...                     Salesforce Delete    ${ns}Relationship__c  ${rel_id}

Delete Separately Reciprocal Last
    [Documentation]     Deletes the relationship and then the reciprocal relationship
    &{contact1} =        API Create Contact
    &{contact2} =        API Create Contact
    ${ns} =              Get EDA namespace prefix
    ${rel_id} =          Salesforce Insert  ${ns}Relationship__c
    ...                      ${ns}Contact__c=${contact1}[Id]
    ...                      ${ns}RelatedContact__c=${contact2}[Id]
    &{rel} =             Salesforce Get  ${ns}Relationship__c  ${rel_id}
    Salesforce Delete    ${ns}Relationship__c  ${rel_id}
    Run Keyword And Expect Error  *ENTITY_IS_DELETED*
    ...                     Salesforce Delete    ${ns}Relationship__c  ${rel}[${ns}ReciprocalRelationship__c]

Delete Together
    [Documentation]     Deleted relationship & reciprocal relationship together
    [tags]  unstable
    &{contact1} =        API Create Contact
    &{contact2} =        API Create Contact
    ${ns} =              Get EDA namespace prefix
    ${rel_id} =          Salesforce Insert  ${ns}Relationship__c
    ...                      ${ns}Contact__c=${contact1}[Id]
    ...                      ${ns}RelatedContact__c=${contact2}[Id]
    &{rel} =             Salesforce Get  ${ns}Relationship__c  ${rel_id}
    Run Task             execute_anon
    ...  apex=delete [SELECT Id FROM ${ns}Relationship__c WHERE Id = '${rel_id}' OR Id = '${rel}[${ns}ReciprocalRelationship__c]'];
    Remove Session Record  ${ns}Relationship__c  ${rel_id}
    Remove Session Record  ${ns}Relationship__c  ${rel}[${ns}ReciprocalRelationship__c]
