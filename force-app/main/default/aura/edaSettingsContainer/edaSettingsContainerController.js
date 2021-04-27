({
    init: function (component, event, helper) {
        helper.setPageReference(component);
    },
    primaryAffiliationModalRequestHandler: function (component, event, helper) {
        event.stopPropagation();
        const eventParameters = event.getParams();
        helper.openPrimaryAffiliationModal(component, eventParameters);
    },
    handleModalSaveEvent: function (component, event, helper) {
        event.stopPropagation();
        helper.handleModalSaveEvent(component, event.getParam("saveModel"));
    }
});
