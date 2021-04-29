({
    handleAutoEnrollmentMappingStatusChange: function (component, event, helper) {
        helper.handleAutoEnrollmentMappingStatusChange(component, event.getParam("autoProgramEnrollmentStatus"));
    },

    handleAutoEnrollmentMappingRoleChange: function (component, event, helper) {
        helper.handleAutoEnrollmentMappingRoleChange(component, event.getParam("autoProgramEnrollmentRole"));
    }
});
