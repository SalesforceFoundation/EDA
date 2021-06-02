({
    openAutoEnrollmentMappingModal: function (component, eventParameters) {
        const actionName = eventParameters.actionName;
        const mappingName = eventParameters.mappingName;
        const oldAccountRecordType = eventParameters.oldAccountRecordType;
        const autoProgramEnrollmentStatus = eventParameters.autoProgramEnrollmentStatus;
        const autoProgramEnrollmentRole = eventParameters.autoProgramEnrollmentRole;

        component.set("v.actionName", actionName);
        component.set("v.mappingName", mappingName);
        component.set("v.oldAccountRecordType", oldAccountRecordType);
        component.set("v.newAccountRecordType", oldAccountRecordType);
        component.set("v.autoProgramEnrollmentStatus", autoProgramEnrollmentStatus);
        component.set("v.autoProgramEnrollmentRole", autoProgramEnrollmentRole);

        let modalBody;
        let modalFooter;

        let modalHeaderLabel;
        let confirmButton;
        let cancelButton;

        switch (component.get("v.actionName")) {
            case "create":
                modalHeaderLabel = $A.get("$Label.c.stgAutoEnrollmentNewModalTitle");
                confirmButton = $A.get("$Label.c.stgBtnSave");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
            case "edit":
                modalHeaderLabel = $A.get("$Label.c.stgAutoEnrollmentEditModalTitle");
                confirmButton = $A.get("$Label.c.stgBtnSave");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
            case "delete":
                modalHeaderLabel = $A.get("$Label.c.stgAutoEnrollmentDeleteModalTitle");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                confirmButton = $A.get("$Label.c.stgBtnDelete");
                break;
        }

        $A.createComponents(
            [
                [
                    "c:autoEnrollmentMappingModal",
                    {
                        actionName: component.get("v.actionName"),
                        oldAccountRecordType: component.get("v.oldAccountRecordType"),
                        newAccountRecordType: component.get("v.newAccountRecordType"),
                        autoProgramEnrollmentStatus: component.get("v.autoProgramEnrollmentStatus"),
                        autoProgramEnrollmentRole: component.get("v.autoProgramEnrollmentRole"),
                        modalDataChangeEvent: component.getReference("c.handleModalDataChangeEvent")
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
    handleModalDataChangeEvent: function (component, event) {
        event.stopPropagation();
        const field = event.getParam("field");
        const fieldValue = event.getParam("fieldValue");
        switch (field) {
            case "newAccountRecordType":
                component.set("v.newAccountRecordType", fieldValue);
                break;
            case "autoProgramEnrollmentStatus":
                component.set("v.autoProgramEnrollmentStatus", fieldValue);
                break;
            case "autoProgramEnrollmentRole":
                component.set("v.autoProgramEnrollmentRole", fieldValue);
                break;
        }
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
        switch (component.get("v.actionName")) {
            case "create":
                this.handleModalCreateConfirm(component);
                break;
            case "edit":
                this.handleModalEditConfirm(component);
                break;
            case "delete":
                this.handleModalDeleteConfirm(component);
                break;
        }
    },

    handleModalEditConfirm: function (component) {
        let modalSaveEvent = component.getEvent("modalSaveEvent");

        const actionName = component.get("v.actionName");
        const mappingName = component.get("v.mappingName");
        const oldAccountRecordType = component.get("v.oldAccountRecordType");
        const newAccountRecordType = component.get("v.newAccountRecordType");
        const autoProgramEnrollmentStatus = component.get("v.autoProgramEnrollmentStatus");
        const autoProgramEnrollmentRole = component.get("v.autoProgramEnrollmentRole");

        const saveModel = {
            modalType: "autoenrollmentmapping",
            action: actionName,
            mappingName: mappingName,
            oldAccountRecordType: oldAccountRecordType,
            newAccountRecordType: newAccountRecordType,
            autoProgramEnrollmentStatus: autoProgramEnrollmentStatus,
            autoProgramEnrollmentRole: autoProgramEnrollmentRole
        };
        modalSaveEvent.setParams({
            saveModel: saveModel
        });
        modalSaveEvent.fire();
    },

    handleModalDeleteConfirm: function (component) {
        let modalSaveEvent = component.getEvent("modalSaveEvent");

        const actionName = component.get("v.actionName");
        const mappingName = component.get("v.mappingName");

        const deleteModel = {
            modalType: "autoenrollmentmapping",
            action: actionName,
            mappingName: mappingName
        };

        modalSaveEvent.setParams({
            saveModel: deleteModel
        });
        modalSaveEvent.fire();
    },

    handleModalCreateConfirm: function (component) {
        let modalSaveEvent = component.getEvent("modalSaveEvent");

        const actionName = component.get("v.actionName");
        const mappingName = component.get("v.mappingName");
        const newAccountRecordType = component.get("v.newAccountRecordType");
        const autoProgramEnrollmentStatus = component.get("v.autoProgramEnrollmentStatus");
        const autoProgramEnrollmentRole = component.get("v.autoProgramEnrollmentRole");

        const saveModel = {
            modalType: "autoenrollmentmapping",
            action: actionName,
            mappingName: mappingName,
            accountRecordType: newAccountRecordType,
            autoProgramEnrollmentStatus: autoProgramEnrollmentStatus,
            autoProgramEnrollmentRole: autoProgramEnrollmentRole
        };
        modalSaveEvent.setParams({
            saveModel: saveModel
        });
        modalSaveEvent.fire();
    }
});
