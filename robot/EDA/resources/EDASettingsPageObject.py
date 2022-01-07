from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import HomePage
from cumulusci.robotframework.pageobjects import pageobject
import time
from datetime import date


@pageobject("Home", "EDA Settings")
class EDASettingsPage(BaseEDAPage, HomePage):

    def _is_current_page(self):
        """ Verify we are on the EDA Settings page
        """
        locator = eda_lex_locators["eda_settings_page"]["page_title"].format("EDA Settings")
        self.selenium.wait_until_page_contains_element(
            locator,
            error="EDA Settings header is not available"
        )