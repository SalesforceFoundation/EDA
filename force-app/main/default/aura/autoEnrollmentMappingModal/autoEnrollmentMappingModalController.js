({
    handleAccountRecordTypeChange: function (component, event, helper) {
        helper.handleAccountRecordTypeChange(component, event.getParam("accountRecordType"));
    },

    handleAutoEnrollmentMappingStatusChange: function (component, event, helper) {
        helper.handleAutoEnrollmentMappingStatusChange(component, event.getParam("autoProgramEnrollmentStatus"));
    }
});
