({
    toggleIsView : function(component, event, helper) {
        component.set("v.isView", event.getParam("isView"));
        var enablePrefPhone = component.find("enablePrefPhoneEdit").get("v.value");
    },
    runBackfill : function (component, event, helper) {
        helper.runBackfill(component);
    },
    runCleanUp : function (component, event, helper) {
        helper.runCleanUp(component);
    },
})