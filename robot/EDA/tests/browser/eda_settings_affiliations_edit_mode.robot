*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Validate Edit Mode For Affiliations, Settings
    [tags]  unstable
    Go To Eda Settings
    Wait Until Element Is visible	//a[contains(text(),'Affiliations')]
    Click Link				//a[contains(text(),'Affiliations')]

    #Set focus to the status field
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@class='slds-button-group']//span[contains(text(), 'Save')]

    #Save the changes
#    Select Checkbox                 //label[@class='slds-checkbox']//input[@type='checkbox']

    # Record Type Validation
    Click Element                   //input[contains(@class,'affl-record-type-enforced')]/parent::label

    # Save the form
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Save')]

*** Keywords ***




