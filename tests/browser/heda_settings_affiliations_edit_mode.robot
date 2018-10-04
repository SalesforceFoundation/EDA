*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

#AccessibilityTestService accessibilityService = 
#  ProviderFactory.get().get(AccessibilityTestService.class);
#
#// run accessibility checks and add them to
#// the test's list of accessibility issues
#getPageObjectContext().addAccessibilityIssues(
#  getWdUtil().getCurrentUrl(),
#  this.getName(),
#  accessibilityService.checkAccessibility(getCurrentWebDriver())
#);


Go To Heda Home
    Go To Heda Home
    Select Frame			//iframe[contains(@id, "vfFrameId")]
    Click Link				//a[contains(text(),'Affiliations')]
    Wait Until Element Is visible	//a[contains(text(),'Affiliations')]
 #   Capture Page Screenshot

Validate Edit Mode For Affiliations, Settings
    
    #Yes radio button
    Go To Heda Home
    Select Frame                    //iframe[contains(@id, "vfFrameId")]
     #Select the 'Yes' radio button
    Click Element                   //div[@data-aura-rendered-by='106:0']//input[@type='radio']

    #Capture Page Screenshot

    #Set focus to the status field
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Edit')]
    Wait Until Element Is visible   //div[@data-aura-rendered-by='123:0']//input[@type='text']

     #Enter known value into status field, then save the form
    Click Element                   //div[@data-aura-rendered-by='128:0']//input[@type='radio']
    Input text                      //div[@data-aura-rendered-by='123:0']//input[@type='text']      StatusTest1
    Textfield Value Should Be       //div[@data-aura-rendered-by='123:0']//input[@type='text']      StatusTest1


    #Save the changes
    Select Checkbox                 //label[@class='slds-checkbox']//input[@type='checkbox']
#    Capture Page Screenshot
    Click Element                   //div[@class='slds-button-group']//span[contains(text(), 'Save')]
    

*** Keywords ***




