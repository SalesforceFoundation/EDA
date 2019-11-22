*** Settings ***
Documentation
...     Verify Create Affiliations and functionality of
...     Enable Record Type Validation
...     When selected, if users specify an Account as a 
...     Contact's Primary Affiliation, EDA requires that 
...     the Account have a record type and that all 
...     Account Record Type values are correctly mapped 
...     to their respective Contact Primary Affl Fields 
...     in Affiliation Mappings. If validation fails, 
...     an error prevents the Affiliation from being saved.

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
    [tags]                          unstable

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
    [tags]                          unstable
    # Create a new contact and populate the Primary Business Organization and Lastname
    Create next contact
    Go To Object Home                       Contact
    Select contact                          ${CONTACT2.FirstName}
    ...                                     ${CONTACT2.LastName}

    Wait for Locator                        eda_settings.administrative_account     ${CONTACT2.LastName}
    Click on Element                        eda_settings.administrative_account     ${CONTACT2.LastName}

    ${edit_mode} =                          Get eda Locator                         eda_settings.contact_edit
    Go to affiliations edit mode            ${edit_mode}


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



