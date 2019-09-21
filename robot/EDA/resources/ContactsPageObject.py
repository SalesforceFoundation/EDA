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
        locator = contacts_locators["action"]
        locator_close_action = contacts_locators["action_close"]

        # In some cases, the action dialog opens by default,
        # hence making sure it is closed, before opening it otherwise it would nullify the click command
        if self.eda.check_if_element_exists(locator_close_action):
            self.selenium.click_element(locator_close_action)

        self.selenium.wait_until_page_contains_element(
            locator,
            error="'Action' button is not available on Contacts page"
        )
        self.selenium.click_element(locator)

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
        locator = contacts_locators["new_contact_button"]
        element = self.selenium.driver.find_element_by_xpath(locator)
        self.selenium.wait_until_page_contains_element(locator)
        self.selenium.driver.execute_script("arguments[0].click()", element)


    def refresh_contacts(self):
        """ Refresh the contacts list by clicking on the refresh button """
        locator = contacts_locators["refresh"]
        self.selenium.click_element(locator)


    def select_action(self, action):
        """ Select the action shortcut """
        locator = contacts_locators["action_shortcut"].format(action)
        self.selenium.wait_until_page_contains_element(locator,
        error="Action '" + action + "' doesn't exist in the list of Action Shortcuts")
        self.selenium.click_element(locator)

   
    def open_app_launcher(self, app_name):
        """ Navigates to a Salesforce App via the App Launcher """
        locator = eda_lex_locators["app_launcher"]["app_link"].format(app_name)
        self.builtin.log("Opening the App Launcher")
        self.salesforce.open_app_launcher()
        time.sleep(1)
        self.builtin.log("Getting the web element for the app")
        self.selenium.set_focus_to_element(locator)
        elem = self.selenium.get_webelement(locator)
        self.builtin.log("Getting the parent link from the web element")
        link = elem.find_element_by_xpath("../../..")
        self.selenium.set_focus_to_element(link)
        self.builtin.log("Clicking the link")
        link.click()
        self.builtin.log("Waiting for modal to close")
        self.salesforce.wait_until_modal_is_closed()


    def verify_timezone(self):
        """ Verify that a timezone value exists
            there is currently an open bug on this,
            once fixed, the keyword needs to be modified to check for a specific timezone
        """
        locator = contacts_locators["timezone"]
        self.selenium.page_should_contain_element(locator)
        self.builtin.log("Actual timezone isn't checked; waiting for bug to be fixed", "WARN")

    def select_contact(self,contact_firstname, contact_lastname):
        """ Select the contact from the Contacts Recently Viewed list """
        locator_contact = contacts_locators["select_contact"].format(contact_firstname, contact_lastname)
        self.selenium.wait_until_page_contains_element(
            locator_contact,
            error="Contact named: " + contact_firstname + " " + contact_lastname + " not found in Recently Viewed list"
        )
        self.selenium.click_element(locator_contact)

    def validate_preferred_phone_form(self):
        """ Test the preferred phone fields and functionality """

        self.open_item(contacts_locators["edit_contact"], "Edit button not found for Contact", False)

        locator_menu = contacts_locators["preferred_phone"]
        element_menu = self.selenium.driver.find_element_by_xpath(locator_menu)
        locator_tab = contacts_locators["preferred_tab"]
        self.selenium.driver.execute_script("arguments[0].scrollIntoView()", element_menu)

        locator_preferred_phone_home_menu_dropdown = contacts_locators["preferred_phone_home_dropdown"]
        element_menu_home = self.selenium.driver.find_element_by_xpath(locator_preferred_phone_home_menu_dropdown)

        if not self.check_if_element_exists(locator_tab):
            self.selenium.driver.execute_script("arguments[0].click()", element_menu_home)
            time.sleep(1)

        self.open_item(contacts_locators["preferred_tab"], "Home Phone not found as an option on Preferred Phone", False)

        # Attempt to Save the form
        contact_save = contacts_locators["contact_save"]
        self.selenium.click_element(contact_save)

        time.sleep(1)

        # Verify the error message that pops up
        locator = contacts_locators["preferred_error_message"]
        self.selenium.wait_until_page_contains_element(locator)
        
        # Enter a value for Home Phone and then save the Contact form
        # After entering a value for Home Phone the form should save 
        # without any error.

        locator_for_home_phone = contacts_locators["field_for_home_phone"]
        self.selenium.wait_until_page_contains_element(
            locator_for_home_phone,
            error="Home Phone field not found on Contacts form"
            )
        #self.selenium.click_element(locator_for_home_phone)
        self.selenium.get_webelement(locator_for_home_phone).send_keys("555-555-1212")

        # Save the form - this time successfully
        contact_save = contacts_locators["contact_save"]
        self.selenium.click_element(contact_save)

        self.selenium.driver.switch_to.default_content()
        # Grab the current frame
        currentFrame = self.selenium.driver.execute_script("return self.name")
        self.builtin.log(
            "Current frame 1: " + currentFrame
        )
