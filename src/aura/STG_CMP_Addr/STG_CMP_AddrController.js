({
    toggleIsView : function(component, event) {
        component.set("v.isView", event.getParam("isView"));
    },
    runBackfill : function (component, event, helper) {
        helper.runBackfill(component);
    },
    runCleanUp : function (component, event, helper) {
        helper.runCleanUp(component);
    },
    handlePhoneSync : function (component, event, helper) {
        helper.handlePhoneSync(component, event);
    },
})