({
    handleNavigate: function (component) {
        const educationCloudSettings = component.find("educationCloudSettings");
        const educationCloudSettingsElement = educationCloudSettings.getElement();
        const pageRef = component.get("v.pageReference");
        educationCloudSettingsElement.handleNavigate(pageRef);
    }
});
