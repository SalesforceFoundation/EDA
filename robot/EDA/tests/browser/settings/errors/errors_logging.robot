*** Settings ***
Documentation   Validates errors, error handling and debug logging in errors settings
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
    ...                                         Store Errors=True
    ...                                         Error Handling=True
    ...                                         Debug Logging=False
    Click action button on new EDA settings     Save

*** Test Cases ***
Validate store errors, error handling and debug logging are updated in hierarchy settings
    [Documentation]         Verifies the preferred email and preferred phone settings can be
    ...                     updated in EDA Settings page and the same settings are updated in
    ...                     hierarchy settings under custom settings.
    [tags]                                      unstable         W-9425199       rbt:high
    Select settings from navigation pane        Errors
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Store Errors=False
    ...                                         Error Handling=False
    ...                                         Debug Logging=True
    Click action button on new EDA settings     Save
    ${store_errors}=                            Get Custom Settings Value       Store_Errors_On__c
    ${error_handling}=                          Get Custom Settings Value       Disable_Error_Handling__c
    ${enable_debug}=                            Get Custom Settings Value       Enable_Debug__c
    Should Be Equal As Strings                  ${store_errors}      False
    Should Be Equal As Strings                  ${error_handling}      True
    Should Be Equal As Strings                  ${enable_debug}      True

