*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Validate Edit Mode For EDA Settings, SYSTEM
    Go To Eda Settings

    # Visit System tab
    Click Link				        //a[contains(text(),'System')]
    Wait Until Element Is visible	//a[contains(text(),'System')]

    #Go into Edit mode now
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@class='slds-button-group']//span[contains(text(), 'Save')] 

    # Error Notifications
    Select From List By Label       //select[contains(@class,'default-account-model-record-type-input-select')]   Academic Program
    Click Element                   //input[contains(@class,'send-errors')]/parent::label

    # Error Notification Recipient
    Select From List By Label       //select[@name='error_to_type']   User


*** Keywords ***


