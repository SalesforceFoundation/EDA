({
    openPrimaryAffiliationsModal: function (component, event) {
        //Event passing detail doesn't seem to be working...
        console.log("Parameters: " + JSON.stringify(event.getParams()));
        console.log("affiliationsDetail: " + JSON.stringify(event.getParam('affiliationsAction')));
        console.log("affiliationsAction: " + JSON.stringify(event.getParam('affiliationsDetail')));
        console.log("Arguments: " + JSON.stringify(event.getParam('arguments')));
        let hack = JSON.parse(JSON.stringify(event.getParam('arguments')));
        console.log("HACK: " + JSON.stringify(hack));
        console.log("HACK Object: " + JSON.stringify(hack[0]));
        let hackDetails = hack[0].Xo.affiliationsDetail;
        console.log("HACK ARGH: " + JSON.stringify(hackDetails));

        let modalBody;
        let modalFooter;
        $A.createComponents([
            ["c:primaryAffiliationsModal",
            {
                "accountRecordType": hackDetails.accountRecordTypeName,
                "contactField": hackDetails.contactFieldName,
                "affiliationsModalEvent": component.getReference("c.handleModalEventMethod"),
            }],
            ["c:customModalFooter",
            {
                "confirmButtonLabel": "Save",
                "confirmButtonTitle":"Save",
                "cancelButtonLabel": "Cancel",
                "cancelButtonTitle": "Cancel",
                "customModalFooterButtonClickEvent": component.getReference("c.handleModalEventMethod"),
            }]
        ],
            function (components, status) {
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    modalFooter = components[1];
                    component.find("primaryAffiliationsOverlayLibrary").showCustomModal({
                        header: "Is this a modal?",
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: false,
                        cssClass: "mymodal"
                    });
                }
            }
        );
    },
    handleModalEventMethod: function (component, event) {
        component.set("v.accountRecordType", event.getParam("accountRecordType"));
        component.set("v.contactField", event.getParam("contactField"));
    }
});
