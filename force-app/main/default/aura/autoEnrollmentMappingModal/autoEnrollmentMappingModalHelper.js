({
    handleAccountRecordTypeChange: function (component, accountRecordType) {
        component.set("v.accountRecordType", accountRecordType);
        this.dispatchDataChangeEvent(component, "accountRecordType", accountRecordType);
    },
    handleAutoEnrollmentMappingStatusChange: function (component, autoProgramEnrollmentStatus) {
        component.set("v.autoProgramEnrollmentStatus", autoProgramEnrollmentStatus);
        this.dispatchDataChangeEvent(component, "autoProgramEnrollmentStatus", autoProgramEnrollmentStatus);
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
