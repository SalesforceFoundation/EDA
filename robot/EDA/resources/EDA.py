import logging
import time
import warnings

from BaseObjects import BaseEDAPage
from cumulusci.robotframework.utils import selenium_retry, capture_screenshot_on_error
from robot.libraries.BuiltIn import RobotNotRunningError

from robot.utils import lower
from selenium.common.exceptions import NoSuchWindowException
from selenium.webdriver.common.keys import Keys

from locators_49 import eda_lex_locators as locators_49
from locators_48 import eda_lex_locators as locators_48
locators_by_api_version = {
    49.0: locators_49,  # Summer '20
    48.0: locators_48   # Spring '20
}
# will get populated in _init_locators
eda_lex_locators = {}


@selenium_retry
class EDA(BaseEDAPage):

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    ROBOT_LIBRARY_VERSION = 1.0

    def __init__(self, debug=False):
        self.debug = debug
        self.current_page = None
        self._session_records = []
        # Turn off info logging of all http requests
        logging.getLogger("requests.packages.urllib3.connectionpool").setLevel(
            logging.WARN
        )
        self._init_locators()

    def _init_locators(self):
        try:
            client = self.cumulusci.tooling
            response = client._call_salesforce(
                'GET', 'https://{}/services/data'.format(client.sf_instance)
            )
            self.latest_api_version = float(response.json()[-1]['version'])
            if self.latest_api_version not in locators_by_api_version:
                warnings.warn("Could not find locator library for API %d" % self.latest_api_version)
                self.latest_api_version = max(locators_by_api_version.keys())
        except RobotNotRunningError:
            # We aren't part of a running test, likely because we are
            # generating keyword documentation. If that's the case, assume
            # the latest supported version
            self.latest_api_version = max(locators_by_api_version.keys())
        locators = locators_by_api_version[self.latest_api_version]
        eda_lex_locators.update(locators)

    def populate_address(self, loc, value):
        """ Populate address with Place Holder aka Mailing Street etc as a locator
            and actual value of the place holder.
        """
        xpath = eda_lex_locators["mailing_address"].format(loc)
        field = self.selenium.get_webelement(xpath)
        field.send_keys(value)

    def click_record_button(self, title):
        """ Pass title of the button to click the buttons on the records edit page. Most common buttons are: save and cancel.
        """
        locator = eda_lex_locators["record"]["button"].format(title)
        self.selenium.set_focus_to_element(locator)
        button = self.selenium.get_webelement(locator)
        button.click()

    def click_dropdown(self, title):
        locator = eda_lex_locators["record"]["list"].format(title)
        self.selenium.set_focus_to_element(locator)
        self.selenium.get_webelement(locator).click()

    def pick_date(self, value):
        """To pick a date from the date picker"""
        locator = eda_lex_locators["record"]["datepicker"].format(value)
        self.selenium.set_focus_to_element(locator)
        self.selenium.get_webelement(locator).click()

    def click_edit_button(self, title):
        locator = eda_lex_locators["record"]["edit_button"].format(title)
        self.selenium.get_webelement(locator).click()

    def click_run_action_button(self,text):
        """ This method clicks the any action button (blue in color) present in EDA settings sub
            tabs. Pass the name of the button from robot file.
        """
        locator = eda_lex_locators["eda_settings"]["run_action"].format(text)
        self.selenium.wait_until_page_contains_element(
            locator, error=f"Run action button with locator '{locator}' is not available")
        self.selenium.click_element(locator)

    def verify_record(self, name):
        """ Checks for the record in the object page and returns true if found else returns false
        """
        locator = eda_lex_locators["account_list"].format(name)
        self.selenium.page_should_contain_element(locator)

    def header_field_value(self, title, value):
        """Validates if the specified header field has specified value"""
        locator = eda_lex_locators["header_field_value"].format(title, value)
        self.selenium.page_should_contain_element(locator)

    def select_modal_checkbox(self, title):
        """"""
        locator = eda_lex_locators["modal"]["checkbox"].format(title)
        self.selenium.get_webelement(locator).click()

    def select_relatedlist(self, title):
        """click on the related list to open it"""
        locator = eda_lex_locators["record"]["related"]["title"].format(title)
        element = self.selenium.driver.find_element_by_xpath(locator)
        self.selenium.driver.execute_script('arguments[0].click()', element)

    def select_checkbox_in_eda_settings(self, loc_check, loc_checkbox):
        """ Selects checkbox.  Does nothing if checkbox is already checked """
        if self._check_if_element_exists(loc_check):
            return
        else:
            self.selenium.click_button("Edit")
            self.selenium.get_webelement(loc_checkbox).click()
            self.selenium.click_button("Save")
            self.selenium.wait_until_element_is_visible(loc_check)
            return

    def _check_if_element_exists(self, xpath):
        """
            Checks if the given xpath exists
            this is only a helper function being called from other keywords
        """
        elements = int(self.selenium.get_element_count(xpath))
        return True if elements > 0 else False

    def get_eda_locator(self, path, *args, **kwargs):
        """ Returns a rendered locator string from the eda_lex_locators
            dictionary.  This can be useful if you want to use an element in
            a different way than the built in keywords allow.
        """
        locator = eda_lex_locators
        for key in path.split('.'):
            locator = locator[key]
        main_loc = locator.format(*args, **kwargs)
        return main_loc

    def wait_for_new_window(self, title):
        """ Waits for specified window to be available
            by checking every 1 seconds for 25 times
        """
        window_found = False

        for i in range(25):
            i += 1
            time.sleep(1)
            titles = self.selenium.get_window_titles()
            for j in titles:
                if j == title:
                    window_found = True
                    return window_found

            if window_found:
                return
            else:
                continue

        self.builtin.log("Timed out waiting for window with title " + title)
        return window_found

    @capture_screenshot_on_error
    def wait_for_locator(self, path, *args, **kwargs):
        main_loc = self.get_eda_locator(path,*args, **kwargs)
        self.selenium.wait_until_element_is_visible(main_loc, timeout=60)

    @capture_screenshot_on_error
    def click_on_element(self,path, *args, **kwargs):
        main_loc = self.get_eda_locator(path,*args, **kwargs)
        self.selenium.wait_until_element_is_visible(main_loc)
        self.selenium.click_element(main_loc)

    def java_click_on_element(self,path, *args, **kwargs):
        main_loc = self.get_eda_locator(path,*args, **kwargs)
        self.selenium.wait_until_element_is_visible(main_loc)
        # javascript is being used here because the usual selenium click is highly unstable for this element on MetaCI

        self.selenium.driver.execute_script(
            "arguments[0].click()",
            self.selenium.driver.find_element_by_xpath(main_loc))
        time.sleep(1)

    def format_all(self, loc, value):
        """ Formats the given locator with the value for all {} occurrences """
        count = 0
        for s in loc:
            if s is '{':
                count += 1

        if count == 1:
            return loc.format(value)
        elif count == 2:
            return loc.format(value, value)
        elif count == 3:
            return loc.format(value, value, value)

    def populate_placeholder(self, loc, value):
        """ Populate placeholder element as a locator
            and actual value of the place holder.
        """
        xpath = eda_lex_locators["input_placeholder"].format(loc)
        field = self.selenium.get_webelement(xpath)
        field.send_keys(value)
        field.send_keys(Keys.ARROW_DOWN + Keys.ENTER)

    def edit_eda_settings_checkbox(self, checkbox_label, checkbox_toggle):
        """ Updates the checkbox_label value to checkbox_toggle in the EDA settings page """
        locator_checkbox_default = eda_lex_locators["eda_settings"]["checkbox_default"].format(checkbox_label)
        locator_checkbox = eda_lex_locators["eda_settings"]["checkbox"].format(checkbox_label)
        locator_edit = eda_lex_locators["eda_settings"]["edit"]
        locator_save = eda_lex_locators["eda_settings"]["save"]

        checkbox_default = self.selenium.get_element_attribute(locator_checkbox_default, "alt")
        if checkbox_default == checkbox_toggle:
            return
        else:
            self.selenium.click_element(locator_edit)
            self.selenium.wait_until_page_contains_element(
                locator_checkbox,
                error="Checkbox not found on the page"
            )
            self.selenium.click_element(locator_checkbox)
            self.selenium.click_element(locator_save)
            locator_toast = eda_lex_locators["success_message"].format("Settings successfully saved.")
            self.selenium.wait_until_page_contains_element(locator_toast)

    def verify_toast_message(self, value):
        """ Verifies the toast message """
        locator = eda_lex_locators["toast_message"].format(value)
        self.selenium.wait_until_page_contains_element(locator)

    def close_toast_message(self):
        """ Close the toast message banner """
        self.selenium.wait_until_element_is_visible(eda_lex_locators["toast_close"])
        self.selenium.click_element(eda_lex_locators["toast_close"])
        self.selenium.wait_until_element_is_not_visible(eda_lex_locators["toast_close"])

    def get_eda_namespace_prefix(self):
        """ Returns the EDA namespace value if the target org is a managed org else returns blank value """
        if not hasattr(self.cumulusci, '_describe_result'):
            self.cumulusci._describe_result = self.cumulusci.sf.describe()
        objects = self.cumulusci._describe_result['sobjects']
        level_object = [o for o in objects if o['label'] == 'Program Plan'][0]
        return self._get_namespace_prefix(level_object['name'])

    def _get_namespace_prefix(self, name):
        """" This is a helper function to capture the EDA namespace prefix of the target org """
        parts = name.split('__')
        if parts[-1] == 'c':
            parts = parts[:-1]
        if len(parts) > 1:
            return parts[0] + '__'
        else:
            return ''

    def close_all_tabs(self):
        """ Gets the count of the tabs that are open and closes them all """
        locator = eda_lex_locators["close_tab"]
        count = int(self.selenium.get_element_count(locator))
        for i in range(count):
            self.selenium.wait_until_element_is_visible(locator)
            self.selenium.get_webelement(locator).click()

    def click_on_element_if_exists(self, path, *args, **kwargs):
        """ Clicks on the element if it exists
            by building a locator using the path and args
            but the keyword will not fail in case the element doesn't exist
        """
        main_loc = self.get_eda_locator(path, *args, **kwargs)
        if self._check_if_element_exists(main_loc):
            self.selenium.click_element(main_loc)

    @capture_screenshot_on_error
    def select_tab(self, title):
        """ Switch between different tabs on a record page like Related, Details, News, Activity and Chatter
            Pass title of the tab
        """
        tab_found = False
        locators = eda_lex_locators["tabs"].values()
        for i in locators:
            locator = i.format(title)
            if self._check_if_element_exists(locator):
                print(locator)
                buttons = self.selenium.get_webelements(locator)
                for button in buttons:
                    print(button)
                    if button.is_displayed():
                        print("button displayed is {}".format(button))
                        self.salesforce._focus(button)
                        button.click()
                        time.sleep(5)
                        tab_found = True
                        break

        assert tab_found, "tab not found"

    def shift_to_default_content(self):
        """ Returns to main content, and out of iframe """
        self.selenium.driver.switch_to.default_content()
        currentFrame = self.selenium.driver.execute_script("return self.name")
        self.builtin.log(
            "Current frame 2: " + currentFrame
        )
        return

    def open_custom_settings(self, title, error_message, capture_screen):
        """ Performs a wait until the element shows on the page, and clicks the element """
        self.selenium.wait_until_page_contains_element(
            eda_lex_locators["custom_settings_title"].format(title),
            timeout=60,
            error=error_message
        )
        self.selenium.click_element(eda_lex_locators["custom_settings_title"].format(title))
        if capture_screen:
            self.selenium.capture_page_screenshot()

    def verify_app_exists(self, app):
        """Verifies that the given app is present in the app launcher"""
        locator = eda_lex_locators["app_tile"].format(app)
        self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{app} did not open in 1 min')

    def select_frame_with_value(self, value):
        """ Selects the first displayed iframe on the page identified by the given value
            :param value should be the 'id', 'title' or 'name' attribute of the webelement used to identify the iframe
        """
        locator = eda_lex_locators['frame'].format(value, value, value)
        frames = self.selenium.get_webelements(locator)
        for frame in frames:
            if frame.is_displayed():
                for i in range(10):
                    try:
                        self.selenium.select_frame(locator)
                        return
                    except NoSuchWindowException:
                        self.builtin.log("Caught NoSuchWindowException; trying again..", "WARN")
                        i += 1
                        time.sleep(0.5)
                        continue
        raise Exception('Unable to find an iframe with a name, title or id with value "{}"'.format(value))

    def go_to_eda_settings_tab(self, tab):
        """ Navigates to EDA settings URL and click on the tab passed by the parameter
            and then loads the page object identified by the tab name
        """
        url_pattern = "{root}/lightning/n/{object}"
        object_name = "{}HEDA_Settings".format(self.get_eda_namespace_prefix())
        url = url_pattern.format(root=self.cumulusci.org.lightning_base_url, object=object_name)
        self.selenium.go_to(url)
        self.salesforce.wait_until_loading_is_complete()
        self.wait_for_locator("frame", "accessibility title", "accessibility title", "accessibility title")
        self.select_frame_with_value("accessibility title")

        locator_tab = eda_lex_locators["eda_settings"]["tab"].format(tab)
        self.selenium.wait_until_page_contains_element(locator_tab, error=f"'{tab}' tab is not available on the page")
        self.salesforce._jsclick(locator_tab)
        tab = tab.replace(" ", "_")
        self.pageobjects.load_page_object(tab, "HEDA_Settings")

    def click_edit_on_eda_settings_page(self):
        locator = eda_lex_locators["eda_settings"]["edit"]
        self.selenium.wait_until_page_contains_element(locator, error="Edit button is not available on the page")
        self.selenium.wait_until_element_is_visible(locator)
        self.selenium.click_element(locator)

    def click_action_button_on_eda_settings_page(self, action):
        """ Clicks on the action (eg: Save, Cancel) button on the EDA Settings page """
        locator = eda_lex_locators["eda_settings"]["action"].format(lower(action))
        self.selenium.wait_until_page_contains_element(
            locator, error=f"Action button with locator '{locator}' is not available on the EDA settings page")
        self.selenium.click_element(locator)
        if action == "Save":
            self.verify_toast_message("Settings successfully saved.")
            self.close_toast_message()

    def update_dropdown_value(self,**kwargs):
        """ This method will update the drop down field value passed in keyword arguments
            Pass the expected value to be set in the drop down field from the tests
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_cc"]["dropdown_values"].format(field,value)
            self.selenium.wait_until_page_contains_element(locator,
                                                error=f"'{value}' as dropdown value in '{field}' field is not available ")
            self.selenium.click_element(locator)

    def verify_selected_dropdown_value(self,**kwargs):
        """ This method will confirm if the value to be set in dropdown field is retained after save action
            Pass the expected value to be verified from the tests using keyword arguments
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_cc"]["updated_dropdown_value"].format(field,value)
            self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
            actual_value = self.selenium.get_webelement(locator).text
            if not str(value).lower() == str(actual_value).lower() :
                raise Exception (f"Drop down value in '{field}' is not updated and the value is '{actual_value}'")

    def verify_dropdown_field_status(self, **kwargs):
        """ Verify the drop down field is disabled/enabled for the user
            we have to pass the name of the field and the expected status
            of the field as either enabled or disabled
        """
        for field,expected_value in kwargs.items():
            locator = eda_lex_locators["eda_settings"]["dropdown_field"].format(field)
            self.selenium.page_should_contain_element(locator)
            self.selenium.wait_until_element_is_visible(locator,
                                                error= f"Element '{field}' is not displayed for the user")
            actual_value = self.selenium.get_webelement(locator).get_attribute(expected_value)
            expected_value = bool(expected_value == "disabled")
            if not str(expected_value).lower() == str(actual_value).lower() :
                raise Exception (f"Drop down field {field} status is {actual_value} instead of {expected_value}")
