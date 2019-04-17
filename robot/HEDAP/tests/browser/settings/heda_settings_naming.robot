*** Settings ***

Resource        robot/HEDAP/resources/HEDA.robot
Library         robot/HEDAP/resources/HEDA.py
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***


Open HEDA Settings


    Go To Heda Settings

    Wait for Locator                            heda_settings.system_tab
    Click on Element                            heda_settings.system_tab


    # The following call to Select Checkbox In Heda Settings goes into EDIT mode, then SAVE the setting
    # So this call must NOT be called while in EDIT mode, else the Edit button will be not found.
    # This call places a checkmark in the Automatic Household Naming checkbox
    ${hh_naming_check} =   Get Heda Locator     heda_settings.hh_naming_check
    ${hh_role_checkbox} =  Get Heda Locator     heda_settings.hh_naming_role_checkbox
    Select Checkbox In Heda Settings            ${hh_naming_check}        ${hh_role_checkbox}                


    #Go into Edit Mode, to set the Administrative Account Name Format
    Click Button                                Edit

    Click on Element                            heda_settings.hh_adminfnamelname

    #Save settings
    Click Button                                Save

