({
    openSettingsBatchJobModal: function (component, eventParameters) {
        const batchJobToRun = eventParameters.batchJobToRun;

        component.set("v.batchJobToRun", batchJobToRun);

        let modalBody;
        let modalFooter;

        let modalHeaderLabel;
        let modalDesc;
        let confirmButton;
        let cancelButton;

        switch (component.get("v.batchJobToRun")) {
            case "ACCT_AdministrativeNameRefresh_BATCH":
                modalHeaderLabel = $A.get("$Label.c.stgRefreshAdminNamesModalTitle");
                modalDesc = $A.get("$Label.c.stgRefreshAdminNamesModalBody");
                confirmButton = $A.get("$Label.c.stgBtnUpdate");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
            case "ACCT_HouseholdNameRefresh_BATCH":
                modalHeaderLabel = $A.get("$Label.c.stgRefreshHouseholdNamesModalTitle");
                modalDesc = $A.get("$Label.c.stgRefreshHouseholdNamesModalBody");
                confirmButton = $A.get("$Label.c.stgBtnUpdate");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
            case "CON_EMAIL_BATCH":
                modalHeaderLabel = $A.get("$Label.c.stgPreferredPhoneEmailModalTitle");
                modalDesc = $A.get("$Label.c.stgPreferredPhoneEmailModalBody");
                confirmButton = $A.get("$Label.c.stgBtnUpdate");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
            case "CON_EthnicityRace_BATCH":
                modalHeaderLabel = $A.get("$Label.c.stgEthnicityRaceBackfillModalTitle");
                modalDesc = $A.get("$Label.c.stgEthnicityRaceBackfillModalBody");
                confirmButton = $A.get("$Label.c.stgBtnUpdate");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
            case "COUR_DescriptionCopy_BATCH":
                modalHeaderLabel = $A.get("$Label.c.stgCourseDataMigrationModalTitle");
                modalDesc = $A.get("$Label.c.stgCourseDataMigrationModalBody");
                confirmButton = $A.get("$Label.c.stgBtnUpdate");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
        }

        $A.createComponents(
            [
                [
                    "c:batchJobModal",
                    {
                        modalAction: modalDesc
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
        this.handleModalBatchConfirm(component);
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
