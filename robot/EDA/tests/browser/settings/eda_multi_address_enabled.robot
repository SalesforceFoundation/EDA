*** Settings ***
Documentation
...     Verify Multi Addresses Enabled functionality

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AccountsAndContactsSettingsPageObject.py
...             robot/EDA/resources/ContactsPageObject.py

Suite Setup     Open test browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***

Enable Household Account
    [Documentation]     Validates the hierarchy settings page (custom settings) after enabling
    ...                 multi address checkbox (Household Account) under Accounts and Contacts
    ...                 tab in EDA settings
    [tags]                                      unstable
    Go to EDA settings tab                      Accounts and Contacts
    Click action button on EDA settings page    Edit

    # Check Household Account
    Wait for Locator                            account_types.household
    Click on Element                            account_types.household

    Click on Element                            account_types.save
    Close toast message

    # Open Custom Settings
    Shift to default content
    Go To Setup Home
    Wait For New Window                         Home | Salesforce
    Select window                               Home | Salesforce
    Wait Until Loading Is Complete

    Populate Placeholder                        Quick Find          custom settings

    Open custom settings                        Custom Settings
    ...                                         Cannot find Custom Settings page
    ...                                         false

    ${custom_settings_hierarchy} =              Get eda Locator
    ...                                         custom_settings.custom_settings_frame
    Select frame                        ${custom_settings_hierarchy}
    Wait for Locator                    custom_settings.hierarchy_settings
    Click on Element                    custom_settings.hierarchy_settings


    ${custom_settings_definition} =     Get eda Locator
    ...                                 custom_settings.custom_settings_definition
    Select frame                        ${custom_settings_definition}
    Wait for Locator                    custom_settings.manage
    Click on Element                    custom_settings.manage

    # Verify "No records to display." exists
    ${custom_settings_h_settings} =     Get eda Locator
    ...                                 custom_settings.custom_settings_h_settings
    Select frame                        ${custom_settings_h_settings}
    Wait for Locator                    custom_settings.no_records
    Click on Element                    custom_settings.no_records
