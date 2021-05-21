({
    doInit: function (component, event, helper) {
        helper.getNamespaceName(event, component);
        helper.createDescription(event, component);
    },
    handleEdaSettingsRedirect: function (component, event, helper) {
        helper.handleEdaSettingsRedirect(event, component);
    }
});
