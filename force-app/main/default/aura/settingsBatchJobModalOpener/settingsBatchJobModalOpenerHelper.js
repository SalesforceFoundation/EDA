({
    openSettingsBatchJobModal: function (component, eventParameters) {
        window.alert("3 inside openSettingsBatchJobModal");
        const batchJobToRun = eventParameters.batchJobToRun;

        component.set("v.batchJobToRun", batchJobToRun);

        let modalBody;
        let modalFooter;

        let modalHeaderLabel;
        let confirmButton;
        let cancelButton;

        switch (component.get("v.batchJobToRun")) {
            case "ACCT_HouseholdNameRefresh_BATCH":
                modalHeaderLabel = $A.get("$Label.c.stgRefreshHHAcctNameTitle");
                confirmButton = $A.get("$Label.c.stgBtnUpdate");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
        }

        $A.createComponents(
            [
                [
                    "c:batchJobModal",
                    {
                        batchJobToRun: component.get("v.batchJobToRun")
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
    // handleModalDataChangeEvent: function (component, event) {
    //     event.stopPropagation();
    //     const field = event.getParam("field");
    //     const fieldValue = event.getParam("fieldValue");

    //     switch (field) {
    //         case "accountRecordType":
    //             component.set("v.accountRecordType", fieldValue);
    //             break;
    //         case "contactField":
    //             component.set("v.contactField", fieldValue);
    //             break;
    //     }
    // },
    handleModalFooterEvent: function (component, event) {
        event.stopPropagation();
        switch (event.getParam("action")) {
            case "confirm":
                this.handleModalFooterConfirm(component);
                break;
        }
    },
    handleModalFooterConfirm: function (component) {
        switch (component.get("v.batchJobToRun")) {
            case "ACCT_HouseholdNameRefresh_BATCH":
                this.handleModalBatchConfirm(component);
                break;
        }
    },
    handleModalBatchConfirm: function (component) {
        let modalSaveEvent = component.getEvent("modalSaveEvent");

        const batchJobToRun = component.get("v.batchJobToRun");

        const saveModel = {
            modalType: "batchjob",
            batchJobToRun: batchJobToRun
        };

        modalSaveEvent.setParams({
            saveModel: saveModel
        });
        modalSaveEvent.fire();
    }
});
