*** Settings ***
Documentation   Validate system tab in EDA Settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify system settings can retain value on save
    [Documentation]         Updates the values of checkbox and dropdown fields in system settings to
    ...                     the passed value as arguments and verifies the same values are retained
    ...                     after saving it.
    [tags]                    unstable        W-8042700     rbt:high
    Go to EDA settings tab    System
    Update checkbox value
    ...                       Store Errors=false
    ...                       Send Error Notifications=true
    ...                       Disable Error Handling=true
    ...                       Automatically Rename Household Accounts=true
    Click action button on EDA settings page    Edit
    Update system dropdown value
    ...                       Default Account Model=Household Account
    Click action button on EDA settings page    Save
    # Below step is necessary as sometimes the dropdown field is not loading to verify its value
    Go to EDA settings tab    System
    Sleep                     25
    Verify checkbox value
    ...                       Store Errors=false
    ...                       Send Error Notifications=true
    ...                       Disable Error Handling=true
    ...                       Automatically Rename Household Accounts=true
    Verify dropdown value
    ...                       Default Account Model=Household Account

Verify refresh all administrative names and refresh all household names are active
    [Documentation]         Checks "Refresh  All Administrative Names" and "Refresh All Household
    ...                     Names" button are active in read mode.
    [tags]                                      unstable        W-8109925        rbt:high
    Go to EDA settings tab    System
    Click run action button                     Refresh All Administrative Names
    Verify admin toast message
    ...     The Administrative Account naming refresh was queued successfully. An email will be sent at the completion of the batch.
    Click run action button                     Refresh All Household Names
    Verify household toast message
    ...     The Household Account naming refresh was queued successfully. An email will be sent at the completion of the batch.
