*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***
Validate Edit Mode For Course Connections, Settings
    Go To Eda Settings

    Wait for Locator                        eda_settings.course_connections_tab
    Click on Element                        eda_settings.course_connections_tab

    #Go into Edit Mode
    Click Button                            Edit

    #Verify that the checkbox can be modified.  
    Wait for Locator                        eda_settings.cc_checkbox
    Click on Element                        eda_settings.cc_checkbox

    ${student_select} =  Get Eda Locator    eda_settings.student_select
    ${faculty_select} =  Get Eda Locator    eda_settings.faculty_select

    Select From List By Label       ${student_select}   Student
    Select From List By Label       ${faculty_select}   Faculty

    #Save settings
    Click Button                                Save
