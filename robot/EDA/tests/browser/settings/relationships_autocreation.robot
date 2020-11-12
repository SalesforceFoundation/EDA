*** Settings ***
Documentation   Validate relationships autocreation sub tab in EDA Settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/RelationshipsSettingsPageObject.py
Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Delete inserted data        AND
...             Capture screenshot and delete records and close browser

Test Setup      Run keywords
...             Go to EDA settings tab          Relationships      AND
...             Go to relationships sub tab     Autocreation

*** Keywords ***
Delete inserted data
    [Documentation]             Validates autocreation settings can be deleted.This test is added to
    ...                         clean the data so this suite runs clean on every run.
    Go to EDA settings tab          Relationships
    Go to relationships sub tab     Autocreation
    Click action button on EDA settings page    Edit
    Click delete setting icon       Object=Test
    Handle alert
    Sleep       1
    Verify setting deleted          True        Object=Test
    Click action button on EDA settings page    Save
    Scroll web page
    Verify setting removed          Object=Test

*** Test Cases ***
Verify autocreation relationship settings can be added in both read and edit mode
    [Documentation]         Validates autocreation settings can be added in read and edit mode. Also
    ...                     checks if those values are retained after save.
    [tags]                  unstable        W-8380706     rbt:high
    Enter new autocreate setting
    ...         Object API Name=Campaign Member
    ...         Field Label=Referee__c
    ...         Relationship Type=Referrer
    Enter campaign type
    ...         Campaign Types=Referral Program
    Click add new setting button        New Auto-Create Setting      Add Setting
    Scroll web page
    Verify new autocreation setting
    ...         Object=Campaign Member
    ...         Field=Referee__c
    ...         Type=Referrer
    ...         Campaign=Referral Program
    Click action button on EDA settings page    Edit
    Enter new autocreate setting
    ...         Object API Name=Test
    ...         Field Label=Test
    ...         Relationship Type=Test
    Enter campaign type
    ...         Campaign Types=Referral Program
    ...         Campaign Types=Test
    Click add new setting button        New Auto-Create Setting      Add Setting
    Scroll web page
    Verify autocreation setting edit mode
    ...         Object=Test
    ...         Field=Test
    ...         Type=Test
    ...         Campaign=Test
    Click action button on EDA settings page    Cancel

Verify autocreation relationship settings can be deleted
    [Documentation]         Validates autocreation settings can be deleted.
    [tags]                  unstable        W-8380720     rbt:high
    Click action button on EDA settings page    Edit
    Click delete setting icon       Object=Campaign Member
    Handle alert
    Sleep       1
    Verify setting deleted          True        Object=Campaign Member
    Click action button on EDA settings page    Save
    Scroll web page
    Verify setting removed          Object=Campaign Member