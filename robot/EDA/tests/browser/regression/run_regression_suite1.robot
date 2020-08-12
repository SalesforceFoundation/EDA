*** Settings ***
Documentation   Regression suite to test new program and course offering
Resource        robot/EDA/resources/EDA.robot
Resource        robot/EDA/resources/test_data.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AffiliationsSettingsPageObject.py

Suite Setup     Run keywords
...             Open Test Browser
...             Initialize Test Data

Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Create A New Program Plan
    [Documentation]     Creates a new program plan record
    [tags]                                  unstable
    Go to page                              Listing         Program_Plan__c
    Click Object Button                     New
    Wait for Locator                        program_plans.pp_name

    Populate Field                          Program Plan Name
    ...                 robotTest Program Plan Name Test Program - this is just a robot test string
    Click on Element                        program_plans.save_button

Create A Course Offering
    [Documentation]     Creates a new course offerring record
    [tags]                                  unstable

    Go to page                              Listing         Course_Offering__c
    Click Object Button                     New

    Wait for Locator                        course_offering.search_courses
    Click on Element                        course_offering.search_courses

    Wait for Locator                        course_offering.new_course_button
    Click on Element                        course_offering.new_course_button

    Populate Field                          Course Name
    ...                 robotTest Course Name Test1 - this is just another robot test string in
    ...                 place of a course name
    Populate Field                          Department      Robot Academic Program Account
    Press Keys                              //input[@title='Search Accounts']
    ...                                     ARROW_DOWN+RETURN

    Click on Element                        course_offering.final_save_button

    Click on Element                        term.search_terms
    Click on Element                        term.new_term_button
    Populate Field                          Term Name               Robot Automation Term
    Click on Element                        term.account
    Press Keys                              //input[@title='Search Accounts']
    ...                                     ARROW_DOWN+RETURN

    Click on Element                        term.save_button
    ${id_offering} =                        Generate Random String

    Click on Element                        term.course_offering_id
    Input Text          //span[contains(text(), 'Course Offering ID')]//../following-sibling::input
    ...                 ${id_offering}
    Click on Element                        course_offering.next_save_button