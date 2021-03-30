({
    openPrimaryAffiliationsModal: function (component, eventParameters) {
        const affiliationsAction = eventParameters.affiliationsAction;
        const accountRecordType = eventParameters.accountRecordType;
        const contactField = eventParameters.contactField;

        component.set("v.accountRecordType",accountRecordType);
        component.set("v.affiliationsAction",affiliationsAction);
        component.set("v.contactField",contactField);

        let modalBody;
        let modalFooter;
        let modalHeaderLabel;
        let confirmButton;
        let cancelButton;

        switch(component.get("v.affiliationsAction")) {
            case "edit":
                modalHeaderLabel = $A.get("$Label.c.stgAffiliationsEditModalTitle");
                confirmButton = $A.get("$Label.c.stgBtnSave");
                cancelButton = $A.get("$Label.c.stgBtnCancel");
                break;
        }

        $A.createComponents([
            ["c:primaryAffiliationsModal",
            {
                "affiliationsAction": component.get("v.affiliationsAction"),
                "accountRecordType": component.get("v.accountRecordType"),
                "contactField": component.get("v.contactField"),
                "modalDataChangeEvent": component.getReference("c.handleModalDataChangeEvent"),
            }],
            ["c:customModalFooter",
            {
                "confirmButtonLabel": confirmButton,
                "confirmButtonTitle": confirmButton,
                "cancelButtonLabel": cancelButton,
                "cancelButtonTitle": cancelButton,
                "customModalFooterEvent": component.getReference("c.handleModalFooterEvent"),
            }]
        ],
            function (components, status) {
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    modalFooter = components[1];
                    component.find("edaSettingsOverlayLibrary").showCustomModal({
                        header: modalHeaderLabel,
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: false,
                        cssClass: "mymodal"
                    });
                }
            }
        );
    },
    handleModalDataChangeEvent: function (component, event) {
        const field = event.getParam("field");
        const fieldValue = event.getParam("fieldValue");

        switch(field) {
            case "accountRecordType":
                component.set("v.accountRecordType", fieldValue);
                break;
            case "contactField":
                component.set("v.contactField", fieldValue);
                break;
        }
    },
    handleModalFooterEvent: function (component, event) {
        switch(event.getParam("action")){
            case "confirm":
                this.handleModalFooterConfirm(component);
                break;
        }
    },
    handleModalFooterConfirm: function(component) {
        switch(component.get("v.affiliationsAction")) {
            case "edit":
                this.handleModalEditConfirm(component);
                break;
        }
    },
    handleModalEditConfirm: function(component) {
        //Call controller directly in Apex and attempt save,
        //Fail out if save does not resolve
        //Use accountRecordType, contactField, and mappingName
    }
});
