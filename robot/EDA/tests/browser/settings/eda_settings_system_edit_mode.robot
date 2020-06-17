*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Validate Edit Mode For EDA Settings, SYSTEM
    Go to EDA settings tab          System

    #Go into Edit mode now
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@class='slds-button-group']//span[contains(text(), 'Save')] 

    # Error Notifications
    Select From List By Label       //select[contains(@class,'default-account-model-record-type-input-select')]   Academic Program
    Click Element                   //input[contains(@class,'send-errors')]/parent::label

    # Error Notification Recipient
    Select From List By Label       //select[@name='error_to_type']   User