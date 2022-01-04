*** Settings ***

Resource        cumulusci/robotframework/Salesforce.robot
Library         cumulusci.robotframework.PageObjects
Library         robot/EDA/resources/EDA.py
Library         DateTime

*** Variables ***
${NS}

*** Keywords ***
Capture Screenshot and Delete Records and Close Browser
    [Documentation]         Captures screenshot if a test fails, deletes session records
    ...                     and closes the browser
    Run Keyword If Any Tests Failed      Capture Page Screenshot
    Close All Browsers
    Delete Session Records

API create program plan
    [Documentation]         Creating a Program Plan through API call
    [Arguments]             ${program_plan_name}    &{fields}

    ${ns} =                 Get EDA namespace prefix
    ${prog_plan_id} =       Salesforce Insert       ${ns}Program_Plan__c
    ...                         Name=${program_plan_name}
    ...                         &{fields}
    &{program_plan} =       Salesforce Get          ${ns}Program_Plan__c   ${prog_plan_id}
    [return]                &{program_plan}

API create plan requirement
    [Documentation]         Creating a Plan Requirement through API call
    [Arguments]             ${plan_req_name}        ${program_plan_id}      &{fields}

    ${ns} =                 Get EDA namespace prefix
    ${prog_req_id} =        Salesforce Insert       ${ns}Plan_Requirement__c
    ...                         Name=${plan_req_name}
    ...                         ${ns}Program_Plan__c=${program_plan_id}
    ...                         &{fields}
    &{plan_requirement} =   Salesforce Get          ${ns}Plan_Requirement__c   ${prog_req_id}
    [return]                &{plan_requirement}

API create language
    [Documentation]         Creating a language record through API
    [Arguments]             ${language_name}

    ${ns} =                 Get EDA namespace prefix
    ${language_id} =        Salesforce Insert       ${ns}Language__c
    ...                         Name=${language_name}
    &{language} =           Salesforce Get          ${ns}Language__c   ${language_id}
    [return]                &{language}

API Get ID
    [Documentation]         Returns the ID of a record identified by the given field_name and
    ...                     field_value input for a specific object
    [Arguments]             ${obj_name}             ${field_name}               ${field_value}
    @{records} =            Salesforce Query        ${obj_name}
    ...                         select=Id
    ...                         ${field_name}=${field_value}
    &{Id} =                 Get From List           ${records}      0
    [return]                ${Id}[Id]

API Create Contact
    [Documentation]         Creates a contact using the arguments passed from the tests and returns
    ...                     the ID of a contact record after inserting it
    [Arguments]             &{fields}
    ${contact_id} =         Salesforce Insert  Contact
    ...                         FirstName=${faker.first_name()}
    ...                         LastName=${faker.last_name()}
    ...                         &{fields}
    &{contact} =            Salesforce Get  Contact  ${contact_id}
    [return]                &{contact}

API Create Collaboration Group
    [Documentation]
    ...             Creates a collaboration group by sending name and collaboration type
    [Arguments]      ${group_name}
    ${group_id} =  Salesforce Insert  CollaborationGroup
    ...                  Name=${group_name}
    ...                  CollaborationType=Public
    [return]         ${group_id}

API Update Records
    [Documentation]         Updates the record based on the Id,field_name & field_value.
    [Arguments]             ${obj_name}    ${id}   &{fields}
    ${record} =             Salesforce Update  ${obj_name}   ${id}
    ...                     &{fields}
    @{records} =            Salesforce Query      ${obj_name}
    ...                         select=Id
    &{Id} =                 Get From List  ${records}  0
    [return]                &{Id}

Create Contact with Email
    [Documentation]         Creating a contact with email address through API
    ${first_name} =           Generate Random String
    ${last_name} =            Generate Random String
    Go To Object Home         Contact
    Click Object Button       New
    Populate Form
    ...                       First Name=${first_name}
    ...                       Last Name=${last_name}
    ...                       Work Email= dshattuck@salesforce.com
    Click Modal Button        Save
    Wait Until Modal Is Closed
    ${contact_id} =           Get Current Record Id
    Store Session Record      Contact  ${contact_id}
    [return]                  ${contact_id}

Create Organization Foundation
    [Documentation]         Creating an organization account through API
    ${account_name} =          Generate Random String
    Go To Object Home          Account
    Click Object Button        New
    Select Record Type         Organization
    Populate Form
    ...                        Account Name=${account_name}
    Click Modal Button         Save
    Wait Until Modal Is Closed
    ${account_id} =            Get Current Record Id
    Store Session Record       Account  ${account_id}
    [return]                   ${account_id}

