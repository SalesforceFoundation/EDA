*** Settings ***
Documentation   Validates account model health check card
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SettingsHealthCheckPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify account model health check settings checks pass
    [Documentation]         Validates the account model health card is displayed with settings for
    ...                     Administrative, Household, Default Account Model and Unique account
    ...                     record type checks.Also verifies the status of each setting.
    [tags]                  unstable        rbt:high        W-8880346
    Go to settings health check
    Current page should be                      Home        Settings Health Check
    Run health check settings                   Account Model  AccountModel   AccountModelResults
    ...                     Administrative Account Record Type=Passed
    ...                     Default Account Model=Passed
    ...                     Household Account Record Type=Passed
    ...                     Unique Administrative and Household Account Record Type Settings.=Passed