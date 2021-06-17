({
    openRelationshipMappingModal: function (component, event, helper) {
        helper.openRelationshipMappingModal(component, event.getParam("arguments"));
    },
    handleModalDataChangeEvent: function (component, event, helper) {
        helper.handleModalDataChangeEvent(component, event);
    },
    handleModalFooterEvent: function (component, event, helper) {
        helper.handleModalFooterEvent(component, event);
    }
});
