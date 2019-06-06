*** Settings ***


Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***
 
    
Create Contact And Verify
    ${contact_id} =  API Populate Create And Return Contact with Address    Joe      Mazzocco   5345 Calero Ave             San Jose     95023     CA     USA    
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Header Field Value              Account Name        &{contact}[LastName] Administrative Account
    Select Tab    Details 
    Page Should Contain    5345 Calero Ave  
    Go To Object Home         Contact
    Verify Record    &{contact}[FirstName] &{contact}[LastName]

Verify EDA Settings
    Reload Page
    Go To Eda Settings

    Wait for Locator                            eda_settings.affiliations_tab
    Click on Element                            eda_settings.affiliations_tab

    ${affl_check} =  Get Eda Locator            eda_settings.affiliations_check
    ${affl_role_checkbox} =  Get Eda Locator    eda_settings.affiliations_role_checkbox
    Select Checkbox In Eda Settings             ${affl_check}        ${affl_role_checkbox}
    
    Wait for Locator                            eda_settings.affiliation_mappings_tab
    Click on Element                            eda_settings.affiliation_mappings_tab

    #Go into Edit Mode
    Click Button                                Edit

    #Save settings
    Click Button                                Save


Verify Affiliations, Program Enrollments and No Duplicates
    Reload Page
    Set Window Size                         1024    1024
    Go To Object Home                       Contact

    ${cnb} =                                Get Eda Locator         contact.new_button
    Scroll Element Into View                ${cnb}
    Wait for Locator                        contact.new_button
    Click on Element                        contact.new_button

    ${cfn} =                                Get Eda Locator         contact.first_name
    Scroll Element Into View                ${cfn}
    Wait for Locator                        contact.first_name
    Click on Element                        contact.first_name

    ${contact_first_name} =                 Get Eda Locator         contact.first_name
    Scroll Element Into View                ${contact_first_name}
    Input Text                              ${contact_first_name}   robotTestFirstName

    ${contact_last_name} =                  Get Eda Locator         contact.last_name
    Scroll Element Into View                ${contact_last_name}
    Click Element                           ${contact_last_name}
    Input Text                              ${contact_last_name}    robotTestLastName

    Click on Element                        contact.save_button

    ${pe_new_button} =  Get Eda Locator     contact.program_enrollment_new_button
    Scroll Element Into View                ${pe_new_button}

    Wait for Locator                        contact.program_enrollment_new_button
    Click on Element                        contact.program_enrollment_new_button

    Wait for Locator                        programenrollment_account
    Populate Field                          Program    robotTestLastName Academic Account - this is just a robot test string

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

    #Verify that we have ONE affiliated account
    Reload Page
    ${acc} =                                Get Eda Locator     affiliated_accounts_count
    Scroll Element Into View                ${acc}
    Wait for Locator                        affiliated_accounts_count

    #Verify that we have ONE program enrollment
    ${pec} =                                Get Eda Locator     program_enrollments_count
    Scroll Element Into View                ${pec}
    Wait for Locator                        program_enrollments_count
 

Create A New Program Plan

    Reload Page
    #Check for EDA Tile
    Open App Launcher

    Wait for Locator                        program_plans.program_plan
    Click on Element                        program_plans.program_plan

    Click Object Button                     New

    Wait for Locator                        program_plans.pp_name

    Populate Field                          Program Plan Name   robotTest Program Plan Name Test Program - this is just a robot test string

    Click on Element                        program_plans.save_button


Create A Course Offering

    Reload Page
    #Check for EDA Tile
    Open App Launcher

    Wait for Locator                        course_offering.main_tab
    Click on Element                        course_offering.main_tab
    Click Object Button                     New


    Wait for Locator                        course_offering.search_courses
    Click on Element                        course_offering.search_courses

    Wait for Locator                        course_offering.new_course_button
    Click on Element                        course_offering.new_course_button

    Populate Field                          Course Name     robotTest Course Name Test1 - this is just another robot test string in place of a course name
    Populate Field                          Department      Robot Academic Program Account
    Press Keys                              //input[@title='Search Accounts']          ARROW_DOWN+RETURN
    

    Click on Element                        course_offering.final_save_button

    
    Click on Element                        term.search_terms
    Click on Element                        term.new_term_button
    Populate Field                          Term Name               Robot Automation Term 
    Click on Element                        term.account
    Press Keys                              //input[@title='Search Accounts']          ARROW_DOWN+RETURN


    Click on Element                        term.save_button
    ${id_offering} =                        Generate Random String

    Click on Element                        term.course_offering_id
    Input Text                              //span[contains(text(), 'Course Offering ID')]//../following-sibling::input         ${id_offering}
    Click on Element                        course_offering.next_save_button
