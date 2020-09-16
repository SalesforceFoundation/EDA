from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject


@pageobject("System", "HEDA_Settings")
class SystemSettingsPage(BaseEDAPage, BasePage):

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

    def update_system_dropdown_value(self,**kwargs):
        """ This method will update the drop down field value passed in keyword arguments
            Pass the expected value to be set in the drop down field from the tests
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_relationships"]["dropdown_value"].format(field,value)
            self.selenium.wait_until_page_contains_element(locator,
                                                error=f"'{value}' as dropdown value in '{field}' field is not available ")
            self.selenium.click_element(locator)
