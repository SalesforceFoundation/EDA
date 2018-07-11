*** Settings ***
  
Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Go To Heda Home
    Go To Heda Home
    #Wait Until Element Is visible     //header[@id='oneHeader']/div[3]/one-appnav/div/one-app-nav-bar/nav/ul/li[10]/a/span  timeout=10
    Click Element       //a[contains(text(),'System')]


Validate Edit Mode
    Go To Heda Home
    Click Element    //*[@title='Edit']
    Wait Until Modal Is Open
    #Wait Until Element Is visible       //div[@id='j_id0:stgContainer']/div/div/div/div[2]/div/button/span



*** Keywords ***


Get Random Contact Info
    ${first_name} =  Generate Random String
    ${last_name} =  Generate Random String
    Set Test Variable  ${first_name}  ${first_name}
    Set Test Variable  ${last_name}  ${last_name}


