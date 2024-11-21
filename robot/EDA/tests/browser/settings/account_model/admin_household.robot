*** Settings ***
Documentation   Validates administrative and household record type settings in account model
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Run Keywords
...             Update settings to out of the box values        AND
...             Capture screenshot and delete records and close browser

Test Setup      Go to education cloud settings

*** Keywords ***

Setup Test Data
    ${admin_id} =              Get Record Type Id        ${sObject_name}     ${admin_record_type}
    Set suite variable         ${admin_id}
    ${hh_id} =                 Get Record Type Id        ${sObject_name}     ${hh_record_type}
    Set suite variable         ${hh_id}

Update settings to out of the box values
    Go to education cloud settings
    Select settings from navigation pane        Account Model
    Click action button on new EDA settings     Edit
    Update settings dropdown value
    ...                                         Administrative Account Record Type=Administrative
    ...                                         Household Account Record Type=Household Account
    Scroll to field                             Household Account Name Format
    Update settings dropdown value
    ...                                         Administrative Account Name Format={!LastName} Administrative Account
    ...                                         Household Account Name Format={!LastName} Household
    Click action button on new EDA settings     Save

*** Variables ***
${admin_record_type}       Household Account
${hh_record_type}          Administrative
${sObject_name}            Account
${admin_acc_name_format}   {!{!FirstName}} {!LastName} Administrative Account
${hh_acc_name_format}      {!LastName} Family

*** Test Cases ***
Validate admin and household account record type settings are updated in hierarchy settings
    [Documentation]         Verifies the admin and household record type settings can be updated in
    ...                     EDA Settings page and the same record types are updated in hierarchy
    ...                     settings under custom settings.
    [tags]                                      unstable        W-9225268       rbt:high
    Select settings from navigation pane        Account Model
    Click action button on new EDA settings     Edit
    Update settings dropdown value
    ...                                         Administrative Account Record Type=Household Account
    ...                                         Household Account Record Type=Administrative
    Click action button on new EDA settings     Save
    ${admin_acc_rt}=                            Get Custom Settings Value       Administrative_Account_Record_Type__c
    ${hh_acc_rt}=                               Get Custom Settings Value       Household_Addresses_RecType__c
    Should Be Equal As Strings                  ${admin_acc_rt}      ${admin_id}
    Should Be Equal As Strings                  ${hh_acc_rt}         ${hh_id}

Validate admin and household account naming format settings are updated in hierarchy settings
    [Documentation]         Verifies the admin and household account naming settings can be updated
    ...                     in EDA Settings page and the same are updated in hierarchy
    ...                     settings under custom settings.
    [tags]                                      unstable        W-9294235       rbt:high
    Select settings from navigation pane        Account Model
    Switch window                               MAIN
    Scroll to field                             Household Account Name Format
    Update settings dropdown value
    ...                                         Administrative Account Name Format=${admin_acc_name_format}
    ...                                         Household Account Name Format=${hh_acc_name_format}
    Click action button on new EDA settings     Save
    ${admin_naming_format}=                     Get Custom Settings Value       Admin_Account_Naming_Format__c
    ${hh_naming_format}=                        Get Custom Settings Value       Household_Account_Naming_Format__c
    Should Be Equal As Strings                  ${admin_naming_format}      ${admin_acc_name_format}
    Should Be Equal As Strings                  ${hh_naming_format}         ${hh_acc_name_format}
