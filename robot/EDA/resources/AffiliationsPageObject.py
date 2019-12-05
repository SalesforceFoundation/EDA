import datetime
import logging
import time
import pytz

from cumulusci.robotframework.pageobjects import ListingPage
from cumulusci.robotframework.pageobjects import pageobject
from locators import affiliations_locators
from locators import eda_lex_locators
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

@pageobject("Listing", "hed__HEDA_Settings")
class EDASettingsPage(ListingPage):
    object_name = "hed__HEDA_Settings"

    @property
    def eda(self):
        return self.builtin.get_library_instance('EDA')

    @property
    def pageobjects(self):
        return self.builtin.get_library_instance("cumulusci.robotframework.PageObjects")

    def _is_current_page(self):
        """ Verify we are on the EDA Settings page
            by verifying that the header title is 'EDA Settings'
        """
        locator = affiliations_locators["header"]
        self.selenium.page_should_contain_element(
            locator,
            message="Header with text 'EDA Settings' is not available on the page"
        )

    def _go_to_page(self, filter_name=None):
        url_pattern = "{root}/lightning/n/{object}"
        name = self._object_name
        object_name = "{}{}".format(self.cumulusci.get_namespace_prefix(), name)
        url = url_pattern.format(root=self.cumulusci.org.lightning_base_url, object=object_name)
        self.selenium.go_to(url)
        self.salesforce.wait_until_loading_is_complete()
        self.eda.wait_for_locator("frame", "accessibility title")
        self.salesforce.select_frame_with_title("accessibility title")


    def _check_if_element_exists(self, xpath):
        """ Checks if the given xpath exists """
        elements = int(self.selenium.get_matching_xpath_count(xpath))
        return True if elements > 0 else False

    def verify_timezone(self):
        """ Verify that a timezone value exists
            there is currently an open bug on this,
            once fixed, the keyword needs to be modified to check for a specific timezone
        """
        self.selenium.page_should_contain_element(affiliations_locators["timezone"])
        self.builtin.log("Actual timezone isn't checked; waiting for bug to be fixed", "WARN")

    def verify_toast_message(self, value):
        """ Verifies the toast message """
        self.selenium.wait_until_page_contains_element(affiliations_locators["toast_message"].format(value))

    def place_in_view(self,locator):
        """ Scroll the field or object into the current view 
            Examples:
            | =Function= | =argument= |
            | place_in_view | any locator |
            | self.place_in_view(affiliations_locators["header"]) | |
        """        
        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(locator)
        )

    def open_item(self, locator, error_message, capture_screen):
        """ Performs a wait until the element shows on the page, and clicks the element """
        self.selenium.wait_until_page_contains_element(
            locator, 
            timeout=60,
            error=error_message
        )
        self.selenium.click_element(locator)
        if capture_screen:
            self.selenium.capture_page_screenshot()

    def go_to_affiliation_settings(self):
        """ Navigate to the Affiliations and Settings pages """
        self.open_item(
            affiliations_locators["affiliations_tab"],
            "Cannot find the Affiliations tab",
            False
        )
        self.open_item(
            affiliations_locators["affiliations_settings_tab"],
            "Cannot find the Settings tab in the Affiliations page",
            False
        )
        return
        
    def Click_button_on_location(self, button, page):
        """ Select the specified button from the page that is specified """
        self.selenium.wait_until_page_contains_element(
            page,
            timeout=60
        )
        self.open_item(
            page,
            "Cannot find {} ".format(page), 
            True
        )
        self.selenium.click_button(button)

    def Enable_the_checkbox(self, title, tab, loc_checkbox, loc_checkbox_edit):
        """ Ensure that the specified checkbox is checked 
            Set the checkbox if it is not set
            Do nothing if the checkbox is already set
        """
        
        self.selenium.wait_until_page_contains_element(
            tab,
            timeout=60
        )
        self.open_item(
            tab,
            "Cannot find {} tab".format(tab), 
            False
        )

        # Checkbox needs to be marked as checked
        if self._check_if_element_exists(loc_checkbox):
            self.builtin.log("{} checkbox is checked.".format(title))
            return
        else: 
            self.builtin.log(
                "{} checkbox is NOT checked.\n".format(title) +
                "Opening EDIT mode"
            )
            self.selenium.click_button("Edit")
            self.builtin.log("Setting the {} checkbox.".format(title))
            self.selenium.wait_until_page_contains_element(
                loc_checkbox_edit,
                timeout=60
            )
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(loc_checkbox_edit)
            )
            self.selenium.click_button("Save")
            self.eda.close_toast_message()
            self.builtin.log(
                "Checkbox for {} setting has been set.\n".format(title) 
            )

    def Disable_the_checkbox(self, title, tab, loc_checkbox, loc_checkbox_edit):
        """ Ensure that the specified checkbox is NOT checked 
            Uncheck the checkbox if it is checked
            Do nothing if the checkbox is already clear
        """
        
        self.selenium.wait_until_page_contains_element(
            tab,
            timeout=60
        )
        self.open_item(
            tab,
            "Cannot find {} tab".format(tab), 
            False
        )

        # Checkbox needs to be unchecked
        if self._check_if_element_exists(loc_checkbox):
            self.builtin.log("{} checkbox is already clear.".format(title))
            return
        else: 
            self.builtin.log(
                "{} checkbox is checked.\n" +
                "Opening EDIT mode"
            )
            self.selenium.click_button("Edit")
            self.builtin.log("Clearing the {} checkbox.".format(title))
            self.selenium.wait_until_page_contains_element(
                loc_checkbox_edit,
                timeout=60
            )
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(loc_checkbox_edit)
            )
            self.selenium.click_button("Save")
            self.eda.close_toast_message()
            self.builtin.log("{} checkbox has been cleared.".format(title))

    def process_default_values(self):
        """ Validate the default values for Affiliation Settings """
        
        self.open_item(
            affiliations_locators["affiliations_tab"], 
            "Cannot find the Affiliations tab in EDA Settings",
            False)

        self.open_item(
            affiliations_locators["affiliations_settings_tab"], 
            "Cannot find the Settings tab in Affiliations",
            False)

        # Verify the default values for the checkboxes
        self.selenium.driver.find_element_by_xpath(affiliations_locators["un_ert_validation"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["un_delete_rec_affl"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["un_specify_role_for_c_affl"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["un_copy_affl_end_date"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["un_copy_affl_start_date"])

        # Verify the default values for the dropdowns
        self.selenium.driver.find_element_by_xpath(affiliations_locators["affiliations_former"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["affiliations_student"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["affiliations_current"])
        return
