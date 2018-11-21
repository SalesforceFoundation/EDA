*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***


Validate Edit Mode For Courses - Edit Mode, Settings
    Go To Heda Settings
    Wait Until Element Is visible	//a[contains(text(),'Courses')]
    Click Link				//a[contains(text(),'Courses')]
    
    #Former 
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@class='slds-button-group']//span[contains(text(), 'Save')]
    

*** Keywords ***

