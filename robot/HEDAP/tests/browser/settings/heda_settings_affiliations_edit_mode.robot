*** Settings ***

Resource        robot/HEDAP/resources/HEDA.robot
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
    Click Element                   //input[contains(@class,'affl-record-type-enforced')]/parent::label

    # Save the form
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Save')]

*** Keywords ***




*** Settings ***

Resource        robot/HEDAP/resources/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Validate Edit Mode For Affiliations, Settings
    [tags]  unstable
    Go To Heda Settings

    Wait for Locator                            heda_settings.affiliations_tab
    Click on Element                            heda_settings.affiliations_tab


    #Select Specify Role
    ${affl_check} =  Get Heda Locator           heda_settings.affiliations_check
    ${affl_role_checkbox} =  Get Heda Locator   heda_settings.affiliations_role_checkbox
    Select Checkbox In Heda Settings            ${affl_check}        ${affl_role_checkbox}  


    Click Button                                Edit

    #will add additional tests here in next phase

    Click Button                                Save

*** Keywords ***




