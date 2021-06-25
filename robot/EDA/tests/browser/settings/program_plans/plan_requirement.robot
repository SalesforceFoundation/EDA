*** Settings ***
Documentation   Validates preferred email and phone in contact information settings
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
    Select settings from navigation pane        Program Plans
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Plan Requirement Hierarchy=True
    Click action button on new EDA settings     Save

*** Test Cases ***
Validate plan requirement setting is updated in hierarchy settings
    [Documentation]         Verifies the plan requirement hierarchy setting can be
    ...                     updated in EDA Settings page and the same setting is updated in
    ...                     hierarchy settings under custom settings.
    [tags]                                      unstable         W-9425719       rbt:high
    Select settings from navigation pane        Program Plans
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Plan Requirement Hierarchy=False
    Click action button on new EDA settings     Save
    ${prog_plan}=                               Get Custom Settings Value       Validate_Program_Plan_for_Nested_PR__c
    Should Be Equal As Strings                  ${prog_plan}      False

