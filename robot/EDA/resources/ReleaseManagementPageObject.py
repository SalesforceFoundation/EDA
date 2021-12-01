from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import HomePage
from cumulusci.robotframework.pageobjects import pageobject
import time
from datetime import date


@pageobject("Home", "Release Management")
class ReleaseManagementPage(BaseEDAPage, HomePage):

    def _is_current_page(self):
        """ Verify we are on the Release Management page
            by verifying Release Management page header
        """
        locator = eda_lex_locators["release_management"]["page_title"].format("releaseManagementTitle")
        self.selenium.wait_until_page_contains_element(
            locator,
            error="Release management header is not available"
        )