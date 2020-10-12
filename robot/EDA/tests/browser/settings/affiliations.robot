*** Settings ***
Documentation   Validate affiliations tab in EDA Settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AffiliationsSettingsPageObject.py
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser

Test Setup      Go to EDA settings tab          Affiliations

*** Test Cases ***
Verify all checkboxes are unchecked and all dropdwons filled with none
    [Documentation]         Updates all checkbox values as unchecked and all dropdown fields filled
    ...                     with value 'None' in settings tab under affiliations
    [tags]                    unstable        W-8188773     rbt:high
    Update checkbox value
    ...         Enable Record Type Validation=false
    ...         Delete Related Affiliation When Deleting Program Enrollment=false
    ...         Specify Role for Created Affiliations=false
    ...         Copy Affiliation End Date from Program Enrollment=false
    ...         Copy Affiliation Start Date from Program Enrollment=false
    Go to EDA settings tab          Affiliations
    Verify checkbox value
    ...         Enable Record Type Validation=false
    ...         Delete Related Affiliation When Deleting Program Enrollment=false
    ...         Specify Role for Created Affiliations=false
    ...         Copy Affiliation End Date from Program Enrollment=false
    ...         Copy Affiliation Start Date from Program Enrollment=false
    Click action button on EDA settings page    Edit
    Load Page Object                     System                          HEDA_Settings
    Update system dropdown value
    ...         Status for Affiliations Not Deleted =--None--
    ...         Role for Created Affiliations =--None--
    ...         Status for Created Affiliations =--None--
    Click action button on EDA settings page    Save
    Go to EDA settings tab          Affiliations
    Verify dropdown value
    ...         Status for Affiliations Not Deleted =--None--
    ...         Role for Created Affiliations =--None--
    ...         Status for Created Affiliations =--None--

Verify all checkboxes are checked and all dropdwons filled other than none
    [Documentation]         Updates all checkbox values as checked and all dropdown fields filled
    ...                     with values other than 'None' in settings tab under affiliations
    [tags]                    unstable        W-8188756     rbt:high
    Update checkbox value
    ...         Enable Record Type Validation=true
    ...         Delete Related Affiliation When Deleting Program Enrollment=true
    ...         Specify Role for Created Affiliations=true
    ...         Copy Affiliation End Date from Program Enrollment=true
    ...         Copy Affiliation Start Date from Program Enrollment=true
    Go to EDA settings tab          Affiliations
    Verify checkbox value
    ...         Enable Record Type Validation=true
    ...         Delete Related Affiliation When Deleting Program Enrollment=true
    ...         Specify Role for Created Affiliations=true
    ...         Copy Affiliation End Date from Program Enrollment=true
    ...         Copy Affiliation Start Date from Program Enrollment=true
    Click action button on EDA settings page    Edit
    Load Page Object                     System                          HEDA_Settings
    Update system dropdown value
    ...         Status for Affiliations Not Deleted =Former
    ...         Role for Created Affiliations =Student
    ...         Status for Created Affiliations =Current
    Click action button on EDA settings page    Save
    Go to EDA settings tab          Affiliations
    Verify dropdown value
    ...         Status for Affiliations Not Deleted =Former
    ...         Role for Created Affiliations =Student
    ...         Status for Created Affiliations =Current

Verify checkbox values can retain values on save
    [Documentation]         Updates the checkbox values of affiliations settings tab and verifies
    ...                     the updated values are retained upon save
    [tags]                    unstable        W-8177333     rbt:high
    Update checkbox value
    ...         Enable Record Type Validation=true
    ...         Delete Related Affiliation When Deleting Program Enrollment=true
    ...         Specify Role for Created Affiliations=false
    ...         Copy Affiliation End Date from Program Enrollment=false
    ...         Copy Affiliation Start Date from Program Enrollment=false
    Go to EDA settings tab          Affiliations
    Verify checkbox value
    ...         Enable Record Type Validation=true
    ...         Delete Related Affiliation When Deleting Program Enrollment=true
    ...         Specify Role for Created Affiliations=false
    ...         Copy Affiliation End Date from Program Enrollment=false
    ...         Copy Affiliation Start Date from Program Enrollment=false

Verify dropdown values can retain values on save
    [Documentation]         Updates the dropdown values of affiliations settings tab and verifies
    ...                     the updated values are retained upon save
    [tags]                    unstable        W-8177351     rbt:high
    Click action button on EDA settings page    Edit
    Load Page Object                     System                          HEDA_Settings
    Update system dropdown value
    ...         Status for Affiliations Not Deleted =--None--
    ...         Role for Created Affiliations =--None--
    ...         Status for Created Affiliations =--None--
    Click action button on EDA settings page    Save
    Go to EDA settings tab          Affiliations
    Verify dropdown value
    ...         Status for Affiliations Not Deleted =--None--
    ...         Role for Created Affiliations =--None--
    ...         Status for Created Affiliations =--None--


