import datetime
import logging
import time
import pytz

from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
from locators import contacts_locators
from locators import eda_lex_locators
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

@pageobject("Home", "Contacts")
class ContactsHomePage(BasePage):
    object_name = None

    @property
    def eda(self):
        return self.builtin.get_library_instance('EDA')

    def click_action_button(self):
        """ Clicks on the 'Action' button in Contacts """

        # In some cases, the action dialog opens by default,
        # hence making sure it is closed, before opening it otherwise it would nullify the click command
        if self._check_if_element_exists(contacts_locators["action_close"]):
            self.selenium.click_element(contacts_locators["action_close"])

        self.selenium.wait_until_page_contains_element(
            contacts_locators["action"],
            error="'Action' button is not available on Contacts page"
        )
        self.selenium.click_element(contacts_locators["action"])

    def _is_current_page(self):
        """ Verify we are on the Contacts page
            by verifying that the header title is 'Contacts'
        """
        locator = contacts_locators["header"]
        self.selenium.page_should_contain_element(
            locator,
            message="Header with text 'Contacts' is not available on the page"
        )
    def _check_if_element_exists(self, xpath):
        """ Checks if the given xpath exists """
        elements = int(self.selenium.get_element_count(xpath))
        return True if elements > 0 else False


    def click_new_contact_button(self):
        """ Clicks on the 'New Contact' button in Contacts """
        self.selenium.wait_until_page_contains_element(contacts_locators["new_contact_button"])
        self.selenium.driver.execute_script(
            "arguments[0].click()", 
            self.selenium.driver.find_element_by_xpath(contacts_locators["new_contact_button"])
        )

    def refresh_contacts(self):
        """ Refresh the contacts list by clicking on the refresh button """
        self.selenium.click_element(contacts_locators["refresh"])

    def select_action(self, action):
        """ Select the action shortcut """
        self.selenium.wait_until_page_contains_element(
            contacts_locators["action_shortcut"].format(action),
            error="Action '" + action + "' doesn't exist in the list of Action Shortcuts"
        )
        self.selenium.click_element(contacts_locators["action_shortcut"].format(action))

    def verify_timezone(self):
        """ Verify that a timezone value exists
            there is currently an open bug on this,
            once fixed, the keyword needs to be modified to check for a specific timezone
        """
        self.selenium.page_should_contain_element(contacts_locators["timezone"])
        self.builtin.log("Actual timezone isn't checked; waiting for bug to be fixed", "WARN")

    def select_contact(self,contact_firstname, contact_lastname):
        """ Select the contact from the Contacts Recently Viewed list """
        self.selenium.wait_until_page_contains_element(
            contacts_locators["select_contact"].format(contact_firstname, contact_lastname),
            error="Contact named: " + contact_firstname + " " + contact_lastname + " not found in Recently Viewed list"
        )
        self.selenium.click_element(contacts_locators["select_contact"].format(contact_firstname, contact_lastname))

    def validate_preferred_phone_form(self):
        """ Test the preferred phone fields and functionality """

        self.selenium.wait_until_page_contains_element(
            contacts_locators["edit_contact"], 
            timeout=60,
            error="Edit button not found for Contact"
        )
        self.open_item(
            contacts_locators["edit_contact"], 
            "Edit button not found for Contact", 
            False
        )

        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(contacts_locators["preferred_phone"])
        )

        if not self._check_if_element_exists(contacts_locators["preferred_tab"]):
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(contacts_locators["preferred_phone_home_dropdown"])
            )

        self.open_item(
            contacts_locators["preferred_tab"], 
            "Home Phone not found as an option on Preferred Phone", 
            False
        )

        # Attempt to Save the form
        self.selenium.click_element(contacts_locators["contact_save"])

        # Verify the error message that pops up
        self.selenium.wait_until_page_contains_element(
            contacts_locators["preferred_error_message"],
            timeout=60
        )
        
        # Enter a value for Home Phone and then save the Contact form
        # After entering a value for Home Phone the form should save 
        # without any error.

        self.selenium.wait_until_page_contains_element(
            contacts_locators["field_for_home_phone"],
            timeout=60,
            error="Home Phone field not found on Contacts form"
        )
        self.selenium.get_webelement(contacts_locators["field_for_home_phone"]).send_keys("555-555-1212")
        time.sleep(3) # if we don't wait, then the field doesn't complete the input of the phone number

        # Save the form - this time successfully
        self.selenium.click_element(contacts_locators["contact_save"])
        self.eda.close_toast_message()
        self.selenium.driver.switch_to.default_content()

    def verify_toast_message(self, value):
        """ Verifies the toast message """
        self.selenium.wait_until_page_contains_element(contacts_locators["toast_message"].format(value))

    def place_in_view(self,locator):
        """ Scroll the field or object into the current view 
            Examples:
            | =Function= | =argument= |
            | place_in_view | any locator |
            | self.place_in_view(contacts_locators["header"]) | |
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

    def open_apex(self, title, error_message, capture_screen):
        """ Performs a wait until the element shows on the page, and clicks the element """
        self.selenium.wait_until_page_contains_element(
            contacts_locators["apex_jobs"].format(title), 
            timeout=60,
            error=error_message
        )
        self.selenium.click_element(contacts_locators["apex_jobs"].format(title))
        if capture_screen:
            self.selenium.capture_page_screenshot()

    def Verify_setting_of_disable_preferred_phone_enforcement(self):
        """ Verify that Disable Preferred Phone enforcement checkbox is not checked 
            Clear the checkbox if it is set
            Do nothing if the checkbox is already empty
        """

        self.selenium.wait_until_page_contains_element(
            contacts_locators["accounts_contacts"],
            timeout=60
        )

        self.open_item(
            contacts_locators["accounts_contacts"],
            "Cannot find Account and Contacts on EDA Settings page", 
            True
        )

        # Checkbox for 'Disable Preferred Phone enforcement' should be empty
        if self._check_if_element_exists(contacts_locators["disable_preferred_phone"]):
            self.builtin.log("Disable Preferred Phone enforcement is empty.")
        else: 
            self.builtin.log(
                "Disable Preferred Phone enforcement is NOT empty.\n" +
                "Opening EDIT mode"
            )
            self.selenium.click_button("Edit")
            self.builtin.log("Removing checkmark from 'Disable Preferred Phone enforcement' checkbox.")
            self.selenium.get_webelement(contacts_locators["disable_checked"]).click()
            self.selenium.click_button("Save")
            self.eda.close_toast_message()
            self.builtin.log(
                "Disable Preferred Phone enforcement setting has been cleared.\n" +
                "Saving changes.\n" +
                "Proper configuration is in place for testing 'Disable Preferred Phone enforcement'."
            )

    def Set_the_disable_preferred_phone_enforcement(self):
        """ Verify that Disable Preferred Phone enforcement checkbox is checked.
            Set the checkbox if it is not already set.
            Do nothing if the checkbox is already checked.
        """
        
        self.selenium.wait_until_page_contains_element(
            contacts_locators["accounts_contacts"],
            timeout=60
        )
        self.open_item(
            contacts_locators["accounts_contacts"],
            "Cannot find Account and Contacts on EDA Settings page", 
            True
        )

        # Checkbox for 'Disable Preferred Phone enforcement' needs to be marked as checked
        if self._check_if_element_exists(contacts_locators["preferred_phone_active"]):
            self.builtin.log("Disable Preferred Phone enforcement is checked.")
            return
        else: 
            self.builtin.log(
                "Disable Preferred Phone enforcement is NOT checked.\n" +
                "Opening EDIT mode"
            )
            self.selenium.click_button("Edit")
            self.builtin.log("Setting 'Disable Preferred Phone enforcement' checkbox.")

            self.selenium.wait_until_page_contains_element(
                contacts_locators["disable_checked"],
                timeout=60,
            )
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(contacts_locators["disable_checked"])
            )
            self.selenium.click_button("Save")
            self.eda.close_toast_message()
            self.builtin.log(
                "Disable Preferred Phone enforcement checkbox has been checked.\n" +
                "Saving changes.\n" +
                "Proper configuration is in place for testing 'Disable Preferred Phone enforcement'."
            )

    def Clear_the_disable_preferred_phone_enforcement(self):
        """ Verify that Disable Preferred Phone enforcement checkbox is not checked 
            Clear the checkbox if it is set
            Do nothing if the checkbox is already empty
        """

        self.selenium.wait_until_page_contains_element(
            contacts_locators["accounts_contacts"],
            timeout=60
        )
        self.open_item(
            contacts_locators["accounts_contacts"],
            "Cannot find Account and Contacts on EDA Settings page", 
            True
        )

        # Checkbox for 'Disable Preferred Phone enforcement' should be empty
        if self._check_if_element_exists(contacts_locators["disable_preferred_phone"]):
            self.builtin.log("Disable Preferred Phone enforcement is clear.")
        else: 

            # Click on Edit button
            self.selenium.click_button("Edit")
            self.builtin.log("Setting 'Disable Preferred Phone enforcement' checkbox.")
            self.builtin.log(
                "Disable Preferred Phone enforcement is currently checked.\n" +
                "In EDIT mode"
            )
            self.builtin.log("Clearing 'Disable Preferred Phone enforcement' checkbox.")
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(contacts_locators["disable_checked"])
            )
            self.selenium.click_button("Save")
            self.eda.close_toast_message()

        # Before running the 'Run Cleanup', we need to choose a 
        # field for the Preferred Phone to copy the value from, 
        # if you're not using the standard Phone field (or it has
        # no value) and more than one 'Phone' field is defined.
        # We'll choose 'Work Phone'

        self.selenium.click_button("Edit")

        if self._check_if_element_exists(contacts_locators["copy_from"]):
            self.selenium.driver.execute_script(
                "arguments[0].click()",
                self.selenium.driver.find_element_by_xpath(contacts_locators["copy_from"])
            )
        self.selenium.get_webelement(contacts_locators["copy_from"]).send_keys("H" + Keys.ENTER)

        # Click Save
        self.selenium.click_button("Save")
        self.eda.close_toast_message()
        self.builtin.log(
            "Disable Preferred Phone enforcement checkbox has been cleared.\n" +
            "Saving changes.\n" +
            "Proper configuration is in place for testing 'Disable Preferred Phone enforcement'."
        )

    def Run_phone_cleanup(self):
        """ Click on the 'Run Cleanup' button.
            Also verifies that the 'Run Cleanup' was queued to run.
        """

        if self._check_if_element_exists(contacts_locators["run_cleanup"]):
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(contacts_locators["run_cleanup"])
            )
        self.selenium.wait_until_page_contains("The process was queued successfully")
        self.selenium.wait_until_page_contains_element(
            contacts_locators["successful_run"],
            timeout=60
        )

        self.builtin.log("Run Cleanup executed")
        return

    def Add_home_phone_to_contact_and_verify(self, FirstName, LastName):
        """ Open the contact details and add a home phone and save
            Verify that the home phone is NOT copied to Phone field
            and that the 'Preferred Phone' is set to None
        """
        self.select_contact(FirstName, LastName)
        # Navigate to Detail tab
        self.open_item(
            contacts_locators["details_tab"], 
            "Details tab not found on contact", 
            False
        )
        self.open_item(
            contacts_locators["edit_contact"], 
            "Edit button not found on contact", 
            False
        )
        self.place_in_view(contacts_locators["phone_home"])
        self.selenium.driver.execute_script(
            "window.scrollTo(0, document.body.scrollHeight)"
        )
        self.open_item(
            contacts_locators["phone_home"], 
            "Home Phone field not found on contact", 
            False
        )
        self.selenium.get_webelement(contacts_locators["phone_home"]).send_keys("123-123-1234")
        self.open_item(
            contacts_locators["footer_save"], 
            "Save button not avaible on EDIT Contact page", 
            False
        )
        self.eda.close_toast_message()
        self._check_if_element_exists(contacts_locators["phone_verify_has_number"])
        return

    def Add_home_phone_and_work_phone_to_contact(self, FirstName, LastName, checked):
        """ Open the contact details and add a home phone and office phone
            and save.
        """
        self.select_contact(FirstName, LastName)
        # Navigate to Detail tab
        self.open_item(
            contacts_locators["details_tab"], 
            "Details tab not found on contact", 
            True
        )
        self.open_item(
            contacts_locators["edit_contact"], 
            "Edit button not found on contact", 
            False
        )
        self.place_in_view(contacts_locators["phone_home"])
        self.selenium.driver.execute_script(
            "window.scrollTo(0, document.body.scrollHeight)"
        )
        self.open_item(
            contacts_locators["phone_home"], 
            "Home Phone field not found on contact", 
            False
        )
        self.selenium.wait_until_page_contains_element(
            contacts_locators["field_for_home_phone"],
            timeout=60,
            error="Home Phone field not found on Contacts form"
        )
        self.selenium.clear_element_text(contacts_locators["field_for_home_phone"])
        self.selenium.get_webelement(contacts_locators["field_for_home_phone"]).send_keys("456-789-1011")
        time.sleep(3) # if we don't wait, then the field doesn't complete the input of the phone number
        self.selenium.clear_element_text(contacts_locators["field_for_work_phone"])
        self.selenium.get_webelement(contacts_locators["field_for_work_phone"]).send_keys("121-314-1516")
        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(contacts_locators["field_for_work_phone"])
        )

        # Attempt to Save the form
        self.selenium.click_element(contacts_locators["contact_save"])
        if checked == "False":
            # Verify the error message that pops up
            self.selenium.wait_until_page_contains_element(
                contacts_locators["which_preferred_error_message"],
                timeout=10
            )
            self.selenium.driver.execute_script(
                "arguments[0].scrollIntoView()", 
                self.selenium.driver.find_element_by_xpath(contacts_locators["which_footer_cancel"])
            )
            self.open_item(
                contacts_locators["which_footer_cancel"], 
                "Cancel button not avaible on EDIT Contact page", 
                True
            )
            return
        else:
            self.eda.close_toast_message()
        return

    def Verify_contact_values(self, FirstName, LastName):
        """ Verify that the Home Phone number is copied to Phone field """

        self.select_contact(FirstName, LastName)
        self.selenium.wait_until_page_contains("Details")
        self.selenium.wait_until_page_contains_element(
            contacts_locators["details_tab"], 
            timeout=60
        )
        self.open_item(
            contacts_locators["details_tab"], 
            "Details tab not found on contact", 
            False
        )
        self.selenium.driver.refresh()
        self.selenium.wait_until_page_contains_element(
            contacts_locators["details_tab"],
            timeout=60
        )
        self.open_item(
            contacts_locators["details_tab"], 
            "Details tab not found on contact", 
            False
        )

        self.selenium.wait_until_page_contains_element(
            contacts_locators["phone_verify"],
            timeout=30
        )
        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(contacts_locators["home_phone_verify"])
        )
        self.selenium.wait_until_page_contains_element(
            contacts_locators["home_phone_verify"],
            timeout=60
        )
        return

    def Go_to_affiliations_edit_mode(self, loc):
        """ Go into Edit mode and remove the con
        """    
        self.selenium.driver.execute_script(
            "arguments[0].click()", 
            self.selenium.driver.find_element_by_xpath(loc)
        )

        self.selenium.driver.execute_script(
            "arguments[0].click()", 
            self.selenium.driver.find_element_by_xpath(contacts_locators["delete_icon"])
        )

        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(contacts_locators["primary_business_organization"])
        )
        
        xpath = contacts_locators["primary_business_organization"]
        field = self.selenium.get_webelement(xpath)
        field.send_keys("Robot Academic Program Account" + Keys.ARROW_DOWN + Keys.ENTER)

        self.selenium.click_element(contacts_locators["button_save_affiliation"])
        self.eda.close_toast_message()


    def Enable_enchanced_checkbox(self):
        """ Ensure that the Enhanced Preferred Phone Functionality checkbox is checked 
            Set the checkbox if it is not set
            Do nothing if the checkbox is already set
        """
        
        self.selenium.wait_until_page_contains_element(
            contacts_locators["accounts_contacts"],
            timeout=60
        )
        self.open_item(
            contacts_locators["accounts_contacts"],
            "Cannot find Account and Contacts on EDA Settings page", 
            True
        )

        # Checkbox for 'Disable Preferred Phone enforcement' needs to be marked as checked
        if self._check_if_element_exists(contacts_locators["enhanced_preferred_set"]):
            self.builtin.log("Enable Enhanced Preferred Phone Functionality is checked.")
            return
        else: 
            self.builtin.log(
                "Enable Enhanced Preferred Phone Functionality is NOT checked.\n" +
                "Opening EDIT mode"
            )
            self.selenium.click_button("Edit")
            self.builtin.log("Setting 'Enable Enhanced Preferred Phone Functionality' checkbox.")
            self.selenium.wait_until_page_contains_element(
                contacts_locators["enhanced_preferred_clear_faux"],
                timeout=60
            )
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(contacts_locators["enhanced_preferred_clear_faux"])
            )
            self.selenium.click_button("Save")
            self.eda.close_toast_message()
            self.builtin.log(
                "Enable Enhanced Preferred Phone Functionality setting has been set.\n" +
                "Saving changes.\n" +
                "Proper configuration is in place for testing 'Disable Preferred Phone enforcement'."
            )

    def Disable_enchanced_checkbox(self):
        """ Verify that Enable Enhanced Preferred Phone Functionality checkbox is not checked 
            Clear the checkbox if it is set
            Do nothing if the checkbox is already empty
        """

        self.selenium.wait_until_page_contains_element(
            contacts_locators["accounts_contacts"],
            timeout=60
        )
        self.open_item(
            contacts_locators["accounts_contacts"],
            "Cannot find Account and Contacts on EDA Settings page", 
            True
        )

        # Click on Edit button
        self.selenium.click_button("Edit")
        self.builtin.log("Clearing 'Enable Enhanced Preferred Phone Functionality' checkbox.")

        # Checkbox for 'Enable Enhanced Preferred Phone Functionality' should be empty
        if self._check_if_element_exists(contacts_locators["enhanced_preferred_clear"]):
            self.builtin.log("Enable Enhanced Preferred Phone Functionality is clear.")
            return
        else: 
            self.builtin.log(
                "Enable Enhanced Preferred Phone Functionality is checked.\n" +
                "Opening EDIT mode"
            )
            self.builtin.log("Clearing 'Enable Enhanced Preferred Phone Functionality' checkbox.")

            # Clear the check in the checkbox
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(contacts_locators["enhanced_preferred_set_faux"])
            )
        # Click Save
        self.selenium.click_button("Save")
        self.eda.close_toast_message()
        self.builtin.log(
            "Enable Enhanced Preferred Phone Functionality setting has been cleared.\n" +
            "Saving changes.\n" +
            "Proper configuration is in place for testing 'Disable Preferred Phone enforcement'."
        )

    def Wait_and_refresh_static_page_until_text(self, search_text, wait_time, loc_frame, loc_text):
        """ Wait for text to appear on static page.  Note that the page is refreshed each 'wait_time' until
            the specified text 'search_text' appears. 
            'loc_text' will return the text portion of the locator
        """    
        self.selenium.driver.refresh()
        self.selenium.select_frame(loc_frame)
        textPortion = self.selenium.get_text(loc_text)
        while (textPortion != search_text):
            time.sleep(wait_time)
            self.selenium.driver.refresh()
            self.selenium.select_frame(loc_frame)
            textPortion = self.selenium.get_text(loc_text)
