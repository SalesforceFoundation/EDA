*** Settings ***
Documentation
...     Test Affiliations Mappings:  
...     Verifies the following:
...        All standard field values
...        All text fields retain null value on save
...        All text fields retain text value on save
...        All checkbox fields can retain checked value on save
...        All checkbox fields can retain unchecked values on save
...        All mappings can be deleted

Resource        cumulusci/robotframework/Salesforce.robot
Resource        robot/EDA/resources/EDA.robot
Library         robot/EDA/resources/EDA.py
Library         DateTime
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AffiliationsPageObject.py

Test Setup      Initialize test setup

Suite Setup     Run keywords
...             Initialize test data
...             Open test browser

Suite Teardown  Run keywords
...             Close Browser 

*** Test Cases ***

All standard field values
    [tags]                                      unstable

    Current page should be                      Listing                    
    ...                                         hed__HEDA_Settings

    # Ensure you're on Affiliations > Settings
    Go to EDA settings    
    Go to affiliation mappings

    # Verify that we have the correct defaults
    Process default mapping values


    Shift to default content
    Go To Object Home                           Account
    Close all tabs

All text fields retain null value on save
    [tags]                                      unstable

    Current page should be                      Listing                 
    ...                                         hed__HEDA_Settings

    # Ensure you're on Affiliations > Settings
    Go to EDA settings    
    Go to affiliation mappings

    ${affl_mappings_tab} =                      Get Eda Locator         eda_settings.affl_mappings_tab

    # Edit the dropdowns - go into Edit mode
    Click button on location                    Edit                    ${affl_mappings_tab}

    Clear everything on affiliation mappings

    #Save settings
    Click button on location                    Save                    ${affl_mappings_tab}
    Close toast message

    Shift to default content
    Go To Object Home                           Account
    Close all tabs


All text fields retain text value on save
    [tags]                                      unstable

    Current page should be                      Listing                 
    ...                                         hed__HEDA_Settings

    # Ensure you're on Affiliations > Settings
    Go to EDA settings    
    Go to affiliation settings

    ${affl_mappings_tab} =                      Get Eda Locator         eda_settings.affl_mappings_tab

    # Edit the dropdowns - go into Edit mode
    Click button on location                    Edit                    ${affl_mappings_tab}
    Add text to all text fields

    #Save settings
    Click button on location                    Save                    ${affl_mappings_tab}
    Close toast message

    Shift to default content
    Go To Object Home                           Account
    Close all tabs

All checkbox fields can retain checked value on save
    [tags]                                      unstable

    Current page should be                      Listing                 
    ...                                         hed__HEDA_Settings

    # Ensure you're on Affiliations > Settings
    Go to EDA settings    
    Go to affiliation settings

    ${affl_mappings_tab} =                      Get Eda Locator         eda_settings.affl_mappings_tab
    ${auto_enroll_academic_program} =           Get Eda Locator         eda_settings.auto_enroll_academic_program
    ${checkbox_ap_affl} =                       Get Eda Locator         eda_settings.checkbox_ap_affl

    ${auto_enroll_business_organization} =      Get Eda Locator         eda_settings.auto_enroll_business_organization
    ${auto_enroll_educational_institution} =    Get Eda Locator         eda_settings.auto_enroll_educational_institution
    ${auto_enroll_household_account} =          Get Eda Locator         eda_settings.auto_enroll_household_account
    ${auto_enroll_sports_organization} =        Get Eda Locator         eda_settings.auto_enroll_sports_organization
    ${auto_enroll_university_department} =      Get Eda Locator         eda_settings.auto_enroll_university_department

    ${pbo_affl_edit} =                          Get Eda Locator         eda_settings.pbo_affl_edit
    ${pei_affl_edit} =                          Get Eda Locator         eda_settings.pei_affl_edit
    ${ph_affl_edit} =                           Get Eda Locator         eda_settings.ph_affl_edit
    ${pso_affl_edit} =                          Get Eda Locator         eda_settings.pso_affl_edit
    ${pd_affl_edit} =                           Get Eda Locator         eda_settings.pd_affl_edit

    # Primary Academic Program
    Enable the checkbox                         Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${auto_enroll_academic_program}
    ...                                         ${checkbox_ap_affl}

    # Primary Business Organization
    Enable the checkbox                         Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${auto_enroll_business_organization}
    ...                                         ${pbo_affl_edit}

    # Primary Educational Institution
    Enable the checkbox                         Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${auto_enroll_educational_institution}
    ...                                         ${pei_affl_edit}

    # Primary Household
    Enable the checkbox                         Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${auto_enroll_household_account}
    ...                                         ${ph_affl_edit}

    # Primary Sports Organization
    Enable the checkbox                         Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${auto_enroll_sports_organization}
    ...                                         ${pso_affl_edit}

    # Primary Department
    Enable the checkbox                         Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${auto_enroll_university_department}
    ...                                         ${pd_affl_edit}

    Shift to default content
    Go To Object Home                           Account
    Close all tabs

