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
    [tags]                  rbt:high        W-8976999
    Go to education cloud settings
    Select settings from navigation pane        Course Connections
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Course Connection Record Types=False
    Click action button on new EDA settings     Save
    Go to settings health check
    Current page should be      Home        Settings Health Check
    Run health check settings   Course Connections  courseconnection   courseconnectionsettingsResults
    ...                         Course Connection Record Types=Warning

Verify course connections health check when course connections is enabled
    [Documentation]         Validates course connections health check card displays status of all
    ...                     settings when course connections in EDA Settings is enabled
    [tags]                  rbt:high        W-9048400
    Go to education cloud settings
    Select settings from navigation pane        Course Connections
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Course Connection Record Types=True
    Click action button on new EDA settings     Save
    Go to settings health check
    Reload page
    Current page should be                      Home        Settings Health Check
    Run health check settings   Course Connections  courseconnection   courseconnectionsettingsResults
    ...           Default Student Record Type=Passed
    ...           Default Faculty Record Type=Passed
    ...           Unique Default Faculty Record Type and Default Active Student Record Type Settings=Passed