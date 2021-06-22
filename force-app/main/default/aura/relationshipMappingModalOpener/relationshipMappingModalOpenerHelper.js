({
    openRelationshipMappingModal: function (component, eventParameters) {
        const relationshipMappingAction = eventParameters.relationshipMappingAction;
        const relationshipMappingName = eventParameters.relationshipMappingName;
        const femaleValue = eventParameters.femaleValue;
        const maleValue = eventParameters.maleValue;
        const neutralValue = eventParameters.neutralValue;
        const isActive = eventParameters.isActive;

        component.set("v.relationshipMappingAction", relationshipMappingAction);
        component.set("v.relationshipMappingName", relationshipMappingName);
        component.set("v.femaleValue", femaleValue);
        component.set("v.maleValue", maleValue);
        component.set("v.neutralValue", neutralValue);
        component.set("v.isActive", isActive);
        //Saving old name for edit mode
        component.set("v.oldRelationshipMappingName", relationshipMappingName);

        let modalBody;
        let modalFooter;

        let modalHeaderLabel;
        let confirmButton;
        let cancelButton;

        switch (component.get("v.relationshipMappingAction")) {
            case "create":
                modalHeaderLabel = $A.get("$Label.c.stgReciprocalRelNewModalTitle");
                confirmButton = $A.get("$Label.c.stgBtnSave");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
            case "edit":
                modalHeaderLabel = $A.get("$Label.c.stgReciprocalRelEditModalTitle");
                confirmButton = $A.get("$Label.c.stgBtnSave");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
            case "delete":
                modalHeaderLabel = $A.get("$Label.c.stgReciprocalRelDeleteModalTitle");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                confirmButton = $A.get("$Label.c.stgBtnDelete");
                break;
        }

        $A.createComponents(
            [
                [
                    "c:relationshipMappingModal",
                    {
                        relationshipMappingAction: component.get("v.relationshipMappingAction"),
                        relationshipMappingName: component.get("v.relationshipMappingName"),
                        oldRelationshipMappingName: component.get("v.oldRelationshipMappingName"),
                        femaleValue: component.get("v.femaleValue"),
                        maleValue: component.get("v.maleValue"),
                        neutralValue: component.get("v.neutralValue"),
                        isActive: component.get("v.isActive"),
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
            case "relationshipMappingName":
                component.set("v.relationshipMappingName", fieldValue);
                break;
            case "femaleValue":
                component.set("v.femaleValue", fieldValue);
                break;
            case "maleValue":
                component.set("v.maleValue", fieldValue);
                break;
            case "neutralValue":
                component.set("v.neutralValue", fieldValue);
                break;
            case "isActive":
                component.set("v.isActive", fieldValue);
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
        switch (component.get("v.relationshipMappingAction")) {
            case "create":
            case "edit":
            case "delete":
                this.handleModalActionConfirm(component);
                break;
        }
    },

    handleModalActionConfirm: function (component) {
        let modalSaveEvent = component.getEvent("modalSaveEvent");

        const saveModel = this.getModalSaveModel(component);

        modalSaveEvent.setParams({
            saveModel: saveModel
        });
        modalSaveEvent.fire();
    },

    getModalSaveModel: function (component) {
        const relationshipMappingAction = component.get("v.relationshipMappingAction");
        const relationshipMappingName = component.get("v.relationshipMappingName");
        const femaleValue = component.get("v.femaleValue");
        const maleValue = component.get("v.maleValue");
        const neutralValue = component.get("v.neutralValue");
        const isActive = component.get("v.isActive");
        const oldRelationshipMappingName = component.get("v.oldRelationshipMappingName");

        return {
            modalType: "relationshipmapping",
            action: relationshipMappingAction,
            relationshipMappingName: relationshipMappingName,
            oldRelationshipMappingName: oldRelationshipMappingName,
            femaleValue: femaleValue,
            maleValue: maleValue,
            neutralValue: neutralValue,
            isActive: isActive
        };
    }
});
