*** Settings ***
Documentation
...     Test Affiliations Settings:
...     All checkboxes disabled/enabled and all dropdowns
...     set to --None-- or one of the available options
...     This tests the edit and save of the Affiliations
...     Settings checkboxes and dropdowns

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AffiliationsSettingsPageObject.py

Suite Setup     Open test browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Affiliations settings verify standard values
    [Documentation]     Verifies the default values of affiliations tab in EDA Settings
    [tags]                                      unstable

    Go to EDA settings tab                      Affiliations

    # Verify that we have the correct defaults
    Process default values

    Shift to default content
    Go To Object Home                           Account
    Close all tabs

Affiliations settings dropdowns at --None--
    [Documentation]     Updates the checkbox values to none in settings tab of affiliations
    [tags]                                      unstable

    Go to EDA settings tab                      Affiliations
    Go to affiliations sub tab                  Settings

    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab

    # Edit the dropdowns - go into Edit mode
    Click button on location                    Edit                    ${settings_tab}

    ${status_student_affl} =                    Get Eda Locator
    ...                                         eda_settings.status_student_affl
    Select From List By Label                   ${status_student_affl}                      --None--

    ${status_spec_affl_not_deleted_former} =    Get Eda Locator
    ...                                         eda_settings.status_spec_affl_not_deleted_former
    Select From List By Label                   ${status_spec_affl_not_deleted_former}      --None--

    ${status_current_picklist_affl} =           Get Eda Locator
    ...                                         eda_settings.status_current_picklist_affl
    Select From List By Label                   ${status_current_picklist_affl}             --None--

    #Save settings
    Click button on location                    Save                    ${settings_tab}
    Close toast message
    Go To Object Home                           Account
    Close all tabs

Affiliations settings put dropdowns at defaults
    [Documentation]     Updates the dropdown values to defaults and saves it
    [tags]                                      unstable

    Go to EDA settings tab                      Affiliations
    Go to affiliations sub tab                  Settings

    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab

    # Edit the dropdowns - go into Edit mode
    Click button on location                    Edit                    ${settings_tab}

    ${status_spec_affl_not_deleted_former} =    Get Eda Locator
    ...                                         eda_settings.status_spec_affl_not_deleted_former
    Select From List By Label                   ${status_spec_affl_not_deleted_former}      Former

    ${status_student_affl} =                    Get Eda Locator
                                                eda_settings.status_student_affl
    Select From List By Label                   ${status_student_affl}                      Student

    ${status_current_picklist_affl} =           Get Eda Locator
                                                eda_settings.status_current_picklist_affl
    Select From List By Label                   ${status_current_picklist_affl}             Current

    #Save settings
    Click button on location                    Save                    ${settings_tab}
    Close toast message
    Go To Object Home                           Account
    Close all tabs

Affiliations settings checkboxes toggle
    [Documentation]     Validates the settings behavior by enabling/disabling the checkbox values
    Go to EDA settings tab                      Affiliations
    Go to affiliations sub tab                  Settings

    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${ert_validation_checkbox} =                Get Eda Locator         eda_settings.ert_validation
    ${un_ert_validation_checkbox} =             Get Eda Locator
    ...                                         eda_settings.un_ert_validation
    ${ert_edit_validation_checkbox} =           Get Eda Locator
    ...                                         eda_settings.en_re_type_validation

    # Enable Record Type Validation
    Enable the checkbox                         Enable Record Type Validation
    ...                                         ${settings_tab}
    ...                                         ${ert_validation_checkbox}
    ...                                         ${ert_edit_validation_checkbox}

    Disable the checkbox                        Enable Record Type Validation
    ...                                         ${settings_tab}
    ...                                         ${un_ert_validation_checkbox}
    ...                                         ${ert_edit_validation_checkbox}

    # Delete Related Affiliation When Deleting Program Enrollment
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${delete_rec_affl} =                        Get Eda Locator         eda_settings.delete_rec_affl
    ${un_delete_rec_affl} =                     Get Eda Locator
    ...                                         eda_settings.un_delete_rec_affl
    ${del_rel_affl} =                           Get Eda Locator         eda_settings.del_rel_affl

    Enable the checkbox
    ...                                 Delete Related Affiliation When Deleting Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${delete_rec_affl}
    ...                                         ${del_rel_affl}

    Disable the checkbox
    ...                                 Delete Related Affiliation When Deleting Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${un_delete_rec_affl}
    ...                                         ${del_rel_affl}

    # Specify Role for Created Affiliations
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${specify_role_for_c_affl} =                Get Eda Locator
    ...                                         eda_settings.specify_role_for_c_affl
    ${un_specify_role_for_c_affl} =             Get Eda Locator
    ...                                         eda_settings.un_specify_role_for_c_affl
    ${specify_r_checkbox} =                     Get Eda Locator
    ...                                         eda_settings.specify_r_checkbox

    Enable the checkbox                         Specify Role for Created Affiliations
    ...                                         ${settings_tab}
    ...                                         ${specify_role_for_c_affl}
    ...                                         ${specify_r_checkbox}

    Disable the checkbox                        Specify Role for Created Affiliations
    ...                                         ${settings_tab}
    ...                                         ${un_specify_role_for_c_affl}
    ...                                         ${specify_r_checkbox}

    # Copy Affiliation End Date from Program Enrollment
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${copy_affl_end_date} =                     Get Eda Locator
    ...                                         eda_settings.copy_affl_end_date
    ${un_copy_affl_end_date} =                  Get Eda Locator
    ...                                         eda_settings.un_copy_affl_end_date
    ${copy_affliation_end_checkbox} =           Get Eda Locator
    ...                                         eda_settings.copy_affliation_end_checkbox

    Enable the checkbox                         Copy Affiliation End Date from Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${copy_affl_end_date}
    ...                                         ${copy_affliation_end_checkbox}

    Disable the checkbox                        Copy Affiliation End Date from Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${un_copy_affl_end_date}
    ...                                         ${copy_affliation_end_checkbox}

    # Copy Affiliation Start Date from Program Enrollment
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${copy_affl_start_date} =                   Get Eda Locator
    ...                                         eda_settings.copy_affl_start_date
    ${un_copy_affl_start_date} =                Get Eda Locator
    ...                                         eda_settings.un_copy_affl_start_date
    ${copy_affliation_start_checkbox} =         Get Eda Locator
    ...                                         eda_settings.copy_affliation_start_checkbox

    Enable the checkbox                         Copy Affiliation Start Date from Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${copy_affl_start_date}
    ...                                         ${copy_affliation_start_checkbox}

    Disable the checkbox                        Copy Affiliation Start Date from Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${un_copy_affl_start_date}
    ...                                         ${copy_affliation_start_checkbox}
    Go To Object Home                           Account
    Close all tabs