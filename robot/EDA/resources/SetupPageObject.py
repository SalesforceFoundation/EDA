from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
from selenium.webdriver.common.keys import Keys
import time

@pageobject("Home", "Setup")
class SetupHomePage(BaseEDAPage, BasePage):

    def _go_to_page(self):
        """ Navigate to the Setup Home via URL and switch to the new window """
        self.salesforce.go_to_setup_home()
        self.eda.wait_for_new_window("Home | Salesforce")
        self.selenium.switch_window("Home | Salesforce")
        self.salesforce.wait_until_loading_is_complete()

    def click_custom_settings(self, setting):
        """ Clicks the custom settings using the name of the setting passed from the test
        """
        locator = eda_lex_locators["eda_setup"]["custom_settings"].format(setting)
        self.selenium.wait_until_page_contains_element(locator)
        self.selenium.wait_until_element_is_visible(locator)
        self.selenium.click_element(locator)

    def click_custom_settings_action_button(self, button):
        """ Clicks the custom settings button using the name of the button passed from the test
        """
        locator = eda_lex_locators["eda_setup"]["settings_action_button"].format(button)
        self.selenium.wait_until_page_contains_element(locator)
        self.selenium.wait_until_element_is_visible(locator)
        self.selenium.click_element(locator)

    def select_hierarchy_settings(self, frame, setting):
        """
            This method navigates from custom settings home screen to hierarchy settings. Pass the
            arguments (name of the link, button and name of the iframe to be selected) from the
            tests
        """
        self.eda.select_frame_with_value(frame)
        self.click_custom_settings(setting)
        self.selenium.unselect_frame()

    def go_to_hierarchy_settings_view(self, frame, button):
        """
            This method navigates from selected hierarchy settings home screen to hierarchy
            settings view. Pass the arguments (name of the link, button and name of the iframe to
            be selected) from the tests
        """
        self.eda.select_frame_with_value(frame)
        self.click_custom_settings_action_button(button)
        self.selenium.unselect_frame()

    def perform_a_quick_find_on(self, item):
        """ Searches for the given item through Quick Find on Setup page """
        self.eda.populate_placeholder("Quick Find", item)

    def wait_and_refresh_static_page_until_text(self, search_text, wait_time, loc_frame, loc_text):
        """ Wait for text to appear on static page.  Note that the page is refreshed each 'wait_time' until
            the specified text 'search_text' appears.
            'loc_text' will return the text portion of the locator
        """
        self.selenium.driver.refresh()
        self.selenium.select_frame(loc_frame)
        text_portion = self.selenium.get_text(loc_text)
        while text_portion != search_text:
            self.selenium.driver.refresh()
            self.selenium.select_frame(loc_frame)
            text_portion = self.selenium.get_text(loc_text)

    def verify_setup_owner_section(self, frame, value):
        """ Verifies the set up owner section"""
        self.eda.select_frame_with_value(frame)
        locator = eda_lex_locators["eda_setup"]["setup_owner"]
        self.selenium.wait_until_page_contains_element(locator)
        actual_value = self.selenium.get_webelement(locator).text
        self.builtin.log("Set up owner table value :" + actual_value)
        self.selenium.unselect_frame()
        if not str(value).lower() == str(actual_value).lower() :
                raise Exception (f"Expected {value} but it displayed {actual_value}")
