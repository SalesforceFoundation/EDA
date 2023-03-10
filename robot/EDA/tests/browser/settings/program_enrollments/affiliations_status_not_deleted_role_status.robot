*** Settings ***
Documentation   Validate Status for Affilations Not Deleted, Role for Created Affilaitions and Status for Created Affiliationsfields in Settings
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
    Update settings dropdown value
    ...                                         Status for Affiliations Not Deleted=Former
    ...                                         Role for Created Affiliations=Student
    ...                                         Status for Created Affiliations=Current
    Click action button on new EDA settings     Save

*** Variables ***
${status_nd}               Current
${affl_role}               Prospect
${affl_status}             Former

*** Test Cases ***
Validate affiliation related to deleted program enrollments start and end date settings in program enrollments is updated in hierarchy settings
    [Documentation]         Verifies Status for Affilations Not Deleted Role for Created Affilaitions and Status for Created Affiliations settings can be updated in
    ...                     EDA Settings page and the same field is updated in hierarchy
    ...                     settings under custom settings.
    [tags]                                      W-9354256       rbt:high    quadrant:Q3

    Select settings from navigation pane        Program Enrollments
    Click action button on new EDA settings     Edit
    Update settings dropdown value
    ...                                         Status for Affiliations Not Deleted=Current
    ...                                         Role for Created Affiliations=Prospect
    ...                                         Status for Created Affiliations=Former
    Click action button on new EDA settings     Save
    ${status_not_deleted}=                      Get Custom Settings Value       Affl_ProgEnroll_Del_Status__c
    ${role}=                                    Get Custom Settings Value       Affl_ProgEnroll_Role_Map__c
    ${status}=                                  Get Custom Settings Value       Affl_ProgEnroll_Status_Map__c
    Should Be Equal As Strings                  ${status_nd}         ${status_not_deleted}
    Should Be Equal As Strings                  ${affl_role}         ${role}
    Should Be Equal As Strings                  ${affl_status}       ${status}