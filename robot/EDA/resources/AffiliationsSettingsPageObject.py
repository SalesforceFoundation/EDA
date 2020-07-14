from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
from selenium.webdriver.common.keys import Keys


@pageobject("Affiliations", "HEDA_Settings")
class AffiliationsSettingsPage(BaseEDAPage, BasePage):

    def _is_current_page(self):
        """
            Verify we are on the EDA Settings page for Affiliations
            by verifying the HEDA Settings URL and the Affiliations tab
        """
        location = "/lightning/n/{}{}".format(self.eda.get_eda_namespace_prefix(), self._object_name)
        self.selenium.location_should_contain(location)

        locator_tab = eda_lex_locators["eda_settings"]["tab"].format("Affiliations")
        self.selenium.wait_until_page_contains_element(
            locator_tab,
            error=f"Affiliations tab with locator '{locator_tab}' is not available on the page"
        )

    def open_item(self, locator, error_message, capture_screen):
        """ Performs a wait until the element shows on the page, and clicks the element.
            Pass capture_screen as False to turn off screen capture and True to turn on
            screen capture
        """
        self.selenium.wait_until_page_contains_element(
            locator,
            timeout=60,
            error=error_message
        )
        self.selenium.click_element(locator)

        if capture_screen:
            self.selenium.capture_page_screenshot()

    def go_to_affiliations_sub_tab(self, sub_tab):
        """ Click on the given sub_tab in the Affiliations Settings page """
        locator = eda_lex_locators["affiliations_locators"]["sub_tab"].format(sub_tab)
        self.selenium.wait_until_page_contains_element(locator,
                                                       error=f"'{sub_tab}' sub tab is not available on the page")
        self.selenium.click_element(locator)

    def go_to_affiliations_edit_mode(self, loc):
        """ Go into Edit mode and remove the con
        """    
        self.selenium.driver.execute_script(
            "arguments[0].click()", 
            self.selenium.driver.find_element_by_xpath(loc)
        )

        self.selenium.driver.execute_script(
            "arguments[0].click()", 
            self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["delete_icon"])
        )

        self.selenium.driver.execute_script(
            "arguments[0].scrollIntoView()", 
            self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["primary_business_organization"])
        )
        
        xpath = eda_lex_locators["affiliations_locators"]["primary_business_organization"]
        field = self.selenium.get_webelement(xpath)
        field.send_keys("Robot Academic Program Account" + Keys.ARROW_DOWN + Keys.ENTER)

        self.selenium.click_element(eda_lex_locators["affiliations_locators"]["button_save_affiliation"])
        self.eda.close_toast_message()

    def enable_the_checkbox(self, title, tab, loc_checkbox, loc_checkbox_edit):
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
        if self.eda._check_if_element_exists(loc_checkbox):
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

    def disable_the_checkbox(self, title, tab, loc_checkbox, loc_checkbox_edit):
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
        if self.eda._check_if_element_exists(loc_checkbox):
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

        locator_tab = eda_lex_locators["eda_settings"]["tab"].format("Affiliations")
        locator_subtab = eda_lex_locators["affiliations_locators"]["sub_tab"].format("Settings")

        self.open_item(locator_tab, "Cannot find the Affiliations tab in EDA Settings", False)
        self.open_item(locator_subtab, "Cannot find the Settings tab in Affiliations", False)

        # Verify the default values for the checkboxes
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["un_ert_validation"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["un_delete_rec_affl"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["specify_role_for_c_affl"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["copy_affl_end_date"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["copy_affl_start_date"])

        # Verify the default values for the dropdowns
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["affiliations_former"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["affiliations_student"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["affiliations_current"])
        return

    def process_default_mapping_values(self):
        """
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
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["account_record_type_academic_program"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["contact_primary_affl_field_primary_academic_program"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enroll_academic_program"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_status_academic_program"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_role_academic_program"])

        # Business Organization
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["account_record_type_business_organization"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["contact_primary_affl_field_primary_business_organization"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enroll_business_organization"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_status_business_organization"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_role_business_organization"])

        # Educational Institution
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["account_record_type_educational_institution"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["contact_primary_affl_field_primary_educational_institution"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enroll_educational_institution"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_status_educational_institution"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_role_educational_institution"])

        # Household Account
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["account_record_type_household_account"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["contact_primary_affl_field_primary_household"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enroll_household_account"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_status_household_account"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_role_household_account"])

        # Sports Organization
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["account_record_type_sports_organization"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["contact_primary_affl_field_primary_sports_organization"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enroll_sports_organization"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_status_sports_organization"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_role_sports_organization"])

        # University Department
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["account_record_type_university_department"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["contact_primary_affl_field_primary_department"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enroll_university_department"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_status_university_department"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment_read_mode_role_university_department"])

        valText = self.selenium.get_text(eda_lex_locators["affiliations_locators"]["account_record_type_input"])
        self.builtin.log("Input text of Account Record Type is " + valText)
        
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["primary_affl_field_input"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["auto_enrollment"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["status_mapping_field_input"])
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["role_mapping_field_input"])

    def clear_everything_on_affiliation_mappings(self):
        """ Clears all values from every field and checkbox on the Affiliation Mappings page """

        # Academic Program
        self.selenium.clear_element_text(eda_lex_locators["affiliations_locators"]["auto_enrollment_edit_mode_status_academic_program"])
        self.selenium.clear_element_text(eda_lex_locators["affiliations_locators"]["auto_enrollment_edit_mode_role_academic_program"])

        self.selenium.clear_element_text(eda_lex_locators["affiliations_locators"]["acc_record_type"].format("Academic Program"))
        self.selenium.clear_element_text(
            eda_lex_locators["affiliations_locators"]["contact_primary_affl_field"].format("Primary Academic Program"))

        # Business Organization
        self.selenium.clear_element_text(eda_lex_locators["affiliations_locators"]["acc_record_type"].format("Business Organization"))
        self.selenium.clear_element_text(
            eda_lex_locators["affiliations_locators"]["contact_primary_affl_field"].format("Primary Business Organization"))

        # Educational Institution
        self.selenium.clear_element_text(eda_lex_locators["affiliations_locators"]["acc_record_type"].format("Educational Institution"))
        self.selenium.clear_element_text(
            eda_lex_locators["affiliations_locators"]["contact_primary_affl_field"].format("Primary Educational Institution"))

        # Household Account
        self.selenium.clear_element_text(eda_lex_locators["affiliations_locators"]["acc_record_type"].format("Household Account"))
        self.selenium.clear_element_text(
            eda_lex_locators["affiliations_locators"]["contact_primary_affl_field"].format("Primary Household"))

        # Sports Organization
        self.selenium.clear_element_text(eda_lex_locators["affiliations_locators"]["acc_record_type"].format("Sports Organization"))
        self.selenium.clear_element_text(
            eda_lex_locators["affiliations_locators"]["contact_primary_affl_field"].format("Primary Sports Organization"))

        # University Department
        self.selenium.clear_element_text(eda_lex_locators["affiliations_locators"]["acc_record_type"].format("University Department"))
        self.selenium.clear_element_text(
            eda_lex_locators["affiliations_locators"]["contact_primary_affl_field"].format("Primary Department"))

    def add_text_to_all_text_fields(self):
        """ Add sample text to each text field to verify that populated fields may be saved properly """
        # Academic Program
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["art_ap_input_affl_empty"]).send_keys("Academic Program")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["paf_pap_input_affl_empty"]).send_keys("Primary Academic Program")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ae_em_status_empty"]).send_keys("Current")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ae_em_role_empty"]).send_keys("Student")

        # Business Organization
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ae_em_bo_empty"]).send_keys("Business Organization")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ae_em_pbo_empty"]).send_keys("Primary Business Organization")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ae_enroll_bo_empty"]).send_keys("5")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ae_enroll_bo_status_empty"]).send_keys("6")

        # Educational Institution
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ei_art_em_empty"]).send_keys("Educational Institution")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ei_cpaf_em_empty"]).send_keys("Primary Educational Institution")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ei_aes_em_empty"]).send_keys("9")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ed_aer_em_empty"]).send_keys("10")

        # Household Account
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ha_art_em_empty"]).send_keys("Household Account")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ha_cpaf_em_empty"]).send_keys("Primary Household")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ha_aes_em_empty"]).send_keys("13")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ha_aer_em_empty"]).send_keys("14")

        # Sports Organization
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["so_art_em_empty"]).send_keys("Sports Organization")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["pso_cpaf_em_empty"]).send_keys("Primary Sports Organization")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["so_aes_em_empty"]).send_keys("18")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["so_aer_em_empty"]).send_keys("19")

        # University Department
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ud_art_em_empty"]).send_keys("University Department")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ud_cpaf_em_empty"]).send_keys("Primary Department")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ud_aes_em_empty"]).send_keys("22")
        self.selenium.driver.find_element_by_xpath(eda_lex_locators["affiliations_locators"]["ud_aer_em_empty"]).send_keys("23")

