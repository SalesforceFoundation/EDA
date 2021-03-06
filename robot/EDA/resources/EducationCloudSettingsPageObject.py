from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import HomePage
from cumulusci.robotframework.pageobjects import pageobject
import time
from datetime import date


@pageobject("Home", "Education Cloud Settings")
class EducationCloudSettingsPage(BaseEDAPage, HomePage):

    def _is_current_page(self):
        """ Verify we are on the Settings Health Check page
            by verifying Settings Health Check page header
        """
        locator = eda_lex_locators["eda_settings_new"]["edc_header"].format("Education Data Architecture")
        self.selenium.wait_until_page_contains_element(
            locator,
            error="EDC header is not available"
        )

    def verify_app_tiles_displayed(self,**kwargs):
        """ This method verifies the app tiles are displayed in the Education Cloud Settings home
            page.
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_new"]["app_tile"].format(field,value)
            self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{locator} is not available')
            self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")

    def click_app_in_edc_home(self,value):
        """ This method will click on the button in a tile to launch a particular app by accepting
            the name of the button as its parameter
        """
        locator = eda_lex_locators["eda_settings_new"]["global_action"].format(value)
        self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{locator} is not available')
        self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
        self.selenium.click_element(locator)