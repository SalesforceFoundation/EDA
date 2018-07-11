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

	#Edit Mode
	Click Link	link=Accounts and Contacts
	
	#Click Edit Button
	Click Element	//div[@id='j_id0:stgContainer']/div/div/div/div[2]/div/button[2]/span

	#We're now in Edit mode
	#Disable Preferred Email enforcement
	Click Element	//div[@id='tabs']/div[5]/div/div/div[2]/div/div/label/span
	
	#Contact Multi-Addresses Enabled
	Click Element	//div[@id='tabs']/div[5]/div/div/div[7]/div/div/label/span

	#Iterate thru Account Record Types
	Click Element	id=4744:0
	Click Element	label=Academic Program

        Click Element   id=4744:0
        Click Element   label=Administrative

        Click Element   id=4744:0
        Click Element   label=Business Organization

        Click Element   id=4744:0
        Click Element   label=Educational Institution

        Click Element   id=4744:0
        Click Element   label=Household Account

        Click Element   id=4744:0
        Click Element   label=Sports Organization

        Click Element   id=4744:0
        Click Element   label=University Department

	#Account record types that support multiple address management
	Click Element	//div[@id='tabs']/div[5]/div/div/div[13]/div/div/label/span
        Click Element   //div[@id='tabs']/div[5]/div/div/div[13]/div[2]/div/label/span
        Click Element   //div[@id='tabs']/div[5]/div/div/div[13]/div[3]/div/label/span
        Click Element   //div[@id='tabs']/div[5]/div/div/div[13]/div[4]/div/label/span
        Click Element   //div[@id='tabs']/div[5]/div/div/div[13]/div[5]/div/label/span
        Click Element   //div[@id='tabs']/div[5]/div/div/div[13]/div[6]/div/label/span
        Click Element   //div[@id='tabs']/div[5]/div/div/div[13]/div[7]/div/label/span

	#Run Backfill
	Click Element	xpath=(//button[@type='button'])[9]
*** Keywords ***


Get Random Contact Info
    ${first_name} =  Generate Random String
    ${last_name} =  Generate Random String
    Set Test Variable  ${first_name}  ${first_name}
    Set Test Variable  ${last_name}  ${last_name}



