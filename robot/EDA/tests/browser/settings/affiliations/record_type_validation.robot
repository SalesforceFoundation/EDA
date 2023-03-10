*** Settings ***
Documentation   Validates record type validation field in affiliations
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Update settings to out of the box values        AND
...             Capture screenshot and delete records and close browser
Test Setup      Go to education cloud settings

***Keywords***
Update settings to out of the box values
    Go to education cloud settings
    Select settings from navigation pane        Affiliations
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Record Type Validation=True
    Click action button on new EDA settings     Save

*** Test Cases ***
Validate record type validation settings in affiliations is updated in hierarchy settings
    [Documentation]         Verifies the record type validation setting can be updated in
    ...                     EDA Settings page and the same field is updated in hierarchy
    ...                     settings under custom settings.
    [tags]                                      W-9354256       rbt:high        quadrant:Q3

    Select settings from navigation pane        Affiliations
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Record Type Validation=False
    Click action button on new EDA settings     Save
    ${type_enforced}=                               Get Custom Settings Value       Affiliation_Record_Type_Enforced__c
    Should Be Equal As Strings                  ${type_enforced}      False