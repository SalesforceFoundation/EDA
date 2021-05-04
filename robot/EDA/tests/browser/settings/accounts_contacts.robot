*** Settings ***
Documentation   Validates accounts and contacts tab in EDA settings in both edit and read mode
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AccountsAndContactsSettingsPageObject.py
...             robot/EDA/resources/CoursesSettingsPageObject.py
Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Go to EDA settings tab      Accounts and Contacts


*** Test Cases ***
Validate run cleanup button is active in read and edit mode
    [Documentation]         Checks run cleanup button in accounts and contacts tab in EDA settings
    ...                     is active in read mode and inactive in edit mode. Also validates the
    ...                     text "The Cleanup was queued successfully. An email will be sent when
    ...                     the batch is completed." appears after the button is clicked.
    [tags]                                      unstable        W-8016783       rbt:high
    Click action button on EDA settings page    Edit
    Verify action button status                 Update=disabled
    Click action button on EDA settings page    Cancel
    Click run action button                     Update
    Verify text appears
    ...     The Cleanup was queued successfully. An email will be sent when the batch is completed.

Verify disable preferred phone enforcement shows and hides as expected
    [Documentation]         Checks disable preferred phone enforcement is displayed when enable
    ...                     enhanced preferred phone functionality is checked and vice versa.
    [tags]                                      unstable        W-8089752       rbt:high
    Update checkbox value
    ...                       Enhanced Preferred Phone Functionality=true
    ...                       Require Preferred Phone=false
    Verify checkbox value
    ...                       Enhanced Preferred Phone Functionality=true
    ...                       Require Preferred Phone=false
    Update enable preferred phone checkbox value
    ...                       Enhanced Preferred Phone Functionality=false
    Verify disable preferred phone enforcement displayed
    ...                       Require Preferred Phone=false
    Click action button on EDA settings page    Save
    Verify checkbox value
    ...                       Enhanced Preferred Phone Functionality=false
    Update enable preferred phone checkbox value
    ...                       Enhanced Preferred Phone Functionality=true
    Verify disable preferred phone enforcement displayed
    ...                       Require Preferred Phone=true
    Update disable preferred phone checkbox value
    ...                       Require Preferred Phone=true
    Click action button on EDA settings page    Save
    Verify checkbox value
    ...                       Enhanced Preferred Phone Functionality=true
    ...                       Require Preferred Phone=true
    Update enable preferred phone checkbox value
    ...                       Enhanced Preferred Phone Functionality=false
    Verify disable preferred phone enforcement displayed
    ...                       Require Preferred Phone=false
    Click action button on EDA settings page    Save
    Verify checkbox value
    ...                       Enhanced Preferred Phone Functionality=false
    Verify disable preferred phone enforcement displayed
    ...                       Require Preferred Phone=false

Validate all checkboxes can retain value on save in accounts and contacts settings
    [Documentation]         Validates that all checkbox fields in accounts and contacts settings
    ...                     page retains value after clicking on save button. The status of checkbox
    ...                     is true if checked and false if unchecked
    [tags]                  unstable        W-8620850       rbt:high
    Click action button on EDA settings page    Edit
    Set checkbox value
    ...                 Require Preferred Email=true
    ...                 Enhanced Preferred Phone Functionality=true
    ...                 Require Preferred Phone=true
    ...                 Allow Multiple Contact Addresses=true
    ...                 Update Address Records for Simple Changes=true
    Set multi account contact checkbox
    ...                 Account Types with Multi-Addresses Enabled=true
    ...                 Account Types without Contacts to Delete=true
    Click action button on EDA settings page    Save
    Verify checkbox value
    ...                 Require Preferred Email=true
    ...                 Enhanced Preferred Phone Functionality=true
    ...                 Require Preferred Phone=true
    ...                 Allow Multiple Contact Addresses=true
    ...                 Update Address Records for Simple Changes=true
    Verify multi account contact checkbox
    ...                 Account Types with Multi-Addresses Enabled=true
    ...                 Account Types without Contacts to Delete=true
    Click action button on EDA settings page    Edit
    Set checkbox value
    ...                 Require Preferred Email=false
    ...                 Enhanced Preferred Phone Functionality=false
    ...                 Allow Multiple Contact Addresses=false
    ...                 Update Address Records for Simple Changes=false
    Set multi account contact checkbox
    ...                 Account Types with Multi-Addresses Enabled=false
    ...                 Account Types without Contacts to Delete=false
    Click action button on EDA settings page    Save
    Verify checkbox value
    ...                 Require Preferred Email=false
    ...                 Enhanced Preferred Phone Functionality=false
    ...                 Allow Multiple Contact Addresses=false
    ...                 Update Address Records for Simple Changes=false
    Verify multi account contact checkbox
    ...                 Account Types with Multi-Addresses Enabled=false
    ...                 Account Types without Contacts to Delete=false