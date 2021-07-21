*** Settings ***
Documentation   Verifies that an Affiliation Mapping can be added and deleted
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Capture screenshot and delete records and close browser
Test Setup      Go to education cloud settings

***Keywords***
Setup Test Data
    ${values} =                Get Affiliation Mappings Value  ${sObject_name}     ${field_name}
    Set suite variable         ${values}

*** Variables ***
${field_name}               Account_Record_Type__c
${sObject_name}             Affl_Mappings__c

*** Test Cases ***
Validate Affiliation Mappings can be Deleted
    [Documentation]         Verifies an affiliation mapping can be deleted from the affiliations table in EDA Settings. Also verifies the learn more link

# Go to new EDA Settings
# Delete sports organization affiliation mapping
# Click Delete

# Select primary affiliation field on contact as "Primary Sports Organization"
# Click Save

# Click Tell me more link
# Expected Results:

# Verify the affiliation mapping is removed from the table
# Verify sports organization affiliation mapping is created
# Verify power of us hub link is opened
    [tags]                                      unstable        W-9549025       rbt:high

    Select settings from navigation pane        Affiliations
    Click show actions button                   Educational Institution       Delete
    Click footer button                         Delete
    Reload Page
    Wait Until Loading is Complete
    ${name_val}=                                Get Affiliation Mappings Value  ${sObject_name}     ${field_name}
    List Should Not Contain Value               ${values}       Educational_Institution 