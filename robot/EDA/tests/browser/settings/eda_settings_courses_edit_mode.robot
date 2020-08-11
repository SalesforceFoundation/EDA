*** Settings ***
Documentation   Validate courses tab in edit mode under EDA settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/CoursesSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Validate Edit Mode For Courses - Edit Mode, Settings
    [Documentation]     Validates the edit mode for courses tab in EDA settings
    Go to EDA settings tab          Courses

    Click Button                    Edit
    Click Button                    Save