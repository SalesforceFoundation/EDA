({
    toggleIsView : function(component, event, helper) {
        component.set("v.isView", event.getParam("isView"));
        var enablePrefPhone = component.find("enablePrefPhoneEdit").get("v.value");

        helper.toggleDisablePhoneEnforcementCheckbox(component, enablePrefPhone);
    },
    runBackfill : function (component, event, helper) {
        helper.runBackfill(component);
    },
    runCleanUp : function (component, event, helper) {
        helper.runCleanUp(component);
    },
})