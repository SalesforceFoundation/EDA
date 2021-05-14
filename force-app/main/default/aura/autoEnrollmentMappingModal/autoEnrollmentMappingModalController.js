({
    handleAutoEnrollmentMappingAccountRecordTypeChange: function (component, event, helper) {
        helper.handleAutoEnrollmentMappingAccountRecordTypeChange(component, event.getParam("newAccountRecordType"));
    },
    handleAutoEnrollmentMappingStatusChange: function (component, event, helper) {
        helper.handleAutoEnrollmentMappingStatusChange(component, event.getParam("autoProgramEnrollmentStatus"));
    },

    handleAutoEnrollmentMappingRoleChange: function (component, event, helper) {
        helper.handleAutoEnrollmentMappingRoleChange(component, event.getParam("autoProgramEnrollmentRole"));
    }
});
