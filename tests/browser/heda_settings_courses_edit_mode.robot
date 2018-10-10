*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Go To Heda Home
    Go To Heda Home
    Select Frame			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'Courses')]
    Wait Until Element Is visible	//a[contains(text(),'Courses')]

Validate Edit Mode For Courses - Edit Mode, Settings
    
    #Yes radio button
    Go To Heda Home
    Select Frame                    //iframe[contains(@id, "vfFrameId")]
    Click Element                   //div[@data-aura-rendered-by='106:0']//input[@type='radio']

    #Former 
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@data-aura-rendered-by='123:0']//input[@type='text']

    #Enter known value into 'Former' field, then save the form
    Click Element                   //div[@data-aura-rendered-by='128:0']//input[@type='radio']
    Input text                      //div[@data-aura-rendered-by='123:0']//input[@type='text']      StatusTest1
    Textfield Value Should Be       //div[@data-aura-rendered-by='123:0']//input[@type='text']      StatusTest1

    #Enable Record Type Validation
    Select Checkbox                 //label[@class='slds-checkbox']//input[@type='checkbox']
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Save')]
    

*** Keywords ***

