({
    openReleaseGateModal: function (component, eventParameters) {
        const releaseGateAction = eventParameters.releaseGateAction;
        const productRegistryName = eventParameters.productRegistryName;
        const productName = eventParameters.productName;
        const productLabel = eventParameters.productLabel;
        const releaseGateName = eventParameters.releaseGateName;
        const releaseGateLabel = eventParameters.releaseGateLabel;

        component.set("v.releaseGateAction", releaseGateAction);
        component.set("v.productRegistryName", productRegistryName);
        component.set("v.productName", productName);
        component.set("v.productLabel", productLabel);
        component.set("v.releaseGateName", releaseGateName);
        component.set("v.releaseGateLabel", releaseGateLabel);

        let modalBody;
        let modalFooter;
        let modalHeaderLabel;
        let confirmButton;
        let cancelButton;

        switch (component.get("v.releaseGateAction")) {
            case "activate":
                modalHeaderLabel = $A.get("$Label.c.stgReleaseGateActivate").replace("{0}", releaseGateLabel);
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                confirmButton = $A.get("$Label.c.stgBtnReleaseGateActivate");
                break;
        }

        $A.createComponents(
            [
                [
                    "c:releaseGateModal",
                    {
                        releaseGateAction: component.get("v.releaseGateAction"),
                        productRegistryName: component.get("v.productRegistryName"),
                        productName: component.get("v.productName"),
                        productLabel: component.get("v.productLabel"),
                        releaseGateName: component.get("v.releaseGateName"),
                        releaseGateLabel: component.get("v.releaseGateLabel")
                    }
                ],
                [
                    "c:customModalFooter",
                    {
                        confirmButtonLabel: confirmButton,
                        confirmButtonTitle: confirmButton,
                        cancelButtonLabel: cancelButton,
                        cancelButtonTitle: cancelButton,
                        customModalFooterEvent: component.getReference("c.handleModalFooterEvent")
                    }
                ]
            ],
            function (components, status) {
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    modalFooter = components[1];
                    //Create the modal
                    component.find("edaOverlayLibrary").showCustomModal({
                        header: modalHeaderLabel,
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: false
                    });
                }
            }
        );
    },
    handleModalFooterEvent: function (component, event) {
        event.stopPropagation();
        switch (event.getParam("action")) {
            case "confirm":
                this.handleModalFooterConfirm(component);
                break;
        }
    },
    handleModalFooterConfirm: function (component) {
        switch (component.get("v.releaseGateAction")) {
            case "activate":
                this.handleModalActionConfirm(component);
                break;
        }
    },

    handleModalActionConfirm: function (component) {
        let modalSaveEvent = component.getEvent("modalSaveEvent");

        const saveModel = this.getReleaseGateModel(component);

        modalSaveEvent.setParams({
            saveModel: saveModel
        });
        modalSaveEvent.fire();
    },

    getReleaseGateModel: function (component) {
        const releaseGateAction = component.get("v.releaseGateAction");
        const productRegistryName = component.get("v.productRegistryName");
        const productName = component.get("v.productName");
        const productLabel = component.get("v.productLabel");
        const releaseGateName = component.get("v.releaseGateName");
        const releaseGateLabel = component.get("v.releaseGateLabel");

        return {
            modalType: "releasegate",
            releaseGateAction: releaseGateAction,
            productRegistryName: productRegistryName,
            productName: productName,
            productLabel: productLabel,
            releaseGateName: releaseGateName,
            releaseGateLabel: releaseGateLabel
        };
    }
});
