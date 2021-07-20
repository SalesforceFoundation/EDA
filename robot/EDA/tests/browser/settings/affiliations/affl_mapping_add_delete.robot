*** Settings ***
Documentation   Verifies that an Affiliation Mapping can be added and deleted
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Update settings to out of the box values        AND
...             Capture screenshot and delete records and close browser
Test Setup      Go to education cloud settings

***Keywords***
Update settings to out of the box values
    Go to education cloud settings
    Select settings from navigation pane        Affiliations
    Click action button on new EDA settings     Edit
    Set toggle input
    ...                                         Record Type Validation=True
    Click action button on new EDA settings     Save

*** Test Cases ***
Validate record type validation settings in affiliations is updated in hierarchy settings
    [Documentation]         Verifies an affiliation mapping can be added and deleted from the affiliations table in EDA Settings. Also verifies the learn more link

# Go to new EDA Settings
# Delete sports organization affiliation mapping
# Click Delete
# Click New
# Select account record type "Sports Organization"
# Select primary affiliation field on contact as "Primary Sports Organization"
# Click Save
# Click Tell me more link
# Expected Results:

# Verify the affiliation mapping is removed from the table
# Verify sports organization affiliation mapping is created
# Verify power of us hub link is opened
    [tags]                                      unstable        W-9549025       rbt:high

    Select settings from navigation pane        Affiliations
    Click show actions button                   Sports Organization       Delete
    Click footer button                         Delete
    Reload Page
    Wait Until Loading is Complete
    ${name_val}=                                Get Affiliation Mappings Value  field_name  record_type_name
    List Should Not Contain Value               ${values}       Sports Organization 
   
   # Click action button on new EDA settings     New
   # Update settings dropdown value
    #...                                         Name=Cousin
   # ...                                         Female=Cousin
   # ...                                         Male=Cousin
   # ...                                         Neutral=Cousin
   # Click footer button                         Save
   # Click action button on new EDA settings     Save
    # ${type_enforced}=                               Get Custom Settings Value       Affiliation_Record_Type_Enforced__c
    # Should Be Equal As Strings                  ${type_enforced}      False