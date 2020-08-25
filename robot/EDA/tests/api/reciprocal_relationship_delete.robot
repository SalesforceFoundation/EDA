*** Settings ***
Documentation   Validates deletion of reciprocal relationships
Resource  robot/EDA/resources/EDA.robot
Suite Teardown  Delete Session Records

*** Test Cases ***

Delete Separately Reciprocal First
    [Documentation]     Deletes the reciprocal relationship and then the relationship
    &{contact1} =        API Create Contact
    &{contact2} =        API Create Contact
    ${rel_id} =          Salesforce Insert  Relationship__c
    ...                      Contact__c=${contact1}[Id]
    ...                      RelatedContact__c=${contact2}[Id]
    &{rel} =             Salesforce Get  Relationship__c  ${rel_id}
    Salesforce Delete    Relationship__c  ${rel}[ReciprocalRelationship__c]
    Run Keyword And Expect Error  *ENTITY_IS_DELETED*
    ...                     Salesforce Delete    Relationship__c  ${rel_id}

Delete Separately Reciprocal Last
    [Documentation]     Deletes the relationship and then the reciprocal relationship
    &{contact1} =        API Create Contact
    &{contact2} =        API Create Contact
    ${rel_id} =          Salesforce Insert  Relationship__c
    ...                      Contact__c=${contact1}[Id]
    ...                      RelatedContact__c=${contact2}[Id]
    &{rel} =             Salesforce Get  Relationship__c  ${rel_id}
    Salesforce Delete    Relationship__c  ${rel_id}
    Run Keyword And Expect Error  *ENTITY_IS_DELETED*
    ...                     Salesforce Delete    Relationship__c  ${rel}[ReciprocalRelationship__c]

Delete Together
    [Documentation]     Deleted relationship & reciprocal relationship together
    [tags]  unstable
    &{contact1} =        API Create Contact
    &{contact2} =        API Create Contact
    ${rel_id} =          Salesforce Insert  Relationship__c
    ...                      Contact__c=${contact1}[Id]
    ...                      RelatedContact__c=${contact2}[Id]
    &{rel} =             Salesforce Get  Relationship__c  ${rel_id}
    Run Task             execute_anon
    ...  apex=delete [SELECT Id FROM Relationship__c WHERE Id =
    ...     '${rel_id}' OR Id = '${rel}[ReciprocalRelationship__c]'];
    Remove Session Record  Relationship__c  ${rel_id}
    Remove Session Record  Relationship__c  ${rel}[ReciprocalRelationship__c]
