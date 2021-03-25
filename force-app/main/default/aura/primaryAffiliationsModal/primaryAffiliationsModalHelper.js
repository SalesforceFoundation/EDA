({
    handleToggle: function (component) {
        console.log(component.get("v.accountRecordType"));
        console.log(component.get("v.contactField"));

        component.set("v.accountRecordType", "Academic_Program");
        component.set("v.contactField", "Primary_Academic_Program__c");
        let primaryAffiliationEvent = component.getEvent("affiliationsModalEvent");
        primaryAffiliationEvent.setParams({
            affiliationsAction: "change",
            accountRecordType: component.get("v.accountRecordType"),
            contactField: component.get("v.contactField")
        });
        primaryAffiliationEvent.fire();
    },
    handleCancel: function (component, event, helper) {
        component.find("primaryAffiliationsOverlayLibrary").notifyClose();
    },
    handleSave: function (component, event, helper) {
        let primaryAffiliationEvent = component.getEvent("affiliationsModalEvent");
        primaryAffiliationEvent.setParams({
            affiliationsAction: component.get("v.affiliationsAction"),
            accountRecordType: component.get("v.accountRecordType"),
            contactField: component.get("v.contactField")
        });

        try {
            primaryAffiliationEvent.fire();
            component.find("primaryAffiliationsOverlayLibrary").notifyClose();
        } catch (e) {
            //save for validation handling
            //console.error(e);
        }
    }
});
