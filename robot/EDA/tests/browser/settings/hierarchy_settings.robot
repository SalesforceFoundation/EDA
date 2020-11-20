*** Settings ***
Documentation   Validates hierarchy settings under custom settings in set up
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SetupPageObject.py
...             robot/EDA/resources/AccountsAndContactsSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

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
    Select frame        Custom Settings ~ Salesforce - Developer Edition
    Click custom settings       Hierarchy Settings
    Select frame        Custom Setting Definition ~ Salesforce - Developer Edition
    Click custom settings action button     Manage
    Select frame        Custom Setting Hierarchy Settings ~ Salesforce - Developer Edition
    Verify setup owner section      No records to display.
    Unselect frame
    Go to custom settings setup



