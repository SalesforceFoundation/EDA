*** Settings ***
Documentation   Validates relationships in edit mode in EDA settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/RelationshipsSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Validate Edit Mode For Relationships, Settings
    [Documentation]     Validates the relationships tab in EDA settings is available in Edit mode
    Go to EDA settings tab      Relationships

    Click Element
    ...                         //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible
    ...                         //div[@class='slds-button-group']//span[contains(text(), 'Save')]

    Select From List By Label       //select[contains(@class,'reciprocal-method')]   Value Inversion
    Select From List By Label       //select[contains(@class,'reciprocal-method')]   List Setting

    Go to relationships sub tab     Reciprocal Settings
    Click Element                   //input[contains(@class,'rec-settg-active')]/parent::label

    Go to relationships sub tab     Autocreation