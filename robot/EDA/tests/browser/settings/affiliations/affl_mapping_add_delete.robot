*** Settings ***
Documentation   Verifies that an Affiliation Mapping can be added and deleted
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Capture screenshot and delete records and close browser
Test Setup      Go to education cloud settings


*** Variables ***
${field_name}               Name

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
    Click show actions button                   Household Account       Delete
    Click footer button                         Delete
    Reload Page
    Wait Until Loading is Complete
    ${name_val}=                                Get Affiliation Mappings   ${field_name}
    List Should Not Contain Value               ${name_val}       Household Account