*** Settings ***
Documentation
...     Verify Multi Addresses Enabled functionality

Resource        cumulusci/robotframework/Salesforce.robot
Resource        robot/EDA/resources/EDA.robot
Library         robot/EDA/resources/EDA.py
Library         DateTime
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/ContactsPageObject.py

Test Setup      Initialize test setup

Suite Setup     Run keywords
...             Initialize test data
...             Open test browser

Suite Teardown  Run keywords
...             Capture screenshot and delete records and close browser 

*** Test Cases ***

Enable Household Account
    [tags]                              unstable
    Go To Eda Settings
    Wait for Locator                    tabs.accountsandcontacts
    Click on Element                    tabs.accountsandcontacts

    Wait for Locator                    account_types.edit
    Click on Element                    account_types.edit

    # Check Household Account
    Wait for Locator                    account_types.household 
    Click on Element                    account_types.household

    Click on Element                    account_types.save
    Close toast message

    # Open Custom Settings
    Shift to default content
    Go To Setup Home
    Wait For New Window                 Home | Salesforce
    Select window                       Home | Salesforce
    Wait Until Loading Is Complete

    Populate Placeholder                Quick Find          custom settings

    Open custom settings                Custom Settings
    ...                                 Cannot find Custom Settings page
    ...                                 false

    ${custom_settings_hierarchy} =      Get eda Locator     custom_settings.custom_settings_frame
    Select frame                        ${custom_settings_hierarchy}
    Wait for Locator                    custom_settings.hierarchy_settings
    Click on Element                    custom_settings.hierarchy_settings


    ${custom_settings_definition} =     Get eda Locator     custom_settings.custom_settings_definition
    Select frame                        ${custom_settings_definition}
    Wait for Locator                    custom_settings.manage
    Click on Element                    custom_settings.manage

    # Verify "No records to display." exists
    ${custom_settings_h_settings} =     Get eda Locator     custom_settings.custom_settings_h_settings
    Select frame                        ${custom_settings_h_settings}
    Wait for Locator                    custom_settings.no_records
    Click on Element                    custom_settings.no_records
    
*** Keywords ***

Initialize test setup
    Select App Launcher App             EDA
    Close all tabs


Initialize test data
    [Documentation]                         Enable Household Account and Verify Custom Setting of Hierarchy Settings

    ${NAMESPACE} =                          Get EDA namespace prefix
    Set suite variable                      ${NAMESPACE}
