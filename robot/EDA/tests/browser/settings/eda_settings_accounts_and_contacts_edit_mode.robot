*** Settings ***
Documentation       Test all the checkboxes in the
...                 Accounts and Contacts Settings page
...                 by checking and unchecking them

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SettingsPageObject.py
Suite Setup     Run keywords
...             Open Test Browser
...             Get namespace
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***
Validate Edit Mode For Accounts and Contacts Settings and Click Checkboxes
    Go to page                      Custom      HEDA_Settings
    Current page should be          Custom      HEDA_Settings
    
    Wait for Locator            	tabs.accountsandcontacts
    Click on Element                tabs.accountsandcontacts

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

Get namespace
    [Documentation]                 Get EDA namespace and store it in a suite variable

    ${NS} =                         Get EDA namespace prefix
    Set suite variable              ${NS}