*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SettingsPageObject.py
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Keywords ***
Test Checkbox
    [Arguments]                     ${account_label}
    Wait for Locator                account_types.account_checkbox    ${account_label}
    Click on element                account_types.account_checkbox    ${account_label}

*** Test Cases ***

Validate Edit Mode For Accounts and Contacts Settings
    [tags]                          unstable
    Go to page                      Custom      HEDA_Settings
    
    Wait for Locator            	tabs.accountsandcontacts
    Click on Element                tabs.accountsandcontacts

    Wait for Locator                account_types.edit
    Click on Element                account_types.edit

    Wait for Locator                account_types.administrative
    Click on Element                account_types.administrative

Click Checkboxes
    [Setup]  Run keywords
    ...  Go to page                 Custom     HEDA_Settings
    ...  AND  Click on element  tabs.accountsandcontacts
    ...  AND  Click on element  account_types.edit

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
