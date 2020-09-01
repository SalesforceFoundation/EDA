*** Settings ***
Documentation   Validates standard field values of system tab in eda settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Go to EDA settings tab      System

*** Test Cases ***
Validate Standard Field values in system settings
    [Documentation]         Verify the standard field values for the below fields in system settings
    ...                     Default Account Model, Store Errors, Send Error Notifications, Error
    ...                     Notification Recipients, Disable Error Handling, Automatic Household
    ...                     Naming checkbox, Administrative Account Name Format and Household
    ...                     Account Name Format
    [tags]                                      unstable        W-041787
    # Default Account Model
    Wait for Locator        eda_settings.default_account_model
    Wait for Locator        eda_settings.store_errors
    Wait for Locator        eda_settings.send_error_notifications
    Wait for Locator        eda_settings.error_notification_recipients
    Wait for Locator        eda_settings.disable_error_handling
    # Wait for Locator      eda_settings.automatic_household_naming
    Wait for Locator        eda_settings.adminstrative_account_name_format
    Wait for Locator        eda_settings.household_account_name_format