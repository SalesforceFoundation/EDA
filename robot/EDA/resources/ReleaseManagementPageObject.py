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
            raise Exception("Feature description for feature " + '{feature}' + " is empty")

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