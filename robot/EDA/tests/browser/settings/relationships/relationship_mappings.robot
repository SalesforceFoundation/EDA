*** Settings ***
Documentation   Validates reciprocal relationships in relationships settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/EducationCloudSettingsPageObject.py
Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Capture screenshot and delete records and close browser
Test Setup      Go to education cloud settings

*** Keywords ***

Setup Test Data
    ${values} =                Get Relationship Type Values        ${sObject_name}     ${field_name}
    Set suite variable         ${values}

*** Variables ***
${field_name}               Active__c
${sObject_name}             Relationship_Lookup__c

*** Test Cases ***
Validate relationship mappings can be added and it is updated
    [Documentation]         Verifies a relationship mapping can be added in Education cloud
    ...                     settings page and the same is updated.
    [tags]                                      unstable        W-9606659       rbt:high

    Select settings from navigation pane        Relationships
    Click action button on new EDA settings     New
    List Should Not Contain Value               ${values}       Cousin
    Update settings dropdown value
    ...                                         Name=Cousin
    ...                                         Female=Cousin
    ...                                         Male=Cousin
    ...                                         Neutral=Cousin
    Click footer button                         Save
    Reload Page
    Wait Until Loading is Complete
    ${name_val}=                                Get Relationship Type Values        ${sObject_name}     ${field_name}
    List Should Contain Value                   ${name_val}       Cousin

Validate relationship mappings can be deleted and it is updated
    [Documentation]         Verifies a relationship mapping can be deleted in Education cloud
    ...                     settings page and the same is updated.
    [tags]                                      unstable        W-9606659       rbt:high

    Select settings from navigation pane        Relationships
    Click show actions button                   Cousin       Delete
    Click footer button                         Delete
    Reload Page
    Wait Until Loading is Complete
    ${name_val}=                                Get Relationship Type Values        ${sObject_name}     ${field_name}
    List Should Not Contain Value               ${values}       Cousin