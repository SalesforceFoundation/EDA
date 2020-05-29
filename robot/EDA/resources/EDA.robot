*** Settings ***

Resource        cumulusci/robotframework/Salesforce.robot
Library         robot/EDA/resources/EDA.py
Library         DateTime

*** Keywords ***
Capture Screenshot and Delete Records and Close Browser
    [Documentation]         Captures screenshot if a test fails, deletes session records and closes the browser
    Run Keyword If Any Tests Failed      Capture Page Screenshot
    Close Browser
    Delete Session Records

Populate Create And Return Contact with Address
    [Arguments]     ${first_name}           ${last_name}      
    ...             ${mailing_street}       ${mailing_city}
    ...             ${mailing_zip}          ${mailing_state}      ${mailing_country}
    Go To Object Home         Contact
    Click Object Button       New
    Populate Form
    ...                       First Name=${first_name}
    ...                       Last Name=${last_name}
    Click Dropdown            Primary Address Type
    Click Link                link=Work
    Populate Address          Mailing Street            ${mailing_street}
    Populate Address          Mailing City              ${mailing_city}
    Populate Address          Mailing Zip/Postal Code   ${mailing_zip}
    Populate Address          Mailing State/Province    ${mailing_state}
    Populate Address          Mailing Country           ${mailing_country}
    Click Modal Button        Save
    Wait Until Modal Is Closed

    ${contact_id} =           Get Current Record Id
    Store Session Record      Contact  ${contact_id}
    [return]                  ${contact_id}

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
    [Documentation]         Returns the ID of a record identified by the given field_name and field_value input for a specific object
    [Arguments]             ${obj_name}             ${field_name}               ${field_value}
    @{records} =            Salesforce Query        ${obj_name}
    ...                         select=Id
    ...                         ${field_name}=${field_value}
    &{Id} =                 Get From List           ${records}      0
    [return]                &{Id}[Id]

API Create Contact
    ${first_name} =  Generate Random String
    ${last_name} =   Generate Random String
    ${contact_id} =  Salesforce Insert  Contact
    ...                  FirstName=${first_name}
    ...                  LastName=${last_name}
    &{contact} =     Salesforce Get  Contact  ${contact_id}
    [return]         &{contact}

Create Contact with Email
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

Select Frame With Title
    [Arguments]                 ${name}
    Select Frame                //iframe[@title= '${name}']
    
Scroll Page To Location
    [Arguments]                 ${x_location}    ${y_location}
    Execute JavaScript          window.scrollTo(${x_location},${y_location})

Go to EDA settings
    [Documentation]             Clicks on App Waffle and selects 'EDA Settings' tab
    Select app launcher tab     EDA Settings
    Select frame with title     accessibility title
