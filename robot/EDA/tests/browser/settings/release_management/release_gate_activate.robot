*** Settings ***
Documentation   Validate Release Management Activation
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/ReleaseManagementPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Activate release gate to in progress state
    [Documentation]         Validates the Sample Inactive release gate activate button is clicked and status changes and remains in progress
    [tags]                  rbt:high        W-10059975
    Go to release management
    Current page should be                      Home               Release Management
    #Inactive
    Verify release gate item                    Example Product    Sample Inactive Release Gate
    Verify release gate item icon               Example Product    Sample Inactive Release Gate       action-announcement
    Verify release gate item activation status  Example Product    Sample Inactive Release Gate       Inactive
    Verify release gate item activationdate     Example Product    Sample Inactive Release Gate       Activate by
    Activate release gate item                  Example Product    Sample Inactive Release Gate
    Verify release gate item icon               Example Product    Sample Inactive Release Gate       action-more
    Verify release gate item activation status  Example Product    Sample Inactive Release Gate       In Progress
    Verify release gate item activationdate     Example Product    Sample Inactive Release Gate       none
    
    #Make sure there is no sampleinactive contact record for any following run
    @{records}=  Salesforce Query  Contact  select=Id
    ...          where=LastName='sampleinactive'
    ...          limit=1
    ${count}=    Get length  @{records}

    Run Keyword If
    ...    ${count} > 0
    ...    Salesforce Delete  Contact  ${records}[0][Id]

Cancel activation release gate to in progress state
    [Documentation]         Validates the Sample Inactive release gate activate button is clicked and the cancel button is pressed, the status remains the same
    [tags]                  rbt:high        W-10059975
    Go to release management
    Current page should be                      Home               Release Management
    #Inactive
    Verify release gate item                    Example Product    Sample Inactive Release Gate
    Verify release gate item icon               Example Product    Sample Inactive Release Gate       action-announcement
    Verify release gate item activation status  Example Product    Sample Inactive Release Gate       Inactive
    Verify release gate item activationdate     Example Product    Sample Inactive Release Gate       Activate by
    Cancel activation release gate item         Example Product    Sample Inactive Release Gate
    Verify release gate item icon               Example Product    Sample Inactive Release Gate       action-announcement
    Verify release gate item activation status  Example Product    Sample Inactive Release Gate       Inactive
    Verify release gate item activationdate     Example Product    Sample Inactive Release Gate       Activate by