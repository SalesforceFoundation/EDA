({
    toggleIsView : function(component, event, helper) {
        component.set("v.isView", event.getParam("isView"));
    },
    runBackfill : function (component, event, helper) {
        helper.runBackfill(component);
    },
    runCleanUp : function (component, event, helper) {
        helper.runCleanUp(component);
    },
})