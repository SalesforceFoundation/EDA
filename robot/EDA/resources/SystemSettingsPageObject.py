from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
import time


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

    def verify_admin_toast_message(self, value):
        """ Verifies the admin  toast message """
        locator = eda_lex_locators["eda_settings_system"]["admin_success_toast"]
        time.sleep(0.5) # This wait is needed for the toast message validation
        self.selenium.wait_until_page_contains_element(locator)
        actual_value = self.selenium.get_webelement(locator).text
        self.builtin.log("Toast message :" + actual_value)
        if not str(value).lower() == str(actual_value).lower() :
                raise Exception (f"Expected {value} but it displayed {actual_value}")

    def verify_household_toast_message(self, value):
        """ Verifies the household specific toast message """
        locator = eda_lex_locators["eda_settings_system"]["hh_success_toast"]
        time.sleep(0.5) # This wait is needed for the toast message validation
        self.selenium.wait_until_page_contains_element(locator)
        actual_value = self.selenium.get_webelement(locator).text
        self.builtin.log("Toast message :" + actual_value)
        if not str(value).lower() == str(actual_value).lower() :
                raise Exception (f"Expected {value} but it displayed {actual_value}")
