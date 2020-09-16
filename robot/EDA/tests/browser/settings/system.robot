*** Settings ***
Documentation   Validate system tab in EDA Settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify standard field values
    [Documentation]         Checks for the default account model value as Administrative and checks
    ...                     store errors checkbox is checked and send error notification checkbox
    ...                     is unchecked and error notification recipient dropdown is set to
    ...                     All Sys Admins and checkboxes for disable error handling and automatic
    ...                     household naming are unchecked and administrative account name format
    ...                     is set to {!LastName} Administrative and household account name format
    ...                     dropdown is set to {!LastName} Household.
    [tags]                    unstable        W-041787      rbt:high
    Go to EDA settings tab    System
    Verify checkbox value
    ...                       Store Errors=true
    ...                       Send Error Notifications=false
    ...                       Disable Error Handling=false
    ...                       Automatically Rename Household Accounts=false
    Verify dropdown value
    ...                       Default Account Model=Administrative
    ...                       Error Notification Recipients=All Sys Admins
    ...                       Administrative Account Name Format={!LastName} Administrative Account
    ...                       Household Account Name Format={!LastName} Household

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
    Verify checkbox value
    ...                       Store Errors=false
    ...                       Send Error Notifications=true
    ...                       Disable Error Handling=true
    ...                       Automatically Rename Household Accounts=true
    Verify dropdown value
    ...                       Default Account Model=Household Account