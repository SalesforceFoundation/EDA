*** Settings ***
Documentation   Validate reciprocal relationships sub tab in EDA Settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/RelationshipsSettingsPageObject.py
Suite Setup     Run keywords
...             Open Test Browser       AND
...             Go to EDA settings tab          Relationships      AND
...             Go to relationships sub tab     Reciprocal Settings     AND
...             Initialize test data
Suite Teardown  Run Keywords
...             Delete inserted data        AND
...             Capture screenshot and delete records and close browser

Test Setup      Run keywords
...             Go to EDA settings tab          Relationships      AND
...             Go to relationships sub tab     Reciprocal Settings

*** Keywords ***
Initialize test data
    [Documentation]             Reads the no of rows present in reciprocal relationship settings
    ...                         upon login and returns the count
    ${settings_count} =         Get total settings count
    Set Suite Variable          ${settings_count}

Delete inserted data
    [Documentation]             Validates reciprocal settings can be deleted. Also checks if those
    ...                         values are retained after save. This test is added to clean the data
    ...                         so this suite runs clean on every run.
    Go to EDA settings tab          Relationships
    Go to relationships sub tab     Reciprocal Settings
    Click action button on EDA settings page    Edit
    Click delete setting icon       Name=Name1
    Handle alert
    Sleep       1
    Verify setting deleted          True        Name=Name1
    Click action button on EDA settings page    Save
    Scroll web page
    Verify setting removed          Name=Name1

*** Test Cases ***
Verify reciprocal relationship settings can be added in both read and edit mode
    [Documentation]         Validates reciprocal settings can be added in read and edit mode. Also
    ...                     checks if those values are retained after save.
    [tags]                    unstable        W-8214822     rbt:high
    Enter new reciprocal setting
    ...         Name=Name
    ...         Female=Female
    ...         Male=Male
    ...         Neutral=Neutral
    Set reciprocal setting status
    ...         Active=true
    Click add new setting button        New Reciprocal Setting      Add Setting
    Scroll web page
    Verify new reciprocal setting
    ...         Name=Name
    ...         Female=Female
    ...         Male=Male
    ...         Neutral=Neutral
    Verify new setting checkbox status
    ...         Active=true
    Click action button on EDA settings page    Edit
    Enter new reciprocal setting
    ...         Name=Name1
    ...         Female=Female1
    ...         Male=Male1
    ...         Neutral=Neutral1
    Set reciprocal setting status
    ...         Active=false
    Click add new setting button        New Reciprocal Setting      Add Setting
    Scroll web page
    Verify reciprocal setting edit mode
    ...         Name=Name1
    ...         Female=Female1
    ...         Male=Male1
    ...         Neutral=Neutral1
    Verify new setting checkbox status edit mode
    ...         Active=false
    Click action button on EDA settings page    Cancel
    ${actual_count}=        Get total settings count
    ${result}=        Evaluate        ${actual_count} > ${settings_count}
    Log To Console          ${result}
    # Below commented steps are alternate solution to verify count and let it be in test if needed
    # ${no_of_records}=       Verify settings count       ${settings_count}       ${actual_count}
    # ...                     expected=True
    # Log To Console    ${no_of_records}
    Enter new reciprocal setting
    ...         Name=Name
    ...         Female=Female
    ...         Male=Male
    ...         Neutral=Neutral
    Set reciprocal setting status
    ...         Active=true
    Click add new setting button        New Reciprocal Setting      Add Setting
    Scroll web page
    ${final_count} =       Get total settings count
    Should Be Equal As Integers     ${actual_count}     ${final_count}

Verify reciprocal relationship settings can be deleted
    [Documentation]         Validates reciprocal settings can be deleted. Also checks if those
    ...                     values are retained after save.
    [tags]                    unstable        W-8245483     rbt:high
    Click action button on EDA settings page    Edit
    Click delete setting icon       Name=Name1
    Handle alert
    Sleep       1
    Verify setting deleted          True        Name=Name1
    Click action button on EDA settings page    Save
    Scroll web page
    Verify setting removed          Name=Name1

Verify existing reciprocal setting can be edited and values retained on save
    [Documentation]         Validates reciprocal settings can be updated. Also checks if those
    ...                     values are retained after save.
    [tags]                    unstable        W-8251460     rbt:high
    Click action button on EDA settings page    Edit
    Update existing reciprocal setting      column=Name1
    ...                                     Name=Name1
    ...                                     Female=Female1
    ...                                     Male=Male1
    ...                                     Neutral=Neutral1
    Set reciprocal setting status
    ...         Active=true
    Click action button on EDA settings page    Save
    Scroll web page
    Verify updated reciprocal setting      column=Name1
    ...                                    Name=Name1
    ...                                    Female=Female1
    ...                                    Male=Male1
    ...                                    Neutral=Neutral1