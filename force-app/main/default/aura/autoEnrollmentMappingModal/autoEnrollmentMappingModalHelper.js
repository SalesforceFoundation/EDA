({
    handleAccountRecordTypeChange: function (component, accountRecordType) {
        component.set("v.accountRecordType", accountRecordType);
        this.dispatchDataChangeEvent(component, "accountRecordType", accountRecordType);
    },
    dispatchDataChangeEvent: function (component, field, fieldValue) {
        let modalDataChangeEvent = component.getEvent("modalDataChangeEvent");
        modalDataChangeEvent.setParams({
            field: field,
            fieldValue: fieldValue
        });
        modalDataChangeEvent.fire();
    }
});
