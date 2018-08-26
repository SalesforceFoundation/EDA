*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Go To Heda Home
    Go To Heda Home
    Select Frame			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'System')]
    Wait Until Element Is visible	//a[contains(text(),'System')]
    Capture Page Screenshot

Validate Edit Mode For HEDA Settings, SYSTEM
    
    Go To Heda Home
    Select Frame                    //iframe[contains(@id, "vfFrameId")]

    Click Link				        //a[contains(text(),'System')]
    Wait Until Element Is visible	//a[contains(text(),'System')]
    Capture Page Screenshot

    #Go into Edit mode now
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@data-aura-rendered-by='1163:0']//span[contains(text(), 'Default Account Model')]
    Capture Page Screenshot
    

*** Keywords ***


Get Random Contact Info
    ${first_name} =  Generate Random String
    ${last_name} =  Generate Random String
    Set Test Variable  ${first_name}  ${first_name}
    Set Test Variable  ${last_name}  ${last_name}


