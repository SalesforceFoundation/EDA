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
    Run Keyword If          '${PREV TEST STATUS}' == 'PASS'
    ...                     Run Keywords
    ...                     Reload Page     AND
    ...                     Select App Launcher Tab      Settings Health Check      AND
    ...                     Current page should be      Home        Settings Health Check       AND
    ...                     Click health check button       Run Health Check        AND
    ...                     Verify last run date        AND
    ...                     Go to custom settings setup     AND
    ...                     Select App Launcher Tab      Settings Health Check      AND
    ...                     Verify last run date
    ...                     ELSE    Fail