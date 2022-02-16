*** Settings ***
Documentation   Validate Release Management View List of Gates
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/ReleaseManagementPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify release management page displays EDA release gates
    [Documentation]         Validates EDA release gates and features
    [tags]                  rbt:high        W-10541240
    Go to release management
    Current page should be                      Home                                     Release Management
    #Latest EDA Release
    Verify release gate product                 Education Data Architecture
    Verify release gate item                    Education Data Architecture              Latest EDA Release
    Verify release gate item description        Education Data Architecture              Latest EDA Release         There were no features gated for this release. Therefore, all features were automatically released.
    Verify release gate item icon               Education Data Architecture              Latest EDA Release         action-approval
    Verify release gate item activation status  Education Data Architecture              Latest EDA Release         Activated
    Verify release gate item activationdate     Education Data Architecture              Latest EDA Release         none

Verify release management page displays Advisor Link release gates
    [Documentation]         Validates Advisor Link release gates and features
    [tags]                  rbt:high        W-10059977
    Go to release management
    Current page should be                      Home               Release Management
    Verify release gate product                 Advisor Link

    #Summer'21
    Verify release gate item                    Advisor Link       Summer '21
    Verify release gate item description        Advisor Link       Summer '21       Here's what's new in Summer '21. See the documentation for instructions on setting up these features, and then activate the release.     
    Verify release gate item icon               Advisor Link       Summer '21       action-announcement
    Verify release gate item activation status  Advisor Link       Summer '21       Inactive
    Verify release gate item activationdate     Advisor Link       Summer '21       Activate by
    ##Feature: Flexible Advisee Snapshot
    Verify release gate feature                 Advisor Link       Summer '21       Flexible Advisee Snapshot
    Verify release gate feature description     Advisor Link       Summer '21       Flexible Advisee Snapshot
    Verify release gate feature link            Advisor Link       Summer '21       Flexible Advisee Snapshot                Set Up the Advisee Snapshot and Contact Details       https://powerofus.force.com/s/article/SAL-Advisor-App-Snapshot-Contact
    ##Feature: Flexible Student Snapshot
    Verify release gate feature                 Advisor Link       Summer '21       Flexible Student Snapshot
    Verify release gate feature description     Advisor Link       Summer '21       Flexible Student Snapshot
    Verify release gate feature link            Advisor Link       Summer '21       Flexible Student Snapshot                Set Up the Student Snapshot and Student Details       https://powerofus.force.com/s/article/SSH-Set-Up-Student-Snapshot-and-Details
    ##Feature: Front Desk Appointment Scheduling
    Verify release gate feature                 Advisor Link       Summer '21       Front Desk Appointment Scheduling
    Verify release gate feature description     Advisor Link       Summer '21       Front Desk Appointment Scheduling
    Verify release gate feature link            Advisor Link       Summer '21       Front Desk Appointment Scheduling        Set Up Front Desk Appointment Scheduling              https://powerofus.force.com/s/article/SAL-Set-Up-Front-Desk-Appointment-Scheduling

    #Spring'21
    Verify release gate item                    Advisor Link       Spring '21       
    Verify release gate item description        Advisor Link       Spring '21       Spring '21 is now activated for all orgs
    Verify release gate item icon               Advisor Link       Spring '21       action-approval
    Verify release gate item activation status  Advisor Link       Spring '21       Activated
    Verify release gate item activationdate     Advisor Link       Spring '21       Activated on
    ##Feature: Flex Scheduling
    Verify release gate feature                 Advisor Link       Spring '21       Flex Scheduling
    Verify release gate feature description     Advisor Link       Spring '21       Flex Scheduling
    Verify release gate feature link            Advisor Link       Spring '21       Flex Scheduling         Set Up Location-Based Advising Availability       https://powerofus.force.com/s/article/SAL-Set-Up-Location-Based-Advising-Availability
    ##Feature: Group Availability
    Verify release gate feature                 Advisor Link       Spring '21       Group Availability
    Verify release gate feature description     Advisor Link       Spring '21       Group Availability
    Verify release gate feature link            Advisor Link       Spring '21       Group Availability      Set Up Group Advising Availability       https://powerofus.force.com/s/article/SAL-Set-Up-Group-Availability

