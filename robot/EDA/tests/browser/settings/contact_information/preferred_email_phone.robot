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
    Select settings from navigation pane        Contact Information
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Require Preferred Email=True
    ...                                         Enhanced Preferred Phone Functionality=True
    ...                                         Require Preferred Phone=True
    Click action button on new EDA settings     Save

*** Variables ***
${fluency}                  Intermediate
${preferred_phone}          Mobile Phone

*** Test Cases ***
Validate preferred email and preferred phone settings are updated in hierarchy settings
    [Documentation]         Verifies the preferred email and preferred phone settings can be
    ...                     updated in EDA Settings page and the same settings are updated in
    ...                     hierarchy settings under custom settings.
    [tags]                                      W-9294254       rbt:high    quadrant:Q3
    Select settings from navigation pane        Contact Information
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Require Preferred Email=False
    ...                                         Enhanced Preferred Phone Functionality=False
    Click action button on new EDA settings     Save
    ${pref_email}=                              Get Custom Settings Value       Disable_Preferred_Email_Enforcement__c
    ${pref_phone}=                              Get Custom Settings Value       Disable_Preferred_Phone_Enforcement__c
    ${pref_phone_sync}=                         Get Custom Settings Value       Enable_New_Preferred_Phone_Sync__c
    Should Be Equal As Strings                  ${pref_email}      True
    Should Be Equal As Strings                  ${pref_phone}      True
    Should Be Equal As Strings                  ${pref_phone_sync}      False

