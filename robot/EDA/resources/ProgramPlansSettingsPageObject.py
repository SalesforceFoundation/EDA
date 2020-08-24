from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
import time

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

    def uncheck_nested_plan_requirements(self):
        """ Unchecking the `Validate Program Plan for Nested Plan Requirements` checkbox (false)
            Check for the value and if it is not false, go into edit mode and uncheck to make it
            false.
        """
        locator_read = eda_lex_locators["eda_settings_program_plans"]["checkbox_read"].format("Validate Program Plan for Nested Plan Requirements")
        locator_edit = eda_lex_locators["eda_settings_program_plans"]["checkbox_edit"].format("Validate Program Plan for Nested Plan Requirements")

        self.selenium.wait_until_page_contains_element(locator_read)
        actual_value = self.selenium.get_webelement(locator_read).get_attribute("alt")
        if not actual_value == "False":
            self.eda.click_action_button_on_eda_settings_page("Edit")
            self.selenium.wait_until_page_contains_element(
                locator_edit,
                error=f"Program plan for nested plan requirements checkbox is not available on the page. Locator:'{locator_edit}'")
            self.selenium.click_element(locator_edit)
            self.eda.click_action_button_on_eda_settings_page("Save")

    def update_nested_plan_requirements_checkbox(self):
        """ Set the checkbox for 'Nested plan requirements' field """
        locator_edit = eda_lex_locators["eda_settings_program_plans"]["checkbox_edit"].format("Validate Program Plan for Nested Plan Requirements")
        locator_enabled = eda_lex_locators["eda_settings_program_plans"]["updated_checkbox_edit"].format("Validate Program Plan for Nested Plan Requirements")
        self.selenium.wait_until_page_contains_element(locator_edit)

        for i in range(3):
            i += 1
            self.salesforce._jsclick(locator_edit)
            time.sleep(1) # This is needed as the DOM elements needs to be updated in edit mode
            actual_value = self.selenium.get_element_attribute(locator_enabled, "data-qa-checkbox-state")
            if actual_value == "true":
                return
        raise Exception("Clicking element 'Nested plan requirements' failed after multiple tries")

    def verify_nested_plan_requirements_checkbox(self, expectedCheckboxValue):
        """ This method will verify the 'Validate Program Plan for Nested Plan Requirements'
            checkbox is set to the value passed in the arg
        """
        locator_read = eda_lex_locators["eda_settings_program_plans"]["checkbox_read"].format("Validate Program Plan for Nested Plan Requirements")
        self.selenium.wait_until_page_contains_element(locator_read)
        self.selenium.wait_until_element_is_visible(locator_read)
        actual_value = self.selenium.get_element_attribute(locator_read, "alt")
        if not str(expectedCheckboxValue).lower() == str(actual_value).lower():
            raise Exception(f"Value of 'Validate Program Plan for Nested Plan Requirements' is not '{expectedCheckboxValue}' as expected")
