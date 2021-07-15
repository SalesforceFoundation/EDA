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
    Wait until loading is complete
    Current page should be                  Details             Contact
    Click Related List Button               Affiliated Accounts           New
    Create account from modal               Organization        Academic Program        TestAccount
    Click Modal Button                      Save
    Wait until loading is complete
    Reload Page
    Select RelatedList                      Affiliated Accounts
    Verify affiliation account              TestAccount

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