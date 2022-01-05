from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import HomePage
from cumulusci.robotframework.pageobjects import pageobject
import time
from datetime import date


@pageobject("Home", "Release Management")
class ReleaseManagementPage(BaseEDAPage, HomePage):

    def _is_current_page(self):
        """ Verify we are on the Release Management page
            by verifying Release Management page header
        """
        locator = eda_lex_locators["release_management"]["page_title"].format("Release Management")
        self.selenium.wait_until_page_contains_element(
            locator,
            error="Release management header is not available"
        )

    def verify_release_gate_product(self, product):
        """ Verify the release product exists on the 
            release management page
        """
        locator = eda_lex_locators["release_management"]["release_product"].format(product)
        self.selenium.wait_until_page_contains_element(
            locator,
            error=f"Release product '{product}' is not available"
        )        
        self.selenium.wait_until_element_is_visible(
            locator,
            timeout=60,
            error= "Element is not displayed for the user"
        )

    def verify_release_gate_item(self, product, gate_item):
        """ Verify the release gate item for the specified 
            product exists
        """
        locator = eda_lex_locators["release_management"]["release_gate_item"].format(product, gate_item)
        self.selenium.wait_until_page_contains_element(
            locator,
            error=f"Release gate item '{gate_item}' is not available"
        )   
        self.selenium.wait_until_element_is_visible(
            locator,
            timeout=60,
            error= "Element is not displayed for the user"
        )

    def verify_release_gate_item_description(self, product, gate_item, description):
        """ Verify the release gate item description exists
        """
        locator = eda_lex_locators["release_management"]["release_gate_item_description"].format(product, gate_item, description)
        self.selenium.wait_until_page_contains_element(
            locator,
            error=f"Release gate item description '{description}' is not available"
        )   
        self.selenium.wait_until_element_is_visible(
            locator,
            timeout=60,
            error= "Element is not displayed for the user"
        )

    def verify_release_gate_item_icon(self, product, gate_item, icon):
        """ Verify the release gate item icon exists
        """
        locator = eda_lex_locators["release_management"]["release_gate_item_icon"].format(product, gate_item, icon)
        self.selenium.wait_until_page_contains_element(
            locator,
            error=f"Release gate item icon '{icon}' is not available"
        )   
        self.selenium.wait_until_element_is_visible(
            locator,
            timeout=60,
            error= "Element is not displayed for the user"
        )

    def verify_release_gate_item_activationdate(self, product, gate_item, activation_type):
        """ Verify the release gate item activation date
        """
        if str(activation_type).lower() == "activate by":
            locator = eda_lex_locators["release_management"]["release_gate_item_activationdate_activateby"].format(product, gate_item)
            self.selenium.wait_until_page_contains_element(
                locator,
                error=f"Release gate item activation '{activation_type}' is not available"
            ) 
        elif str(activation_type).lower() == "activated on":
            locator = eda_lex_locators["release_management"]["release_gate_item_activationdate_activateon"].format(product, gate_item)
            self.selenium.wait_until_page_contains_element(
                locator,
                error=f"Release gate item activation '{activation_type}' is not available"
            ) 
        elif str(activation_type).lower() == "none":
            locator = eda_lex_locators["release_management"]["release_gate_item_activationdate"].format(product, gate_item)
            self.selenium.page_should_not_contain_element(locator)
        else:
            raise Exception(f"activation_type is not supported '{activation_type}'")
        
    def verify_release_gate_item_activation_status(self, product, gate_item, activation_status):
        """ Verify the release gate item activation status
        """
        if str(activation_status).lower() == "activated":
            locator = eda_lex_locators["release_management"]["release_gate_item_status_activated"].format(product, gate_item)
            self.selenium.wait_until_page_contains_element(
                locator,
                error=f"Release gate item activation status '{activation_status}' is not available"
            ) 
        elif str(activation_status).lower() == "in progress":
            locator = eda_lex_locators["release_management"]["release_gate_item_status_inprogress"].format(product, gate_item)
            self.selenium.wait_until_page_contains_element(
                locator,
                error=f"Release gate item activation status '{activation_status}' is not available"
            ) 
        elif str(activation_status).lower() == "inactive":
            locator = eda_lex_locators["release_management"]["release_gate_item_status_inactive"].format(product, gate_item)
            self.selenium.wait_until_page_contains_element(
                locator,
                error=f"Release gate item activation status '{activation_status}' is not available"
            ) 
        elif str(activation_status).lower() == "none":
            locator = eda_lex_locators["release_management"]["release_gate_item_statusrow"].format(product, gate_item)
            self.selenium.page_should_not_contain_element(locator)
        else:
            raise Exception(f"activation_status is not supported '{activation_status}'")

    def verify_release_gate_feature(self, product, gate_item, feature):
        """ Verify the release gate feature for the specified 
            product and gate item exists
        """
        locator = eda_lex_locators["release_management"]["release_gate_feature"].format(product, gate_item, feature)
        self.selenium.wait_until_page_contains_element(
            locator,
            error=f"Release gate feature '{feature}' is not available"
        )   
        self.selenium.wait_until_element_is_visible(
            locator,
            timeout=60,
            error= "Element is not displayed for the user"
        )

    def verify_release_gate_feature_description(self, product, gate_item, feature):
        """ Verify the release gate feature description exists
            and the description is not empty
        """
        locator = eda_lex_locators["release_management"]["release_gate_feature_description"].format(product, gate_item, feature)
        self.selenium.wait_until_page_contains_element(
            locator,
            error=f"Release gate feature '{feature}' is not available"
        )   
        self.selenium.wait_until_element_is_visible(
            locator,
            timeout=60,
            error= "Element is not displayed for the user"
        )
        text = self.selenium.get_webelement(locator).text
        if(len(text) == 0):
            raise Exception(f"Feature description for feature " + '{feature}' + " is empty")

    def verify_release_gate_feature_link(self, product, gate_item, feature, link_label, link_url):
        """ Verify the release gate feature link exists
            and matches the label and link url
        """
        locator = eda_lex_locators["release_management"]["release_gate_feature_link"].format(product, gate_item, feature, link_label, link_url)
        self.selenium.wait_until_page_contains_element(
            locator,
            error=f"Release gate feature link '{link_label} {link_url}' is not available"
        )   
        self.selenium.wait_until_element_is_visible(
            locator,
            timeout=60,
            error= "Element is not displayed for the user"
        )

    def open_release_gate_item_activation(self, product, gate_item):
        """ Clicks on the activate button within the feature gate to open the confirmation modal
        """
        locator = eda_lex_locators["release_management"]["release_gate_item_status_inactive"].format(product, gate_item)
        self.selenium.wait_until_page_contains_element(
            locator,
            error=f"Release gate item - activation button is not available"
        ) 
        self.selenium.click_element(locator)
         
    
    def verify_release_gate_activation_modal(self,header_value,body_value):
        """ Verifies the header and text body of the opened modal to confirm the activation of a feature gate
        """
        modalHeaderLocator = eda_lex_locators["release_management"]["release_gate_activation_modal_header"];
        modalBodyLocator = eda_lex_locators["release_management"]["release_gate_activation_modal_text_body"];

        self.selenium.wait_until_element_is_visible(modalHeaderLocator)
        modalHeader = self.selenium.get_webelement(modalHeaderLocator).text
        modalBody = self.selenium.get_webelement(modalBodyLocator).text
        if modalHeader not in header_value:
            raise Exception(f"Release Gate activation modal does not have correct header: Expected: {header_value} vs. Actual: {modalHeader}")
        if modalBody not in body_value:
            raise Exception(f"Release gate activation modal does not have expected text body. Expected: {body_value} vs. Actual: {modalBody}")
    
    def activate_release_gate_item(self, product, gate_item):
        """ Activates the release gate by confirming the activation in the modal
        """
        locator = eda_lex_locators["release_management"]["release_gate_confirm_activate_button"].format(product, gate_item)
        self.selenium.wait_until_page_contains_element(
            locator,
            error="Release gate item - confirmation activation button is not available"
        )
        self.selenium.click_element(locator)
        time.sleep(2)
        self.eda.verify_custom_toast_message_displayed()
        time.sleep(0.5)

    def cancel_activation_release_gate_item(self, product, gate_item):
        """ Clicks on Release gate item Activate button
            and then clicks on Cancel
        """
        locator = eda_lex_locators["release_management"]["release_gate_item_status_inactive"].format(product, gate_item)
        self.selenium.wait_until_page_contains_element(
            locator,
            error=f"Release gate item - activation button is not available"
        ) 
        self.selenium.click_element(locator)
        locator = eda_lex_locators["release_management"]["release_gate_cancel_activate_button"].format(product, gate_item)
        self.selenium.wait_until_page_contains_element(
            locator,
            error="Release gate item - cancellation button within activation modal is not available"
        )
        self.selenium.click_element(locator)
        time.sleep(0.5)