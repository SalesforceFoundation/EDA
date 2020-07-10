*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify standard field values
    [Documentation]         Checks for the default account model value as Administrative and checks store errors
    ...                     checkbox is checked and send error notification checkbox is unchecked and error
    ...                     notification recipient dropdown is set to All Sys Admins and checkboxes for disable
    ...                     error handling and automatic household naming are unchecked and administrative 
    ...                     account name format is set to {!LastName} Administrative and household account
    ...                     name format dropdown is set to {!LastName} Household.
    [tags]                                      unstable        W-041787
    Go to EDA settings tab                      System
    Verify default checkbox value
    ...                                         Store Errors=true
    ...                                         Send Error Notifications=false
    ...                                         Disable Error Handling=false
    ...                                         Automatically Rename Household Accounts=false                                         
    Verify default dropdown value              
    ...                                         Default Account Model=Administrative
    ...                                         Error Notification Recipients=All Sys Admins
    ...                                         Administrative Account Name Format={!LastName} Administrative Account
    ...                                         Household Account Name Format={!LastName} Household
# Test EDA System Settings
#     [Setup]                 Go to EDA settings tab             System

#     # Default Account Model
#     Wait for Locator        eda_settings.default_account_model
#     Wait for Locator        eda_settings.store_errors
#     Wait for Locator        eda_settings.send_error_notifications
#     Wait for Locator        eda_settings.error_notification_recipients
#     Wait for Locator        eda_settings.disable_error_handling
#     # Wait for Locator      eda_settings.automatic_household_naming
#     Wait for Locator        eda_settings.adminstrative_account_name_format
#     Wait for Locator        eda_settings.household_account_name_format