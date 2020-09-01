*** Settings ***
Documentation       Test all the checkboxes in the
...                 Accounts and Contacts Settings page
...                 by checking and unchecking them

Resource        robot/EDA/resources/EDA.robot
Library         robot/EDA/resources/EDA.py
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AccountsAndContactsSettingsPageObject.py
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***
Validate Edit Mode For Accounts and Contacts Settings and Click Checkboxes
    [Documentation]     Clicks the checkboxes in edit mode for accounts and
    ...                 contacts tab in EDA settings.
    Go to EDA settings tab          Accounts and Contacts

    Wait for Locator                account_types.edit
    Click on Element                account_types.edit

    Wait for Locator                account_types.administrative
    Click on Element                account_types.administrative

    Test Checkbox                   Academic Program
    Test Checkbox                   Administrative
    Test Checkbox                   Business Organization
    Test Checkbox                   Educational Institution
    Test Checkbox                   Household Account
    Test Checkbox                   Sports Organization
    Test Checkbox                   University Department

    Click on Element                account_types.save
    Close toast message

Unclick Checkboxes
    [Documentation]     Unselects the checkboxes in edit mode for accounts and contacts
    ...                 tab in EDA settings
    Click on Element                account_types.edit
    Wait for Locator                account_types.administrative
    Click on Element                account_types.administrative

    Test Checkbox                   Academic Program
    Test Checkbox                   Administrative
    Test Checkbox                   Business Organization
    Test Checkbox                   Educational Institution
    Test Checkbox                   Household Account
    Test Checkbox                   Sports Organization
    Test Checkbox                   University Department

    Wait for Locator                account_types.save
    Click on Element                account_types.save


*** Keywords ***
Test Checkbox
    [Documentation]                 Click on the checkbox identified by the {argument} label
    [Arguments]                     ${account_label}
    Wait for Locator                account_types.account_checkbox    ${account_label}
    Click on element                account_types.account_checkbox    ${account_label}