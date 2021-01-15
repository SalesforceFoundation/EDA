*** Settings ***
Documentation   Validates course connections functionalities in both edit and non edit modes
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/CourseConnectionsSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Run keywords
...             Go to EDA settings tab          Course Connections      AND
...             Update enable cc to default

*** Test Cases ***
Validate drop down values appear when checkbox is unchecked
    [Documentation]         Checks for the warning message when the Enable Course Connections is
    ...                     unchecked. Checks the dropdown field is disabled for Default Active
    ...                     Student Record Type and Default Faculty Record Type. The value of the
    ...                     dropdown field status is True when disbaled and False when enabled.
    [tags]                                      W-041782        rbt:high
    Go to EDA settings tab          Course Connections
    Click action button on EDA settings page    Edit
    Verify enable course connections warning    true
    Sleep                                       10
    Verify dropdown field status
    ...                                         Default Active Student Record Type=disabled
    ...                                         Default Faculty Record Type=disabled

Validate Edit Mode For Course Connections, Settings
    [Documentation]         Check for the warning message when the Enable Course Connections is
    ...                     unchecked. Check the warning message disappears when the Enable Course
    ...                     Connections is checked. Verify default values for Student and Faculty
    ...                     record types. Also validates the field values of Enable course
    ...                     connections, Default Active Student Record Type and Default Faculty
    ...                     Record Type are reatined upon saving which also includes the validation
    ...                     of fields in non edit mode.
    [tags]                      W-041783        W-041784        rbt:high
    Click action button on EDA settings page    Edit
    Verify enable course connections warning    true
    Set enable course connections
    Verify enable course connections warning    false
    Verify dropdown values                      Default Active Student Record Type
    ...                                         Default
    ...                                         Faculty
    ...                                         Student
    Verify dropdown values                      Default Faculty Record Type
    ...                                         Default
    ...                                         Faculty
    ...                                         Student
    Click action button on EDA settings page    Cancel
    Click action button on EDA settings page    Edit
    Set enable course connections
    Update dropdown value
    ...                                         Default Active Student Record Type=Student
    ...                                         Default Faculty Record Type=Faculty
    Click action button on EDA settings page    Save
    Go to EDA settings tab                      Course Connections
    #This is a work around as we have consistent issues with fields visible to the user
    Verify enable course connections            true
    Verify selected dropdown value
    ...                                         Default Active Student Record Type=Student
    ...                                         Default Faculty Record Type=Faculty