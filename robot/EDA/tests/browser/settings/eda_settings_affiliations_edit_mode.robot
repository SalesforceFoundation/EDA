*** Settings ***
Documentation   Validates affiliations in EDA settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AffiliationsSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Validate Edit Mode For Affiliations, Settings
    [Documentation]     Validates the edit mode for affiliations in EDA settings
    [tags]                          unstable
    Go to EDA settings tab          Affiliations

    Click Element               //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible
    ...                         //div[@class='slds-button-group']//span[contains(text(), 'Save')]

    # Record Type Validation
    Click Element               //input[contains(@class,'affl-record-type-enforced')]/parent::label

    Click Element               //div[@class='slds-button-group']//span[contains(text(), 'Save')]