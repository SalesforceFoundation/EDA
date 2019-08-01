*** Settings ***
Documentation
...     Verify Plan Requirement with both Program Plan & Parent Plan Requirement can be created when setting is disabled

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Run keywords
...             Initialize test data
...             Open test browser
Suite Teardown  Delete records and close browser

*** Test Cases ***
Validate creation of Plan Requirement - Nested Plan Requirement setting disabled
    [Documentation]                 Verify Plan Requirement can be created with both Program Plan & Parent Plan Requirement when setting is disabled
    [tags]                          stable

    Go to EDA settings
    Click on element                eda_settings.tab                Program Plans
    Edit EDA settings checkbox      Validate Program Plan for Nested Plan Requirements      false

    Go to record home               &{program_plan}[Id]
    Wait until loading is complete
    Sleep                           3
    Select tab                      Related
    Click on element                record.related.new              Plan Requirements
    Wait until modal is open
    ${plan_req_name} =              Get EDA locator                 plan_requirement.plan_requirement_name
    Input text                      ${plan_req_name}                Intro to Literature
    Wait for locator                plan_requirement.program_plan   &{program_plan}[Name]
    Populate placeholder            Search Plan Requirements        &{plan_requirement_1}[Name]
    Click on element                modal.save
    Wait for locator                plan_requirement.toast_message

    ${plan_requirement_2} =         API Get ID          ${ns}Plan_Requirement__c        Name        Intro to Literature
    Store session record            ${ns}Plan_Requirement__c        ${plan_requirement_2}

*** Keywords ***
Initialize test data
    [Documentation]                 Create Program Plan and Plan Requirement through API
    &{program_plan} =               API create program plan         BA English
    &{plan_requirement_1} =         API create plan requirement     Advanced Literature     &{program_plan}[Id]
    ${ns} =                         Get eda namespace prefix

    Set suite variable              &{program_plan}
    Set suite variable              &{plan_requirement_1}
    Set suite variable              ${ns}

    Store session record            ${ns}Program_Plan__c            &{program_plan}[Id]
    Store session record            ${ns}Plan_Requirement__c        &{plan_requirement_1}[Id]