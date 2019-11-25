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
...             Capture screenshot and delete records and close browser 

*** Test Cases ***
Verify basic preferred phone functionality
    [tags]                          unstable
    Current page should be                  Home
    ...                                     Contacts

    Open EDA Settings Tab menu item
    Enable enchanced checkbox
    Clear the disable preferred phone enforcement
    Shift to default content

    Go To Object Home                       Contact
    Select contact                          ${CONTACT.FirstName}
    ...                                     ${CONTACT.LastName}
    Validate preferred phone form

Verify disable preferred phone enforcement
    [tags]                          unstable
    Current page should be                  Home
    ...                                     Contacts

    # Using 2 phone fields
    #
    # Enhanced box is checked
    #
    # Positive Scenario
    #
    # 1) Disable checkbox is not checked
    # 2) Create a contact and then populate home phone,
    #    office phone, hit save, it should thow an error
    Open EDA Settings Tab menu item
    Enable enchanced checkbox
    Clear the disable preferred phone enforcement    
    Shift to default content

    Create next contact
    Go To Object Home                       Contact
    Add home phone and work phone to contact
    ...                                     ${CONTACT2.FirstName}
    ...                                     ${CONTACT2.LastName}
    ...                                     False 

    # Negative Scenario
    #
    # 1) Disable checkbox is checked
    # 2) Create Contact → populate home phone, office phone → hit 
    #    save → Preferred Phone is populated →  It should not throw 
    #    an error
    Open EDA Settings Tab menu item
    Set the disable preferred phone enforcement
    Shift to default content

    Create third contact
    Go To Object Home                       Contact
    Add home phone and work phone to contact
    ...                                     ${CONTACT3.FirstName}
    ...                                     ${CONTACT3.LastName}
    ...                                     True 

Verify batch functionality of preferred phone
    [tags]                          unstable
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

    # Create a new contact and add some phone numbers
    # Note:  The 'Disable Preferred Phone enforcement'
    #        is NOT being enforced
    Create last contact
    Go To Object Home                       Contact
    
    # Note:  look in ContactsPageObject.py to see that the following
    #        test does indeed verify the phone numbers
    Add home phone to contact and verify    ${CONTACT4.FirstName}
    ...                                     ${CONTACT4.LastName}

    # Now we'll reconfigure the EDA Setting
    # and run another test to check 'Run Cleanup'

    Open EDA Settings Tab menu item
    Enable enchanced checkbox    
    Clear the disable preferred phone enforcement
    Run phone cleanup
    Shift to default content

    Go To Setup Home
    Wait For New Window                         Home | Salesforce
    Select window                               Home | Salesforce
    Wait Until Loading Is Complete
    Populate Placeholder                        Quick Find          Apex Jobs

    Open Apex                                   Apex Jobs
    ...                                         Cannot find Apex Jobs page
    ...                                         false

    ${wait_frame} =                             Get Eda Locator     eda_settings.wait_frame
    ${wait_loc_text} =                          Get Eda Locator     eda_settings.wait_loc_text

    Wait and refresh static page until text     Completed
    ...                                         5
    ...                                         ${wait_frame}
    ...                                         ${wait_loc_text}

    Unselect Frame

    # Verify that 'Run Cleanup' produced correct results
    # The code is found in ContactsPageObject.py
    Go To Object Home                       Contact
    Shift to default content
    Verify contact values                   ${CONTACT4.FirstName}
    ...                                     ${CONTACT4.LastName}

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

Switch to successful
    Go To Setup Home
    Wait For New Window                     Home | Salesforce
    Select window                           Home | Salesforce
    Wait Until Loading Is Complete
    Populate Placeholder                    Quick Find          Apex Jobs
    Open Apex                               Apex Jobs
    ...                                     Cannot find Apex Jobs page
    ...                                     false

    Select frame with title                 Apex Jobs ~ Salesforce - Developer Edition
    
    ${LOCATOR} =                            Get Eda Locator     eda_settings.batch_successful

    Set focus to element                    ${LOCATOR}
    Mouse Over                              ${LOCATOR}

    Wait until page contains element        ${LOCATOR}           timeout=1240     error="Apex Jobs Batch Completed element not found"
    Capture Page Screenshot
    Unselect Frame

    Go To Object Home                       Contact
    Shift to default content
    Verify contact values                   ${CONTACT4.FirstName}
    ...                                     ${CONTACT4.LastName}


