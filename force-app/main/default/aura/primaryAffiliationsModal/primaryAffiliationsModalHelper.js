({
    handleAccountRecordTypeChange: function (component, accountRecordType) {
        component.set("v.accountRecordType", accountRecordType);
        this.dispatchDataChangeEvent(component);
    },
    handleContactFieldChange: function (component, contactField) {
        component.set("v.contactField", contactField);
        this.dispatchDataChangeEvent(component);
    },
    dispatchDataChangeEvent: function (component) {
        let primaryAffiliationEvent = component.getEvent("affiliationsModalEvent");
        primaryAffiliationEvent.setParams({
            accountRecordType: component.get("v.accountRecordType"),
            contactField: component.get("v.contactField")
        });
        primaryAffiliationEvent.fire();
    }
});
