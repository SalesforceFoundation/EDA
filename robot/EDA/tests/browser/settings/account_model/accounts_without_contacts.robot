*** Settings ***
Documentation   Validates accounts without contacts settings in account model
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Go to new eda settings

*** Keywords ***

Setup Test Data
    ${admin_id} =              Get Record Type Id        ${sObject_name}     ${admin_record_type}
    Set suite variable         ${admin_id}

*** Variables ***
${admin_record_type}       Administrative
${sObject_name}            Account

*** Test Cases ***
Validate accounts without contacts settings are updated in hierarchy settings
    [Documentation]         Verifies the account without contacts setting can be updated in
    ...                     EDA Settings page and the same record type is updated in hierarchy
    ...                     settings under custom settings.
    [tags]                                      unstable        W-9225285       rbt:high
    Select settings from navigation pane        Account Model
    Click action button on new EDA settings     Edit
    Select and move from list                   Accounts Without Contacts       Administrative
    Click action button on new EDA settings     Save
    ${acc_to_delete}=                           Get Custom Settings Value       Accounts_to_Delete__c
    Should Be Equal As Strings                  ${acc_to_delete}      ${admin_id}