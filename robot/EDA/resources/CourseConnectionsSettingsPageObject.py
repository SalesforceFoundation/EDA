from BaseObjects import BaseEDAPage

from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
from locators import eda_lex_locators


@pageobject("Course_Connections", "HEDA_Settings")
class CourseConnectionsSettingsPage(BaseEDAPage, BasePage):

    def _is_current_page(self):
        """
            Verify we are on the EDA Settings page for Course Connections
            by verifying the HEDA Settings URL and the Course Connections tab
        """
        location = "/lightning/n/{}{}".format(self.eda.get_eda_namespace_prefix(), self._object_name)
        self.selenium.location_should_contain(location)

        locator_tab = eda_lex_locators["eda_settings"]["tab"].format("Course Connections")
        self.selenium.wait_until_page_contains_element(
            locator_tab,
            error=f"Course Connections tab with locator '{locator_tab}' is not available on the page"
        )

    def set_enable_course_connections(self):
        """ Set the checkbox for 'Enable Course Connections' field """
        locator = eda_lex_locators["eda_settings"]["enable_checkbox"].format("Enable Course Connections")
        self.selenium.wait_until_page_contains_element(locator)
        self.selenium.click_element(locator)

    def update_enable_cc_to_default(self):
        """ Updating the `Enable Course Connections` checkbox to default value (false)
            Check for the value and if it is not false, go into edit mode and update
        """
        locator_default = eda_lex_locators["eda_settings"]["default_checkbox"].format("Enable Course Connections")
        locator_edit_mode = eda_lex_locators["eda_settings"]["enable_checkbox"].format("Enable Course Connections")

        actual_value = self.selenium.get_webelement(locator_default).get_attribute("alt")
        if not actual_value == "False":
            self.eda.click_edit_on_eda_settings_page()
            self.selenium.wait_until_page_contains_element(
                locator_edit_mode,
                error=f"Enable course connections checkbox is not available on the page. Locator:'{locator_edit_mode}'")
            self.selenium.click_element(locator_edit_mode)
            self.eda.click_action_button_on_eda_settings_page("Save")

    def verify_dropdown_values(self, field, *args):
        """ Verify the field has the drop down values given by *args
            we have to pass all the values available in the UI since the count is also verified
        """
        locator = eda_lex_locators["eda_settings_cc"]["dropdown_values"]
        locator_count = eda_lex_locators["eda_settings_cc"]["dropdown_values_count"].format(field)
        actual_count = int(self.selenium.get_element_count(locator_count))
        expected_count = args.__len__()
        if expected_count == actual_count:
            for value in args:
                locator = locator.format(field, value)
                self.selenium.page_should_contain_element(locator, message=f"'{field}' does not contain the value '{value}'")
        else:
            raise Exception(f"Mismatch in count of drop down values. Actual = '{actual_count}'. Expected = '{expected_count}'")

    def verify_enable_course_connections_warning(self, is_displayed):
        """ Verify the warning message is displayed
            this message gets displayed when the 'Enable Course Connections' field is unchecked
        """
        locator_enabled = eda_lex_locators["eda_settings_cc"]["enable_cc_warning_enabled"]
        locator_disabled = eda_lex_locators["eda_settings_cc"]["enable_cc_warning_disabled"]
        if str(is_displayed).lower() == "true":
            self.selenium.wait_until_page_contains_element(locator_enabled,
                                                           error="Enable course connections warning is not displayed")
        else:
            self.selenium.wait_until_page_contains_element(
                locator_disabled, error="Enable course connections warning is displayed")
