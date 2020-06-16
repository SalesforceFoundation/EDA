from cumulusci.robotframework.pageobjects import BasePage
from cumulusci.robotframework.pageobjects import pageobject
from locators import eda_lex_locators


@pageobject("Course_Connections", "HEDA_Settings")
class CourseConnectionsSettingsPage(BasePage):

    @property
    def eda(self):
        return self.builtin.get_library_instance('EDA')

    def _is_current_page(self):
        """
            Verify we are on the EDA Settings page for Course Connections
            by verifying the HEDA Settings URL and the Course Connections tab
        """
        location = "/lightning/n/{}{}".format(self.eda.get_eda_namespace_prefix(), self._object_name)
        self.selenium.location_should_contain(location)

        locator_tab = eda_lex_locators["eda_settings"]["tab"].format("Course Connections")
        self.selenium.wait_until_page_contains_element(
            locator_tab,
            error=f"Course Connections tab with locator '{locator_tab}' is not available on the page"
        )
