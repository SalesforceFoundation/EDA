*** Settings ***
Documentation   Validates reciprocal and prevent duplicate in relationship settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Update settings to out of the box values        AND
...             Capture screenshot and delete records and close browser

Test Setup      Go to education cloud settings

*** Keywords ***
Update settings to out of the box values
    [Documentation]         Resets the settings value to its out of the box values
    Go to education cloud settings
    Select settings from navigation pane        Relationships
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Prevent Duplicate Relationships=True
    Update settings dropdown value
    ...                                         Reciprocal Method=List Setting
    Click action button on new EDA settings     Save

*** Test Cases ***
Validate reciprocal method and prevent duplicate settings are updated in hierarchy settings
    [Documentation]         Verifies the reciprocal method and prevent duplicate relationships
    ...                     settings are updated and the same are reflected in the hierarchy
    ...                     settings.
    [tags]                                      W-9425217       rbt:high        quadrant:Q3
    Select settings from navigation pane        Relationships
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Prevent Duplicate Relationships=False
    Update settings dropdown value
    ...                                         Reciprocal Method=Value Inversion
    Click action button on new EDA settings     Save
    ${reci_method}=                             Get Custom Settings Value       Reciprocal_Method__c
    ${prevent_duplicates}=                      Get Custom Settings Value       Allow_AutoCreated_Duplicates__c
    Should Be Equal As Strings                  ${reci_method}      Value Inversion
    Should Be Equal As Strings                  ${prevent_duplicates}      True

