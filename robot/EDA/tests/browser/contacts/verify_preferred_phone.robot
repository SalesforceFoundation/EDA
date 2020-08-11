*** Settings ***
Documentation
...     Verify Preferred Phone functionality

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AccountsAndContactsSettingsPageObject.py
...             robot/EDA/resources/ContactsPageObject.py

Suite Setup     Run keywords
...             Initialize test data
...             Open test browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify basic preferred phone functionality
    [Documentation]     Validates the preferred phone in contact details record after enabling
    ...                 enhanced preferred phone in accounts and contacts tab in EDA settings
    [tags]                          unstable

    Go to EDA settings tab          Accounts and Contacts
    Enable enhanced checkbox
    Clear the disable preferred phone enforcement
    Shift to default content

    Go To Page                    Listing                       Contact
    Click Link                    ${CONTACT.FirstName} ${CONTACT.LastName}
    Wait until loading is complete
    Current page should be                  Details             Contact
    Validate preferred phone form

Verify disable preferred phone enforcement
    [Documentation]     Validates both scenarios (disable preferred phone - checked and unchecked)
    ...                 by first checking/unchecking the checkbox in accounts and contacts tab in
    ...                 EDA settings then creates a new contact record to validate if the error
    ...                 message is displayed or not.
    [tags]                          unstable

    # Using 2 phone fields
    #
    # Enhanced box is checked
    #
    # Positive Scenario
    #
    # 1) Disable checkbox is not checked
    # 2) Create a contact and then populate home phone,
    #    office phone, hit save, it should thow an error
    Go to EDA settings tab          Accounts and Contacts
    Enable enhanced checkbox
    Clear the disable preferred phone enforcement
    Shift to default content

    Create next contact
    Go To Page                    Listing                       Contact
    Add home phone and work phone to contact
    ...                                     ${CONTACT2.FirstName} ${CONTACT2.LastName}
    ...                                     False

    # Negative Scenario
    #
    # 1) Disable checkbox is checked
    # 2) Create Contact → populate home phone, office phone → hit
    #    save → Preferred Phone is populated →  It should not throw
    #    an error
    Go to EDA settings tab          Accounts and Contacts
    Set the disable preferred phone enforcement
    Shift to default content

    Create third contact
    Go To Object Home                       Contact
    Add home phone and work phone to contact
    ...                                     ${CONTACT3.FirstName} ${CONTACT3.LastName}
    ...                                     True

Verify batch functionality of preferred phone
    [Documentation]     Validates the run clean up functionality in accounts and contacts tab in
    ...                 EDA settings.
    [tags]                                  unstable

    # Verify the EDA Setting 'Disable Preferred Phone enforcement'

    # The following places us inside an iFrame.  Remember to jump
    # back out when done.

    # Make sure the 'Disable Preferred Phone enforcement' checkbox
    # has a check in the checkbox
    Go to EDA settings tab                      Accounts and Contacts
    Enable enhanced checkbox
    Set the disable preferred phone enforcement
    Disable enhanced checkbox
    Shift to default content

    # Create a new contact and add some phone numbers
    # Note:  The 'Disable Preferred Phone enforcement'
    #        is NOT being enforced
    Create last contact
    Go to object home                           Contact

    # Note:  look in ContactsPageObject.py to see that the following
    #        test does indeed verify the phone numbers
    Add home phone to contact and verify    ${CONTACT4.FirstName} ${CONTACT4.LastName}

    # Now we'll reconfigure the EDA Setting
    # and run another test to check 'Run Cleanup'

    Go to EDA settings tab                      Accounts and Contacts
    Enable enhanced checkbox
    Clear the disable preferred phone enforcement
    Run phone cleanup
    Shift to default content

    Go to page                                  Home        Setup
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

Create third contact
    [Documentation]     Create a new contact with a randomly generated firstname and lastname
    ...                 via API

    &{CONTACT3} =                           API Create Contact
    Set suite variable                      &{CONTACT3}

Create last contact
    [Documentation]     Create a new contact with a randomly generated firstname and lastname
    ...                 via API

    &{CONTACT4} =                           API Create Contact
    Set suite variable                      &{CONTACT4}

Restore eda settings
    [Documentation]     Updates the disable preferred phone enforcement checkbox if it is
    ...                 not checked
    Go to EDA settings tab                  Accounts and Contacts
    Set the disable preferred phone enforcement
    Shift to default content