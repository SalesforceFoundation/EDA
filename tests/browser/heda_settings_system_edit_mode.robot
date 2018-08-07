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
    

Validate Edit Mode
    Go To Heda Home
    Select Frame	                //iframe[contains(@id, "vfFrameId")]
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@data-aura-rendered-by='123:0']//input[@type='text']

    
    
    

#    #Disable Error Handling
#    Click Link				link=//div[@id='tabs']/div[6]/div/div/div[14]/div/div/label/span
#    Wait Until Element Is visible	//div[@id='tabs']/div[6]/div/div/div[14]/div/div/label/span

#    #Automatic Household Naming
#    Click Link				link=//div[@id='tabs']/div[6]/div/div/div[17]/div/div/label/span
#    Wait Until Element Is visible       //div[@id='tabs']/div[6]/div/div/div[17]/div/div/label/span
#
#    #Administrative Account Name Format
#    Click Element			id=1806:0
#    Click Element			label={!LastName} Administrative Account
#
#
#    #Household Account Name Format
#    Click Element			id=1839:0
#    Click Element			label={!LastName} ({!{!FirstName}}) Household
#
#    Click Element                       id=1839:0
#    Click Element                       label={!{!FirstName}} {!LastName} Household 
#
#    Click Element                       id=1839:0
#    Click Element                       label={!LastName} Family
#
#    Click Element                       id=1839:0
#    Click Element                       label={!LastName} ({!{!FirstName}}) Family
#
#    Click Element                       id=1839:0
#    Click Element                       label={!{!FirstName}} {!LastName} Family
#    
#
#    Click Element                       id=1839:0
#    Click Element                       label=Other
#
#    Click Record Button    Save


#Validate Store Errors
#    Click Element	xpath=(//img[@alt='True'])[4]
#    Wait Until Element Is visible       xpath=(//img[@alt='True'])[4]


#Validate Send Error Notifications
#    Click Element	xpath=(//img[@alt='False'])[17]
#    Wait Until Element Is visible       xpath=(//img[@alt='True'])[17]


*** Keywords ***


Get Random Contact Info
    ${first_name} =  Generate Random String
    ${last_name} =  Generate Random String
    Set Test Variable  ${first_name}  ${first_name}
    Set Test Variable  ${last_name}  ${last_name}


