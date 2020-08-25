*** Settings ***
Documentation
...     Verify Plan Requirement with both Program Plan & Parent Plan Requirement
...     cannot be created or updated when setting is enabled

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/ProgramPlansSettingsPageObject.py

Suite Setup     Run keywords
...             Initialize test data
...             Open test browser

Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Validate creation of Plan Requirement - Nested Plan Requirement setting enabled
    [Documentation]                 Verify Plan Requirement cannot be created with both Program Plan
    ...                             & Parent Plan Requirement when setting is enabled
    [tags]                          unstable

    Go to EDA settings tab          Program Plans
    Edit EDA settings checkbox      Validate Program Plan for Nested Plan Requirements      true

    Go to record home               ${program_plan}[Id]

    Java click on element           panel_tab_lookup    Related

    Wait until loading is complete
    Wait for locator                record.related.new              Plan Requirements
    Java click on element           record.related.new              Plan Requirements

    Wait until modal is open
    ${plan_req_name} =              Get EDA locator         plan_requirement.plan_requirement_name
    Input text                      ${plan_req_name}                Intro to Literature
    Wait for locator                plan_requirement.program_plan   ${program_plan}[Name]
    Populate placeholder            Search Plan Requirements        ${plan_requirement_1}[Name]
    Click on element                modal.save

    Wait for locator                plan_requirement.error
    ...                             Plan Requirements can specify either a Program Plan or a parent
    ...                             Plan Requirement, but not both. If this Plan Requirement is a
    ...                             child of another Plan Requirement, specify a parent Plan
    ...                             Requirement only. If this Plan Requirement is a child of a
    ...                             Program Plan, specify a Program Plan only.
    Java click on element           plan_requirement.delete_field   Program Plan
    ...                             ${program_plan}[Name]
    Java click on element           plan_requirement.plan_requirement_name

    Wait until page contains        Save
    Click on element                modal.save
    Wait for locator                plan_requirement.toast_message

    ${plan_requirement_2} =         API Get ID          ${ns}Plan_Requirement__c        Name
    ...                             Intro to Literature
    Set suite variable              ${plan_requirement_2}
    Store session record            ${ns}Plan_Requirement__c        ${plan_requirement_2}

Validate updation of Plan Requirement - Nested Plan Requirement setting enabled
    [Documentation]                 Verify Plan Requirement cannot be updated with both Program Plan
    ...                             & Parent Plan Requirement when setting is enabled
    [tags]                          unstable

    Go to record home               ${plan_requirement_2}
    Wait for locator                record.actions          Edit
    Java click on element           record.actions          Edit
    Wait until modal is open
    Wait for locator                plan_requirement.parent_plan_req_name
    ...                             ${plan_requirement_1}[Name]
    Populate placeholder            Search Program Plans...                 ${program_plan}[Name]

    Java click on element           plan_requirement.program_plan_name      ${program_plan}[Name]

    Click Button                    Save
    Wait for locator                plan_requirement.error          Plan Requirements can specify
    ...                             either a Program Plan or a parent Plan Requirement, but not
    ...                             both. If this Plan Requirement is a child of another Plan
    ...                             Requirement, specify a parent Plan Requirement only. If this
    ...                             Plan Requirement is a child of a Program Plan, specify a Program
    ...                             Plan only.

    Java click on element           plan_requirement.delete_field   Parent Plan Requirement
    ...                             ${plan_requirement_1}[Name]
    Java click on element           plan_requirement.plan_requirement_name
    Click Button                    Save
    Wait for locator                plan_requirement.toast_message

    ${plan_requirement_2} =         API Get ID          ${ns}Plan_Requirement__c        Name
    ...                             Intro to Literature
    Store session record            ${ns}Plan_Requirement__c        ${plan_requirement_2}


*** Keywords ***
Initialize test data
    [Documentation]                 Create Program Plan and Plan Requirement through API
    &{program_plan} =               API create program plan         BA English
    &{plan_requirement_1} =         API create plan requirement     Advanced Literature
    ...                             ${program_plan}[Id]
    ${ns} =                         Get eda namespace prefix

    Set suite variable              &{program_plan}
    Set suite variable              &{plan_requirement_1}
    Set suite variable              ${ns}

    Store session record            ${ns}hed__Program_Plan__c            ${program_plan}[Id]
    Store session record            ${ns}hed__Plan_Requirement__c        ${plan_requirement_1}[Id]