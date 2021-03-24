({,
    handleToggle: function (component, event, helper) {
        let toggleValue = component.get("v.toggle");
        component.set("v.toggle", !toggleValue);
        console.log("Toggle set to "+ toggleValue);
    },
    handleCancel: function (component, event, helper) {
        component.find("primaryAffiliationsOverlayLibrary").notifyclose();
    },
    handleSave: function (component, event, helper) {
        console.log("save clicked");
    },
})