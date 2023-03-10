*** Settings ***
Documentation   Validates addresses updates in addresses settings section
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Run Keywords
...             Update settings to out of the box values        AND
...             Capture screenshot and delete records and close browser

Test Setup      Go to education cloud settings

*** Keywords ***

Setup Test Data
    ${admin_id} =              Get Record Type Id        ${sObject_name}     ${admin_record_type}
    Set suite variable         ${admin_id}
    ${business_id} =           Get Record Type Id        ${sObject_name}     ${business_record_type}
    Set suite variable         ${business_id}
    ${academic_id} =           Get Record Type Id        ${sObject_name}     ${academic_record_type}
    Set suite variable         ${academic_id}

Update settings to out of the box values
    Go to education cloud settings
    Select settings from navigation pane        Addresses
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Allow Multiple Contact Addresses=True
    ...                                         Update Address Records for Simple Changes=False
    Click action button on new EDA settings     Save

*** Variables ***
${admin_record_type}       Administrative
${business_record_type}    Business Organization
${academic_record_type}    Academic Program
${sObject_name}            Account

*** Test Cases ***
Validate multiple contact addresses and address records for simple changes settings
    [Documentation]         Verifies the allow multiple contact addresses and update address records
    ...                     for simple changes are updated in the hierarchy settings
    [tags]                                      W-9354261       rbt:high        quadrant:Q3
    Select settings from navigation pane        Addresses
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Allow Multiple Contact Addresses=False
    ...                                         Update Address Records for Simple Changes=True
    Click action button on new EDA settings     Save
    ${multiple_contact_address}=                Get Custom Settings Value       Contacts_Addresses_Enabled__c
    ${update_address_records}=                  Get Custom Settings Value       Simple_Address_Change_Treated_as_Update__c
    Should Be Equal As Strings                  ${multiple_contact_address}      False
    Should Be Equal As Strings                  ${update_address_records}      True

Validate enable multiple addresses for account setting is updated in hierarchy settings
    [Documentation]         Verifies the enable multiple addresses setting can be updated in
    ...                     EDA Settings page and the same record type is updated in hierarchy
    ...                     settings under custom settings.
    [tags]                                      W-9294273       rbt:high
    Select settings from navigation pane        Addresses
    Click action button on new EDA settings     Edit
    Select and move from list                   Enable Multiple Addresses for Account Types       Academic Program
    Click action button on new EDA settings     Save
    ${multi_address_enabled}=                   Get Custom Settings Value       Accounts_Addresses_Enabled__c
    Should Contain                              ${multi_address_enabled}      ${business_id}
    Should Contain                              ${multi_address_enabled}      ${admin_id}
    Should Contain                              ${multi_address_enabled}      ${academic_id}