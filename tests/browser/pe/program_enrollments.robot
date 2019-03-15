*** Settings ***

Resource        tests/HEDA.robot
Library         tests/HEDA.py
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Verify HEDA Settings
    [tags]                          unstable
    Go To Heda Settings

    Wait for Locator                        heda_settings.affiliations_tab
	Click on Element                        heda_settings.affiliations_tab

    #Go into Edit Mode - Note:  we are in Affiliations/Settings
    Click Button                            Edit

    Wait for Locator                        heda_settings.affiliations_role_checkbox

    ${affiliations_role_checkbox} =  Get Heda Locator    heda_settings.affiliations_role_checkbox
    Select checkbox                         ${affiliations_role_checkbox}        
    Checkbox Should Be Selected             ${affiliations_role_checkbox}        

    #Save settings
    Click Button                            Save
    



    Wait for Locator                        heda_settings.affiliation_mappings_tab
    Click on Element                        heda_settings.affiliation_mappings_tab

    #Go into Edit Mode
    Click Button                            Edit

    #Save settings
    Click Button                            Save


Create A Contact
    [tags]                          unstable

    Go To Object Home                       Contact

    Wait for Locator                        contact.new_button
    Click on Element                        contact.new_button

    Wait for Locator                        contact.first_name
    Click on Element                        contact.first_name

    ${contact_first_name} =                 Get Heda Locator      contact.first_name
    Input Text                              ${contact_first_name}   robotTestFirstName

    ${contact_last_name} =                  Get Heda Locator      contact.last_name
    Click Element                           ${contact_last_name}
    Input Text                              ${contact_last_name}     robotTestLastName

    Click on Element                        contact.save_button

    Click on Element                        contact.program_enrollment_new_button

    Wait for Locator                        programenrollment_account
    Populate Field                          Program    robotTestLastName Administrative Account - this is just a robot test string

    #Create a New Account as part of this flow
    Click on Element                        new_account

    #Drop down and select Academic
    Wait for Locator                        list_of_departments
    Wait for Locator                        academic_program
    
    Click on Element                        academic_program

    Wait for Locator                        new_account_next_button
    Click on Element                        new_account_next_button

    Wait for Locator                        new_account_name
    Populate Field                          Account Name    Robot Account

    Wait for Locator                        new_account_save_button
    Click on Element                        new_account_save_button

    Wait for Locator                        new_program_enrollment_save_button
    Click on Element                        new_program_enrollment_save_button

    #Verify that we have ONE affiliated account
    Reload Page
    Wait for Locator                        affiliated_accounts_count

    #Verify that we have ONE program enrollment
    Wait for Locator                        program_enrollments_count