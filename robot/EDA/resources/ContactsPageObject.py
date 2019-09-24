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
        if self.eda.check_if_element_exists(contacts_locators["action_close"]):
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
    def check_if_element_exists(self, xpath):
        """ Checks if the given xpath exists """
        elements = int(self.selenium.get_matching_xpath_count(xpath))
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

   
    def open_app_launcher(self, app_name):
        """ Navigates to a Salesforce App via the App Launcher """
        
        self.builtin.log("Opening the App Launcher")
        self.salesforce.open_app_launcher()
        time.sleep(1)
        self.builtin.log("Getting the web element for the app")
        self.selenium.set_focus_to_element(locator)
        self.builtin.log("Getting the parent link from the web element")
        self.selenium.set_focus_to_element(elem.find_element_by_xpath("../../.."))
        self.builtin.log("Clicking the link")
        self.selenium.get_webelement(eda_lex_locators["app_launcher"]["app_link"].format(app_name)).find_element_by_xpath("../../..").click()
        self.builtin.log("Waiting for modal to close")
        self.salesforce.wait_until_modal_is_closed()


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

        self.selenium.wait_until_page_contains_element(contacts_locators["edit_contact"], error="Edit button not found for Contact")
        self.open_item(contacts_locators["edit_contact"], "Edit button not found for Contact", False)

        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(contacts_locators["preferred_phone"])
        )

        element_menu_home = self.selenium.driver.find_element_by_xpath(contacts_locators["preferred_phone_home_dropdown"])

        if not self.check_if_element_exists(contacts_locators["preferred_tab"]):
            self.selenium.driver.execute_script("arguments[0].click()", element_menu_home)
            time.sleep(1)

        self.open_item(contacts_locators["preferred_tab"], "Home Phone not found as an option on Preferred Phone", False)

        # Attempt to Save the form
        self.selenium.click_element(contacts_locators["contact_save"])
        time.sleep(1)

        # Verify the error message that pops up
        self.selenium.wait_until_page_contains_element(contacts_locators["preferred_error_message"])
        
        # Enter a value for Home Phone and then save the Contact form
        # After entering a value for Home Phone the form should save 
        # without any error.

        self.selenium.wait_until_page_contains_element(
            contacts_locators["field_for_home_phone"],
            error="Home Phone field not found on Contacts form"
            )
        self.selenium.get_webelement(contacts_locators["field_for_home_phone"]).send_keys("555-555-1212")

        # Save the form - this time successfully
        self.selenium.click_element(contacts_locators["contact_save"])

        self.selenium.driver.switch_to.default_content()
        # Grab the current frame
        currentFrame = self.selenium.driver.execute_script("return self.name")
        self.builtin.log(
            "Current frame 1: " + currentFrame
        )

    def verify_toast_message(self, value):
        """ Verifies the toast message """
        self.selenium.wait_until_page_contains_element(contacts_locators["toast_message"].format(value))

    def Test_home_phone_functionality(self, contact_firstname, contact_lastname):
        """ Validate Home Phone functionality """
        self.builtin.log("Validate Home Phone functionality.")
        self.builtin.log(
            "Open contact: " +
            contact_firstname +
            " " +
            contact_lastname
        )
        # Navigate to Detail tab
        self.selenium.wait_until_page_contains_element(contacts_locators["details_tab"], error="Details Tab not found on contact")
        self.open_item(contacts_locators["details_tab"], "Details tab not found on contact", True)
        # Open EDIT mode
        self.open_item(contacts_locators["edit_contact"], "Edit button not found on contact", False)
        # Place specific field in view, because it's off-screen at the moment
        self.place_in_view(contacts_locators["field_for_phone"])
        self.open_item(contacts_locators["footer_cancel"], "Cancel button not avaible on EDIT Contact page", False)
        time.sleep(1)

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
        self.selenium.wait_until_page_contains_element(locator, error=error_message)
        self.selenium.click_element(locator)
        if capture_screen:
            self.selenium.capture_page_screenshot()
            
    def focus_tab(self, tab):
        """ Performs the following: 
            Lookup the locator
            Wait until the element shows on the page, and clicks the element 
        """
        element_menu = self.selenium.driver.find_element_by_xpath(contacts_locators["tab_menu"].format(tab))
        self.selenium.wait_until_page_contains_element(
            contacts_locators["tab_menu"].format(tab),
            error="Contact tab unavailable"
        )
        # javascript is being used here because the usual selenium click is highly unstable for this element on MetaCI
        self.selenium.driver.execute_script("arguments[0].click()", element_menu)
        time.sleep(1)

        # Sometimes, single click fails. Hence an additional condition to click on it again
        if not self.check_if_element_exists(contacts_locators["tab_tab"].format(tab)):
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(contacts_locators["tab_menu"].format(tab))
            )
            time.sleep(1)


    def Verify_setting_of_disable_preferred_phone_enforcement(self):
        """ Verify that Disable Preferred Phone enforcement checkbox is not checked 
            Clear the checkbox if it is set
            Do nothing if the checkbox is already empty
        """

        self.selenium.wait_until_page_contains_element(contacts_locators["accounts_contacts"])

        self.open_item(contacts_locators["accounts_contacts"],"Cannot find Account and Contacts on EDA Settings page", True)

        # Checkbox for 'Disable Preferred Phone enforcement' should be empty
        if self.check_if_element_exists(contacts_locators["disable_preferred_phone"]):
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
            self.builtin.log(
                "Disable Preferred Phone enforcement setting has been cleared.\n" +
                "Saving changes.\n" +
                "Proper configuration is in place for testing 'Disable Preferred Phone enforcement'."
            )
        self.eda.shift_to_default_content()

    def Set_the_disable_preferred_phone_enforcement(self):
        """ Verify that Disable Preferred Phone enforcement checkbox is not checked 
            Clear the checkbox if it is set
            Do nothing if the checkbox is already empty
        """
        
        self.selenium.wait_until_page_contains_element(contacts_locators["accounts_contacts"])
        self.open_item(contacts_locators["accounts_contacts"],"Cannot find Account and Contacts on EDA Settings page", True)


        # Checkbox for 'Disable Preferred Phone enforcement' should be empty
        if self.check_if_element_exists(contacts_locators["preferred_phone_active"]):
            self.builtin.log("Disable Preferred Phone enforcement is checked.")
            return
        else: 
            self.builtin.log(
                "Disable Preferred Phone enforcement is NOT checked.\n" +
                "Opening EDIT mode"
            )
            self.selenium.click_button("Edit")
            self.selenium.capture_page_screenshot()
            self.builtin.log("Setting 'Disable Preferred Phone enforcement' checkbox.")
            time.sleep(1)

            self.selenium.wait_until_page_contains_element(contacts_locators["disable_checked"])
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(contacts_locators["disable_checked"])
            )
            self.selenium.click_button("Save")
            time.sleep(1)
            self.builtin.log(
                "Disable Preferred Phone enforcement setting has been set.\n" +
                "Saving changes.\n" +
                "Proper configuration is in place for testing 'Disable Preferred Phone enforcement'."
            )
            self.selenium.capture_page_screenshot()

        self.eda.shift_to_default_content()

    def Clear_the_disable_preferred_phone_enforcement(self):
        """ Verify that Disable Preferred Phone enforcement checkbox is checked 
            Set the checkbox if it is clear
            Do nothing if the checkbox is already empty
        """

        self.selenium.wait_until_page_contains_element(contacts_locators["accounts_contacts"])
        self.open_item(contacts_locators["accounts_contacts"],"Cannot find Account and Contacts on EDA Settings page", True)

        # Click on Edit button
        self.selenium.click_button("Edit")
        self.selenium.capture_page_screenshot()
        self.builtin.log("Setting 'Disable Preferred Phone enforcement' checkbox.")
