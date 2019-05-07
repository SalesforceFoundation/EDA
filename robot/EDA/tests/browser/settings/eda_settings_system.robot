*** Settings ***

Resource        robot/EDA/resources/EDA.robot
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser

*** Test Cases ***

Test EDA System Settings
    Go To Eda Settings
    Wait For Locator                    eda_settings.system_tab
    Click On Element                    eda_settings.system_tab

    # Default Account Model
    Element Should be Visible           //span[contains(@class,'default-account-model-record-type-output-text')]
