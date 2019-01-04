*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Validate Edit Mode For Affiliations, Settings
    [tags]  unstable
    Go To Heda Settings
    Wait Until Element Is visible	//a[contains(text(),'Affiliations')]
    Click Link				//a[contains(text(),'Affiliations')]

    #Set focus to the status field
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@class='slds-button-group']//span[contains(text(), 'Save')]
    Textfield Value Should Be       //div[@class='slds-tabs--scoped']//input[@type='text']      StatusTest1

    #Save the changes
    Select Checkbox                 //label[@class='slds-checkbox']//input[@type='checkbox']

    # Record Type Validation
    Click Element                   //input[contains(@class,'store-errors')]/parent::label

    # Save the form
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Save')]

*** Keywords ***




