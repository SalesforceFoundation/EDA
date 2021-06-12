from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import HomePage
from cumulusci.robotframework.pageobjects import pageobject
import time
from datetime import date


@pageobject("Home", "Settings Health Check")
class SettingsHealthCheckPage(BaseEDAPage, HomePage):

    def _is_current_page(self):
        """ Verify we are on the Settings Health Check page
            by verifying Settings Health Check page header
        """
        locator = eda_lex_locators["settings_health_check"]["health_check_header"].format("Settings Health Check")
        self.selenium.wait_until_page_contains_element(
            locator,
            error="Settings Health Check header is not available"
        )

    def click_health_check_button(self,text):
        """ This method clicks the 'Run Health Check' button on Settings Health Check page.
        """
        locator = eda_lex_locators["settings_health_check"]["run_health_check_button"].format(text)
        self.selenium.wait_until_page_contains_element(
            locator, timeout=60, error=f"Run Health Check button with locator '{locator}' is not available")
        self.selenium.click_element(locator)

    def click_expand_button(self, settingName):
        """ This method will click the expand button on tree grids on settings health check page
            Pass the name of health check category from your test ex - AccountModel, Affiliation
            Mappings, ReciprocalRelationships and CourseConnections
        """
        locator = eda_lex_locators["settings_health_check"]["expand_button"].format(settingName)
        self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f"Expand button is not displayed to the user")
        self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
        self.selenium.click_element(locator)

    def verify_last_run_date(self):
        """ This method will verify 'Last Run' field on Settings Health Check page has a date in it
            and the date is equal to todays date(system date).
        """
        locator = eda_lex_locators["settings_health_check"]["last_run_date"]
        self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{locator} is not available')
        self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
        time.sleep(0.25) #to give enough time for the system to update date
        actual_value = self.selenium.get_webelement(locator).text
        last_run_date = actual_value.split(" ")
        todays_date = date.today().strftime('%-m/%-d/%Y')
        self.builtin.log(todays_date)
        if not todays_date in last_run_date:
            raise Exception(f"Value of {todays_date} is not present in {last_run_date} and so the dates are not matching as expected")

    def verify_status_of_a_setting(self,healthCheckCard,**kwargs):
        """ This method validates the status of a setting for the setting passed in kwargs
            Pass the health check card, setting name and the expected status to be verified from the
            tests using keyword arguments
        """
        for field,expected_value in kwargs.items():
            locator = eda_lex_locators["settings_health_check"]["status_value"].format(healthCheckCard,field)
            self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{locator} is not available')
            self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
            actual_value = self.selenium.get_webelement(locator).text
            self.builtin.log(f"Actual value of {field} is {actual_value}")
            if not str(expected_value).lower() == str(actual_value).lower() :
                raise Exception (f"Status of {field} is {actual_value} but it should be {expected_value}")

    def return_all_checks_status(self,healthCheckCard,expected_value):
        """ This method will verify the status of of all checks before clicking on expand all
            button to verify status of each setting. Pass the name of the health check card and
            the expected text from robot. Returns true if all settings are passed and false if any
            one of the setting is failed
        """
        locator = eda_lex_locators["settings_health_check"]["all_checks_status"].format(healthCheckCard)
        self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{locator} is not available')
        self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
        actual_value = self.selenium.get_webelement(locator).text
        return True if str(actual_value).lower() == str(expected_value).lower() else False

    def verify_recommended_fix(self,healthCheckCard,**kwargs):
        """ This method validates the status of a setting for the setting passed in kwargs
            Pass the health check card, setting name and the expected status to be verified from the
            tests using keyword arguments
        """
        for field,expected_value in kwargs.items():
            locator = eda_lex_locators["settings_health_check"]["recommended_fix_value"].format(healthCheckCard,field)
            self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{locator} is not available')
            self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
            actual_value = self.selenium.get_webelement(locator).text
            self.builtin.log(f"Actual value of {field} is {actual_value}")
            if not str(expected_value).lower() in str(actual_value).lower() :
                raise Exception (f"Expected text :{expected_value} in recommended fix message is not found in {actual_value}")



