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

Resource        robot/EDA/resources/EDA.robot
Library         cumulusci.robotframework.PageObjects
...             robot/EDA/resources/AffiliationsSettingsPageObject.py

Suite Setup     Open test browser
Suite Teardown  Capture screenshot and delete records and close browser

*** Test Cases ***
All standard field values
    [Documentation]     Verifies the default values of affiliations mappings sub tab
    [tags]                                      unstable

    Go to EDA settings tab                      Affiliations
    Go to affiliations sub tab                  Affiliation Mappings

    # Verify that we have the correct defaults
    Process default mapping values

All text fields retain null value on save
    [Documentation]     Verifies the text fields in affiliation mappins sub tab are null/clear
    ...                 after clearing and saving
    [tags]                                      unstable

    Go to EDA settings tab                      Affiliations
    Go to affiliations sub tab                  Affiliation Mappings

    ${affl_mappings_tab} =                      Get Eda Locator
    ...                                         eda_settings.affl_mappings_tab

    # Edit the dropdowns - go into Edit mode
    Click button on location                    Edit                    ${affl_mappings_tab}

    Clear everything on affiliation mappings

    #Save settings
    Click button on location                    Save                    ${affl_mappings_tab}
    Close toast message

All text fields retain text value on save
    [Documentation]     Verifies the values entered in text fields of affiliations mapping sub tab
    ...                 are retained after save.
    [tags]                                      unstable

    Go to EDA settings tab                      Affiliations
    Go to affiliations sub tab                  Settings

    ${affl_mappings_tab} =                      Get Eda Locator
    ...                                         eda_settings.affl_mappings_tab

    # Edit the dropdowns - go into Edit mode
    Click button on location                    Edit                    ${affl_mappings_tab}
    Add text to all text fields

    #Save settings
    Click button on location                    Save                    ${affl_mappings_tab}
    Close toast message

All checkbox fields can retain checked value on save
    [Documentation]     Verifies the checkbox fields retain the updated value (checked) after save
    [tags]                                      unstable

    Go to EDA settings tab                      Affiliations
    Go to affiliations sub tab                  Settings

    ${affl_mappings_tab} =                      Get Eda Locator
    ...                                         eda_settings.affl_mappings_tab
    ${auto_enroll_academic_program} =           Get Eda Locator
    ...                                         affiliations_locators.auto_enroll_academic_program
    ${checkbox_ap_affl} =                       Get Eda Locator
    ...                                         eda_settings.checkbox_ap_affl

    ${auto_enroll_business_organization} =      Get Eda Locator
    ...                                         eda_settings.auto_enroll_business_organization
    ${auto_enroll_educational_institution} =    Get Eda Locator
    ...                                         eda_settings.auto_enroll_educational_institution
    ${auto_enroll_household_account} =          Get Eda Locator
    ...                                         eda_settings.auto_enroll_household_account
    ${auto_enroll_sports_organization} =        Get Eda Locator
    ...                                         eda_settings.auto_enroll_sports_organization
    ${auto_enroll_university_department} =      Get Eda Locator
    ...                                         eda_settings.auto_enroll_university_department

    ${pbo_affl_edit} =                          Get Eda Locator
    ...                         eda_settings.primary_affl_edit      Primary Business Organization
    ${pei_affl_edit} =                          Get Eda Locator
    ...                         eda_settings.primary_affl_edit      Primary Educational Institution
    ${ph_affl_edit} =                           Get Eda Locator
    ...                         eda_settings.primary_affl_edit      Primary Household
    ${pso_affl_edit} =                          Get Eda Locator
    ...                         eda_settings.primary_affl_edit      Primary Sports Organization
    ${pd_affl_edit} =                           Get Eda Locator
    ...                         eda_settings.primary_affl_edit      Primary Department

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

All checkbox fields can retain unchecked values on save
    [Documentation]     Verifies the checkbox fields retain the updated value (unchecked)
    ...                 after save.
    [tags]                                      unstable

    Go to EDA settings tab                      Affiliations
    Go to affiliations sub tab                  Settings

    ${affl_mappings_tab} =                      Get Eda Locator
    ...                                         eda_settings.affl_mappings_tab

    ${ap_aff_unchecked} =                       Get Eda Locator
    ...                             eda_settings.primary_affl_unchecked     Primary Academic Program
    ${checkbox_ap_affl} =                       Get Eda Locator
    ...                                         eda_settings.checkbox_ap_affl

    ${pbo_affl_unchecked} =                     Get Eda Locator
    ...                     eda_settings.primary_affl_unchecked     Primary Business Organization
    ${pei_affl_unchecked} =                     Get Eda Locator
    ...                     eda_settings.primary_affl_unchecked     Primary Educational Institution
    ${ph_affl_unchecked} =                      Get Eda Locator
    ...                     eda_settings.primary_affl_unchecked     Primary Household
    ${pso_affl_unchecked} =                     Get Eda Locator
    ...                     eda_settings.primary_affl_unchecked     Primary Sports Organization
    ${pd_affl_unchecked} =                      Get Eda Locator
    ...                     eda_settings.primary_affl_unchecked     Primary Department

    ${pbo_affl_edit} =                          Get Eda Locator
    ...                     eda_settings.primary_affl_edit      Primary Business Organization
    ${pei_affl_edit} =                          Get Eda Locator
    ...                     eda_settings.primary_affl_edit      Primary Educational Institution
    ${ph_affl_edit} =                           Get Eda Locator
    ...                     eda_settings.primary_affl_edit      Primary Household
    ${pso_affl_edit} =                          Get Eda Locator
    ...                     eda_settings.primary_affl_edit      Primary Sports Organization
    ${pd_affl_edit} =                           Get Eda Locator
    ...                     eda_settings.primary_affl_edit      Primary Department

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
