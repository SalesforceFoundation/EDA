from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
from cumulusci.robotframework.utils import selenium_retry, capture_screenshot_on_error
from selenium.webdriver.common.keys import Keys
import time


@pageobject("Relationships", "HEDA_Settings")
class RelationshipsSettingsPage(BaseEDAPage, BasePage):

    def _is_current_page(self):
        """
            Verify we are on the EDA Settings page for Relationships
            by verifying the HEDA Settings URL and the Relationships tab
        """
        location = "/lightning/n/{}{}".format(self.eda.get_eda_namespace_prefix(), self._object_name)
        self.selenium.location_should_contain(location)

        locator_tab = eda_lex_locators["eda_settings"]["tab"].format("Relationships")
        self.selenium.wait_until_page_contains_element(
            locator_tab,
            error=f"Relationships tab with locator '{locator_tab}' is not available on the page"
        )

    @capture_screenshot_on_error
    def click_delete_setting_icon(self,**kwargs):
        """ This method will click the delete icon in edit mode
            Pass the name of the field to be deleted as keyword arguments from robot file
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_relationships"]["delete_setting_icon"].format(field,value)
            self.selenium.wait_until_page_contains_element(locator)
            self.selenium.wait_until_element_is_visible(locator)
            self.selenium.double_click_element(locator)
            time.sleep(1) #This wait is needed for handle alert keyword

    def go_to_relationships_sub_tab(self, sub_tab):
        """ Click on the given sub_tab in the Affiliations Settings page """
        locator = eda_lex_locators["relationships_settings_locators"]["sub_tab"].format(sub_tab)
        self.selenium.wait_until_page_contains_element(locator,
                                                       error=f"'{sub_tab}' sub tab is not available on the page")
        self.selenium.click_element(locator)

    def enter_new_reciprocal_setting(self,**kwargs):
        """ This method will enter the new reciprocal settings
            Pass the expected value to be entered along with field name as keyword arguments
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_relationships"]["new_reciprocal_setting"].format(field)
            self.selenium.wait_until_page_contains_element(locator,
                                                error=f"'{field}' field is not available ")
            self.selenium.clear_element_text(locator)
            self.selenium.get_webelement(locator).send_keys(value)

    def get_total_settings_count(self):
        """ This method will return the number of rows in the reciprocal settings"""
        locator = eda_lex_locators["eda_settings_relationships"]["settings_count"]
        self.selenium.wait_until_page_contains_element(locator, error="Reciprocal settings table is not available")
        for i in range(3):
                i += 1
                actual_count = int(self.selenium.get_element_count(locator))
                if actual_count > 0 :
                    break
        return actual_count

    def update_reciprocal_method_value(self,**kwargs):
        """ This method will update the drop down field value passed in keyword arguments
            Pass the expected value to be set in the drop down field from the tests
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_relationships"]["dropdown_read"].format(field)
            text = self.selenium.get_webelement(locator).text
            if not str(text).lower() == str(value).lower():
                self.eda.click_action_button_on_eda_settings_page("Edit")
                locator_edit = eda_lex_locators["eda_settings_relationships"]["dropdown_value"].format(field,value)
                self.selenium.wait_until_page_contains_element(locator_edit,
                                                error=f"'{locator_edit}' is not available ")
                self.selenium.click_element(locator_edit)
                self.eda.click_action_button_on_eda_settings_page("Save")

    def set_reciprocal_setting_status(self,**kwargs):
        """ This method will set the active checkbox status to active/inactive
            Pass the expected value to be set in the checkbox field from the tests
            true - checked, false - unchecked
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_relationships"]["active_checkbox"].format(field)
            self.selenium.wait_until_page_contains_element(locator)
            self.selenium.wait_until_element_is_visible(locator)
            if str(value).lower() == "true":
                self.salesforce._jsclick(locator)

    def update_existing_reciprocal_setting(self,column,**kwargs):
        """ This method will update the existing reciprocal settings
            Pass the expected value to be updated along with field name as keyword arguments
        """
        for field,value in kwargs.items():
            if str(field).lower() == "name":
                locator = eda_lex_locators["eda_settings_relationships"]["updtate_setting_name"].format(field,str(field).lower())
                self.selenium.page_should_contain_element(locator)
                self.selenium.clear_element_text(locator)
                locator = eda_lex_locators["eda_settings_relationships"]["update_setting_name_cleared"]
                self.selenium.get_webelement(locator).send_keys(value + Keys.TAB)
            else:
                time.sleep(5)
                locator = eda_lex_locators["eda_settings_relationships"]["update_setting_rest"].format(column,str(field).lower())
                self.selenium.page_should_contain_element(locator)
                self.selenium.clear_element_text(locator)
                self.selenium.get_webelement(locator).send_keys(value + Keys.TAB)

    def verify_new_setting_checkbox_status(self, **kwargs):
        """ Checks the expected status (True or False) of the checkbox for newly added setting
            Pass the expected value and field name from the tests
            true - checked, false - unchecked
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_relationships"]["new_setting_checkbox"].format(str(field).lower())
            actual_status = self.selenium.get_element_attribute(locator, "alt")
            if str(value).lower() != str(actual_status).lower():
                raise Exception(f"{field} checkbox value expected to be {value}, but actual is {actual_status}")

    def verify_new_setting_checkbox_status_edit_mode(self, **kwargs):
        """ Checks the expected status (True or False) of the checkbox for newly added in edit mode
            Pass the expected value and field name from the tests
            true - checked, false - unchecked
        """
        for field,value in kwargs.items():
            self.selenium.execute_javascript("window.scrollTo(0, document.body.scrollHeight)")
            time.sleep(5)
            locator = eda_lex_locators["eda_settings_relationships"]["new_setting_checkbox_edit"].format(str(field).lower())
            self.selenium.page_should_contain_element(locator)
            for i in range(5):
                i += 1
                time.sleep(5)
                actual_status = self.selenium.get_element_attribute(locator,"data-qa-checkbox-state")
                self.builtin.log(locator)
                self.builtin.log(actual_status)
                if str(actual_status).lower() == str(value).lower() or str(actual_status).lower() == "":
                    self.builtin.log("The checkbox value in edit mode is" + actual_status)
                    break
                raise Exception("Verifying 'Active checkbox' failed after multiple tries")


    def verify_new_reciprocal_setting(self,**kwargs):
        """ This method will validate the new reciprocal setting added recently which is always in
            in last row. Pass the name of the reciprocal relationship and its value as keyword args
            and this method will assign constant numeric value against each setting and validates
            the corresponding value
        """
        for field,value in kwargs.items():
            if str(field).lower() == "name":
                locator = eda_lex_locators["eda_settings_relationships"]["new_settings"].format(5,str(field).lower(),value)
                self.selenium.page_should_contain_element(locator)
            elif str(field).lower() == "female":
                locator = eda_lex_locators["eda_settings_relationships"]["new_settings"].format(4,str(field).lower(),value)
                self.selenium.page_should_contain_element(locator)
            elif str(field).lower() == "male":
                locator = eda_lex_locators["eda_settings_relationships"]["new_settings"].format(3,str(field).lower(),value)
                self.selenium.page_should_contain_element(locator)
            else:
                locator = eda_lex_locators["eda_settings_relationships"]["new_settings"].format(2,str(field).lower(),value)
                self.selenium.page_should_contain_element(locator)

    def verify_reciprocal_setting_edit_mode(self,**kwargs):
        """ This method will validate the new reciprocal setting added recently which is always in
            in last row in edit mdoe. Pass the name of the reciprocal relationship and its value as
            keyword args and this method will assign constant numeric value against each setting
            and validates the corresponding value
        """
        for field,value in kwargs.items():
            if str(field).lower() == "name":
                locator = eda_lex_locators["eda_settings_relationships"]["new_setting_edit"].format(5,str(field).lower(),field,value)
                self.selenium.page_should_contain_element(locator)
            elif str(field).lower() == "female":
                locator = eda_lex_locators["eda_settings_relationships"]["new_setting_edit"].format(4,str(field).lower(),field,value)
                self.selenium.page_should_contain_element(locator)
            elif str(field).lower() == "male":
                locator = eda_lex_locators["eda_settings_relationships"]["new_setting_edit"].format(3,str(field).lower(),field,value)
                self.selenium.page_should_contain_element(locator)
            else:
                locator = eda_lex_locators["eda_settings_relationships"]["new_setting_edit"].format(2,str(field).lower(),field,value)
                self.selenium.page_should_contain_element(locator)

    def verify_settings_count(self, settings_count, actual_count, expected):
        """ This method will compare the reciprocal relationship settings count. It accepts initial
            count, updated count and expected status as arguments
        """
        if str(expected).lower() == "true":
            no_of_records = actual_count - settings_count
            self.builtin.log(no_of_records)
            if no_of_records > 0:
                return int(actual_count)
            else:
                raise Exception("The reciprocal settings are not updated")
        else:
            if actual_count == settings_count:
                no_of_records = actual_count - settings_count
                self.builtin.log(no_of_records)
                return int(actual_count)
            else:
                raise Exception("The reciprocal settings are updated")

    def verify_setting_deleted(self,expectedStatus, **kwargs):

        """ This method will verify the setting is deleted or not based on the expected status sent
            Pass the name of the field and its value as keyword arguments and expected status
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_relationships"]["delete_setting_icon"].format(field,value)
            if str(expectedStatus).lower() == "true":
                self.selenium.page_should_not_contain_element(locator)
            else:
                self.selenium.page_should_contain_element(locator)

    def verify_setting_removed(self,**kwargs):
        """ This method will verify the setting is removed or not based on the expected status sent
            in read mode. Pass the name of the field and its value as keyword arguments and
            expected status
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_relationships"]["removed_setting"].format(str(field).lower(),value)
            self.selenium.page_should_not_contain_element(locator)

    def verify_updated_reciprocal_setting(self,column,**kwargs):
        """ This method will verify the updated reciprocal settings
            Pass the expected value to be verified along with field name as keyword arguments
        """
        for field,value in kwargs.items():
            if str(field).lower() == "name":
                locator = eda_lex_locators["eda_settings_relationships"]["removed_setting"].format(str(field).lower(),value)
                self.selenium.page_should_contain_element(locator)
            else:
                locator = eda_lex_locators["eda_settings_relationships"]["updated_setting"].format(column,str(field).lower(),value)
                self.selenium.page_should_contain_element(locator)

