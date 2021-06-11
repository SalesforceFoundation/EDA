*** Settings ***
Documentation   Validates affiliation mappings health check card
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SettingsHealthCheckPageObject.py
...             robot/EDA/resources/AffiliationsSettingsPageObject.py
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Run keywords
...             Open Test Browser
...             Setup Test Data
Suite Teardown  Run Keywords
...             Revert account record type changes        AND
...             Capture screenshot and delete records and close browser

*** Keywords ***
Setup Test Data
    ${academic_id} =           Get Record Type Id        ${sObject_name}     ${academic_record_type}
    Set suite variable         ${academic_id}

Revert account record type changes
    [Documentation]             Reverts the changes made to the account record type. This is added
    ...                         to clean the data so this suite runs clean on every run.
    API Update Records          RecordType    ${academic_id}      IsActive=true

*** Variables ***
${academic_record_type}    Academic Program
${sObject_name}            Account

*** Test Cases ***
Verify affiliation mappings health check settings checks pass
    [Documentation]         Validates the affiliation mappings health card is displayed with
    ...                     settings for default account record types. Also verifies the status of
    ...                     each setting.
    [tags]                  unstable        rbt:high        W-8925750
    Go to settings health check
    Current page should be      Home        Settings Health Check
    Run health check settings   Affiliation Mappings  AffiliationMappings   AffiliationMappingsResults
    ...         Academic_Program Affiliation Mapping=Passed
    ...         Business_Organization Affiliation Mapping=Passed
    ...         Educational_Institution Affiliation Mapping=Passed
    ...         HH_Account Affiliation Mapping=Passed
    ...         Sports_Organization Affiliation Mapping=Passed
    ...         University_Department Affiliation Mapping=Passed

Verify affiliation mapping health check settings checks fail and display recommended fix message
    [Documentation]         Verifies the failing affiliation mapping health check and its message
    [tags]                  unstable        rbt:high        W-9048429
    API Update Records      RecordType    ${academic_id}      IsActive=false
    Go to settings health check
    Current page should be                      Home        Settings Health Check
    Run health check settings   Affiliation Mappings  AffiliationMappings   AffiliationMappingsResults
    ...         Academic_Program Affiliation Mapping=Failed
    ...         Business_Organization Affiliation Mapping=Passed
    ...         Educational_Institution Affiliation Mapping=Passed
    ...         HH_Account Affiliation Mapping=Passed
    ...         Sports_Organization Affiliation Mapping=Passed
    ...         University_Department Affiliation Mapping=Passed
    Verify recommended fix      AffiliationMappingsResults
    ...                     Account Record Type=Active