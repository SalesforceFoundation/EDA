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

    def enter_account_name_format(self,**kwargs):
        """ This method will enter the account name format after selecting other in the drop down
            Pass the expected value to be set in the input field as arguments
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_system"]["other_accname_format"].format(field)
            self.selenium.wait_until_page_contains_element(locator,
                                                error=f"'{field}' field is not available ")
            self.selenium.clear_element_text(locator)
            self.selenium.get_webelement(locator).send_keys(value)

    def select_recipient_type_value(self,**kwargs):
        """ This method will select the drop down field value passed in keyword arguments
            Pass the expected value to be selected in the drop down field from the tests
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_system"]["recipient_type_value"].format(field,value)
            self.selenium.wait_until_page_contains_element(locator,
                                                error=f"'{value}' as dropdown value in '{field}' field is not available ")
            self.selenium.click_element(locator)

    def select_recipient(self,**kwargs):
        """ This method will select the lookup result for the recipient notification
            Pass the expected value to be selected as arguments
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_system"]["recipient_name"].format(field)
            self.selenium.wait_until_page_contains_element(locator,
                                                error=f"'{field}' field is not available ")
            self.selenium.clear_element_text(locator)
            self.selenium.get_webelement(locator).send_keys(value)
            time.sleep(0.5)
            locator_lookup = eda_lex_locators["eda_settings_system"]["recipient_lookup"].format(value)
            self.selenium.wait_until_page_contains_element(locator_lookup,
                                                error=f"'{locator_lookup}'  is not available ")
            self.selenium.click_element(locator_lookup)

    def verify_admin_toast_message(self, value):
        """ Verifies the admin  toast message """
        locator = eda_lex_locators["eda_settings_system"]["admin_success_toast"]
        time.sleep(0.5) # This wait is needed for the toast message validation
        self.selenium.wait_until_page_contains_element(locator, timeout=60)
        actual_value = self.selenium.get_webelement(locator).text
        self.builtin.log("Toast message :" + actual_value)
        if not str(value).lower() == str(actual_value).lower() :
                raise Exception (f"Expected {value} but it displayed {actual_value}")

    def verify_household_toast_message(self, value):
        """ Verifies the household specific toast message """
        locator = eda_lex_locators["eda_settings_system"]["hh_success_toast"]
        time.sleep(0.5) # This wait is needed for the toast message validation
        self.selenium.wait_until_page_contains_element(locator, timeout=60)
        actual_value = self.selenium.get_webelement(locator).text
        self.builtin.log("Toast message :" + actual_value)
        if not str(value).lower() == str(actual_value).lower() :
                raise Exception (f"Expected {value} but it displayed {actual_value}")

    def verify_system_dropdown_value(self,**kwargs):
        """ This method validates the dropdown value for the field passed in kwargs
            Pass the field name and expected value to be verified from the tests using
            keyword arguments
        """
        for field,expected_value in kwargs.items():
            locator = eda_lex_locators["eda_settings_system"]["other_dropdown_value"].format(field,expected_value)
            self.selenium.page_should_contain_element(locator)
            self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
            actual_value = self.selenium.get_webelement(locator).text
            if not str(expected_value).lower() == str(actual_value).lower() :
                raise Exception (f"Dropdown value in {field} is {actual_value} but it should be {expected_value}")
