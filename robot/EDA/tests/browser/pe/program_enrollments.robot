*** Settings ***
Documentation   Validates the program enrollment functionality in EDA settings and also by creating
...             a new program enrollment
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AffiliationsSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify EDA Settings
    [Documentation]     Validates the affiliations settings in edit mode
    [tags]                                      unstable
    Go to EDA settings tab                      Affiliations

    ${affl_check} =  Get Eda Locator           eda_settings.affiliations_check
    ${affl_role_checkbox} =  Get Eda Locator   eda_settings.affiliations_role_checkbox
    Select Checkbox In Eda Settings            ${affl_check}        ${affl_role_checkbox}

    Wait for Locator                            eda_settings.affiliation_mappings_tab
    Click on Element                            eda_settings.affiliation_mappings_tab

    Click Button                                Edit
    Click Button                                Save


Create A Contact
    [Documentation]     Creates a new contact and account and verifies the affiliation and
    ...                 program enrollment
    [tags]                                  unstable
    Set Window Size                         1024    1024
    Go To Object Home                       Contact

    ${cnb} =                                Get Eda Locator        contact.new_button
    Scroll Element Into View                ${cnb}
    Wait for Locator                        contact.new_button
    Click on Element                        contact.new_button

    ${cfn} =                                Get Eda Locator        contact.first_name
    Scroll Element Into View                ${cfn}
    Wait for Locator                        contact.first_name
    Click on Element                        contact.first_name

    ${contact_first_name} =                 Get Eda Locator        contact.first_name
    Scroll Element Into View                ${contact_first_name}
    Input Text                              ${contact_first_name}   robotTestFirstName

    ${contact_last_name} =                  Get Eda Locator        contact.last_name
    Scroll Element Into View                ${contact_last_name}
    Click Element                           ${contact_last_name}
    Input Text                              ${contact_last_name}    robotTestLastName

    Click on Element                        contact.save_button

    ${pe_new_button} =  Get Eda Locator    contact.program_enrollment_new_button
    Scroll Element Into View                ${pe_new_button}
    Click Related List Button               Program Enrollments     New

    Wait for Locator                        programenrollment_account
    Populate Field                          Program
    ...                     robotTestLastName Academic Account - this is just a robot test string

    #Create a New Account as part of this flow
    Click on Element                        new_account

    #Drop down and select Academic
    Wait for Locator                        list_of_departments
    Wait for Locator                        academic_program
    Click on Element                        academic_program

    Wait for Locator                        new_account_next_button
    Click on Element                        new_account_next_button

    Wait for Locator                        new_account_name
    Populate Field                          Account Name    Robot Academic Program Account

    Wait for Locator                        new_account_save_button
    Click on Element                        new_account_save_button

    Wait for Locator                        new_program_enrollment_save_button
    Click on Element                        new_program_enrollment_save_button
    Sleep                                   1

    #Verify that we have ONE affiliated account
    Reload Page
    ${acc} =                                Get Eda Locator    affiliated_accounts_count
    Scroll Element Into View                ${acc}
    Wait for Locator                        affiliated_accounts_count

    #Verify that we have ONE program enrollment
    ${pec} =                                Get Eda Locator    program_enrollments_count
    Scroll Element Into View                ${pec}
    Wait for Locator                        program_enrollments_count