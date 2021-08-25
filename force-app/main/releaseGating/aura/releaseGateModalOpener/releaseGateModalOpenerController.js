({
    openReleaseGateModal: function (component, event, helper) {
        helper.openReleaseGateModal(component, event.getParam("arguments"));
    },
    handleModalDataChangeEvent: function (component, event, helper) {
        helper.handleModalDataChangeEvent(component, event);
    },
    handleModalFooterEvent: function (component, event, helper) {
        helper.handleModalFooterEvent(component, event);
    }
});
