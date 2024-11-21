*** Settings ***
Documentation   Validates default account model settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AccountsAndContactsSettingsPageObject.py
...             robot/EDA/resources/CoursesSettingsPageObject.py
Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Go to education cloud settings

*** Keywords ***

Setup Test Data
    ${record_type_id} =        Get Record Type Id        ${sObject_name}     ${record_type_name}
    Set suite variable         ${record_type_id}

*** Variables ***
${record_type_name}       Household Account
${sObject_name}           Account

*** Test Cases ***
Validate default account model settings is updated in hierarchy settings
    [Documentation]         Verifies the default account model settings can be updated in EDA
    ...                     Settings page and the same record type is updated in hierarchy settings
    ...                     under custom settings.
    [tags]                                      W-9159697       rbt:high        quadrant:Q3
    Select settings from navigation pane        Account Model
    Click action button on new EDA settings     Edit
    Update settings dropdown value              Default Account Model=Household Account
    Click action button on new EDA settings     Save
    ${account_processor}=                       Get Custom Settings Value       Account_Processor__c
    Should Be Equal As Strings                  ${account_processor}      ${record_type_id}