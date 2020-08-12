*** Settings ***
Documentation   Validates system tab in EDA settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Open EDA Settings
    [Documentation]     Validates system tab in EDA settings in Edit mode
    Go to EDA settings tab                     System

    #The following call to Select Checkbox In Eda Settings goes into EDIT mode,then SAVE the setting
    # So this call must NOT be called while in EDIT mode, else the Edit button will be not found.
    # This call places a checkmark in the Automatic Household Naming checkbox
    ${hh_naming_check} =   Get Eda Locator      eda_settings.hh_naming_check
    ${hh_role_checkbox} =  Get Eda Locator      eda_settings.hh_naming_role_checkbox
    Select Checkbox In Eda Settings             ${hh_naming_check}        ${hh_role_checkbox}


#    #Go into Edit Mode, to set the Administrative Account Name Format
#    Click Button                                Edit
#
#    Click on Element                            eda_settings.hh_adminfnamelname
#
#    #Save settings
#    Click Button                                Save

