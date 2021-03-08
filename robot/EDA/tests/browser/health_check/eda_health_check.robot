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
    Log To Console          ${PREV TEST STATUS}
    Run Keyword If  '${PREV TEST STATUS}' == 'PASS'
    ...     Run Keywords
    ...     Reload Page     AND
    ...     Select App Launcher Tab      Settings Health Check      AND
    ...     Current page should be      Home        Settings Health Check       AND
    ...     Click health check button       Run Health Check        AND
    ...     Verify last run date        AND
    ...     Go to custom settings setup     AND
    ...     Select App Launcher Tab      Settings Health Check      AND
    ...     Verify last run date
    ...     ELSE    Fail

Verify account model health check settings checks pass
    [Documentation]         Validates the account model health card is displayed with settings for
    ...                     Administrative, Household, Default Account Model and Unique account
    ...                     record type checks.Also verifies the status of each setting.
    [tags]                  unstable        rbt:high        W-8880346
    Log To Console          ${PREV TEST STATUS}
    Run Keyword If  '${PREV TEST STATUS}' == 'PASS'  Run account model health check settings
    ...     ELSE    Fail


*** Keywords ***
Run account model health check settings
    [Documentation]             Validates the account model health check settings row by row
    Click health check button       Run Health Check
    ${all_checks_status} =      Return all checks status        Account Model       All checks passed
    Log To Console              ${all_checks_status}
    Run Keyword If  '${all_checks_status}' == 'True'  Click expand button   AccountModel
    Verify status of account model settings     AccountModelResults
    ...         Administrative Account Record Type=Passed
    ...         Default Account Model=Passed
    ...         Household Account Record Type=Passed
    ...         Unique Administrative and Household Account Record Type Settings.=Passed