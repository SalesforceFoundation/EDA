({
    createDescription: function (event, component) {
        var description = $A.get("$Label.c.stgEDASettingsHasMovedDesc");
        var tellMeMore = $A.get("$Label.c.stgTellMeMoreLink");
        const edaDocumentation = '<a href="https://powerofus.force.com/EDA-Education-Cloud-Settings">';

        component.set("v.settingsMovedDesc", description + " " + edaDocumentation + tellMeMore + "</a>");
    }
});
