*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Test EDA System Settings
    Go To Eda Settings
    Wait For Locator                    eda_settings.system_tab
    Click On Element                    eda_settings.system_tab


    # Default Account Model
    Wait for Locator                    eda_settings.default_account_model
    Wait for Locator                    eda_settings.store_errors
    Wait for Locator                    eda_settings.send_error_notifications
    Wait for Locator                    eda_settings.error_notification_recipients
    Wait for Locator                    eda_settings.disable_error_handling
    Wait for Locator                    eda_settings.automatic_household_naming
    Wait for Locator                    eda_settings.adminstrative_account_name_format
    Wait for Locator                    eda_settings.household_account_name_format
