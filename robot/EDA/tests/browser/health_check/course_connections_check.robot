*** Settings ***
Documentation   Validates course connections health check card
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SettingsHealthCheckPageObject.py
...             robot/EDA/resources/CourseConnectionsSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify course connections health check when course connections is disabled
    [Documentation]         Validates course connections health check card displays a warning
    ...                     message with a single setting when course connections in EDA Settings
    ...                     is disabled
    [tags]                  unstable        rbt:high        W-8976999
    Go to EDA settings tab          Course Connections
    Update enable cc to default
    Go to settings health check
    Current page should be      Home        Settings Health Check
    Run course connections health check settings to check warning message

*** Keywords ***
Run course connections health check settings to check warning message
    [Documentation]             Validates the course connections health check settings row by row
    Click health check button       Run Health Check
    ${all_checks_status} =      Return all checks status        Course Connections       All checks passed
    Log To Console              ${all_checks_status}
    Run Keyword If              '${all_checks_status}' == 'True'  Click expand button   courseconnection
    Verify status of a setting     courseconnectionsettingsResults
    ...                     Enable Course Connections=Warning
