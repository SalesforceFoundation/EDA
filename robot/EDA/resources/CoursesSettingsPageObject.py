from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
import time

@pageobject("Courses", "HEDA_Settings")
class CoursesSettingsPage(BaseEDAPage, BasePage):

    def _is_current_page(self):
        """
            Verify we are on the EDA Settings page for Courses
            by verifying the HEDA Settings URL and the Courses tab
        """
        location = "/lightning/n/{}{}".format(self.eda.get_eda_namespace_prefix(), self._object_name)
        self.selenium.location_should_contain(location)

        locator_tab = eda_lex_locators["eda_settings"]["tab"].format("Courses")
        self.selenium.wait_until_page_contains_element(
            locator_tab,
            error=f"Courses tab with locator '{locator_tab}' is not available on the page"
        )

    def verify_text_appears(self, textMessage):
        """ Verify the text message is displayed
            this message gets displayed when the 'Run copy' button is clicked
            in both read and edit mode
        """
        time.sleep(0.5) #No other element to wait until this page loads so using sleep
        locator = eda_lex_locators["eda_settings_courses"]["text_message"].format(textMessage)
        self.selenium.wait_until_page_contains_element(locator,
                                                           error="Run copy text is not displayed")
        text = self.selenium.get_webelement(locator).get_attribute("className")
        if "slds-hide" in text:
            raise Exception(f"The text message {textMessage} is not displayed")