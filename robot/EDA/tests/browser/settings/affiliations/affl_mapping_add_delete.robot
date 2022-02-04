*** Settings ***
Documentation   Verifies that an Affiliation Mapping can be added and deleted
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Capture screenshot and delete records and close browser
Test Setup      Go to education cloud settings


*** Variables ***
${field_name}               Account_Record_Type__c

*** Test Cases ***
Validate Affiliation Mappings can be Deleted
    [Documentation]         Verifies the an affiliation mapping can be deleted from the affiliations table in EDA Settings. 
    [tags]                                      W-10131460       rbt:high
    Select settings from navigation pane        Affiliations
    Sleep                                       1
    Click show actions button                   Sports Organization       Delete
    Click footer button                         Delete
    Verify custom toast message displayed
    Reload Page
    Wait Until Loading is Complete
    ${name_val}=                                Get Affiliation Mappings   ${field_name}
    List Should Not Contain Value               ${name_val}                Sports_Organization

Validate Affiliation Mappings can be Added
    [Documentation]         Verifies an affiliation mapping can be added from the affiliations table in EDA Settings.
    [tags]                                      W-10131460      rbt:high
    Select settings from navigation pane        Affiliations
    Click action button on new EDA settings     New
    Sleep                                       1
    Update settings dropdown value
    ...                                         Account Record Type=Sports Organization
    ...                                         Primary Affiliation Field on Contact=Primary Sports Organization
    Click footer button                         Save
    Verify custom toast message displayed
    Reload Page
    Wait Until Loading is Complete
    ${name_val}=                                Get Affiliation Mappings   ${field_name}
    List Should Contain Value                   ${name_val}                Sports_Organization

Validate Tell me more link works
    [Documentation]         Verifies the "Tell me More" link.
    [tags]                                      W-10131460       rbt:high
    Select settings from navigation pane        Affiliations
    Click on hub link                           Affiliation Mappings      Tell Me More
    Switch window                               NEW
    ${url} =                                    Get location
    Should Start With                           ${url}      https://powerofus.force.com