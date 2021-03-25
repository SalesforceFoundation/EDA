({
    handleToggle: function (component) {
        let primaryAffiliationEvent = component.getEvent("affiliationsModalEvent");
        primaryAffiliationEvent.setParams({
            affiliationsAction: "change",
            accountRecordType: component.get("v.accountRecordType"),
            contactField: component.get("v.contactField")
        });
        primaryAffiliationEvent.fire();
    },
    handleCancel: function (component) {
        component.find("primaryAffiliationsOverlayLibrary").notifyClose();
    },
    handleSave: function (component) {
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
