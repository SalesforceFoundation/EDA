*** Settings ***
Documentation   Validates account model health check card
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SettingsHealthCheckPageObject.py
...             robot/EDA/resources/AccountsAndContactsSettingsPageObject.py
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Reset accounts and contacts settings        AND
...             Capture screenshot and delete records and close browser

*** Keywords ***
Reset accounts and contacts settings
    [Documentation]             Reverts the changes made to the account record type. This is added
    ...                         to clean the data so this suite runs clean on every run.
    Go to EDA settings tab                      Accounts and Contacts
    Click action button on EDA settings page    Edit
    Update account contact record type
    ...                       Administrative Account Record Type=Administrative
    Click action button on EDA settings page    Save

*** Test Cases ***
Verify account model health check settings checks pass
    [Documentation]         Validates the account model health card is displayed with settings for
    ...                     Administrative, Household, Default Account Model and Unique account
    ...                     record type checks. Also verifies the status of each setting.
    [tags]                  unstable        rbt:high        W-8880346
    Go to settings health check
    Current page should be                      Home        Settings Health Check
    Run health check settings                   Account Model  AccountModel   AccountModelResults
    ...                     Administrative Account Record Type=Passed
    ...                     Default Account Model=Passed
    ...                     Household Account Record Type=Passed
    ...                     Unique Administrative and Household Account Record Type Settings.=Passed

Verify account model health check settings checks fail and display correct Recommended Fix text
    [Documentation]         Verifies the failure status of the Account Model test
    [tags]                  unstable        rbt:high        W-8977007
    Go to EDA settings tab          Accounts and Contacts
    Click action button on EDA settings page    Edit
    Update account contact record type
    ...                       Administrative Account Record Type=Household Account
    Click action button on EDA settings page    Save
    Reload Page
    Go to settings health check
    Current page should be                      Home        Settings Health Check
    Run health check settings                   Account Model  AccountModel   AccountModelResults
    ...                     Administrative Account Record Type=Passed
    ...                     Default Account Model=Passed
    ...                     Household Account Record Type=Passed
    ...                     Unique Administrative and Household Account Record Type Settings.=Failed
    Verify recommended fix      AccountModelResults
    ...                     Unique Administrative and Household Account Record Type Settings.=unique