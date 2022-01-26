*** Settings ***
Documentation   Validates account naming for both household and administrative accounts.
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Run keywords
...             Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Keywords ***

*** Variables ***
${admin_record_type}       Administrative
${sObject_name}            Account
${household_acct_name_format_value_es}    Cuenta del hogar {!LastName}

*** Test Cases ***
Validate household account naming format in foreign language
    [Documentation]         Verifies the household account naming format in spanish.
    [tags]                                      rbt:high        W-10259197

    Go to education cloud settings
    Select settings from navigation pane        Account Model
    Click action button on new EDA settings     Edit
    Update settings dropdown value              Default Account Model=Household Account
    Scroll to field                             Administrative Account Name Format
    Update settings dropdown value              Household Account Name Format=Other
    ${locator_account_name_format} =            Get eda Locator     eda_settings.hh_custom_name_format
    Set Focus To Element                        ${locator_account_name_format}
    Input Text  ${locator_account_name_format}  ${household_acct_name_format_value_es}
    Sleep                       1
    Click action button on new EDA settings     Save
    Update user language to spanish
    Sleep                       3
    # Create Contact
    ${contact_id} =                             API Create Contact
    ${result} =                                 SOQL Query
    ...                                         SELECT Account.Name FROM Contact Where Id = '${contact_id}'
    &{acct_name} =                              Get From List  ${result['records']}  0
    Should Contain                              ${acct_name}      ${household_acct_name_format_value_es}

    