*** Settings ***
Documentation
...     Verify Preferred Phone functionality

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
Verify affiliations with contacts
    Current page should be                  Home
    ...                                     Contacts

    Go To Object Home                       Contact
    Select contact                          ${CONTACT.FirstName}
    ...                                     ${CONTACT.LastName}

    Wait for Locator                        eda_settings.affiliations_new
    Click on Element                        eda_settings.affiliations_new
    Wait for Locator                        eda_settings.new_account
    Click on Element                        eda_settings.new_account

    Wait for Locator                        academic_program
    Click on Element                        academic_program

    Wait for Locator                        new_account_next_button
    Click on Element                        new_account_next_button

    Wait for Locator                        new_account_name
    Populate Field                          Account Name    Robot Academic Program Account

    Wait for Locator                        new_account_save_button
    Click on Element                        new_account_save_button
    Close toast message

    Wait for Locator                        new_program_enrollment_save_button
    Click on Element                        new_program_enrollment_save_button
    Close toast message

    Wait for Locator                        eda_settings.affiliated_accounts
    Click on Element                        eda_settings.affiliated_accounts

    Wait for Locator                        eda_settings.affiliation_match

Verify affiliations with blank record types and mismatched primary affiliations

    # Comment out for now, but later Modify this such that it ensures that the checkbox for 
    # Enable Record Type Validation is cleared.
    #Open EDA Settings Tab menu item
    #
    ## Enable Record Type Validation
    #Wait for Locator                        eda_settings.edit_button
    #Click on Element                        eda_settings.edit_button
    #
    #Wait for Locator                        eda_settings.enable_record_type_validation
    #Click on Element                        eda_settings.enable_record_type_validation
    #
    #Wait for Locator                        eda_settings.save_button
    #Click on Element                        eda_settings.save_button

    # Create a new contact and populate the Primary Business Organization and Lastname
    Create next contact
    Go To Object Home                       Contact
    Select contact                          ${CONTACT2.FirstName}
    ...                                     ${CONTACT2.LastName}

    Wait for Locator                        eda_settings.administrative_account     ${CONTACT2.LastName}
    Click on Element                        eda_settings.administrative_account     ${CONTACT2.LastName}

    ${edit_mode} =                          Get eda Locator                         eda_settings.contact_edit
    Go to affiliations edit mode            ${edit_mode}

    # Select the new affiliation on this newly created contact and remove the organization



*** Keywords ***

Initialize test setup
    Select App Launcher App                 EDA
    Close all tabs

Initialize test data
    [Documentation]                         Create a contact with a randomly generated firstname and lastname via API

    &{CONTACT} =                            API Create Contact
    Set suite variable                      &{CONTACT}

    ${NAMESPACE} =                          Get EDA namespace prefix
    Set suite variable                      ${NAMESPACE}

Create next contact
    [Documentation]                         Create a new contact with a randomly generated firstname and lastname via API

    &{CONTACT2} =                           API Create Contact
    Set suite variable                      &{CONTACT2}

Create third contact
    [Documentation]                         Create a new contact with a randomly generated firstname and lastname via API

    &{CONTACT3} =                           API Create Contact
    Set suite variable                      &{CONTACT3}

Create last contact
    [Documentation]                         Create a new contact with a randomly generated firstname and lastname via API

    &{CONTACT4} =                           API Create Contact
    Set suite variable                      &{CONTACT4}

Open EDA Settings Tab menu item
    Select app launcher tab                 EDA Settings
    Select frame with title                 accessibility title

Restore eda settings
    Open EDA Settings Tab menu item
    Set the disable preferred phone enforcement
    Shift to default content


