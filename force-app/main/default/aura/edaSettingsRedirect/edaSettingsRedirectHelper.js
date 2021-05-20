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
    },
    createDescription: function (event, component) {
        var description = $A.get("$Label.c.stgEDASettingsHasMovedDesc");
        var tellMeMore = $A.get("$Label.c.stgTellMeMoreLink");
        var edaDocumentation = '<a href="https://powerofus.force.com/s/article/EDA-Education-Cloud-Settings">';

        component.set("v.settingsMovedDesc", description + " " + edaDocumentation + tellMeMore + "</a>");
    }
});
