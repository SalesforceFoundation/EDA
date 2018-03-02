*** Settings ***

Resource  cumulusci/robotframework/CumulusCI.robot
Resource  cumulusci/robotframework/Salesforce.robot
Suite Setup  Set Login Url
Suite Teardown  Close Browser

*** Test Cases ***

Test Log In
    Open Test Browser
    Wait Until Loading Is Complete
    Page Should Contain  Home
