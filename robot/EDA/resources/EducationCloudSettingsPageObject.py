from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import HomePage
from cumulusci.robotframework.pageobjects import pageobject
import time
from datetime import date


@pageobject("Home", "Education Cloud Settings")
class EducationCloudSettingsPage(BaseEDAPage, HomePage):

    def _is_current_page(self):
        """ Verify we are on the Settings Health Check page
            by verifying Settings Health Check page header
        """
        locator = eda_lex_locators["eda_settings_new"]["edc_header"].format("Education Data Architecture")
        self.selenium.wait_until_page_contains_element(
            locator,
            error="EDC header is not available"
        )

    def verify_app_tiles_displayed(self,**kwargs):
        """ This method verifies the app tiles are displayed in the Education Cloud Settings home
            page.
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_new"]["app_tile"].format(field,value)
            self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{locator} is not available')
            self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")

    def click_app_in_edc_home(self,value):
        """ This method will click on the button in a tile to launch a particular app by accepting
            the name of the button as its parameter
        """
        locator = eda_lex_locators["eda_settings_new"]["global_action"].format(value)
        self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{locator} is not available')
        self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
        self.selenium.click_element(locator)

    def verify_product_card_avatar_displayed(self,value):
        """ This method verifies the product card avatar is displayed in the Education Cloud Settings home
            page.
        """
        locator = eda_lex_locators["eda_settings_new"]["product_card_avator"].format(value)
        self.selenium.wait_until_page_contains_element(locator, timeout=30, error=f'{locator} is not available')
        self.selenium.wait_until_element_is_visible(locator,
                                            error= "Element is not displayed for the user")
    
    def verify_product_card_description_displayed(self,value):
        """ This method verifies the product card description is displayed in the Education Cloud Settings home
            page.
        """
        locator = eda_lex_locators["eda_settings_new"]["product_card_description"].format(value)
        self.selenium.wait_until_page_contains_element(locator, timeout=30, error=f'{locator} is not available')
        self.selenium.wait_until_element_is_visible(locator,
                                            error= "Element is not displayed for the user")
    
    def verify_product_card_button_displayed(self,value):
        """ This method verifies the product card button is displayed in the Education Cloud Settings home
            page.
        """
        locator = eda_lex_locators["eda_settings_new"]["product_card_button"].format(value)
        self.selenium.wait_until_page_contains_element(locator, timeout=30, error=f'{locator} is not available')
        self.selenium.wait_until_element_is_visible(locator,
                                            error= "Element is not displayed for the user")

    def click_product_card_button_in_edc_home(self,value):
        """ This method will click on the footer button in a tile
            the name of the button as its parameter
        """
        locator = eda_lex_locators["eda_settings_new"]["product_card_button"].format(value)
        self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{locator} is not available')
        self.selenium.wait_until_element_is_visible(locator,
                                                error= "Element is not displayed for the user")
        self.selenium.click_element(locator)

    def verify_eda_documentation(self,value):
        """
            Verify we are on the EDA documentation page
        """
        location = value
        self.selenium.location_should_contain(
            location)
            
    def verify_error_is_displayed(self,value):
        """Verifies an error message displayed in a toast within education cloud settings
        """
        locator = eda_lex_locators["eda_settings_new"]["error_toast"].format(value)
        self.selenium.wait_until_page_contains_element(locator, timeout=60, error=f'{locator} is not available')
        self.selenium.wait_until_element_is_visible(locator, error= f'{locator} is not displayed for the user')