#        locator = contacts_locators["toast_message"].format("was saved")
#        self.selenium.wait_until_page_contains_element(locator)


    def verify_toast_message(self, value):
        """ Verifies the toast message """
        locator = contacts_locators["toast_message"].format(value)
        self.selenium.wait_until_page_contains_element(locator)



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
        self.open_item(contacts_locators["details_tab"], "Details tab not found on contact", True)
        # Open EDIT mode
        self.open_item(contacts_locators["edit_contact"], "Edit button not found on contact", False)
        # Place specific field in view, because it's off-screen at the moment
        self.place_in_view(contacts_locators["field_for_phone"])
        self.open_item(contacts_locators["footer_cancel"], "Cancel button not avaible on EDIT Contact page", False)

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
        locator_menu = contacts_locators["tab_menu"].format(tab)
        element_menu = self.selenium.driver.find_element_by_xpath(locator_menu)
        locator_tab = contacts_locators["tab_tab"].format(tab)
        self.selenium.wait_until_page_contains_element(
            locator_menu,
            error="Contact tab unavailable"
        )
        # javascript is being used here because the usual selenium click is highly unstable for this element on MetaCI
        self.selenium.driver.execute_script("arguments[0].click()", element_menu)
        time.sleep(1)

        # Sometimes, single click fails. Hence an additional condition to click on it again
        if not self.check_if_element_exists(locator_tab):
            self.selenium.driver.execute_script("arguments[0].click()", element_menu)
            time.sleep(1)


    def Verify_setting_of_disable_preferred_phone_enforcement(self):
        """ Verify that Disable Preferred Phone enforcement checkbox is not checked 
            Clear the checkbox if it is set
            Do nothing if the checkbox is already empty
        """

        locator_accounts_and_contacts = contacts_locators["accounts_contacts"]
        locator_disable_preferred_phone = contacts_locators["disable_preferred_phone"]
        locator_disable_checked = contacts_locators["disable_checked"]

        self.open_item(contacts_locators["accounts_contacts"],"Cannot find Account and Contacts on EDA Settings page", True)

        # Checkbox for 'Disable Preferred Phone enforcement' should be empty
        if self.check_if_element_exists(locator_disable_preferred_phone):
            self.builtin.log("Disable Preferred Phone enforcement is empty.")
        else: 
            self.builtin.log(
                "Disable Preferred Phone enforcement is NOT empty.\n" +
                "Opening EDIT mode"
            )
            self.selenium.click_button("Edit")
            self.builtin.log("Removing checkmark from 'Disable Preferred Phone enforcement' checkbox.")
            self.selenium.get_webelement(locator_disable_checked).click()
            self.selenium.click_button("Save")
            self.builtin.log(
                "Disable Preferred Phone enforcement setting has been cleared.\n" +
                "Saving changes.\n" +
                "Proper configuration is in place for testing 'Disable Preferred Phone enforcement'."
            )

        self.selenium.driver.switch_to.default_content()
        currentFrame = self.selenium.driver.execute_script("return self.name")
        #self.selenium.driver.execute_script("arguments[0].scrollIntoView()", element_menu)
        self.builtin.log(
            "Current frame 2: " + currentFrame
        )

    def Set_the_disable_preferred_phone_enforcement(self):
        """ Verify that Disable Preferred Phone enforcement checkbox is not checked 
            Clear the checkbox if it is set
            Do nothing if the checkbox is already empty
        """

        locator_disable_preferred_phone = contacts_locators["disable_preferred_phone"]
        locator_disable_checked = contacts_locators["disable_checked"]

        self.open_item(contacts_locators["accounts_contacts"],"Cannot find Account and Contacts on EDA Settings page", True)

        # Checkbox for 'Disable Preferred Phone enforcement' should be empty
        if not self.check_if_element_exists(locator_disable_preferred_phone):
            self.builtin.log("Disable Preferred Phone enforcement is empty.")
        else: 
            self.builtin.log(
                "Disable Preferred Phone enforcement is NOT checked.\n" +
                "Opening EDIT mode"
            )
            self.selenium.click_button("Edit")
            self.selenium.capture_page_screenshot()
            self.builtin.log("Setting 'Disable Preferred Phone enforcement' checkbox.")
            time.sleep(1)
            #self.selenium.get_webelement(locator_disable_checked).click()
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(locator_disable_checked)
            )
            self.selenium.click_button("Save")
            time.sleep(1)
            self.builtin.log(
                "Disable Preferred Phone enforcement setting has been set.\n" +
                "Saving changes.\n" +
                "Proper configuration is in place for testing 'Disable Preferred Phone enforcement'."
            )
            self.selenium.capture_page_screenshot()

        self.selenium.driver.switch_to.default_content()
        currentFrame = self.selenium.driver.execute_script("return self.name")
        #self.selenium.driver.execute_script("arguments[0].scrollIntoView()", element_menu)
        self.builtin.log(
            "Current frame 2: " + currentFrame
        )

