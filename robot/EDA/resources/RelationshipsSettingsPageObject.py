from BaseObjects import BaseEDAPage
from EDA import eda_lex_locators
from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject


@pageobject("Relationships", "HEDA_Settings")
class RelationshipsSettingsPage(BaseEDAPage, BasePage):

    def _is_current_page(self):
        """
            Verify we are on the EDA Settings page for Relationships
            by verifying the HEDA Settings URL and the Relationships tab
        """
        location = "/lightning/n/{}{}".format(self.eda.get_eda_namespace_prefix(), self._object_name)
        self.selenium.location_should_contain(location)

        locator_tab = eda_lex_locators["eda_settings"]["tab"].format("Relationships")
        self.selenium.wait_until_page_contains_element(
            locator_tab,
            error=f"Relationships tab with locator '{locator_tab}' is not available on the page"
        )

    def go_to_relationships_sub_tab(self, sub_tab):
        """ Click on the given sub_tab in the Affiliations Settings page """
        locator = eda_lex_locators["relationships_settings_locators"]["sub_tab"].format(sub_tab)
        self.selenium.wait_until_page_contains_element(locator,
                                                       error=f"'{sub_tab}' sub tab is not available on the page")
        self.selenium.click_element(locator)

    def update_reciprocal_method_value(self,**kwargs):
        """ This method will update the drop down field value passed in keyword arguments
            Pass the expected value to be set in the drop down field from the tests
        """
        for field,value in kwargs.items():
            locator = eda_lex_locators["eda_settings_relationships"]["dropdown_read"].format(field)
            text = self.selenium.get_webelement(locator).text
            if not str(text).lower() == str(value).lower():
                self.eda.click_action_button_on_eda_settings_page("Edit")
                locator_edit = eda_lex_locators["eda_settings_relationships"]["dropdown_value"].format(field,value)
                self.selenium.wait_until_page_contains_element(locator_edit,
                                                error=f"'{locator_edit}' is not available ")
                self.selenium.click_element(locator_edit)
                self.eda.click_action_button_on_eda_settings_page("Save")
