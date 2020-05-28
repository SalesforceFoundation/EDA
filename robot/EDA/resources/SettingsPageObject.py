from cumulusci.robotframework.pageobjects import pageobject
from cumulusci.robotframework.pageobjects import BasePage


@pageobject("Custom", "HEDA_Settings")
class SettingsPage(BasePage):

    @property
    def eda(self):
        return self.builtin.get_library_instance('EDA')
    
    def _is_current_page(self):
        """ Verify we are on the Contact detail page
            by verifying that the url contains '/view'
        """
        namespace = self.eda.get_eda_namespace_prefix()
        self.selenium.wait_until_location_contains(
            "lightning/n/"+namespace+"HEDA_Settings", message="Current page is not Settings Page view"
        )
    
    def _go_to_page(self):
        """To go to EDA Settings page"""
        url_template = "{root}/lightning/n/{object}"
        name = self._object_name
        object_name = "{}{}".format(self.cumulusci.get_namespace_prefix(), name)
        url = url_template.format(root=self.cumulusci.org.lightning_base_url, object=object_name)
        self.selenium.go_to(url)
        self.salesforce.wait_until_loading_is_complete()
        self.eda.wait_for_locator("frame","accessibility title", "accessibility title", "accessibility title")
        self.eda.select_frame_with_value("accessibility title")
