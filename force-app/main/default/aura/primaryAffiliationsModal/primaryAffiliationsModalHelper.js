({
    handleToggle: function (component) {
        let primaryAffiliationEvent = component.getEvent("affiliationsModalEvent");
        primaryAffiliationEvent.setParams({
            type: "change",
            accountRecordType: component.get("v.accountRecordType"),
            contactField: component.get("v.contactField")
        });
        primaryAffiliationEvent.fire();
    }
});
