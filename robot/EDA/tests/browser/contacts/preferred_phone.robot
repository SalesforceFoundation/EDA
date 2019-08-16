*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***
Let Us Populate Create And Return Contact with Home Phone
    [tags]          unstable
    ${contact_id} =  Populate Create And Return Contact with Home Phone    Julian      Joseph   512-555-1234  
    &{contact} =  Salesforce Get    Contact             ${contact_id}
    Select Tab    Details
    Should Be Equal    &{contact}[PreferredPhone__c]    Home