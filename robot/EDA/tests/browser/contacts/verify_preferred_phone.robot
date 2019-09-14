*** Settings ***
Documentation
...     Verify Preferred Phone functionality


Resource        robot/EDA/resources/EDA.robot
Library         DateTime
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/ContactsPageObject.py
...             robot/EDA/resources/TriggerHandlersPageObject.py
Suite Setup     Run keywords
...             Initialize test data
...             Open test browser and print package details
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify preferred phone functionality
    Select app launcher                     EDA
    Close all tabs


    # As a prerequisite, we need to verify that the following trigger handler 
    # exists, and if not then we need to bail/fail:
    Load page object                        Home            TriggerHandlers
    Select app launcher tab                 Trigger Handlers
    Verify trigger handler                  CON_PreferredPhone_TDTM
    Set trigger to active                   CON_PreferredPhone_TDTM

    # Load the Contacts objects
    Current page should be                  Home           Contacts
    Select tab                              Contacts
    Write To Console                        Click on contact: ${CONTACT.FirstName} ${CONTACT.LastName}
    Select contact                          ${CONTACT.FirstName}                   ${CONTACT.LastName}

    # Select the newly created contact and test the preferred phone functionality
    Validate preferred phone form
    

*** Keywords ***
Initialize test data
    [Documentation]             Create a contact with a randomly generated firstname and lastname via API

    ${event_date} =             Get Current Date   result_format=%Y-%m-%d       increment=1 day
    ${start_date} =             Convert Date       ${event_date} 10:00:00       date_format=%Y-%m-%d %H:%M:%S
    ${end_date} =               Convert Date       ${event_date} 10:30:00       date_format=%Y-%m-%d %H:%M:%S

    &{CONTACT} =   API Create Contact
    Write To Console            Contact successfully created, with first name: ${CONTACT.FirstName} and last name: ${CONTACT.LastName}
    Set suite variable          &{CONTACT}

    ${NAMESPACE} =              Get EDA namespace prefix
    Set suite variable          ${NAMESPACE}