Get Affiliation Mappings Value
    [Documentation]         Returns the value of the field in affiliation mappings by accepting the
    ...                     name of the value as a parameter
    ${NS} =                 Get EDA namespace prefix
    [Arguments]             ${field_name}           ${record_type_name}
    ${result} =             SOQL Query
    ...                     SELECT ${NS}${field_name} FROM ${NS}Affl_Mappings__c where ${NS}Account_Record_Type__c = '${record_type_name}'
    &{Id} =                 Get From List  ${result['records']}  0
    [return]                ${Id}[${NS}${field_name}]

Get Affiliation Mappings
    [Documentation]         Returns the value of the field in affiliation mappings by accepting the
    ...                     name of the value as a parameter
    ${NS} =                 Get EDA namespace prefix
    [Arguments]             ${field_name}
    ${result} =             SOQL Query
    ...                     SELECT ${NS}${field_name} FROM ${NS}Affl_Mappings__c
    ${count} =              Get Affl Records Count       ${field_name}
    @{ValueList}=           Create List
    FOR     ${index}        IN RANGE    ${count}
        ${name} =               Set variable    ${result}[records][${index}][${NS}${field_name}]
        Append To List          ${ValueList}    ${name}
    END
    [return]                ${ValueList}

Get Relationship Type Values
    [Documentation]         Returns the list of active picklist values for relationship type field
    ${NS} =                 Get EDA namespace prefix
    [Arguments]             ${obj_name}             ${field_name}
    ${result} =             SOQL Query
    ...                     SELECT Name FROM ${NS}${obj_name} where ${NS}${field_name}=true
    ${count} =              Get Records Count       ${obj_name}     ${field_name}       true
    @{ValueList}=           Create List
    FOR     ${index}    IN RANGE    ${count}
        ${name} =               Set variable    ${result}[records][${index}][Name]
        Append To List          ${ValueList}    ${name}
    END
    [return]                ${ValueList}

Get Custom Settings Value
    [Documentation]         Returns the value of the field in hierarch settings by accepting the
    ...                     name of the value as a parameter
    ${NS} =                 Get EDA namespace prefix
    [Arguments]             ${field_name}
    ${result} =             SOQL Query
    ...                     SELECT ${NS}${field_name} FROM ${NS}Hierarchy_Settings__c
    &{Id} =                 Get From List  ${result['records']}  0
    [return]                ${Id}[${NS}${field_name}]

Get Affl Records Count
    [Documentation]         Returns the no of affl record identified by the given field_name and
    ...                     field_value input for a specific object
    ${NS} =                 Get EDA namespace prefix
    [Arguments]             ${field_name}
    ${result} =             SOQL Query
    ...                     SELECT COUNT(${NS}${field_name}) FROM ${NS}Affl_Mappings__c
    &{Id} =                 Get From List  ${result['records']}  0
    [return]                ${Id}[expr0]

Get Record Type Id
    [Documentation]         Returns the Id of the record type by accepting the name of the record
    ...                     type and sObject type
    ${NS} =                 Get EDA namespace prefix
    [Arguments]             ${sObject_name}             ${record_type_name}
    ${result} =             SOQL Query
    ...                     SELECT Id FROM RecordType WHERE SobjectType = '${sObject_name}' AND Name = '${record_type_name}'
    &{Id} =                 Get From List  ${result['records']}  0
    [return]                ${Id}[Id]

Get Language Field Value
    [Documentation]         Returns the value of a field in language object by accepting the field
    ...                     name , record ID and object name
    ${NS} =                 Get EDA namespace prefix
    [Arguments]             ${obj_name}             ${record_id}       ${field_name}
    ${result} =             SOQL Query
    ...                     SELECT Name FROM ${NS}Language__c where Id IN (SELECT ${NS}${field_name} FROM ${obj_name} WHERE Id = '${record_id}')
    &{Id} =                 Get From List           ${result['records']}      0
    [return]                ${Id}[Name]

Get Contact Language Value
    [Documentation]         Returns language fluency, language name and status of primary language
    ...                     by accepting object name and contact record id
    ${NS} =                 Get EDA namespace prefix
    [Arguments]             ${obj_name}             ${contact_id}
    &{result} =             SOQL Query
    ...                     SELECT ${NS}Fluency__c,${NS}Language__r.Name,${NS}Primary_Language__c FROM ${NS}${obj_name} WHERE hed__Contact__r.Id = '${contact_id}'
    &{contact_language} =                 Get From List           ${result['records']}      0
    [return]                &{contact_language}

Run health check settings
    [Documentation]             Validates the health check settings row by row
    [Arguments]                 ${HealthCheckCard}  ${Button}   ${Results}      &{fields}
    Click health check button       Run Health Check
    ${all_checks_status} =      Return all checks status        ${HealthCheckCard}       All checks passed
    Run Keyword If              '${all_checks_status}' == 'True'  Click expand button   ${Button}
    Verify status of a setting     ${Results}       &{fields}