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
    [tags]                                      unstable        W-9549025       rbt:high

    Select settings from navigation pane        Program Enrollments
    Click action button on new EDA settings     New
    Update settings dropdown value
    ...                                         Account Record Type=Business Organization
    ...                                         Auto-Enrollment Status=Current
    ...                                         Auto-Enrollment Role=Student
    Click footer button                         Save
    ${role}=                                    Get Affiliation Mappings Value       Auto_Program_Enrollment_Role__c     Business_Organization
    ${status}=                                  Get Affiliation Mappings Value       Auto_Program_Enrollment_Status__c     Business_Organization
    Should Be Equal As Strings                  Student      ${role}
    Should Be Equal As Strings                  Current      ${status}

Validate auto enrollment mappings can be deleted and it is updated in custom settings
    [Documentation]         Verifies an auto enrollment mapping can be added in Education cloud
    ...                     settings page and the same is updated in custom settings.
    [tags]                                      unstable        W-9549025       rbt:high

    Select settings from navigation pane        Program Enrollments
    Click show actions button                   Business Organization       Delete
    Click footer button                         Delete
    ${role}=                                    Get Affiliation Mappings Value       Auto_Program_Enrollment_Role__c     Business_Organization
    ${status}=                                  Get Affiliation Mappings Value       Auto_Program_Enrollment_Status__c     Business_Organization
    Should Be Equal As Strings                  None      ${role}
    Should Be Equal As Strings                  None      ${status}
