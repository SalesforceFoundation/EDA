*** Settings ***
Documentation
...     Test Affiliations Settings:  
...     All checkboxes disabled/enabled and all dropdowns 
...     set to --None-- or one of the available options
...     This tests the edit and save of the Affiliations 
...     Settings checkboxes and dropdowns

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
...             Close Browser 

*** Test Cases ***

Affiliations Settings checkboxes unchecked and dropdowns at None
    [tags]                                      unstable


    Current page should be                      Home                    Contacts
    Open EDA Settings Tab menu item

    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${un_ert_validation_checkbox} =             Get Eda Locator         eda_settings.un_ert_validation
    ${ert_edit_validation_checkbox} =           Get Eda Locator         eda_settings.en_re_type_validation


    Disable the checkbox                        Enable Record Type Validation
    ...                                         ${settings_tab}
    ...                                         ${un_ert_validation_checkbox}
    ...                                         ${ert_edit_validation_checkbox}

    # Delete Related Affiliation When Deleting Program Enrollment
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${un_delete_rec_affl} =                     Get Eda Locator         eda_settings.un_delete_rec_affl
    ${del_rel_affl} =                           Get Eda Locator         eda_settings.del_rel_affl

    Disable the checkbox                        Delete Related Affiliation When Deleting Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${un_delete_rec_affl}
    ...                                         ${del_rel_affl}

    # Specify Role for Created Affiliations
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${un_specify_role_for_c_affl} =             Get Eda Locator         eda_settings.un_specify_role_for_c_affl
    ${specify_r_checkbox} =                     Get Eda Locator         eda_settings.specify_r_checkbox

    Disable the checkbox                        Specify Role for Created Affiliations
    ...                                         ${settings_tab}
    ...                                         ${un_specify_role_for_c_affl}
    ...                                         ${specify_r_checkbox}

    # Copy Affiliation End Date from Program Enrollment
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${un_copy_affl_end_date} =                  Get Eda Locator         eda_settings.un_copy_affl_end_date
    ${copy_affliation_end_checkbox} =           Get Eda Locator         eda_settings.copy_affliation_end_checkbox

    Disable the checkbox                        Copy Affiliation End Date from Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${un_copy_affl_end_date}
    ...                                         ${copy_affliation_end_checkbox}

    # Copy Affiliation Start Date from Program Enrollment
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${un_copy_affl_start_date} =                Get Eda Locator         eda_settings.un_copy_affl_start_date
    ${copy_affliation_start_checkbox} =         Get Eda Locator         eda_settings.copy_affliation_start_checkbox

    Disable the checkbox                        Copy Affiliation Start Date from Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${un_copy_affl_start_date}
    ...                                         ${copy_affliation_start_checkbox}

    # Edit the dropdowns
    Click button on location                    Edit                    ${settings_tab}

    ${status_student_affl} =                    Get Eda Locator         eda_settings.status_student_affl
    Select From List By Label                   ${status_student_affl}                      --None--

    ${status_spec_affl_not_deleted_former} =    Get Eda Locator         eda_settings.status_spec_affl_not_deleted_former
    Select From List By Label                   ${status_spec_affl_not_deleted_former}      --None--

    ${status_current_picklist_affl} =           Get Eda Locator         eda_settings.status_current_picklist_affl
    Select From List By Label                   ${status_current_picklist_affl}             --None--

    #Save settings
    Click button on location                    Save                    ${settings_tab}
    Go To Object Home                           Contact
    Close all tabs


Affiliations Settings checkboxes checked and dropdowns selected
    [tags]                                      unstable

    Current page should be                      Home
    ...                                         Contacts

    Open EDA Settings Tab menu item

    # Enable Record Type Validation
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${ert_validation_checkbox} =                Get Eda Locator         eda_settings.ert_validation
    ${ert_edit_validation_checkbox} =           Get Eda Locator         eda_settings.en_re_type_validation

    Enable the checkbox                         Enable Record Type Validation
    ...                                         ${settings_tab}
    ...                                         ${ert_validation_checkbox}
    ...                                         ${ert_edit_validation_checkbox}

    # Delete Related Affiliation When Deleting Program Enrollment
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${delete_rec_affl} =                        Get Eda Locator         eda_settings.delete_rec_affl
    ${del_rel_affl} =                           Get Eda Locator         eda_settings.del_rel_affl

    Enable the checkbox                         Delete Related Affiliation When Deleting Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${delete_rec_affl}
    ...                                         ${del_rel_affl}

    # Specify Role for Created Affiliations
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${specify_role_for_c_affl} =                Get Eda Locator         eda_settings.specify_role_for_c_affl
    ${specify_r_checkbox} =                     Get Eda Locator         eda_settings.specify_r_checkbox

    Enable the checkbox                         Specify Role for Created Affiliations
    ...                                         ${settings_tab}
    ...                                         ${specify_role_for_c_affl}
    ...                                         ${specify_r_checkbox}

    # Copy Affiliation End Date from Program Enrollment
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${copy_affl_end_date} =                     Get Eda Locator         eda_settings.copy_affl_end_date
    ${copy_affliation_end_checkbox} =           Get Eda Locator         eda_settings.copy_affliation_end_checkbox

    Enable the checkbox                         Copy Affiliation End Date from Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${copy_affl_end_date}
    ...                                         ${copy_affliation_end_checkbox}

    # Copy Affiliation Start Date from Program Enrollment
    ${settings_tab} =                           Get Eda Locator         eda_settings.settings_tab
    ${copy_affl_start_date} =                   Get Eda Locator         eda_settings.copy_affl_start_date
    ${copy_affliation_start_checkbox} =         Get Eda Locator         eda_settings.copy_affliation_start_checkbox

    Enable the checkbox                         Copy Affiliation Start Date from Program Enrollment
    ...                                         ${settings_tab}
    ...                                         ${copy_affl_start_date}
    ...                                         ${copy_affliation_start_checkbox}

    # Edit the dropdowns
    Click button on location                    Edit                    ${settings_tab}

    ${status_student_affl} =                    Get Eda Locator         eda_settings.status_student_affl
    Select From List By Label                   ${status_student_affl}                      Student

    ${status_spec_affl_not_deleted_former} =    Get Eda Locator         eda_settings.status_spec_affl_not_deleted_former
    Select From List By Label                   ${status_spec_affl_not_deleted_former}      Former

    ${status_current_picklist_affl} =           Get Eda Locator         eda_settings.status_current_picklist_affl
    Select From List By Label                   ${status_current_picklist_affl}             Current

    #Save settings
    Click button on location                    Save                    ${settings_tab}






*** Keywords ***

Initialize test setup
    Shift to default content
    Select App Launcher App                     EDA
    Close all tabs

Initialize test data
    [Documentation]                             Get the EDA namespace

    ${NAMESPACE} =                              Get EDA namespace prefix
    Set suite variable                          ${NAMESPACE}

Open EDA Settings Tab menu item
    Select app launcher tab                     EDA Settings
    Select frame with title                     accessibility title



