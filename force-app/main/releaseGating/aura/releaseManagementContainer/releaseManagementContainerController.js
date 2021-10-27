({
    releaseGateModalRequestHandler: function (component, event, helper) {
        event.stopPropagation();
        const eventParameters = event.getParams();
        helper.openReleaseGateModal(component, eventParameters);
    },
    handleModalSaveEvent: function (component, event, helper) {
        event.stopPropagation();
        helper.handleModalSaveEvent(component, event.getParam("saveModel"));
    }
});
