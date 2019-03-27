*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Test HEDA System Settings
    Go To Heda Settings
    Wait Until Element Is visible	//a[contains(text(),'System')]
    Click Link				//a[contains(text(),'System')]

    # Default Account Model
    Element Should be Visible   //span[contains(@class,'default-account-model-record-type-output-text')]

*** Keywords ***
