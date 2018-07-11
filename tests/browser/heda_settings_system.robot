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
    

Go To Accounts and Contacts
    Go To Heda Home
    Select Frame  	      		//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'Accounts and Contacts')]
    Wait Until Element Is visible 	//a[contains(text(),'Accounts and Contacts')]

Go To Course Connections
    Go To Heda Home
    Select Frame  			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'Course Connections')]
    Wait Until Element Is visible 	//a[contains(text(),'Course Connections')]

# Need to repair this locator, so commenting out for now
#Go To Course Connections Backfill
#    Go To Heda Home
#    Select Frame			//iframe[contains(@id, "vfFrameId")]
#    Click Link                          //a[contains(text(), 'Backfill')]
#    Wait Until Element Is visible       //a[contains(text(), 'Backfill')]  

Go To Courses
    Go To Heda Home
    Select Frame        		//iframe[contains(@id, "vfFrameId")]
    Click Link          		//a[contains(text(),'Courses')]
    Wait Until Element Is visible 	//a[contains(text(),'Courses')]

Go To Relationships
    Go To Heda Home
    Select Frame         		//iframe[contains(@id, "vfFrameId")]
    Click Link          		//a[contains(text(),'Relationships')]
    Wait Until Element Is visible 	//a[contains(text(),'Relationships')]

Go To Affiliations
    Go To Heda Home
    Select Frame        		//iframe[contains(@id, "vfFrameId")]
    Click Link          		//a[contains(text(),'Affiliations')]
    Wait Until Element Is visible 	//a[contains(text(),'Affiliations')]




#Validate Edit Mode
#    Go To Heda Home
#    Select Frame	//iframe[contains(@id, "vfFrameId")]
    
#    Select Element      //class[contains(@type, "button")]
#    Click Link    	//a[contains(text),'Edit')]
#     Click Element      //button[@class='slds-button']
#    Click Element	//div[@id='j_id0:stgContainer']/div/div/div/div[2]/div/button/span
#    Sleep		5

#    Click Element	label=Chatter Group
#    Click Link          id=1752:0
#    Get Random Contact Info
#    Select Frame	id=1673:0
#    Click Element	label=User
#    Click Link		id=1752:0
#    Get Random Contact Info


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


