*** Settings ***
Documentation   Validate health check for EDA
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SettingsHealthCheckPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify settings health check app is displayed
    [Documentation]         Validates 'Settings Health Check" app is displayed under app tile
    [tags]                  unstable        rbt:high        W-8864633
    Open app launcher
    Verify item exists       Settings Health Check

Verify last run date is updated upon clicking run health check Button
    [Documentation]         Validates the last run date is updated accordingly after clicking the
    ...                     run health check button.
    [tags]                  unstable        rbt:high        W-8874163
    Reload Page
    Select App Launcher Tab      Settings Health Check
    Current page should be      Home        Settings Health Check
    Click health check button       Run Health Check
    # This sleep is necessary to give some time to the page to update date
    Sleep       2
    Verify last run date
    Go to custom settings setup
    Select App Launcher Tab      Settings Health Check
    Verify last run date

Verify account model health check settings checks pass
    [Documentation]         Validates the account model health card is displayed with settings for
    ...                     Administrative, Household, Default Account Model and Unique account
    ...                     record type checks.Also verifies the status of each setting.
    [tags]                  unstable        rbt:high        W-8880346
    Click health check button       Run Health Check
    Sleep       2
    Click expand button             AccountModel