#        time.sleep(1)

        # Checkbox for 'Disable Preferred Phone enforcement' should be empty
        if self.check_if_element_exists(contacts_locators["disable_preferred_phone"]):
            self.builtin.log("Disable Preferred Phone enforcement is clear.")
        else: 
            self.builtin.log(
                "Disable Preferred Phone enforcement is checked.\n" +
                "Opening EDIT mode"
            )
            self.builtin.log("Setting 'Disable Preferred Phone enforcement' checkbox.")
            time.sleep(1)

            # place a check in the checkbox
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(contacts_locators["disable_checked"])
            )
            self.selenium.capture_page_screenshot()

        # Before running the 'Run Cleanup', we need to choose a 
        # field for the Preferred Phone to copy the value from, 
        # if you're not using the standard Phone field (or it has
        # no value) and more than one 'Phone' field is defined.
        # We'll choose 'Work Phone'
        if self.check_if_element_exists(contacts_locators["copy_from"]):
            self.selenium.driver.execute_script(
                "arguments[0].click()",
                self.selenium.driver.find_element_by_xpath(contacts_locators["copy_from"])
            )

        self.selenium.get_webelement(contacts_locators["copy_from"]).send_keys("H" + Keys.ENTER)

        self.selenium.capture_page_screenshot()

        # Click Save
        self.selenium.click_button("Save")
        time.sleep(1)
        self.builtin.log(
            "Disable Preferred Phone enforcement setting has been set.\n" +
            "Saving changes.\n" +
            "Proper configuration is in place for testing 'Disable Preferred Phone enforcement'."
        )
        time.sleep(1)
        self.selenium.capture_page_screenshot()

        #self.eda.shift_to_default_content()


    def Run_phone_cleanup(self):
        """ Click on the 'Run Phone Cleanup' button """

