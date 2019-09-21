import time

from selenium.webdriver.common.keys import Keys
from cumulusci.robotframework.pageobjects import HomePage
from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import DetailPage

from cumulusci.robotframework.pageobjects import pageobject
from locators import trigger_handlers_locators



@pageobject("Home", "TriggerHandlers")
class TriggerHandlersHomePage(BasePage):
    object_name = None

    @property
    def eda(self):
        return self.builtin.get_library_instance('EDA')

    def _is_current_page(self):
        """ Verify we are on the Trigger Handlers page
            by verifying that the header title is 'Trigger Handlers'
        """
        locator = trigger_handlers_locators["header"]
        #self.selenium.click_element(locator)
        self.selenium.page_should_contain_element(
            locator,
            message="Header with text 'Trigger Handlers' is not available on the page"
        )

    def check_if_element_exists(self, xpath):
        """ Checks if the given xpath exists """
        elements = int(self.selenium.get_matching_xpath_count(xpath))
        return True if elements > 0 else False

    def click_action_button(self):
        """ Clicks on the 'Action' button in Contacts """
        locator = trigger_handlers_locators["action"]
        locator_close_action = trigger_handlers_locators["action_close"]

        # In some cases, the action dialog opens by default,
        # hence making sure it is closed, before opening it otherwise it would nullify the click command
        if self.eda.check_if_element_exists(locator_close_action):
            self.selenium.click_element(locator_close_action)

        self.selenium.wait_until_page_contains_element(
            locator,
            error="'Action' button is not available on Contacts page"
        )
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


    def select_action(self, action):
        """ Select the action shortcut """
        locator = trigger_handlers_locators["action_shortcut"].format(action)
        self.selenium.wait_until_page_contains_element(locator,
                                                       error="Action '" + action + "' doesn't exist in the list of Action Shortcuts")
        self.selenium.click_element(locator)

    def select_EDA_tab(self, tab):
        """ Selects Contacts tab - as passed in to the function """
        locator_menu = trigger_handlers_locators["tab_menu"].format(tab)
        element_menu = self.selenium.driver.find_element_by_xpath(locator_menu)
        self.selenium.wait_until_page_contains_element(
            locator_menu,
            error="Contact tab unavailable"
        )
        # javascript is being used here because the usual selenium click is highly unstable for this element on MetaCI
        self.selenium.driver.execute_script("arguments[0].click()", locator_menu)
        time.sleep(1)

        # Sometimes, single click fails. Hence an additional condition to click on it again
        if not self.check_if_element_exists(locator_menu):
            self.selenium.driver.execute_script("arguments[0].click()", element_menu)
            time.sleep(1)


    def verify_trigger_handler(self, trigger):
        """ Verify that trigger handler exists """
        locator_dropdown = trigger_handlers_locators["recently_viewed"]
        locator = trigger_handlers_locators["search_exists"]
        locator_trigger = trigger_handlers_locators["trigger"].format(trigger)
        locator_all_main = trigger_handlers_locators["all_main_fields"]
        locator_preferred_phone = trigger_handlers_locators["preferred_phone"]
        locator_handler = trigger_handlers_locators["trigger_handler"]

        self.selenium.wait_until_page_contains_element(
            locator_dropdown,
            error=locator_trigger + " locator is not available in Trigger Handlers page"
        )
        self.selenium.click_element(locator_dropdown)

        self.selenium.wait_until_page_contains_element(
            locator_all_main,
            error=locator_all_main + " locator is not available in Trigger Handlers page"
        )
        self.selenium.click_element(locator_all_main)

        self.selenium.wait_until_page_contains_element(
            locator,
            error=trigger + " object not found in Trigger Handlers"
        )
        self.selenium.click_element(locator)
        self.selenium.get_webelement(locator).send_keys(trigger + Keys.RETURN)

        # Verify that the CON_PreferredPhone_TDTM object has been found
        self.selenium.wait_until_page_contains_element(
            locator_preferred_phone,
            error="CON_PreferredPhone_TDTM not found in Trigger Handler list"
        )

        time.sleep(1)
        self.selenium.wait_until_page_contains_element(
            locator_handler,
            error="Unable to find Preferred Phone Trigger Handler "
        )
        self.selenium.click_element(locator_handler)

    def select_active_checkbox(self, loc_check, loc_checkbox):
        """ Selects checkbox.  Does nothing if checkbox is already checked """
        if self.check_if_element_exists(loc_check):
            return
        else:
            self.selenium.click_button("Edit Active")
            self.selenium.get_webelement(loc_checkbox).click()
            self.selenium.click_button("Save")
            self.selenium.wait_until_element_is_visible(loc_check)
            return

    def set_trigger_to_active(self, trigger):
        """ Set Preferred Phone trigger to Active.  Leave Active if already checked """
        locator_dropdown = trigger_handlers_locators["recently_viewed"]

        locator_check = trigger_handlers_locators["trigger_active_check"]
        locator_checkbox = trigger_handlers_locators["trigger_checkbox"]
        locator_save = trigger_handlers_locators["trigger_save"]

        if self.check_if_element_exists(locator_check):
            return
        else:
            self.selenium.click_button("Edit Active")

            self.selenium.wait_until_element_is_visible(locator_checkbox)
            self.selenium.get_webelement(locator_checkbox).click()

            self.selenium.click_element(locator_save)
            time.sleep(1)
            self.selenium.wait_until_element_is_visible(locator_check)
            return
