*** Settings ***
Documentation   Validates affiliation mappings health check card
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SettingsHealthCheckPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

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
