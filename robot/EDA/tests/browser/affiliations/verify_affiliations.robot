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

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/ContactsPageObject.py

Suite Setup     Run keywords
...             Initialize test data
...             Open test browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify affiliations with contacts
    [Documentation]     Verifies the affiliation is created after a new academic program account is
    ...                 created from a contact
    [tags]                                  unstable
    Go To Page                              Listing                       Contact
    Click Link                              ${CONTACT.FirstName} ${CONTACT.LastName}
    Current page should be                  Details                       Contact
    Click Related List Button               Affiliated Accounts           New


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
    Select RelatedList                      Affiliated Accounts
    # Wait for Locator                        eda_settings.affiliated_accounts
    # Click on Element                        eda_settings.affiliated_accounts

    Wait for Locator                        eda_settings.affiliation_match

Verify affiliations with blank record types and mismatched primary affiliations
    [Documentation]     Creates a new contact and verifies the affiliations in edit mode
    [tags]                                  unstable
    # Create a new contact and populate the Primary Business Organization and Lastname
    Create next contact
    Go To Object Home           Contact
    Select contact              ${CONTACT2.FirstName}
    ...                         ${CONTACT2.LastName}

    Wait for Locator            eda_settings.administrative_account     ${CONTACT2.LastName}
    Click on Element            eda_settings.administrative_account     ${CONTACT2.LastName}

    ${edit_mode} =              Get eda Locator     eda_settings.contact_edit
    Go to affiliations edit mode            ${edit_mode}


*** Keywords ***
Initialize test data
    [Documentation]     Create a contact with a randomly generated firstname and lastname via API

    &{CONTACT} =                            API Create Contact
    Set suite variable                      &{CONTACT}

    ${NAMESPACE} =                          Get EDA namespace prefix
    Set suite variable                      ${NAMESPACE}

Create next contact
    [Documentation]     Create a new contact with a randomly generated firstname and lastname
    ...                 via API

    &{CONTACT2} =                           API Create Contact
    Set suite variable                      &{CONTACT2}