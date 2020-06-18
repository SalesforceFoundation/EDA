from BaseObjects import BaseEDAPage
from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
from locators import eda_lex_locators


@pageobject("Program_Plans", "HEDA_Settings")
class ProgramPlansSettingsPage(BaseEDAPage, BasePage):

    def _is_current_page(self):
        """
            Verify we are on the EDA Settings page for Program Plans
            by verifying the HEDA Settings URL and the Program Plans tab
        """
        location = "/lightning/n/{}{}".format(self.eda.get_eda_namespace_prefix(), self._object_name)
        self.selenium.location_should_contain(location)

        locator_tab = eda_lex_locators["eda_settings"]["tab"].format("Program Plans")
        self.selenium.wait_until_page_contains_element(
            locator_tab,
            error=f"Program Plans tab with locator '{locator_tab}' is not available on the page"
        )