Verify release management page displays Example Product release gates
    [Documentation]         Validates Example Product release gates and features
    [tags]                  rbt:high        W-10059977
    Go to release management
    Current page should be                      Home               Release Management
    Verify release gate product                 Example Product

    #Disabled    
    Verify release gate item                    Example Product    Sample Disabled Release Gate     
    Verify release gate item description        Example Product    Sample Disabled Release Gate       This is an example release gate in disabled state
    Verify release gate item icon               Example Product    Sample Disabled Release Gate       action-info
    Verify release gate item activation status  Example Product    Sample Disabled Release Gate       none
    Verify release gate item activationdate     Example Product    Sample Disabled Release Gate       none
    ##Feature: Example disabled feature 1
    Verify release gate feature                 Example Product    Sample Disabled Release Gate       Example disabled feature 1
    Verify release gate feature description     Example Product    Sample Disabled Release Gate       Example disabled feature 1
    Verify release gate feature link            Example Product    Sample Disabled Release Gate       Example disabled feature 1        See example feature 1       https://www.salesforce.com
    ##Feature: Example disabled feature 2
    Verify release gate feature                 Example Product    Sample Disabled Release Gate       Example disabled feature 2
    Verify release gate feature description     Example Product    Sample Disabled Release Gate       Example disabled feature 2
    Verify release gate feature link            Example Product    Sample Disabled Release Gate       Example disabled feature 2        See example feature 2       https://www.salesforce.com

    #InProgress    
    Verify release gate item                    Example Product    Sample InProgress Release Gate       
    Verify release gate item description        Example Product    Sample InProgress Release Gate     This is an example release gate in InProgress state
    Verify release gate item icon               Example Product    Sample InProgress Release Gate     action-more
    Verify release gate item activation status  Example Product    Sample InProgress Release Gate     In Progress
    Verify release gate item activationdate     Example Product    Sample InProgress Release Gate     none
    ##Feature: Example inprogress feature 1
    Verify release gate feature                 Example Product    Sample InProgress Release Gate     Example inprogress feature 1
    Verify release gate feature description     Example Product    Sample InProgress Release Gate     Example inprogress feature 1
    Verify release gate feature link            Example Product    Sample InProgress Release Gate     Example inprogress feature 1        See example feature 1       https://www.salesforce.com
    ##Feature: Example inprogress feature 2
    Verify release gate feature                 Example Product    Sample InProgress Release Gate     Example inprogress feature 2
    Verify release gate feature description     Example Product    Sample InProgress Release Gate     Example inprogress feature 2
    Verify release gate feature link            Example Product    Sample InProgress Release Gate     Example inprogress feature 2        See example feature 2       https://www.salesforce.com

    #Active    
    Verify release gate item                    Example Product    Sample Active Release Gate
    Verify release gate item description        Example Product    Sample Active Release Gate         This is an example release gate in active state
    Verify release gate item icon               Example Product    Sample Active Release Gate         action-approval
    Verify release gate item activation status  Example Product    Sample Active Release Gate         Activated
    Verify release gate item activationdate     Example Product    Sample Active Release Gate         Activated on
    ##Feature: Example active feature 1
    Verify release gate feature                 Example Product    Sample Active Release Gate         Example active feature 1
    Verify release gate feature description     Example Product    Sample Active Release Gate         Example active feature 1
    Verify release gate feature link            Example Product    Sample Active Release Gate         Example active feature 1        See example feature 1       https://www.salesforce.com
    ##Feature: Example active feature 2
    Verify release gate feature                 Example Product    Sample Active Release Gate         Example active feature 2
    Verify release gate feature description     Example Product    Sample Active Release Gate         Example active feature 2
    Verify release gate feature link            Example Product    Sample Active Release Gate         Example active feature 2        See example feature 2       https://www.salesforce.com

    #Inactive
    Verify release gate item                    Example Product    Sample Inactive Release Gate
    Verify release gate item description        Example Product    Sample Inactive Release Gate       This is an example release gate in inactive state
    Verify release gate item icon               Example Product    Sample Inactive Release Gate       action-announcement
    Verify release gate item activation status  Example Product    Sample Inactive Release Gate       Inactive
    Verify release gate item activationdate     Example Product    Sample Inactive Release Gate       Activate by
    ##Feature: Example inactive feature 1
    Verify release gate feature                 Example Product    Sample Inactive Release Gate       Example inactive feature 1
    Verify release gate feature description     Example Product    Sample Inactive Release Gate       Example inactive feature 1
    Verify release gate feature link            Example Product    Sample Inactive Release Gate       Example inactive feature 1        See example feature 1       https://www.salesforce.com
    ##Feature: Example inactive feature 2
    Verify release gate feature                 Example Product    Sample Inactive Release Gate       Example inactive feature 2
    Verify release gate feature description     Example Product    Sample Inactive Release Gate       Example inactive feature 2
    Verify release gate feature link            Example Product    Sample Inactive Release Gate       Example inactive feature 2        See example feature 2       https://www.salesforce.com