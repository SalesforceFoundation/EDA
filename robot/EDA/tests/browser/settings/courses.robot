*** Settings ***
Documentation   Validates courses tab in EDA settings in both edit and read mode
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/CoursesSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Go to EDA settings tab      Courses


*** Test Cases ***
Validate run copy button is active in read and edit mode
    [Documentation]         Checks run copy button in courses tab in EDA settings is active in read
    ...                     and edit mode. Also validates the text "The process was queued
    ...                     successfully. An email will be sent at the completion of the job."
    ...                     appears after the button is clicked in both modes.
    [tags]                                      W-041780        rbt:high
    Click run action button                     Run Copy
    Verify text appears
    ...     The process was queued successfully. An email will be sent at the completion of the job.
    Reload Page
    Go to EDA settings tab                      Courses
    Click action button on EDA settings page    Edit
    Click run action button                     Run Copy
    Verify text appears
    ...     The process was queued successfully. An email will be sent at the completion of the job.
    Click action button on EDA settings page    Cancel