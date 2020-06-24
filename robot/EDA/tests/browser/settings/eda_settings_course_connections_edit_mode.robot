*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/CourseConnectionsSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Run keywords
...             Go to EDA settings tab          Course Connections      AND
...             Update enable cc to default

*** Test Cases ***
Validate Edit Mode For Course Connections, Settings
    [Documentation]         Check for the warning message when the Enable Course Connections is unchecked
    ...                     Check the warning message disappears when the Enable Course Connections is checked
    ...                     verify default values for Student and Faculty record types
    [tags]                                      unstable        W-041783

    Click edit on EDA settings page
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

#   This is old code, and will be refactored as part of the next WI (W-041784)
#    ${student_select} =  Get Eda Locator    eda_settings.student_select
#    ${faculty_select} =  Get Eda Locator    eda_settings.faculty_select
#
#    Select From List By Label       ${student_select}   Student
#    Select From List By Label       ${faculty_select}   Faculty
