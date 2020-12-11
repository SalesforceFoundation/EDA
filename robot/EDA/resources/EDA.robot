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
    Close Browser
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
    [Documentation]         Creating a contact through API
    ${first_name} =  Generate Random String
    ${last_name} =   Generate Random String
    ${contact_id} =  Salesforce Insert  Contact
    ...                  FirstName=${first_name}
    ...                  LastName=${last_name}
    &{contact} =     Salesforce Get  Contact  ${contact_id}
    [return]         &{contact}

API Create Collaboration Group
    [Documentation]
    ...             Creates a collaboration group by sending name and collaboration type
    [Arguments]      ${group_name}
    ${group_id} =  Salesforce Insert  CollaborationGroup
    ...                  Name=${group_name}
    ...                  CollaborationType=Public
    [return]         ${group_id}

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

Get Records Count
    [Documentation]         Returns the no of record identified by the given field_name and
    ...                     field_value input for a specific object
    ${NS} =                 Get EDA namespace prefix
    [Arguments]             ${obj_name}             ${field_name}       ${field_value}
    ${result} =             SOQL Query
    ...                     SELECT COUNT(Name) FROM ${NS}${obj_name} where ${NS}${field_name}=${field_value}
    &{Id} =                 Get From List  ${result['records']}  0
    [return]                ${Id}[expr0]