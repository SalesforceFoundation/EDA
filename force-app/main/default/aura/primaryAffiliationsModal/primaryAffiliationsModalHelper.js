({
    handleToggle: function (component) {
        let primaryAffiliationEvent = component.getEvent("affiliationsModalEvent");
        primaryAffiliationEvent.setParams({
            accountRecordType: component.get("v.accountRecordType"),
            contactField: component.get("v.contactField")
        });
        primaryAffiliationEvent.fire();
    }
});
