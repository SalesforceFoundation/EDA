({
    init: function (component, event, helper) {
        helper.setPageReference(component);
    },
    primaryAffiliationModalRequestHandler: function (component, event, helper) {
        event.stopPropagation();
        const eventParameters = event.getParams();
        helper.openPrimaryAffiliationModal(component, eventParameters);
    },
    handleAutoEnrollmentModalRequest: function (component, event, helper) {
        event.stopPropagation();
        const eventParameters = event.getParams();
        helper.openAutoEnrollmentMappingModal(component, eventParameters);
    },
    handleRelationshipMappingModalRequest: function (component, event, helper) {
        event.stopPropagation();
        const eventParameters = event.getParams();
        helper.openRelationshipMappingModal(component, eventParameters);
    },
    settingsBatchJobModalRequestHandler: function (component, event, helper) {
        event.stopPropagation();
        const eventParameters = event.getParams();
        helper.openSettingsBatchJobModal(component, eventParameters);
    },
    handleModalSaveEvent: function (component, event, helper) {
        event.stopPropagation();
        helper.handleModalSaveEvent(component, event.getParam("saveModel"));
    }
});
