({
    handleAutoEnrollmentMappingAccountRecordTypeChange: function (component, newAccountRecordType) {
        component.set("v.newAccountRecordType", newAccountRecordType);
        this.dispatchDataChangeEvent(component, "newAccountRecordType", newAccountRecordType);
    },
    handleAutoEnrollmentMappingStatusChange: function (component, autoProgramEnrollmentStatus) {
        component.set("v.autoProgramEnrollmentStatus", autoProgramEnrollmentStatus);
        this.dispatchDataChangeEvent(component, "autoProgramEnrollmentStatus", autoProgramEnrollmentStatus);
    },
    handleAutoEnrollmentMappingRoleChange: function (component, autoProgramEnrollmentRole) {
        component.set("v.autoProgramEnrollmentRole", autoProgramEnrollmentRole);
        this.dispatchDataChangeEvent(component, "autoProgramEnrollmentRole", autoProgramEnrollmentRole);
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
