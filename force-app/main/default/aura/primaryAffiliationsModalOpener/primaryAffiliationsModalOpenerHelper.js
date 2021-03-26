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
                "affiliationsModalEvent": component.getReference("c.handleModalEvent"),
            }],
            ["c:customModalFooter",
            {
                "confirmButtonLabel": confirmButton,
                "confirmButtonTitle": confirmButton,
                "cancelButtonLabel": cancelButton,
                "cancelButtonTitle": cancelButton,
                "customModalFooterButtonClickEvent": component.getReference("c.handleModalFooterEvent"),
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
    handleModalEvent: function (component, event) {
        component.set("v.accountRecordType", event.getParam("accountRecordType"));
        component.set("v.contactField", event.getParam("contactField"));
    },
    handleModalFooterEvent: function (component, event) {
        switch(event.getParam("action")){
            case "save":
                //Call controller directly in Apex and attempt save,
                //Fail out if save does not resolve
                //Use accountRecordType, contactField, and mappingName
                break;
        }
    }
});
