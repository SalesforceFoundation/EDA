from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
from locators import eda_lex_locators


@pageobject("System", "HEDA_Settings")
class SystemSettingsPage(BasePage):

    @property
    def eda(self):
        return self.builtin.get_library_instance('EDA')

    def _is_current_page(self):
        """
            Verify we are on the EDA Settings page for System
            by verifying the HEDA Settings URL and the System tab
        """
        location = "/lightning/n/{}{}".format(self.eda.get_eda_namespace_prefix(), self._object_name)
        self.selenium.location_should_contain(location)

        locator_tab = eda_lex_locators["eda_settings"]["tab"].format("System")
        self.selenium.wait_until_page_contains_element(
            locator_tab,
            error=f"System tab with locator '{locator_tab}' is not available on the page"
        )
