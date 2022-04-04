*** Settings ***
Documentation   Validate Education Cloud Settings home page
Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/EducationCloudSettingsPageObject.py
...             robot/EDA/resources/ReleaseManagementPageObject.py
...             robot/EDA/resources/EDASettingsPageObject.py

Suite Setup     Initialize test data
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
Verify products tools and resources tiles are displayed
    [Documentation]         Validates the products, tools and resources tiles are displayed.
    [tags]                  rbt:high        W-9549044
    Open test browser
    Go to education cloud settings home
    Current page should be                  Home        Education Cloud Settings
    Verify app tiles displayed
    ...                                     Tools=Settings Health Check
    ...                                     Resources=Trailhead
    ...                                     Resources=Trailblazer Community
    ...                                     Resources=YouTube
    close browser

Verify release management page is displayed when user clicks on go to release management button
    [Documentation]         Validates 'Release Management' page is displayed after clicking on the Go to Release Management
    [tags]                  rbt:high        W-10059978
    Open test browser
    Go to education cloud settings home
    Current page should be                  Home        Education Cloud Settings
    Click app in edc home                   Go to Release Management
    Current page should be                  Home        Release Management
    close browser

Verify EDA product card is displayed
    [Documentation]         Validates the EDA product card is displayed.
    [tags]                  rbt:high        W-10073560
    Open test browser
    Go to education cloud settings home
    Current page should be                  Home        Education Cloud Settings
    Verify app tiles displayed  Products=Education Data Architecture
    Verify product card avatar displayed  EDA
    Verify product card description displayed  Education Data Architecture (EDA) is the foundation of the Education Cloud.
    Verify product card button displayed  Go to EDA Settings.
    verify product card button displayed  Go to the EDA documentation.
    Verify product card button displayed  Go to EDA Trailhead modules.
    close browser

Verify mocked SAL product card is displayed
    [Documentation]         Validates the mocked sal product card is displayed.
    [tags]                  rbt:high        W-10073560
    Open test browser
    Go to education cloud settings home
    Current page should be                  Home        Education Cloud Settings
    Verify app tiles displayed  Products=Advisor Link (Mocked)
    Verify product card avatar displayed  TAL
    Verify product card description displayed  dvisor Link (Mocked) gives advisors and advisees new tools to help foster focused conversations about education success.
    Verify product card button displayed  Go to Advisor Link (Mocked) Settings
    verify product card button displayed  Go to Advisor Link (Mocked) Documentation
    Verify product card button displayed  Go to Advisor Link (Mocked) Trailhead
    close browser

Verify EDA settings page is displayed when user clicks on the settings button under Education Data Architecture product tile
    [Documentation]         Validates 'EDA Settings' page is displayed after clicking on the settings button under Education Data Architecture product tile
    [tags]                  rbt:high        W-10073560
    Open test browser
    Go to education cloud settings home
    Current page should be                  Home        Education Cloud Settings
    Sleep                       2
    Click product card button in edc home   Go to EDA Settings.
    Current page should be                  Home        EDA Settings
    close browser

Verify EDA documents page is displayed when user clicks on the documentation button under Education Data Architecture product tile
    [Documentation]         Validates EDA documents page is displayed after clicking on the documentation button under Education Data Architecture product tile
    [tags]                  rbt:high        W-10073560
    Open test browser
    Go to education cloud settings home
    Current page should be                  Home        Education Cloud Settings
    Click product card button in edc home   Go to the EDA documentation.
    Switch Window    locator=NEW
    Verify eda documentation  https://powerofus.force.com/s/article/EDA-Documentation   
    close browser

Verify Trailhead page is displayed when user clicks on the trailhead button under Education Data Architecture product tile
    [Documentation]         Validates EDA trailhead page is displayed after clicking on the trailhead button under Education Data Architecture product tile
    [tags]                  rbt:high        W-10073560
    Open test browser
    Go to education cloud settings home
    Current page should be                  Home        Education Cloud Settings
    Click product card button in edc home   Go to EDA Trailhead modules.
    Switch Window    locator=NEW
    Verify eda documentation  trailhead.salesforce.com/en/content/learn/trails/highered_heda  
    close browser    

Verify user without class access renders release management page with toast error
    [Documentation]         Validates 'Release Management' page with access error is displayed after clicking on the Go to Release Management
    [tags]                  rbt:high        W-10059980
    #give user partial permission to access Release Management page, but not see the release gates
    Run task        add_permission_set_perms
    ...             api_names=Internal_Only_for_Testing
    ...             class_accesses=${{ [{"apexClass": "${ns}EducationCloudSettingsController", "enabled": True}] }}

    Open test browser        useralias=noaccess
    Go to education cloud settings home
    Current page should be                  Home        Education Cloud Settings
    Click app in edc home                   Go to Release Management
    Current page should be                  Home        Release Management
    Verify error is displayed           You do not have access to the Apex class named 'ReleaseGateController'.

    #remove permission added for test
    Run task        add_permission_set_perms
    ...             api_names=Internal_Only_for_Testing
    ...             class_accesses=${{ [{"apexClass": "${ns}EducationCloudSettingsController", "enabled": False}] }}
    close browser

Verify user without EDA settings class access shows error
    [Documentation]         Validates EDA Settings page shows an error when the user does not have class access
    [tags]                  rbt:high        W-10131460
    Open test browser        useralias=noaccess
    Go to education cloud settings
    Current page should be                  Home        EDA Settings
    Verify EDA Settings error is displayed  You can't view this page. Your Salesforce admin can help with that.
    close browser

Verify user without customize application access shows error
    [Documentation]         Validates EDA Settings page shows an error when the user does not have customize application permission
    [tags]                  rbt:high        W-10131460
    #Give user partial permission to access EDASettings page, but customize application permission is missing
    Run task        add_permission_set_perms
    ...             api_names=Internal_Only_for_Testing
    ...             class_accesses=${{ [{"apexClass": "${ns}EDASettingsController", "enabled": True}] }}

    Open test browser        useralias=noaccess
    Go to education cloud settings
    Current page should be                  Home        EDA Settings
    Verify EDA Settings error is displayed  You can't view this page. Your Salesforce admin can help with that.

    #remove permission added for test
    Run task        add_permission_set_perms
    ...             api_names=Internal_Only_for_Testing
    ...             class_accesses=${{ [{"apexClass": "${ns}EDASettingsController", "enabled": False}] }}
    close browser

*** Keywords ***
Initialize test data
    [Documentation]         
    ${ns} =     Get EDA namespace prefix    
