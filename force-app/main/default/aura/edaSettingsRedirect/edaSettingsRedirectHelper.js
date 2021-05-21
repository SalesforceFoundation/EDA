({
    getNamespaceName: function (event, component) {
        var action = component.get("c.getNamespaceName");
        action.setCallback(this, function (response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in namespace attribute on component
                component.set("v.namespace", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    createDescription: function (event, component) {
        var description = $A.get("$Label.c.stgEDASettingsHasMovedDesc");
        var tellMeMore = $A.get("$Label.c.stgTellMeMoreLink");
        const edaDocumentation = '<a href="https://powerofus.force.com/s/article/EDA-Education-Cloud-Settings">';

        component.set("v.settingsMovedDesc", description + " " + edaDocumentation + tellMeMore + "</a>");
    },
    handleEdaSettingsRedirect: function (event, component) {
        let namespace = component.get("v.namespace");
        const pageReference = {
            type: "standard__component",
            attributes: {
                componentName: namespace + "EducationCloudSettingsContainer"
            }
        };
        var navService = component.find("navService");
        event.preventDefault();
        navService.navigate(pageReference);
    }
});
