*** Settings ***
Documentation   Validate Afflilations Related to Delete Program Enrollments, Start and End Dates fields in Settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Update settings to out of the box values        AND
...             Capture screenshot and delete records and close browser
Test Setup      Go to education cloud settings

*** Keywords ***

Update settings to out of the box values
    Go to education cloud settings
    Select settings from navigation pane        Program Enrollments
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Affiliations Related to Deleted Program Enrollments=False
    ...                                         Affiliation End Date=True
    ...                                         Affiliation Start Date=True
    Click action button on new EDA settings     Save

*** Test Cases ***
Validate affiliation related to deleted program enrollments start and end date settings in program enrollments is updated in hierarchy settings
    [Documentation]         Verifies the Program Enrollment field settings can be updated in
    ...                     EDA Settings page and the same field is updated in hierarchy
    ...                     settings under custom settings.
    [tags]                                      W-9354256       rbt:high    quadrant:Q3

    Select settings from navigation pane        Program Enrollments
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Affiliations Related to Deleted Program Enrollments=True
    ...                                         Affiliation End Date=False
    ...                                         Affiliation Start Date=False
    Click action button on new EDA settings     Save
    ${deleted_pr}=                               Get Custom Settings Value       Affl_ProgEnroll_Del__c
    ${affl_end}=                                 Get Custom Settings Value       Affl_ProgEnroll_Copy_End_Date__c
    ${affl_start}=                               Get Custom Settings Value       Affl_ProgEnroll_Copy_Start_Date__c
    Should Be Equal As Strings                  ${deleted_pr}      True
    Should Be Equal As Strings                  ${affl_end}      False
    Should Be Equal As Strings                  ${affl_start}      False