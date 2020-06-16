from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
from locators import eda_lex_locators


@pageobject("Relationships", "HEDA_Settings")
class RelationshipsSettingsPage(BasePage):

    @property
    def eda(self):
        return self.builtin.get_library_instance('EDA')

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
