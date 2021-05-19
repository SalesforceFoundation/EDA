({
    handleEdaSettingsRedirect: function (event, component) {
        const pageReference = {
            type: "standard__component",
            attributes: {
                componentName: "c__EducationCloudSettingsContainer"
            }
        };
        var navService = component.find("navService");
        event.preventDefault();
        navService.navigate(pageReference);
    }
});
