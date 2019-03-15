*** Settings ***

Resource        tests/HEDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

# Create A New Course

#     Click Page Button       Next
#     ${account_id} =  API Create Specific Organization Account      Test

#      &{account} =  API Create Organization Account   
#      ${course} =  API Create And Return Specific Course     ${account_id}   History



Verify HEDA Settings
    Go To Heda Settings
    Wait Until Element Is visible	        //a[contains(text(),'Affiliations')]
    Click Link				                //a[contains(text(),'Affiliations')]

    # Default Account Model
    #Element Should be Visible               //span[contains(@class,'default-account-model-record-type-output-text')]

    #Go into Edit Mode - Note:  we are in Affiliations/Settings
    Click Button                            Edit

    #Wait Until Element Is visible           //label[@class='slds-checkbox']//input[@class='copy-start-date uiInput uiInputCheckbox uiInput--default uiInput--checkbox']//following-sibling::span[@class='slds-checkbox--faux']
    Wait Until Element Is visible           (//label[@class='slds-checkbox'])//input[@class='copy-start-date uiInput uiInputCheckbox uiInput--default uiInput--checkbox']
    Select checkbox                         (//label[@class='slds-checkbox'])//input[@class='copy-start-date uiInput uiInputCheckbox uiInput--default uiInput--checkbox']
    Checkbox Should Be Selected             (//label[@class='slds-checkbox'])//input[@class='copy-start-date uiInput uiInputCheckbox uiInput--default uiInput--checkbox']

    #Save settings
    Click Button                            Save
    



    Wait Until Element Is visible           //a[contains(text(), 'Affiliation Mappings')]
    Click Element                           //a[contains(text(), 'Affiliation Mappings')]

    #Go into Edit Mode
    Click Button                            Edit

    #Save settings
    Click Button                            Save


Create A Contact


    Go To Object Home                       Contact

    Wait Until Element Is visible           //a[@title='New']//div[@title='New']
    Click Element                           //a[@title='New']//div[@title='New']

    Wait Until Element Is visible           //input[contains(@class,'firstName')]
    Click Element                           //input[contains(@class,'firstName')]

    Input Text                              //input[contains(@class,'firstName')]    firstName

    Click Element                           //input[contains(@class,'lastName')]
    Input Text                              //input[contains(@class,'lastName')]     lastName

    Click Element                           //button[@title='Save']

    Click Element                           (//following::div[@class='slds-no-flex']//div[@class='actionsContainer']//div[@title='New'])[4]

    Wait Until Element Is visible           //div[@class='autocompleteWrapper slds-grow']//input[@class=' default input uiInput uiInputTextForAutocomplete uiInput--default uiInput--input uiInput uiAutocomplete uiInput--default uiInput--lookup']
    Populate Field                          Program    lastName Administrative Account

    #Create a New Account as part of this flow
    Click Element                           //span[@title='New Account']

    #Drop down and select Academic
    Wait Until Element Is visible           //button[@class='slds-button slds-button--neutral uiButton--default uiButton--brand uiButton']//span[@class=' label bBody']
    Sleep                                   5
    Press Keys                              none    ARROW_DOWN

    Wait Until Element Is visible           //button[@class='slds-button slds-button--neutral uiButton--default uiButton--brand uiButton']//span[@class=' label bBody']
    Click Element                           //button[@class='slds-button slds-button--neutral uiButton--default uiButton--brand uiButton']//span[@class=' label bBody']

    Wait Until Element Is visible           //input[@class='input uiInput uiInputText uiInput--default uiInput--input']
    Populate Field                          Account Name    Robot Account

    Wait Until Element Is visible           (//button[@class='slds-button slds-button--neutral uiButton--default uiButton--brand uiButton forceActionButton']//span[contains(text(), 'Save')])[2]
    Click Element                           (//button[@class='slds-button slds-button--neutral uiButton--default uiButton--brand uiButton forceActionButton']//span[contains(text(), 'Save')])[2]

    Wait Until Element Is visible           //div[@class='modal-footer slds-modal__footer']//button[@title='Save']
    Click Element                           //div[@class='modal-footer slds-modal__footer']//button[@title='Save']

    #Verify that we have ONE affiliated account
    Reload Page
    Wait Until Element Is visible           (//span[@title='(1)'])[1]

