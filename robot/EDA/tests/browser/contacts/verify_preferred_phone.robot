*** Settings ***
Documentation
...     Verify Preferred Phone functionality


Resource        robot/EDA/resources/EDA.robot
Library         DateTime
Library         SeleniumLibrary
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/ContactsPageObject.py
...             robot/EDA/resources/TriggerHandlersPageObject.py
Suite Setup     Run keywords
...             Initialize test data
...             Open test browser and print package details
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify basic preferred phone functionality
    Select app launcher                     EDA
    Close all tabs
    Enable trigger handler
    Current page should be                  Home
    ...                                     Contacts
    Select tab                              Contacts
    Select contact                          ${CONTACT.FirstName}
    ...                                     ${CONTACT.LastName}
    Validate preferred phone form

Verify disable preferred phone enforcement
    Select app launcher                     EDA
    Close all tabs
    Current page should be                  Home
    ...                                     Contacts

    Open EDA Settings Tab menu item
    Enable enchanced checkbox
    Verify setting of disable preferred phone enforcement
    Shift to default content

    Close all tabs
    Current page should be                  Home            
    ...                                     Contacts
    Select tab                              Contacts
    Select contact                          ${CONTACT.FirstName}
    ...                                     ${CONTACT.LastName}

    Test home phone functionality           ${CONTACT.FirstName}
    ...                                     ${CONTACT.LastName}
    Sleep                                   1

Verify batch functionality of preferred phone
    Select app launcher                     EDA
    Close all tabs

    Current page should be                  Home           Contacts

    # Verify the EDA Setting 'Disable Preferred Phone enforcement'
    
    # The following places us inside an iFrame.  Remember to jump 
    # back out when done.

    # Make sure the 'Disable Preferred Phone enforcement' checkbox 
    # has a check in the checkbox
    Open EDA Settings Tab menu item
    Enable enchanced checkbox    
    Set the disable preferred phone enforcement
    Disable enchanced checkbox    
    Shift to default content

    # Clear the 'Active' checkbox
    Load page object                        Home            TriggerHandlers

    Deactivate trigger handler

    # Create a new contact and add some phone numbers
    # Note:  The trigger handler is NOT set to Active, 
    #        and the 'Disable Preferred Phone enforcement'
    #        is NOT being enforced
    Select app launcher                     EDA
    Current page should be                  Home           Contacts
    Create new contact
    Select tab                              Contacts
    # Note:  look in ContactsPageObject.py to see that the following
    #        test does indeed verify the phone numbers
    Add home phone to contact and verify    ${CONTACT2.FirstName}
    ...                                     ${CONTACT2.LastName}

    # Now we'll reconfigure the trigger and EDA Setting
    # and run another test to check 'Run Cleanup'

    Enable trigger handler

    Select app launcher                     EDA
    Current page should be                  Home           Contacts
    Open EDA Settings Tab menu item
    Enable enchanced checkbox    
    Clear the disable preferred phone enforcement
    Run phone cleanup
    Capture page screenshot
    Shift to default content

    # Verify that 'Run Cleanup' produced correct results
    # The code is found in ContactsPageObject.py
    Select tab                              Contacts
    Shift to default content
    Verify contact values                   ${CONTACT2.FirstName}
    ...                                     ${CONTACT2.LastName}

    # Restore Settings
    Open EDA Settings Tab menu item
    Set the disable preferred phone enforcement
    Shift to default content
    Enable trigger handler



*** Keywords ***
Initialize test data
    [Documentation]             Create a contact with a randomly generated firstname and lastname via API

    &{CONTACT} =   API Create Contact
    #Write To Console            Contact successfully created, with first name: ${CONTACT.FirstName} and last name: ${CONTACT.LastName}
    Set suite variable          &{CONTACT}

    ${NAMESPACE} =              Get EDA namespace prefix
    Set suite variable          ${NAMESPACE}

Create new contact
    [Documentation]             Create a new contact with a randomly generated firstname and lastname via API

    &{CONTACT2} =   API Create Contact
    #Write To Console            Contact successfully created, with first name: ${CONTACT2.FirstName} and last name: ${CONTACT2.LastName}
    Set suite variable          &{CONTACT2}

Deactivate trigger handler
    Get trigger handler
    Clear the check on active checkbox

Enable trigger handler
    Load page object
    ...                                     Home
    ...                                     TriggerHandlers
    Get trigger handler
    Set trigger to active                   CON_PreferredPhone_TDTM

Get trigger handler
    Click item     
    ...                                     //span[text()='Trigger Handlers']
    ...                                     Trigger Handler item not found
    ...                                     True
    Verify trigger handler                  CON_PreferredPhone_TDTM

Open EDA Settings Tab menu item
    Select app launcher tab                 EDA Settings
    Select frame with title                 accessibility title

