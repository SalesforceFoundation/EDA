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
    Run health check settings   Course Connections  courseconnection   courseconnectionsettingsResults
    ...                         Enable Course Connections=Warning

Verify course connections health check when course connections is enabled
    [Documentation]         Validates course connections health check card displays status of all
    ...                     settings when course connections in EDA Settings is enabled
    [tags]                  unstable        rbt:high        W-9048400
    Go to EDA settings tab                      Course Connections
    Click action button on EDA settings page    Edit
    Set enable course connections
    Click action button on EDA settings page    Save
    Go to settings health check
    Reload page
    Current page should be                      Home        Settings Health Check
    Run health check settings   Course Connections  courseconnection   courseconnectionsettingsResults
    ...           Default Active Student Record Type=Passed
    ...           Default Faculty Record Type=Passed
    ...           Unique Default Faculty Record Type and Default Active Student Record Type Settings=Passed