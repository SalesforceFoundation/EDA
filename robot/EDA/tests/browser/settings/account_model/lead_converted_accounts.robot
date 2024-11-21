*** Settings ***
Documentation   Validates automatically rename lead converted settings in account model
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Go to education cloud settings

*** Keywords ***

Setup Test Data
    ${admin_id} =              Get Record Type Id        ${sObject_name}     ${admin_record_type}
    Set suite variable         ${admin_id}
    ${hh_id} =                 Get Record Type Id        ${sObject_name}     ${hh_record_type}
    Set suite variable         ${hh_id}
    ${business_id} =           Get Record Type Id        ${sObject_name}     ${buiness_record_type}
    Set suite variable         ${business_id}

*** Variables ***
${admin_record_type}       Administrative
${hh_record_type}          Household Account
${buiness_record_type}     Business Organization
${sObject_name}            Account

*** Test Cases ***
Validate automatically rename lead converted accounts setting is updated in hierarchy settings
    [Documentation]         Verifies the lead converted accounts setting can be updated in
    ...                     EDA Settings page and the same record type is updated in hierarchy
    ...                     settings under custom settings.
    [tags]                                      W-9549044       rbt:high        quadrant:Q3
    Select settings from navigation pane        Account Model
    Click action button on new EDA settings     Edit
    Select and move from list                   Automatically Rename Lead-Converted Accounts       Business Organization
    Click action button on new EDA settings     Save
    ${lead_converted}=                          Get Custom Settings Value       Lead_Converted_Account_RTypes__c
    Should Contain                              ${lead_converted}      ${hh_id}
    Should Contain                              ${lead_converted}      ${admin_id}
    Should Contain                              ${lead_converted}      ${business_id}