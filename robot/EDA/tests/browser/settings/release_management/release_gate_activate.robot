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
    Open release gate item activation           Example Product    Sample Inactive Release Gate
    Verify release gate activation modal        Activate Sample Inactive Release Gate    Are you sure you want to activate Example Product Sample Inactive Release Gate? Once activated, you can't deactivate it.
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

Activate Advisor Link Release Gate
    [Documentation]         Validates the Advisor Link release gate activate button prompts an expected modal and confirming the actiavtion updates the status to activated
    [tags]                  rbt:high        W-10059976
    Go to release management
    Current page should be                      Home               Release Management
    Verify release gate item                    Advisor Link    Summer '21
    Verify release gate item icon               Advisor Link    Summer '21       action-announcement
    Verify release gate item activation status  Advisor Link    Summer '21       Inactive
    Verify release gate item activationdate     Advisor Link    Summer '21       Activate by
    Cancel activation release gate item         Advisor Link    Summer '21
    Open release gate item activation           Advisor Link    Summer '21
    Verify release gate activation modal        Activate Summer '21    Are you sure you want to activate Advisor Link Summer '21? Once activated, you can't deactivate it.
    Activate release gate item                  Advisor Link    Summer '21
    Verify release gate item icon               Advisor Link    Summer '21       approval
    Verify release gate item activation status  Advisor Link    Summer '21       Activated
    Verify release gate item activationdate     Advisor Link    Summer '21       Activated on
    
    #Make sure there is no summer21 contact record for any following run
    @{records}=  Salesforce Query  Contact  select=Id
    ...          where=LastName='summer21'
    ...          limit=1
    ${count}=    Get length  @{records}

    Run Keyword If
    ...    ${count} > 0
    ...    Salesforce Delete  Contact  ${records}[0][Id]
