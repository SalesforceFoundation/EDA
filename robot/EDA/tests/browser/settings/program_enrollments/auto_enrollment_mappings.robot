*** Settings ***
Documentation   Validates auto enrollment mappings in program enrollment settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/EducationCloudSettingsPageObject.py
Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser
Test Setup      Go to education cloud settings

*** Test Cases ***
Validate auto enrollment mappings can be added and it is updated in custom settings
    [Documentation]         Verifies an auto enrollment mapping can be added in Education cloud
    ...                     settings page and the same is updated in custom settings.
    [tags]                                      W-10131460       rbt:high

    Select settings from navigation pane        Program Enrollments
    Click action button on new EDA settings     New
    Sleep                                       2
    Update settings dropdown value
    ...                                         Account Record Type=Sports Organization
    ...                                         Auto-Enrollment Status=Current
    ...                                         Auto-Enrollment Role=Student
    Click footer button                         Save
    Verify custom toast message displayed
    Reload Page
    ${role}=                                    Get Affiliation Mappings Value       Auto_Program_Enrollment_Role__c     Sports_Organization
    ${status}=                                  Get Affiliation Mappings Value       Auto_Program_Enrollment_Status__c     Sports_Organization
    Should Be Equal As Strings                  Student      ${role}
    Should Be Equal As Strings                  Current      ${status}

Validate previously added auto enrollment mapping account record type is not available from dropdown
    [Documentation]         Verifies a previously added account recordtype is not available from dropdown
    ...                     because there is already an auto enrollment mapping with that recordtype
    [tags]                                      W-10131460      rbt:high

    Select settings from navigation pane             Program Enrollments
    Click action button on new EDA settings          New
    Sleep                                            1
    Validate settings dropdown value does not exist  Account Record Type    Sports Organization

Validate auto enrollment mappings can be deleted and it is updated in custom settings
    [Documentation]         Verifies an auto enrollment mapping can be added in Education cloud
    ...                     settings page and the same is updated in custom settings.
    [tags]                                      W-10131460       rbt:high

    Select settings from navigation pane        Program Enrollments
    Sleep                                       1
    Click show actions button                   Sports Organization       Delete
    Click footer button                         Delete
    Verify custom toast message displayed
    Reload Page
    ${role}=                                    Get Affiliation Mappings Value       Auto_Program_Enrollment_Role__c     Sports_Organization
    ${status}=                                  Get Affiliation Mappings Value       Auto_Program_Enrollment_Status__c     Sports_Organization
    Should Be Equal As Strings                  None      ${role}
    Should Be Equal As Strings                  None      ${status}

Validate Tell me more link works
    [Documentation]         Verifies the "Tell me More" link.
    [tags]                                      W-10131460       rbt:high
    Select settings from navigation pane        Program Enrollments
    Click on hub link                           Auto-Enrollment Mappings      Tell Me More
    Switch window                               NEW
    ${url} =                                    Get location
    Should Start With                           ${url}      https://powerofus.force.com