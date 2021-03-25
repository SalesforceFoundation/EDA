({
    openPrimaryAffiliationsModal: function (component, event) {
        //TODO: Figure out what's going on here and why the details aren't passing.
        let hack = JSON.parse(JSON.stringify(event.getParam('arguments')));
        let eventDetails = hack[0].Xo;
        //console.log("Parameters: " + JSON.stringify(event.getParams()));
        //console.log("affiliationsAction: " + JSON.stringify(event.getParam('affiliationsAction')));
        //console.log("affiliationsDetail: " + JSON.stringify(event.getParam('affiliationsDetail')));
        //console.log("Arguments: " + JSON.stringify(event.getParam('arguments')));
        //console.log("HACK: " + JSON.stringify(hack));
        //console.log("HACK Object: " + JSON.stringify(hack[0]));
        //console.log("HACK ARGH: " + JSON.stringify(hackDetails));

        const accountRecordType = eventDetails.accountRecordType;
        const affiliationsAction = eventDetails.affiliationsAction;
        const contactField = eventDetails.contactField;

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
                "accountRecordType": component.get("v.accountRecordType"),
                "affiliationsAction": component.get("v.affiliationsAction"),
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
