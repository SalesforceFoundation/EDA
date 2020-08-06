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

    def verify_default_checkbox_value(self,**kwargs):
        """ This method validates the default checkbox value for the field passed in kwargs
            Pass the field name and expected value to be verified from the tests using 
            keyword arguments
        """
        for field,expected_value in kwargs.items():
            locator = eda_lex_locators["eda_settings_system"]["default_checkbox"].format(field)
            self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
            actual_value = self.selenium.get_element_attribute(locator, "alt")
            if not str(expected_value).lower() == str(actual_value).lower() :
                raise Exception (f"Checkbox value in {field} is {actual_value} but it should be {expected_value}")

    def verify_default_dropdown_value(self,**kwargs):
        """ This method validates the default dropdown value for the field passed in kwargs
            Pass the field name and expected value to be verified from the tests using 
            keyword arguments
        """
        for field,expected_value in kwargs.items():
            locator = eda_lex_locators["eda_settings_system"]["default_dropdown_value"].format(field,expected_value)
            self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
            actual_value = self.selenium.get_webelement(locator).text
            if not str(expected_value).lower() == str(actual_value).lower() :
                raise Exception (f"Dropdown value in {field} is {actual_value} but it should be {expected_value}")
