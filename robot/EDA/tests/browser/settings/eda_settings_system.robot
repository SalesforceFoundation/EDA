*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Test EDA System Settings
    [Setup]                 Go to EDA settings tab             System

    # Default Account Model
    Wait for Locator        eda_settings.default_account_model
    Wait for Locator        eda_settings.store_errors
    Wait for Locator        eda_settings.send_error_notifications
    Wait for Locator        eda_settings.error_notification_recipients
    Wait for Locator        eda_settings.disable_error_handling
    # Wait for Locator      eda_settings.automatic_household_naming
    Wait for Locator        eda_settings.adminstrative_account_name_format
    Wait for Locator        eda_settings.household_account_name_format