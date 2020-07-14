from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import DetailPage
from cumulusci.robotframework.pageobjects import pageobject
from selenium.webdriver.common.keys import Keys
import time


@pageobject("Details", "Contact")
class ContactDetailPage(BaseEDAPage, DetailPage):
    object_name = "Contact"

    def select_contact(self, contact_firstname, contact_lastname):
        """ Select the contact from the Contacts Recently Viewed list """
        self.selenium.wait_until_page_contains_element(
            eda_lex_locators["contacts_locators"]["select_contact"].format(contact_firstname, contact_lastname),
            error="Contact named: " + contact_firstname + " " + contact_lastname + " not found in Recently Viewed list"
        )
        self.selenium.click_element(eda_lex_locators["contacts_locators"]["select_contact"].format(contact_firstname, contact_lastname))

    def validate_preferred_phone_form(self):
        """ Test the preferred phone fields and functionality """
        self.salesforce.click_object_button("Edit")
        self.salesforce.wait_until_modal_is_open()
        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(eda_lex_locators["contacts_locators"]["preferred_phone"])
        )

        if not self.eda._check_if_element_exists(eda_lex_locators["contacts_locators"]["preferred_tab"]):
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(eda_lex_locators["contacts_locators"]["preferred_phone_home_dropdown"])
            )

        self.open_item(
            eda_lex_locators["contacts_locators"]["preferred_tab"],
            "Home Phone not found as an option on Preferred Phone", 
            False
        )

        # Attempt to Save the form
        self.selenium.click_element(eda_lex_locators["contacts_locators"]["contact_save"])

        # Verify the error message that pops up
        self.selenium.wait_until_page_contains_element(
            eda_lex_locators["contacts_locators"]["preferred_error_message"],
            timeout=60
        )
        
        # Enter a value for Home Phone and then save the Contact form
        # After entering a value for Home Phone the form should save 
        # without any error.

        self.selenium.wait_until_page_contains_element(
            eda_lex_locators["contacts_locators"]["phone_home"],
            timeout=60,
            error="Home Phone field not found on Contacts form"
        )
        self.selenium.get_webelement(eda_lex_locators["contacts_locators"]["phone_home"]).send_keys("555-555-1212")
        time.sleep(3) # if we don't wait, then the field doesn't complete the input of the phone number

        # Save the form - this time successfully
        self.selenium.click_element(eda_lex_locators["contacts_locators"]["contact_save"])
        self.eda.close_toast_message()
        self.selenium.driver.switch_to.default_content()

    def place_in_view(self, locator):
        """ Scroll the field or object into the current view 
            Examples:
            | =Function= | =argument= |
            | place_in_view | any locator |
            | self.place_in_view(eda_lex_locators["contacts_locators"]["header"]) | |
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
            eda_lex_locators["contacts_locators"]["apex_jobs"].format(title),
            timeout=60,
            error=error_message
        )
        self.selenium.click_element(eda_lex_locators["contacts_locators"]["apex_jobs"].format(title))
        if capture_screen:
            self.selenium.capture_page_screenshot()

    def run_phone_cleanup(self):
        """ Click on the 'Run Phone Cleanup' button.
            Also verifies that the 'Run Phone Cleanup' was queued to run.
        """

        if self.eda._check_if_element_exists(eda_lex_locators["contacts_locators"]["run_cleanup"]):
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(eda_lex_locators["contacts_locators"]["run_cleanup"])
            )
        self.selenium.wait_until_page_contains("The process was queued successfully")
        self.selenium.wait_until_page_contains_element(
            eda_lex_locators["contacts_locators"]["successful_run"],
            timeout=60
        )

        self.builtin.log("Run Cleanup executed")
        return

    def add_home_phone_to_contact_and_verify(self, name):
        """ Open the contact details and add a home phone and save
            Verify that the home phone is NOT copied to Phone field
            and that the 'Preferred Phone' is set to None
        """
        self.selenium.click_link(name)
        self.salesforce.click_object_button("Edit")
        self.salesforce.wait_until_modal_is_open()
        self.place_in_view(eda_lex_locators["contacts_locators"]["phone_home"])
        self.selenium.driver.execute_script(
            "window.scrollTo(0, document.body.scrollHeight)"
        )
        self.open_item(
            eda_lex_locators["contacts_locators"]["phone_home"],
            "Home Phone field not found on contact", 
            False
        )
        self.selenium.get_webelement(eda_lex_locators["contacts_locators"]["phone_home"]).send_keys("123-123-1234")
        self.open_item(
            eda_lex_locators["contacts_locators"]["footer_save"],
            "Save button not avaible on EDIT Contact page", 
            False
        )
        self.eda.close_toast_message()
        self.eda._check_if_element_exists(eda_lex_locators["contacts_locators"]["phone_verify_has_number"])
        return

    def add_home_phone_and_work_phone_to_contact(self, name, checked):
        """ Open the contact details and add a home phone and office phone
            and save.
        """
        self.selenium.click_link(name)
        self.salesforce.click_object_button("Edit")
        self.salesforce.wait_until_modal_is_open()
        self.place_in_view(eda_lex_locators["contacts_locators"]["phone_home"])
        self.selenium.driver.execute_script(
            "window.scrollTo(0, document.body.scrollHeight)"
        )
        self.open_item(
            eda_lex_locators["contacts_locators"]["phone_home"],
            "Home Phone field not found on contact", 
            False
        )
        self.selenium.clear_element_text(eda_lex_locators["contacts_locators"]["phone_home"])
        self.selenium.get_webelement(eda_lex_locators["contacts_locators"]["phone_home"]).send_keys("456-789-1011")
        time.sleep(3) # if we don't wait, then the field doesn't complete the input of the phone number
        self.selenium.clear_element_text(eda_lex_locators["contacts_locators"]["field_for_work_phone"])
        self.selenium.get_webelement(eda_lex_locators["contacts_locators"]["field_for_work_phone"]).send_keys("121-314-1516")
        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(eda_lex_locators["contacts_locators"]["field_for_work_phone"])
        )

        # Attempt to Save the form
        self.selenium.click_element(eda_lex_locators["contacts_locators"]["contact_save"])
        if checked == "False":
            # Verify the error message that pops up
            self.selenium.wait_until_page_contains_element(
                eda_lex_locators["contacts_locators"]["which_preferred_error_message"],
                timeout=10
            )
            self.selenium.driver.execute_script(
                "arguments[0].scrollIntoView()", 
                self.selenium.driver.find_element_by_xpath(eda_lex_locators["contacts_locators"]["which_footer_cancel"])
            )
            self.open_item(
                eda_lex_locators["contacts_locators"]["which_footer_cancel"],
                "Cancel button not avaible on EDIT Contact page", 
                True
            )
            return
        else:
            self.eda.close_toast_message()
        return

    def verify_contact_values(self, firstname, lastname):
        """ Verify that the Home Phone number is copied to Phone field """

        self.select_contact(firstname, lastname)
        self.selenium.wait_until_page_contains("Details")
        self.selenium.wait_until_page_contains_element(
            eda_lex_locators["contacts_locators"]["details_tab"],
            timeout=60
        )
        self.open_item(
            eda_lex_locators["contacts_locators"]["details_tab"],
            "Details tab not found on contact", 
            False
        )
        self.selenium.driver.refresh()
        self.selenium.wait_until_page_contains_element(
            eda_lex_locators["contacts_locators"]["details_tab"],
            timeout=60
        )
        self.open_item(
            eda_lex_locators["contacts_locators"]["details_tab"],
            "Details tab not found on contact", 
            False
        )

        self.selenium.wait_until_page_contains_element(
            eda_lex_locators["contacts_locators"]["phone_verify"],
            timeout=30
        )
        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(eda_lex_locators["contacts_locators"]["home_phone_verify"])
        )
        self.selenium.wait_until_page_contains_element(
            eda_lex_locators["contacts_locators"]["home_phone_verify"],
            timeout=60
        )
        return

    def go_to_affiliations_edit_mode(self, loc):
        """ Go into Edit mode and remove the con
        """    
        self.selenium.driver.execute_script(
            "arguments[0].click()", 
            self.selenium.driver.find_element_by_xpath(loc)
        )

        self.selenium.driver.execute_script(
            "arguments[0].click()", 
            self.selenium.driver.find_element_by_xpath(eda_lex_locators["contacts_locators"]["delete_icon"])
        )

        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(eda_lex_locators["contacts_locators"]["primary_business_organization"])
        )
        
        xpath = eda_lex_locators["contacts_locators"]["primary_business_organization"]
        field = self.selenium.get_webelement(xpath)
        field.send_keys("Robot Academic Program Account" + Keys.ARROW_DOWN + Keys.ENTER)

        self.selenium.click_element(eda_lex_locators["contacts_locators"]["button_save_affiliation"])
        self.eda.close_toast_message()

    def wait_and_refresh_static_page_until_text(self, search_text, wait_time, loc_frame, loc_text):
        """ Wait for text to appear on static page.  Note that the page is refreshed each 'wait_time' until
            the specified text 'search_text' appears. 
            'loc_text' will return the text portion of the locator
        """    
        self.selenium.driver.refresh()
        self.selenium.select_frame(loc_frame)
        text_portion = self.selenium.get_text(loc_text)
        while text_portion != search_text:
            time.sleep(wait_time)
            self.selenium.driver.refresh()
            self.selenium.select_frame(loc_frame)
            text_portion = self.selenium.get_text(loc_text)
