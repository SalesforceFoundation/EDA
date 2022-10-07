({
    createDescription: function (event, component) {
        var description = $A.get("$Label.c.stgEDASettingsHasMovedDesc");
        var tellMeMore = $A.get("$Label.c.stgTellMeMoreLink");

        component.set("v.settingsMovedDesc", description + "</a>");
    }
});
