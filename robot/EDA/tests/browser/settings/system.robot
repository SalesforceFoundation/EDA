*** Settings ***
Documentation   Validate system tab in EDA Settings
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/SystemSettingsPageObject.py

Suite Setup     Run keywords
...             Initialize test data
...             Open Test Browser
Suite Teardown  Capture screenshot and delete records and close browser


*** Keywords ***
Initialize test data
    [Documentation]                     Creates collaboration group and gets the SFID of group and
    ...                                 also reads SFID of security user
    ${group_name} =                     Set variable            Test Chatter Group
    ${user_name} =                      Set variable            Security User
    ${group_id}=                        API Create Collaboration Group  ${group_name}
    ${user_id} =                        API Get ID          User     Name       Security User
    Set Suite Variable  ${group_name}
    Set Suite Variable  ${user_name}
    Set Suite Variable  ${group_id}
    Set Suite Variable  ${user_id}

*** Test Cases ***
Verify system settings can retain value on save
    [Documentation]         Updates the values of checkbox and dropdown fields in system settings to
    ...                     the passed value as arguments and verifies the same values are retained
    ...                     after saving it.
    [tags]                    unstable        W-8042700     W-8119542     rbt:high
    Go to EDA settings tab    System
    Scroll web page
    Update checkbox value
    ...                       Store Errors=false
    ...                       Send Error Notifications=true
    ...                       Disable Error Handling=true
    ...                       Automatically Rename Household Accounts=true
    Click action button on EDA settings page    Edit
    Update system dropdown value
    ...                       Default Account Model=Household Account
    ...                       Administrative Account Name Format=Other
    ...                       Household Account Name Format=Other
    Enter account name format
    ...     The name format used for auto-created Administrative Accounts.={!LastName} Admin Account
    ...     The format used for naming Household Accounts.={!LastName} House Account
    Click action button on EDA settings page    Save
    # Below step is necessary as sometimes the dropdown field is not loading to verify its value
    Go to EDA settings tab    System
    Sleep                     25
    Verify checkbox value
    ...                       Store Errors=false
    ...                       Send Error Notifications=true
    ...                       Disable Error Handling=true
    ...                       Automatically Rename Household Accounts=true
    Verify dropdown value
    ...                       Default Account Model=Household Account
    Verify system dropdown value
    ...     The name format used for auto-created Administrative Accounts.={!LastName} Admin Account
    ...     The format used for naming Household Accounts.={!LastName} House Account
    Click action button on EDA settings page    Edit
    Update system dropdown value
    ...                       Administrative Account Name Format={!LastName} Administrative Account
    ...                       Household Account Name Format={!{!FirstName}} {!LastName} Family
    Click action button on EDA settings page    Save
    Go to EDA settings tab    System
    Verify dropdown value
    ...                       Administrative Account Name Format={!LastName} Administrative Account
    ...                       Household Account Name Format={!{!FirstName}} {!LastName} Family

Verify Error Notification Recipients field picklist availability
    [Documentation]         Updates 'Error Notification Recipients' to chatter group and user and
    ...                     validates if the SFID values of the same are retained upon saving.
    [tags]                    unstable        W-8134943     rbt:high
    Go to EDA settings tab    System
    Click action button on EDA settings page    Edit
    Select recipient type value
    ...                       Select recipient type:=Chatter Group
    Select recipient
    ...                       Select Chatter Group=${group_name}
    Click action button on EDA settings page    Save
    Verify dropdown value
    ...                       Error Notification Recipients=${group_id}
    Click action button on EDA settings page    Edit
    Select recipient type value
    ...                       Select recipient type:=All Sys Admins
    Click action button on EDA settings page    Save
    Verify dropdown value
    ...                       Error Notification Recipients=All Sys Admins
    Click action button on EDA settings page    Edit
    Select recipient type value
    ...                       Select recipient type:=User
    Select recipient
    ...                       Select User=${user_name}
    Click action button on EDA settings page    Save
    Verify dropdown value
    ...                       Error Notification Recipients=${user_id}

Verify refresh all administrative names and refresh all household names are active
    [Documentation]         Checks "Refresh  All Administrative Names" and "Refresh All Household
    ...                     Names" button are active in read mode.
    [tags]                                      unstable        W-8109925        rbt:high
    Go to EDA settings tab    System
    Click run action button                     Refresh All Administrative Names
    Verify admin toast message
    ...     The Administrative Account naming refresh was queued successfully. An email will be sent at the completion of the batch.
    Click run action button                     Refresh All Household Names
    Verify household toast message
    ...     The Household Account naming refresh was queued successfully. An email will be sent at the completion of the batch.
