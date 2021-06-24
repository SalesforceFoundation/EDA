({
    openPrimaryAffiliationsModal: function (component, eventParameters) {
        const affiliationsAction = eventParameters.affiliationsAction;
        const mappingName = eventParameters.mappingName;
        const accountRecordType = eventParameters.accountRecordType;
        const contactField = eventParameters.contactField;
        const autoProgramEnrollment = eventParameters.autoProgramEnrollment;

        component.set("v.affiliationsAction", affiliationsAction);
        component.set("v.mappingName", mappingName);
        component.set("v.accountRecordType", accountRecordType);
        component.set("v.contactField", contactField);
        component.set("v.autoProgramEnrollment", autoProgramEnrollment);

        let modalBody;
        let modalFooter;

        let modalHeaderLabel;
        let confirmButton;
        let cancelButton;

        switch (component.get("v.affiliationsAction")) {
            case "create":
                modalHeaderLabel = $A.get("$Label.c.stgNewAfflMapping");
                confirmButton = $A.get("$Label.c.stgBtnSave");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
            case "edit":
                modalHeaderLabel = $A.get("$Label.c.stgAffiliationsEditModalTitle");
                confirmButton = $A.get("$Label.c.stgBtnSave");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
            case "delete":
                modalHeaderLabel = $A.get("$Label.c.stgAffiliationsDeleteModalTitle");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                confirmButton = $A.get("$Label.c.stgBtnDelete");
                break;
        }

        $A.createComponents(
            [
                [
                    "c:primaryAffiliationsModal",
                    {
                        affiliationsAction: component.get("v.affiliationsAction"),
                        accountRecordType: component.get("v.accountRecordType"),
                        contactField: component.get("v.contactField"),
                        autoProgramEnrollment: component.get("v.autoProgramEnrollment"),
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
            case "accountRecordType":
                component.set("v.accountRecordType", fieldValue);
                break;
            case "contactField":
                component.set("v.contactField", fieldValue);
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
        switch (component.get("v.affiliationsAction")) {
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

        const mappingName = component.get("v.mappingName");
        const affiliationsAction = component.get("v.affiliationsAction");
        const accountRecordType = component.get("v.accountRecordType");
        const contactField = component.get("v.contactField");

        const saveModel = {
            modalType: "affiliations",
            action: affiliationsAction,
            mappingName: mappingName,
            accountRecordType: accountRecordType,
            contactField: contactField
        };

        modalSaveEvent.setParams({
            saveModel: saveModel
        });
        modalSaveEvent.fire();
    },

    handleModalDeleteConfirm: function(component) {
        let modalSaveEvent = component.getEvent("modalSaveEvent");

        const mappingName = component.get("v.mappingName");
        const affiliationsAction = component.get("v.affiliationsAction");
        const accountRecordType = component.get("v.accountRecordType");
        const contactField = component.get("v.contactField");
        const autoProgramEnrollment = component.get("v.autoProgramEnrollment");

        const saveModel = {
            modalType: "affiliations",
            action: affiliationsAction,
            mappingName: mappingName,
            accountRecordType: accountRecordType,
            contactField: contactField,
            autoEnrollmentEnabled: autoProgramEnrollment
        };
        
        modalSaveEvent.setParams({
            saveModel: saveModel
        });
        modalSaveEvent.fire();
    },
    handleModalCreateConfirm: function (component) {
        let modalSaveEvent = component.getEvent("modalSaveEvent");

        const mappingName = component.get("v.accountRecordType");
        const affiliationsAction = component.get("v.affiliationsAction");
        const accountRecordType = component.get("v.accountRecordType");
        const contactField = component.get("v.contactField");

        const saveModel = {
            modalType: "affiliations",
            action: affiliationsAction,
            mappingName: mappingName,
            accountRecordType: accountRecordType,
            contactField: contactField
        };

        modalSaveEvent.setParams({
            saveModel: saveModel
        });
        modalSaveEvent.fire();
    }
});
