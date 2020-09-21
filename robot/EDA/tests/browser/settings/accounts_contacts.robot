*** Settings ***
Documentation   Validates accounts and contacts tab in EDA settings in both edit and read mode
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AccountsAndContactsSettingsPageObject.py
...             robot/EDA/resources/CoursesSettingsPageObject.py
Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Go to EDA settings tab      Accounts and Contacts


*** Test Cases ***
Validate run cleanup button is active in read and edit mode
    [Documentation]         Checks run cleanup button in accounts and contacts tab in EDA settings
    ...                     is active in read mode and inactive in edit mode. Also validates the
    ...                     text "The Cleanup was queued successfully. An email will be sent when
    ...                     the batch is completed." appears after the button is clicked.
    [tags]                                      unstable        W-8016783       rbt:high
    Click action button on EDA settings page    Edit
    Verify action button status                 Run Cleanup=disabled
    Click action button on EDA settings page    Cancel
    Click run action button                     Run Cleanup
    Verify text appears
    ...     The Cleanup was queued successfully. An email will be sent when the batch is completed.