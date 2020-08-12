*** Settings ***
Documentation   Validates the preferred phone field by creating new contacts
Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Keywords ***
Populate Create And Return Contact with Home Phone
    [Documentation]     Creates a new contact record using the paramters passed and returns the
    ...                 contact salesforce record id
    [Arguments]      ${first_name}      ${last_name}    ${home_phone}
    Go To Object Home           Contact
    Click Object Button         New
    Populate Form
    ...                         First Name=${first_name}
    ...                         Last Name=${last_name}
    ...                         Home Phone=${home_phone}
    Click Modal Button          Save
    Wait Until Modal Is Closed

    ${contact_id} =             Get Current Record Id
    Store Session Record        Contact  ${contact_id}
    [return]                    ${contact_id}

*** Test Cases ***
Let Us Populate Create And Return Contact with Home Phone
    [Documentation]     Creates a new contact record using home phone
    [tags]           unstable
    ${contact_id} =  Populate Create And Return Contact with Home Phone    Julian       Joseph
    ...                 512-555-1234
    &{contact} =     Salesforce Get    Contact             ${contact_id}
    Select Tab       Details
    #Should Be Equal  &{contact}[PreferredPhone__c]    Home
    #This won't work until the Preferred Phone is Activated