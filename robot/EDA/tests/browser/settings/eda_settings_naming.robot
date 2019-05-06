*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Library         robot/EDA/resources/EDA.py
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***


Open EDA Settings


    Go To Eda Settings

    Wait for Locator                            eda_settings.system_tab
    Click on Element                            eda_settings.system_tab


    # The following call to Select Checkbox In Eda Settings goes into EDIT mode, then SAVE the setting
    # So this call must NOT be called while in EDIT mode, else the Edit button will be not found.
    # This call places a checkmark in the Automatic Household Naming checkbox
    ${hh_naming_check} =   Get Eda Locator      eda_settings.hh_naming_check
    ${hh_role_checkbox} =  Get Eda Locator      eda_settings.hh_naming_role_checkbox
    Select Checkbox In Eda Settings             ${hh_naming_check}        ${hh_role_checkbox}


    #Go into Edit Mode, to set the Administrative Account Name Format
    Click Button                                Edit

    Click on Element                            eda_settings.hh_adminfnamelname

    #Save settings
    Click Button                                Save

