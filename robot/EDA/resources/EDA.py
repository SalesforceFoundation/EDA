import logging
import time
import datetime
import pytz

from cumulusci.robotframework.utils import selenium_retry
from locators import eda_lex_locators
from locators import contacts_locators

from robot.libraries.BuiltIn import BuiltIn
from selenium.webdriver.common.keys import Keys
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from selenium.webdriver.common.keys import Keys


@selenium_retry
class EDA(object):

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

    @property
    def builtin(self):
        return BuiltIn()

    @property
    def salesforce(self):
        return self.builtin.get_library_instance('cumulusci.robotframework.Salesforce')

    @property
    def cumulusci(self):
        return self.builtin.get_library_instance("cumulusci.robotframework.CumulusCI")

    @property
    def selenium(self):
        return self.builtin.get_library_instance("SeleniumLibrary")

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

    def click_special_related_list_button(self, heading, button_title):
        """ To Click on a related list button which would open up a new lightning page rather than a modal.
            Pass the list name and button name
        """
        locator = eda_lex_locators["record"]["related"]["button"].format(
            heading, button_title
        )
        self.selenium.set_focus_to_element(locator)
        self.selenium.get_webelement(locator).click()

    def click_dropdown(self, title):
        locator = eda_lex_locators["record"]["list"].format(title)
        self.selenium.set_focus_to_element(locator)
        self.selenium.get_webelement(locator).click()

    def pick_date(self, value):
        """To pick a date from the date picker"""
        locator = eda_lex_locators["record"]["datepicker"].format(value)
        self.selenium.set_focus_to_element(locator)
        self.selenium.get_webelement(locator).click()

    def select_row(self, value):
        """To select a row on object page based on name and open the dropdown"""
        drop_down = eda_lex_locators["locating_delete_dropdown"].format(value)
        self.selenium.get_webelement(drop_down).click()

    def select_related_row(self, value):
        """To select row from a related list based on name and open the dropdown"""
        locators = eda_lex_locators["related_name"]
        list_ele = self.selenium.get_webelements(locators)
        index = 1
        for locator in list_ele:
            if locator.text != value:
                index = index + 1
            else:
                drop_down = eda_lex_locators["rel_loc_dd"].format(index)
                self.selenium.get_webelement(drop_down).click()
                self.selenium.get_webelement(drop_down).click()

    def select_the_tab(self, title):
        """ Switch between different tabs on a record page like Related, Details, News, Activity and Chatter
            Pass title of the tab
        """
        locator = eda_lex_locators["contacts_tab"].format(title)

        self.builtin.log("locator for select_tab is: " + locator , "INFO")

        self.selenium.wait_until_page_contains_element(
            locator, 
            timeout=60,
            error="List header '{}' is not available on the page".format(title)
        )
        self.selenium.set_focus_to_element(locator)
        self.selenium.get_webelement(locator).click()

    def click_x_icon(self, field_name, value):
        """To click on x """
        locator = eda_lex_locators["delete_icon"].format(field_name, value)
        self.selenium.get_webelement(locator).click()

    def click_edit_button(self, title):
        locator = eda_lex_locators["record"]["edit_button"].format(title)
        self.selenium.get_webelement(locator).click()

    def click_id(self, title):
        locator = eda_lex_locators["aff_id"].format(title)
        self.selenium.get_webelement(locator).click()

    def select_object_dropdown(self):
        locator = eda_lex_locators["object_dd"]
        self.selenium.get_webelement(locator).click()

    def check_status(self, acc_name):
        aff_list = eda_lex_locators["aff_status"].format(acc_name)
        aff_list_text = self.selenium.get_webelement(aff_list).text
        self.aff_id = eda_lex_locators["aff_id"].format(acc_name)
        self.aff_id_text = self.selenium.get_webelement(self.aff_id).text
        return self.aff_id_text, aff_list_text

    def get_id(self):
        locator = eda_lex_locators["click_aff_id"].format(self.aff_id_text)
        self.selenium.get_webelement(locator).click()

    def confirm_status(self, field, status):
        locator = eda_lex_locators["check_status"].format(field, status)
        verify_former = self.selenium.get_webelement(locator).text
        return verify_former

    def verify_field_value(self, field, value):
        locator = eda_lex_locators["check_field"].format(field, value)
        verify_former = self.selenium.get_webelement(locator).text
        return verify_former

    def verify_record(self, name):
        """ Checks for the record in the object page and returns true if found else returns false
        """
        locator = eda_lex_locators["account_list"].format(name)
        self.selenium.page_should_contain_element(locator)

    def select_option(self, name):
        """selects various options in Contact>New opportunity page using name
        """
        locator = eda_lex_locators["dd_options"].format(name)
        self.selenium.get_webelement(locator).click()

    def verify_related_list_items(self, list_name, value):
        """Verifies a specified related list has specified value(doesn't work if the list is in table format)"""
        locator = eda_lex_locators["related_list_items"].format(list_name, value)
        self.selenium.page_should_contain_element(locator)

    def header_field_value(self, title, value):
        """Validates if the specified header field has specified value"""
        locator = eda_lex_locators["header_field_value"].format(title, value)
        self.selenium.page_should_contain_element(locator)

    def verify_details_address(self, field, value):
        """Validates if the details page address field has specified value"""
        locator = eda_lex_locators["detail_page"]["address"].format(field, value)
        self.selenium.page_should_contain_element(locator)

    def check_field_value(self, title, value):
        """checks value of a field in details page(section without header)"""
        locator = eda_lex_locators["detail_page"]["verify_field_value"].format(
            title, value
        )
        self.selenium.page_should_contain_element(locator)

    def select_modal_checkbox(self, title):
        """"""
        locator = eda_lex_locators["modal"]["checkbox"].format(title)
        self.selenium.get_webelement(locator).click()

    def select_related_dropdown(self, title):
        """"""
        locator = eda_lex_locators["record"]["related"]["drop-down"].format(title)
        self.selenium.get_webelement(locator).click()

    def get_header_date_value(self, title):
        """Validates if the specified header field has specified value"""
        locator = eda_lex_locators["header_datepicker"].format(title)
        date = self.selenium.get_webelement(locator).text
        return date

    def get_main_header(self):
        header = self.selenium.get_webelement("//h1/span").text
        return header

    def verify_contact_role(self, name, role):
        """verifies the contact role on opportunity page"""
        locator = eda_lex_locators["opportunity"]["contact_role"].format(name, role)
        self.selenium.page_should_contain_element(locator)

    def select_relatedlist(self, title):
        """click on the related list to open it"""
        locator = eda_lex_locators["record"]["related"]["title"].format(title)
        self.selenium.get_webelement(locator).click()

    def verify_contact_roles(self, **kwargs):
        """"""
        for name, value in kwargs.items():
            locator = eda_lex_locators["object"]["contact_role"].format(name, value)
            self.selenium.page_should_contain_element(locator)

    def page_contains_record(self, title):
        """Validates if the specified record is present on the page"""
        locator = eda_lex_locators["object"]["record"].format(title)
        self.selenium.page_should_not_contain_element(locator)

    def select_checkbox_in_eda_settings(self, loc_check, loc_checkbox):
        """ Selects checkbox.  Does nothing if checkbox is already checked """
        if self.check_if_element_exists(loc_check):
            return
        else:
            self.selenium.click_button("Edit")
            self.selenium.get_webelement(loc_checkbox).click()
            self.selenium.click_button("Save")
            self.selenium.wait_until_element_is_visible(loc_check)
            return

    def check_if_element_exists(self, xpath):
        elements = int(self.selenium.get_matching_xpath_count(xpath))
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
        
    def wait_for_locator(self, path, *args, **kwargs):
        main_loc = self.get_eda_locator(path,*args, **kwargs)    
        self.selenium.wait_until_element_is_visible(main_loc)
            
    def click_on_element(self,path, *args, **kwargs):
        main_loc = self.get_eda_locator(path,*args, **kwargs)
        self.selenium.wait_until_element_is_visible(main_loc)
        self.selenium.click_element(main_loc)

    def populate_placeholder(self, loc, value):
        """ Populate placeholder element as a locator
            and actual value of the place holder.
        """
        xpath = eda_lex_locators["input_placeholder"].format(loc)
        field = self.selenium.get_webelement(xpath)
        field.send_keys(value)
