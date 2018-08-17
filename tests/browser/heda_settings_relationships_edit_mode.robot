*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Go To Heda Home
    Go To Heda Home
    Select Frame			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'Relationships')]
    Wait Until Element Is visible	//a[contains(text(),'Relationships')]
    

Validate Edit Mode For Relationships, Settings
    
    Go To Heda Home
    Select Frame                    //iframe[contains(@id, "vfFrameId")]
    Click Link          		//a[contains(text(),'Relationships')]
    Wait Until Element Is visible 	//a[contains(text(),'Relationships')]

    #Go into Edit mode 
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@data-aura-rendered-by='28:0']

    #List Setting 
    Click Element                   //div[@data-aura-rendered-by='319:0']//option[contains(text(), 'List Setting')]
    Wait Until Element Is visible   //div[@data-aura-rendered-by='319:0']//option[@value='List Setting']


    #Value Inversion
    Click Element                   //div[@data-aura-rendered-by='319:0']//option[contains(text(), 'Value Inversion')]
    Wait Until Element Is visible   //div[@data-aura-rendered-by='319:0']//option[@value='Value Inversion']

    #Enable Record Type Validation
    Select Checkbox                 //label[@class='slds-checkbox']//input[@type='checkbox']
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Save')]
    

*** Keywords ***


Get Random Contact Info
    ${first_name} =  Generate Random String
    ${last_name} =  Generate Random String
    Set Test Variable  ${first_name}  ${first_name}
    Set Test Variable  ${last_name}  ${last_name}


