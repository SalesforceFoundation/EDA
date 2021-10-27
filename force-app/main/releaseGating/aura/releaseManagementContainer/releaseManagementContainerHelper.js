({
    openReleaseGateModal: function (component, eventParameters) {
        const releaseGateAction = eventParameters.releaseGateAction;
        const productRegistryName = eventParameters.productRegistryName;
        const productName = eventParameters.productName;
        const productLabel = eventParameters.productLabel;
        const releaseGateName = eventParameters.releaseGateName;
        const releaseGateLabel = eventParameters.releaseGateLabel;

        component
            .find("releaseGateModal")
            .openReleaseGateModal(
                releaseGateAction,
                productRegistryName,
                productName,
                productLabel,
                releaseGateName,
                releaseGateLabel
            );
    },
    handleModalSaveEvent: function (component, saveModel) {
        const releaseManagement = component.find("releaseManagement");
        const releaseManagementElement = releaseManagement.getElement();
        releaseManagementElement.modalSave(saveModel);
    }
});
