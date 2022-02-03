*** Settings ***
Documentation   Validates enable course connections and default record type settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Run Keywords
...             Update settings to out of the box values        AND
...             Capture screenshot and delete records and close browser

Test Setup      Go to education cloud settings

*** Keywords ***
Setup Test Data
    ${NS} =                    Get EDA namespace prefix
    ${faculty_id} =            Get Record Type Id        ${NS}${sObject_name}     ${faculty_record_type}
    Set suite variable         ${faculty_id}
    ${student_id} =            Get Record Type Id        ${NS}${sObject_name}     ${student_record_type}
    Set suite variable         ${student_id}

Update settings to out of the box values
    Go to education cloud settings
    Select settings from navigation pane        Course Connections
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Course Connection Record Types=True
    Update settings dropdown value
    ...                                         Default Student Record Type=Student
    ...                                         Default Faculty Record Type=Faculty
    Click action button on new EDA settings     Save

*** Variables ***
${faculty_record_type}       Faculty
${student_record_type}       Student
${sObject_name}              Course_Enrollment__c

*** Test Cases ***
Validate enable course connection setting is updated in hierarchy settings
    [Documentation]         Verifies the course connection record type setting is updated in
    ...                     Education Cloud Settings page and it is also updated in the hierarchy
    ...                     settings.
    [tags]                                      W-9425609       rbt:high
    Select settings from navigation pane        Course Connections
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Course Connection Record Types=False
    Click action button on new EDA settings     Save
    ${enable_cc}=                               Get Custom Settings Value       Enable_Course_Connections__c
    Should Be Equal As Strings                  ${enable_cc}      False

Validate default student and faculty record type settings are updated in hierarchy settings
    [Documentation]         Verifies the default student and faculty record type settings are
    ...                     updated in Education Cloud Settings page and it is also updated in the
    ...                     hierarchy settings.
    [tags]                                      W-9425609       rbt:high
    Select settings from navigation pane        Course Connections
    Click action button on new EDA settings     Edit
    Update settings dropdown value
    ...                                         Default Student Record Type=Faculty
    ...                                         Default Faculty Record Type=Student
    Click action button on new EDA settings     Save
    ${faculty}=                                 Get Custom Settings Value       Faculty_RecType__c
    ${student}=                                 Get Custom Settings Value       Student_RecType__c
    Should Be Equal As Strings                  ${faculty}      ${student_id}
    Should Be Equal As Strings                  ${student}      ${faculty_id}