#        self.open_item(contacts_locators["accounts_contacts"],"Cannot find Account and Contacts on EDA Settings page", True)

        self.selenium.wait_until_page_contains_element(contacts_locators["run_cleanup"])

        time.sleep(1)

        if self.check_if_element_exists(contacts_locators["run_cleanup"]):
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(contacts_locators["run_cleanup"])
            )
            self.builtin.log("Run Cleanup executed")
            time.sleep(1)

        self.selenium.wait_until_page_contains_element(contacts_locators["successful_run"])
        self.selenium.capture_page_screenshot()

        # Give 'Run Cleanup' fifteen seconds run time, then continue
        time.sleep(15)

        return


    def Add_home_phone_to_contact_and_verify(self, FirstName, LastName):
        """ Open the contact details and add a home phone and save
            Verify that the home phone is NOT copied to Phone field
            and that the 'Preferred Phone' is set to None
        """
        self.select_contact(FirstName, LastName)
        # Navigate to Detail tab
        self.open_item(contacts_locators["details_tab"], "Details tab not found on contact", True)
        self.open_item(contacts_locators["edit_contact"], "Edit button not found on contact", False)
        self.place_in_view(contacts_locators["phone_home"])

        self.selenium.driver.execute_script(
            "window.scrollTo(0, document.body.scrollHeight)"
        )
        self.selenium.capture_page_screenshot()

        self.open_item(contacts_locators["phone_home"], "Home Phone field not found on contact", False)

        self.selenium.get_webelement(contacts_locators["phone_home"]).send_keys("123-123-1234")
        self.open_item(contacts_locators["footer_save"], "Save button not avaible on EDIT Contact page", False)

        self.selenium.capture_page_screenshot()

        self.check_if_element_exists(contacts_locators["phone_verify_has_number"])
        return

    def Verify_contact_values(self, FirstName, LastName):
        """ Verify that the Home Phone number is copied to Phone """

        self.select_contact(FirstName, LastName)

        self.selenium.wait_until_page_contains_element(contacts_locators["details_tab"])
        self.open_item(contacts_locators["details_tab"], "Details tab not found on contact", True)

        self.selenium.driver.refresh()

        self.selenium.wait_until_page_contains_element(contacts_locators["details_tab"])
        self.open_item(contacts_locators["details_tab"], "Details tab not found on contact", True)


        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(contacts_locators["phone_verify"])
        )

        self.selenium.wait_until_page_contains_element(contacts_locators["phone_verify"])
        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(contacts_locators["phone_verify"])
        )

        self.selenium.wait_until_page_contains_element(contacts_locators["home_phone_verify"])
        self.selenium.capture_page_screenshot()

        return