All checkbox fields can retain unchecked values on save
    [tags]                                      unstable

    Current page should be                      Listing                 
    ...                                         hed__HEDA_Settings

    # Ensure you're on Affiliations > Settings
    Go to EDA settings    
    Go to affiliation settings

    ${affl_mappings_tab} =                      Get Eda Locator         eda_settings.affl_mappings_tab

    ${ap_aff_unchecked} =                       Get Eda Locator         eda_settings.ap_aff_unchecked
    ${checkbox_ap_affl} =                       Get Eda Locator         eda_settings.checkbox_ap_affl

    ${pbo_affl_unchecked} =                     Get Eda Locator         eda_settings.pbo_affl_unchecked
    ${pei_affl_unchecked} =                     Get Eda Locator         eda_settings.pei_affl_unchecked
    ${ph_affl_unchecked} =                      Get Eda Locator         eda_settings.ph_affl_unchecked
    ${pso_affl_unchecked} =                     Get Eda Locator         eda_settings.pso_affl_unchecked
    ${pd_affl_unchecked} =                      Get Eda Locator         eda_settings.pd_affl_unchecked

    ${pbo_affl_edit} =                          Get Eda Locator         eda_settings.pbo_affl_edit
    ${pei_affl_edit} =                          Get Eda Locator         eda_settings.pei_affl_edit
    ${ph_affl_edit} =                           Get Eda Locator         eda_settings.ph_affl_edit
    ${pso_affl_edit} =                          Get Eda Locator         eda_settings.pso_affl_edit
    ${pd_affl_edit} =                           Get Eda Locator         eda_settings.pd_affl_edit

    # Primary Academic Program
    Disable the checkbox                        Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${ap_aff_unchecked}
    ...                                         ${checkbox_ap_affl}

    # Primary Business Organization
    Disable the checkbox                        Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${pbo_affl_unchecked}
    ...                                         ${pbo_affl_edit}

    # Primary Educational Institution
    Disable the checkbox                        Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${pei_affl_unchecked}
    ...                                         ${pei_affl_edit}

    # Primary Household
    Disable the checkbox                        Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${ph_affl_unchecked}
    ...                                         ${ph_affl_edit}

    # Primary Sports Organization
    Disable the checkbox                        Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${pso_affl_unchecked}
    ...                                         ${pso_affl_edit}

    # Primary Department
    Disable the checkbox                        Auto-Enrollment
    ...                                         ${affl_mappings_tab}
    ...                                         ${pd_affl_unchecked}
    ...                                         ${pd_affl_edit}

    Shift to default content
    Go To Object Home                           Account
    Close all tabs

All mappings can be deleted
    [tags]                                      unstable

    Current page should be                      Listing                 
    ...                                         hed__HEDA_Settings

    # Ensure you're on Affiliations > Settings
    Go to EDA settings    
    Go to affiliation settings

    ${affl_mappings_tab} =                      Get Eda Locator         eda_settings.affl_mappings_tab

    # Edit the dropdowns - go into Edit mode
    Click button on location                    Edit                    ${affl_mappings_tab}

    Expand shadow root

    ${mappings_1} =                             Get Eda Locator         eda_settings.del_xpath_arm

    #Save settings
    Click button on location                    Save                    ${affl_mappings_tab}
    Close toast message
    Go To Object Home                           Account
    Close all tabs



*** Keywords ***

Initialize test setup
    Shift to default content
    Select App Launcher App                     EDA
    Close all tabs

Initialize test data
    [Documentation]                             Get the EDA namespace

    ${NAMESPACE} =                              Get EDA namespace prefix
    Set suite variable                          ${NAMESPACE}

