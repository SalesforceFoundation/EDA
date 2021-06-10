*** Settings ***
Documentation   Validates affiliation mappings health check card
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SettingsHealthCheckPageObject.py
...             robot/EDA/resources/AffiliationsSettingsPageObject.py
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Run Keywords
...             Revert account record type changes        AND
...             Capture screenshot and delete records and close browser

*** Keywords ***
Revert account record type changes
    [Documentation]             Reverts the changes made to the account record type. This is added
    ...                         to clean the data so this suite runs clean on every run.
    Go to EDA settings tab                      Affiliations
    Go to affiliations sub tab                  Affiliation Mappings
    Click action button on EDA settings page    Edit
    Modify account record type                  1_Academic_Program        Academic_Program
    Click action button on EDA settings page    Save

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
    Go to education cloud settings
    Go to affiliations sub tab                  Affiliation Mappings
    Click action button on EDA settings page    Edit
    Modify account record type                  Academic_Program        1_Academic_Program
    Click action button on EDA settings page    Save
    Reload Page
    Go to settings health check
    Current page should be                      Home        Settings Health Check
    Run health check settings   Affiliation Mappings  AffiliationMappings   AffiliationMappingsResults
    ...         1_Academic_Program Affiliation Mapping=Failed
    ...         Business_Organization Affiliation Mapping=Passed
    ...         Educational_Institution Affiliation Mapping=Passed
    ...         HH_Account Affiliation Mapping=Passed
    ...         Sports_Organization Affiliation Mapping=Passed
    ...         University_Department Affiliation Mapping=Passed
    Verify recommended fix      AffiliationMappingsResults
    ...                     Unique Affiliation Mapping Record Type=valid