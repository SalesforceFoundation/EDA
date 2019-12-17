import datetime
import logging
import time
import pytz

from cumulusci.robotframework.pageobjects import ListingPage
from cumulusci.robotframework.pageobjects import pageobject
from locators import affiliations_locators
from locators import eda_lex_locators
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

@pageobject("Listing", "hed__HEDA_Settings")
class EDASettingsPage(ListingPage):
    object_name = "hed__HEDA_Settings"

    @property
    def eda(self):
        return self.builtin.get_library_instance('EDA')

    @property
    def pageobjects(self):
        return self.builtin.get_library_instance("cumulusci.robotframework.PageObjects")

    def _is_current_page(self):
        """ Verify we are on the EDA Settings page
            by verifying that the header title is 'EDA Settings'
        """
        locator = affiliations_locators["header"]
        self.selenium.page_should_contain_element(
            locator,
            message="Header with text 'EDA Settings' is not available on the page"
        )

    def _go_to_page(self, filter_name=None):
        url_pattern = "{root}/lightning/n/{object}"
        name = self._object_name
        object_name = "{}{}".format(self.cumulusci.get_namespace_prefix(), name)
        url = url_pattern.format(root=self.cumulusci.org.lightning_base_url, object=object_name)
        self.selenium.go_to(url)
        self.salesforce.wait_until_loading_is_complete()
        self.eda.wait_for_locator("frame", "accessibility title")
        self.salesforce.select_frame_with_title("accessibility title")


    def _check_if_element_exists(self, xpath):
        """ Checks if the given xpath exists """
        elements = int(self.selenium.get_element_count(xpath))
        return True if elements > 0 else False

    def verify_toast_message(self, value):
        """ Verifies the toast message """
        self.selenium.wait_until_page_contains_element(affiliations_locators["toast_message"].format(value))

    def place_in_view(self,locator):
        """ Scroll the field or object into the current view 
            Examples:
            | =Function= | =argument= |
            | place_in_view | any locator |
            | self.place_in_view(affiliations_locators["header"]) | |
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
#        self.selenium.click_element(locator)

        self.selenium.driver.execute_script(
            "arguments[0].click()", 
            self.selenium.driver.find_element_by_xpath(locator)
        )


        if capture_screen:
            self.selenium.capture_page_screenshot()

    def go_to_affiliation_settings(self):
        """ Navigate to the Affiliations and Settings pages """
        self.open_item(
            affiliations_locators["affiliations_tab"],
            "Cannot find the Affiliations tab",
            False
        )
        self.open_item(
            affiliations_locators["affiliations_settings_tab"],
            "Cannot find the Settings tab in the Affiliations page",
            False
        )
        return

    def go_to_affiliation_mappings(self):
        """ Navigate to the Affiliations and Affiliation Mappings page """
        self.open_item(
            affiliations_locators["affiliations_tab"],
            "Cannot find the Affiliations tab",
            False
        )
        self.open_item(
            affiliations_locators["affiliations_mappings_tab"],
            "Cannot find the Affiliation Mappings tab in the Affiliations page",
            False
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
            self.selenium.driver.find_element_by_xpath(affiliations_locators["delete_icon"])
        )

        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(affiliations_locators["primary_business_organization"])
        )
        
        xpath = affiliations_locators["primary_business_organization"]
        field = self.selenium.get_webelement(xpath)
        field.send_keys("Robot Academic Program Account" + Keys.ARROW_DOWN + Keys.ENTER)

        self.selenium.click_element(affiliations_locators["button_save_affiliation"])
        self.eda.close_toast_message()

    def _expandShadowRoot(self, element):
        shadow_root = self.selenium.driver.execute_script('return arguments[0].shadowRoot', element)
        return shadow_root


    def expand_shadow_root(self):
        root1 = self.selenium.driver.find_element_by_xpath(affiliations_locators["del_xpath_arm"])
        shadow_root_1 = self._expandShadowRoot(root1)
        #delete_button = shadow_root_1.find_element_by_css_selector("#delete")
        #delete_button.click()
        self.builtin.log("shadow root 1 is:  {} .".format(shadow_root_1))



    def Click_button_on_location(self, button, page):
        """ Select the specified button from the page that is specified """
        self.selenium.wait_until_page_contains_element(
            page,
            timeout=60
        )
        self.open_item(
            page,
            "Cannot find {} ".format(page), 
            True
        )
        self.selenium.click_button(button)

    def Enable_the_checkbox(self, title, tab, loc_checkbox, loc_checkbox_edit):
        """ Ensure that the specified checkbox is checked 
            Set the checkbox if it is not set
            Do nothing if the checkbox is already set
        """
        
        self.selenium.wait_until_page_contains_element(
            tab,
            timeout=60
        )
        self.open_item(
            tab,
            "Cannot find {} tab".format(tab), 
            False
        )

        # Checkbox needs to be marked as checked
        if self._check_if_element_exists(loc_checkbox):
            self.builtin.log("{} checkbox is checked.".format(title))
            return
        else: 
            self.builtin.log(
                "{} checkbox is NOT checked.\n".format(title) +
                "Opening EDIT mode"
            )
            self.selenium.click_button("Edit")
            self.builtin.log("Setting the {} checkbox.".format(title))
            self.selenium.wait_until_page_contains_element(
                loc_checkbox_edit,
                timeout=60
            )
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(loc_checkbox_edit)
            )
            self.selenium.click_button("Save")
            self.eda.close_toast_message()
            self.builtin.log(
                "Checkbox for {} setting has been set.\n".format(title) 
            )

    def Disable_the_checkbox(self, title, tab, loc_checkbox, loc_checkbox_edit):
        """ Ensure that the specified checkbox is NOT checked 
            Uncheck the checkbox if it is checked
            Do nothing if the checkbox is already clear
        """
        
        self.selenium.wait_until_page_contains_element(
            tab,
            timeout=60
        )
        self.open_item(
            tab,
            "Cannot find {} tab".format(tab), 
            False
        )

        # Checkbox needs to be unchecked
        if self._check_if_element_exists(loc_checkbox):
            self.builtin.log("{} checkbox is already clear.".format(title))
            return
        else: 
            self.builtin.log(
                "{} checkbox is checked.\n" +
                "Opening EDIT mode"
            )
            self.selenium.click_button("Edit")
            self.builtin.log("Clearing the {} checkbox.".format(title))
            self.selenium.wait_until_page_contains_element(
                loc_checkbox_edit,
                timeout=60
            )
            self.selenium.driver.execute_script(
                "arguments[0].click()", 
                self.selenium.driver.find_element_by_xpath(loc_checkbox_edit)
            )
            self.selenium.click_button("Save")
            self.eda.close_toast_message()
            self.builtin.log("{} checkbox has been cleared.".format(title))

    def process_default_values(self):
        """ Validate the default values for Affiliation Settings """
        
        self.open_item(
            affiliations_locators["affiliations_tab"], 
            "Cannot find the Affiliations tab in EDA Settings",
            False)

        self.open_item(
            affiliations_locators["affiliations_settings_tab"], 
            "Cannot find the Settings tab in Affiliations",
            False)

        # Verify the default values for the checkboxes
        self.selenium.driver.find_element_by_xpath(affiliations_locators["un_ert_validation"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["un_delete_rec_affl"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["un_specify_role_for_c_affl"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["un_copy_affl_end_date"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["un_copy_affl_start_date"])

        # Verify the default values for the dropdowns
        self.selenium.driver.find_element_by_xpath(affiliations_locators["affiliations_former"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["affiliations_student"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["affiliations_current"])
        return

    def Process_default_mapping_values(self):
        """
        1. Navigate to EDA Settings. 
        2. Ensure you're on Affiliations > Affiliation Mappings 
        3. Verify the values in the first row contains the following values:
           -Account Record Type: 'Academic Program'
           -Contact Primary Affl Field: 'Primary Academic Program'
           -Auto-Enrollment: checked
           -Auto-Enrollment Status: 'Current'
           -Auto-Enrollment Role: 'Student'
        4. Verify the values in the second row contains the following values:
           -Account Record Type: 'Business Organization'
           -Contact Primary Affl Field: 'Primary Business Organization'
           -Auto-Enrollment: unchecked
           -Auto-Enrollment Status: null
           -Auto-Enrollment Role: null
        5. Verify the values in the third row contains the following values:
           -Account Record Type: 'Educational Institution'
           -Contact Primary Affl Field: 'Primary Educational Institution'
           -Auto-Enrollment: unchecked
           -Auto-Enrollment Status: null
           -Auto-Enrollment Role: null
        6. Verify the values in the fourth row contains the following values:
           -Account Record Type: 'Household Account'
           -Contact Primary Affl Field: 'Primary Household'
           -Auto-Enrollment: unchecked
           -Auto-Enrollment Status: null
           -Auto-Enrollment Role: null
        7. Verify the values in the fifth row contains the following values:
           -Account Record Type: 'Sports Organization'
           -Contact Primary Affl Field: 'Primary Sports Organization'
           -Auto-Enrollment: unchecked
           -Auto-Enrollment Status: null
           -Auto-Enrollment Role: null
        8. Verify the values in the sixth row contains the following values:
           -Account Record Type: 'University Department'
           -Contact Primary Affl Field: 'Primary Department'
           -Auto-Enrollment: unchecked
           -Auto-Enrollment Status: null
           -Auto-Enrollment Role: null
        9. Verify there are only six rows present
        10. Verify that all text fields values are null and the checkbox is unchecked in the 'New Affiliation Mapping' fields
        """

        # Academic Program
        self.selenium.driver.find_element_by_xpath(affiliations_locators["account_record_type_academic_program"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["contact_primary_affl_field_primary_academic_program"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enroll_academic_program"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_status_academic_program"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_role_academic_program"])

        # Business Organization
        self.selenium.driver.find_element_by_xpath(affiliations_locators["account_record_type_business_organization"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["contact_primary_affl_field_primary_business_organization"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enroll_business_organization"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_status_business_organization"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_role_business_organization"])

        # Educational Institution
        self.selenium.driver.find_element_by_xpath(affiliations_locators["account_record_type_educational_institution"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["contact_primary_affl_field_primary_educational_institution"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enroll_educational_institution"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_status_educational_institution"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_role_educational_institution"])

        # Household Account
        self.selenium.driver.find_element_by_xpath(affiliations_locators["account_record_type_household_account"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["contact_primary_affl_field_primary_household"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enroll_household_account"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_status_household_account"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_role_household_account"])

        # Sports Organization
        self.selenium.driver.find_element_by_xpath(affiliations_locators["account_record_type_sports_organization"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["contact_primary_affl_field_primary_sports_organization"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enroll_sports_organization"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_status_sports_organization"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_role_sports_organization"])

        # University Department
        self.selenium.driver.find_element_by_xpath(affiliations_locators["account_record_type_university_department"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["contact_primary_affl_field_primary_department"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enroll_university_department"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_status_university_department"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment_read_mode_role_university_department"])

        valText = self.selenium.get_text(affiliations_locators["account_record_type_input"])
        self.builtin.log("Input text of Account Record Type is " + valText)
        
        self.selenium.driver.find_element_by_xpath(affiliations_locators["primary_affl_field_input"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["auto_enrollment"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["status_mapping_field_input"])
        self.selenium.driver.find_element_by_xpath(affiliations_locators["role_mapping_field_input"])

    def Clear_everything_on_affiliation_mappings(self):
        """ Clears all values from every field and checkbox on the Affiliation Mappings page """


        # Academic Program
        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_status_academic_program"])
        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_role_academic_program"])

        self.selenium.clear_element_text(affiliations_locators["art_ap_input_affl"])
        self.selenium.clear_element_text(affiliations_locators["paf_pap_input_affl"])
        #self.selenium.clear_element_text(affiliations_locators["auto_enroll_academic_program"])



        # Business Organization
#        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_status_business_organization"])
#        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_role_business_organization"])
        self.selenium.clear_element_text(affiliations_locators["art_bo_input_affl"])
        self.selenium.clear_element_text(affiliations_locators["paf_pbo_input_affl"])
        #self.selenium.clear_element_text(affiliations_locators["auto_enroll_business_organization"])

        # Educational Institution
#        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_status_educational_institution"])
#        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_role_educational_institution"])
        self.selenium.clear_element_text(affiliations_locators["art_ei_input_affl"])
        self.selenium.clear_element_text(affiliations_locators["paf_pei_input_affl"])
        #self.selenium.clear_element_text(affiliations_locators["auto_enroll_educational_institution"])

        # Household Account
#        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_status_household_account"])
#        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_role_household_account"])
        self.selenium.clear_element_text(affiliations_locators["art_ha_input_affl"])
        self.selenium.clear_element_text(affiliations_locators["paf_ph_input_affl"])
        #self.selenium.clear_element_text(affiliations_locators["auto_enroll_household_account"])

        # Sports Organization
#        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_status_sports_organization"])
#        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_role_sports_organization"])
        self.selenium.clear_element_text(affiliations_locators["art_so_input_affl"])
        self.selenium.clear_element_text(affiliations_locators["paf_pso_input_affl"])
        #self.selenium.clear_element_text(affiliations_locators["auto_enroll_sports_organization"])

        # University Department
#        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_status_university_department"])
#        self.selenium.clear_element_text(affiliations_locators["auto_enrollment_edit_mode_role_university_department"])
        self.selenium.clear_element_text(affiliations_locators["art_ud_input_affl"])
        self.selenium.clear_element_text(affiliations_locators["paf_pd_input_affl"])
        #self.selenium.clear_element_text(affiliations_locators["auto_enroll_university_department"])

    def Add_text_to_all_text_fields(self):
        #self.selenium.driver.find_element_by_name('foo').send_keys(Keys.CONTROL + "a");
        #driver.find_element_by_name('foo').send_keys(Keys.DELETE);



        # Academic Program
        self.selenium.driver.find_element_by_xpath(affiliations_locators["art_ap_input_affl_empty"]).send_keys("Academic Program")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["paf_pap_input_affl_empty"]).send_keys("Primary Academic Program")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ae_em_status_empty"]).send_keys("Current")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ae_em_role_empty"]).send_keys("Student")



        # Business Organization
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ae_em_bo_empty"]).send_keys("Business Organization")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ae_em_pbo_empty"]).send_keys("Primary Business Organization")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ae_enroll_bo_empty"]).send_keys("5")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ae_enroll_bo_status_empty"]).send_keys("6")

        # Educational Institution
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ei_art_em_empty"]).send_keys("Educational Institution")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ei_cpaf_em_empty"]).send_keys("Primary Educational Institution")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ei_aes_em_empty"]).send_keys("9")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ed_aer_em_empty"]).send_keys("10")

        # Household Account
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ha_art_em_empty"]).send_keys("Household Account")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ha_cpaf_em_empty"]).send_keys("Primary Household")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ha_aes_em_empty"]).send_keys("13")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ha_aer_em_empty"]).send_keys("14")

        # Sports Organization
        self.selenium.driver.find_element_by_xpath(affiliations_locators["so_art_em_empty"]).send_keys("Sports Organization")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["pso_cpaf_em_empty"]).send_keys("Primary Sports Organization")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["so_aes_em_empty"]).send_keys("18")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["so_aer_em_empty"]).send_keys("19")

        # University Department
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ud_art_em_empty"]).send_keys("University Department")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ud_cpaf_em_empty"]).send_keys("Primary Department")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ud_aes_em_empty"]).send_keys("22")
        self.selenium.driver.find_element_by_xpath(affiliations_locators["ud_aer_em_empty"]).send_keys("23")


    def Remove_mapping(self, locator):

        self.selenium.driver.execute_script("arguments[0].click()", self.selenium.driver.find_element_by_xpath(locator))