#         if loc == ("Search Contacts" or "Search Accounts"):
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
            self.success_message("Settings Saved Successfully.")

    def verify_toast_message(self, value):
        """ Verifies the toast message """
        locator = eda_lex_locators["toast_message"].format(value)
        self.selenium.wait_until_page_contains_element(locator)

    def success_message(self, value):
        """ Acknowledges the success message """
        locator = eda_lex_locators["success_message"].format(value)
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
        count = int(self.selenium.get_matching_xpath_count(locator))
        for i in range(count):
            self.selenium.wait_until_element_is_visible(locator)
            self.selenium.get_webelement(locator).click()

    def click_on_element_if_exists(self, path, *args, **kwargs):
        """ Clicks on the element if it exists
            by building a locator using the path and args
            but the keyword will not fail in case the element doesn't exist
        """
        main_loc = self.get_eda_locator(path, *args, **kwargs)
        if self.check_if_element_exists(main_loc):
            self.selenium.click_element(main_loc)

    def convert_time_to_UTC_timezone(self, my_time):
        """ Converts the given datetime to UTC timezone
            my_time should be in the format %Y-%m-%d %H:%M:%S
        """
        my_time_format = datetime.datetime.strptime(my_time, "%Y-%m-%d %H:%M:%S.%f")
        my_time_local = pytz.timezone("America/Los_Angeles").localize(my_time_format, is_dst=None)

        my_time_utc = my_time_local.astimezone(pytz.utc)
        return datetime.datetime.strftime(my_time_utc, "%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"

    def get_eda_locator(self, path, *args, **kwargs):
        """ Returns a rendered locator string from the eda_lex_locators
            dictionary. This can be useful if you want to use an element in
            a different way than the built in keywords allow.
        """
        locator = eda_lex_locators
        for key in path.split('.'):
            locator = locator[key]
        main_loc = locator.format(*args, **kwargs)
        return main_loc

    def select_navigation_tab(self, tab):
        """ Selects navigation tab - as passed in to the function 
            tab is not a locator, but is a label on a tab.
        """
        locator_menu = eda_lex_locators["navigation_menu"]
        element_menu = self.selenium.driver.find_element_by_xpath(locator_menu)
        locator_tab = eda_lex_locators["navigation_tab"].format(tab)

        self.selenium.wait_until_page_contains_element(
            locator_menu,
            error="Navigation menu drop down unavailable"
        )
        # javascript is being used here because the usual selenium click is highly unstable for this element on MetaCI
        self.selenium.driver.execute_script("arguments[0].click()", element_menu)

        # Sometimes, single click fails. Hence an additional condition to click on it again
        if not self.check_if_element_exists(locator_tab):
            self.selenium.driver.execute_script("arguments[0].click()", element_menu)

        self.selenium.wait_until_page_contains_element(
            locator_tab,
            error=tab + " item not found as an available option in: " + locator_tab
        )
        self.selenium.click_element(locator_tab)

    def choose_panel_tab(self,tab):
        """ Opens panel tab - as passed in to the function
            tab is a label on menu item, and not a locator.
        """
        self.selenium.wait_until_page_contains_element(
            eda_lex_locators["choose_tab"].format(tab), 
            timeout=60,
            error="Cannot find the panel tab: " + tab
        )
        self.selenium.click_element(eda_lex_locators["choose_tab"].format(tab))

    def select_tab(self, tab):
        """ Select tab - as passed in to the function
            tab is a label on menu item, and not a locator.
        """
        locator_menu = eda_lex_locators["tab_menu"].format(tab)
        element_menu = self.selenium.driver.find_element_by_xpath(locator_menu)
        locator_tab = eda_lex_locators["tab_tab"].format(tab)
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

    def shift_to_default_content(self):
        """ Returns to main content, and out of iframe """
        self.selenium.driver.switch_to.default_content()
        currentFrame = self.selenium.driver.execute_script("return self.name")
        self.builtin.log(
            "Current frame 2: " + currentFrame
        )
        return

