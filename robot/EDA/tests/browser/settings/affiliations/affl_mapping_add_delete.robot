*** Settings ***
Documentation   Verifies that an Affiliation Mapping can be added and deleted
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Capture screenshot and delete records and close browser
Test Setup      Go to education cloud settings


*** Variables ***
${field_name}               Name

*** Test Cases ***
Validate Affiliation Mappings can be Deleted
    [Documentation]         Verifies an affiliation mapping can be deleted from the affiliations table in EDA Settings. Also verifies the "Tell me More" link.
    [tags]                                      unstable        W-9549025       rbt:high

    Select settings from navigation pane        Affiliations
    Click on hub link                           Affiliation Mappings      Tell Me More
    Switch window                               NEW
    ${url} =                                    Get location
    Should Start With                           ${url}      https://powerofus.force.com
    Switch window                               MAIN
    Click show actions button                   Household Account       Delete
    Click footer button                         Delete
    Reload Page
    Wait Until Loading is Complete
    ${name_val}=                                Get Affiliation Mappings   ${field_name}
    List Should Not Contain Value               ${name_val}       Household Account

Validate Affiliation Mappings can be Added
    [Documentation]         Verifies an affiliation mapping can be added from the affiliations table in EDA Settings.
    [tags]                                      unstable        W-9549025      rbt:high
    Select settings from navigation pane        Affiliations
    Click action button on new EDA settings     New
    Update settings dropdown value
    ...                                         Account Record Type=Household Account
    ...                                         Primary Affiliation Field on Contact=Primary Household
    Click footer button                         Save
    Reload Page
    Wait Until Loading is Complete
    ${name_val}=                                Get Affiliation Mappings   ${field_name}
    List Should Contain Value                   ${name_val}       HH_Account