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

    def verify_last_run_date(self):
        """ This method will verify 'Last Run' field on Settings Health Check page has a date in it
            and the date is equal to todays date(system date).
        """
        locator = eda_lex_locators["settings_health_check"]["last_run_date"]
        self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{locator} is not available')
        self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
        actual_value = self.selenium.get_webelement(locator).text
        last_run_date = actual_value.split(" ")
        todays_date = date.today().strftime('%-m/%-d/%Y')
        self.builtin.log(todays_date)
        if not todays_date in last_run_date:
            raise Exception(f"Value of {todays_date} is not present in {last_run_date} and so the dates are not matching as expected")


