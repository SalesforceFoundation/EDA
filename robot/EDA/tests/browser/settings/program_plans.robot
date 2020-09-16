*** Settings ***
Documentation   Validates program plans functionalities in both edit and non edit modes
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/ProgramPlansSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Run keywords
...             Go to EDA settings tab          Program Plans      AND
...             Uncheck nested plan requirements

*** Test Cases ***
Verify that field values retain when Save button is clicked
    [Documentation]         Checks the program plan for nested plan requirements is not checked.
    ...                     Then updates the checkbox from unchecked to checked and validates the
    ...                     checkbox value is retained after save
    [tags]                                      unstable        W-7961761       rbt:high
    Verify nested plan requirements checkbox    false
    Click action button on EDA settings page    Edit
    Update nested plan requirements checkbox
    Click action button on EDA settings page    Save
    Verify nested plan requirements checkbox    true