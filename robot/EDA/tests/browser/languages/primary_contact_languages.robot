*** Settings ***
Documentation   Validates primary contact language records
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AccountsAndContactsSettingsPageObject.py
...             robot/EDA/resources/CoursesSettingsPageObject.py
Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Capture screenshot and delete records and close browser

*** Keywords ***

Setup Test Data
    &{language} =        API Create language        ${PRIMARY_LANGUAGE}
    Set suite variable     &{language}

*** Variables ***
${PRIMARY_LANGUAGE}       Urdu

*** Test Cases ***
Validate primary contact language record is created and updated in contact
    [Documentation]         Checks a contact language record has been created after creating a
    ...                     contact with primary language. Also verifies the primary language is
    ...                     updated in contact
    [tags]                  unstable        W-9054849       rbt:low
    Go to EDA settings tab            Accounts and Contacts
    Click action button on EDA settings page    Edit
    Update account contact record type
    ...                               Contact Language Fluency=Fluent
    Click action button on EDA settings page    Save
    &{contact}=                       API Create Contact     hed__Primary_Language__c=${language}[Id]
    Log Many                          ${contact}[Id]
    ${language_name}=                 Get Language Field Value  Contact  ${contact}[Id]  Primary_Language__c
    Should Be Equal As Strings        ${language_name}      ${PRIMARY_LANGUAGE}
    &{contact_language}=              Get Contact Language Value  Contact_Language__c  ${contact}[Id]
    Should Be Equal As Strings        Fluent        ${contact_language}[hed__Fluency__c]
    Should Be Equal As Strings        Urdu          ${contact_language}[hed__Language__r][Name]
    Should Be Equal As Strings        True          ${contact_language}[hed__Primary_Language__c]
