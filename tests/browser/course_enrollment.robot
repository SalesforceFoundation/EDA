*** Settings ***

Resource  tests/HEDA.robot
Suite Setup  Set Login Url
Suite Teardown  Close Browser

*** Test Cases ***

Create Course Connection
    Open Test Browser
    &{contact} =        Create Contact
    ${department_id} =  Create Department
    &{term} =           Create Term             ${department_id}
    &{course} =         Create Course           ${department_id}
    &{offering} =       Create Course Offering  &{course}[Id]  &{term}[Id]
    
    Create Course Connection   &{contact}[Id]  &{offering}[Name]

    Go To Record Home          &{contact}[Id]
    ${count} =                 Get Related List Count  Course Connections
    Should Be Equal            ${count}  ${1}
    
*** Keywords ***

Create Contact
    ${first_name} =  Generate Random String
    ${last_name} =   Generate Random String
    ${contact_id} =  Salesforce Insert  Contact
    ...                  FirstName=${first_name}
    ...                  LastName=${last_name}
    &{contact} =     Salesforce Get  Contact  ${contact_id}
    [return]         &{contact}

Create Department
    # Use the UI since we don't yet have easy keywords for querying record types
    ${department_name} =  Generate Random String
    Go To Object Home     Account
    Click Object Button   New
    Select Record Type    University Department
    Populate Form         Account Name=${department_name}
    Click Modal Button    Save
    Wait Until Modal is Closed
    ${department_id} =    Get Current Record Id
    [return]              ${department_id}

Create Term
    [Arguments]       ${account_id}
    ${term_name} =    Generate Random String
    ${term_id} =      Salesforce Insert  Term__c
    ...                   Name=${term_name} 
    ...                   Account__c=${account_id} 
    &{term} =         Salesforce Get  Term__c  ${term_id}
    [return]          &{term}

Create Course
    [Arguments]       ${account_id}
    ${course_name} =  Generate Random String
    ${course_id} =    Salesforce Insert  Course__c
    ...                   Name=${course_name} 
    ...                   Account__c=${account_id} 
    &{course} =       Salesforce Get  Course__c  ${course_id}
    [return]          &{course}

Create Course Offering
    [Arguments]       ${course_id}  ${term_id}
    ${offering_id} =  Salesforce Insert  Course_Offering__c
    ...                   Course__c=${course_id} 
    ...                   Term__c=${term_id} 
    &{offering} =     Salesforce Get  Course_Offering__c  ${offering_id}
    [return]          &{offering}

Create Course Connection
    [Arguments]       ${contact_id}  ${offering_name}
    Go To Record Home          ${contact_id}
    Click Related List Button  Course Connections  New
    Select Record Type         Student
    Populate Field             Course Offering ID  ${offering_name}
    Click Link                 ${offering_name}
    Click Modal Button         Save
    Wait Until Modal Is Closed
