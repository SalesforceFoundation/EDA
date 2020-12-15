*** Settings ***
Documentation   Validates hierarchy settings under custom settings in set up
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SetupPageObject.py
...             robot/EDA/resources/AccountsAndContactsSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Teardown   Go to custom settings setup

*** Test Cases ***
Validate hierarchy settings under custom settings
    [Documentation]     Checks set up owner under hierarchy settings to make sure 'User User' is not
    ...                 displayed.
    [tags]              unstable        W-8448341         rbt:high
    Go to EDA settings tab      Accounts and Contacts
    Click action button on EDA settings page    Edit
    Select accounts contacts checkbox
    ...         Account Types with Multi-Addresses Enabled=Household Account
    Click action button on EDA settings page    Save
    Load Page Object                     Home                          Setup
    Go to custom settings setup
    Select hierarchy settings        Custom Settings
    ...                             Hierarchy Settings
    Wait until loading is complete
    Go to hierarchy settings view       Custom Setting Definition
    ...                                 Manage
    Wait until loading is complete
    Verify setup owner section      Custom Setting Hierarchy
    ...                             No records to display.



