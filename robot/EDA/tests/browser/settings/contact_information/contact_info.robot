*** Settings ***
Documentation   Validates contact information settings in new EDA settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Go to new eda settings

*** Variables ***
${fluency}                  Intermediate
${preferred_phone}          Mobile Phone

*** Test Cases ***
Validate contact language fluency and default phone settings are updated in hierarchy settings
    [Documentation]         Verifies the contact language fluency and default preferred phone can be
    ...                     updated in EDA Settings page and the same record types are updated in
    ...                     hierarchy settings under custom settings.
    [tags]                                      unstable        W-9225304       rbt:high
    Select settings from navigation pane        Contact Information
    Click action button on new EDA settings     Edit
    Update settings dropdown value
    ...                                         Contact Language Fluency=${fluency}
    ...                                         Default Preferred Phone=${preferred_phone}
    Click action button on new EDA settings     Save
    ${con_lang_fluency}=                        Get Custom Settings Value       Default_Contact_Language_Fluency__c
    ${pref_phone}=                              Get Custom Settings Value       Preferred_Phone_Selection__c
    Should Be Equal As Strings                  ${con_lang_fluency}      ${fluency}
    Should Be Equal As Strings                  ${pref_phone}         ${preferred_phone}