*** Settings ***
Documentation   Validates account model health check card displays failures
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SettingsHealthCheckPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify account model health check settings checks pass
    [Documentation]         Verifies the failure status of the Account Model test
    [tags]                  unstable        rbt:high        W-8977007
    Go to EDA settings tab          Accounts and Contacts
    Update system dropdown value
    ...                       Administrative Account Record Type=Household Account
    Click action button on EDA settings page    Save
    Go to settings health check
    Current page should be                      Home        Settings Health Check
    Run health check settings                   Account Model  AccountModel   AccountModelResults
    ...                     Administrative Account Record Type=Passed
    ...                     Default Account Model=Passed
    ...                     Household Account Record Type=Passed
    ...                     Unique Administrative and Household Account Record Type Settings.=Failed