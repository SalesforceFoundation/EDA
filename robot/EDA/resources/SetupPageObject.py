from BaseObjects import BaseEDAPage
from cumulusci.robotframework.pageobjects import HomePage
from cumulusci.robotframework.pageobjects import pageobject


@pageobject("Home", "Setup")
class SetupHomePage(BaseEDAPage, HomePage):

    def _go_to_page(self):
        """ Navigate to the Setup Home via URL and switch to the new window """
        self.salesforce.go_to_setup_home()
        self.eda.wait_for_new_window("Home | Salesforce")
        self.selenium.switch_window("Home | Salesforce")
        self.salesforce.wait_until_loading_is_complete()

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
