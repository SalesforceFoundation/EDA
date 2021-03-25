({
    openPrimaryAffiliationsModal: function (component, event) {
        //Event passing detail doesn't seem to be working...
        console.log("Parameters: " + JSON.stringify(event.getParams()));
        console.log("affiliationsAction: " + JSON.stringify(event.getParam('affiliationsAction')));
        console.log("affiliationsDetail: " + JSON.stringify(event.getParam('affiliationsDetail')));
        console.log("Arguments: " + JSON.stringify(event.getParam('arguments')));
        let hack = JSON.parse(JSON.stringify(event.getParam('arguments')));
        console.log("HACK: " + JSON.stringify(hack));
        console.log("HACK Object: " + JSON.stringify(hack[0]));
        let hackDetails = hack[0].Xo;
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
                "confirmButtonLabel": $A.get("$Label.c.stgBtnSave"),
                "confirmButtonTitle": $A.get("$Label.c.stgBtnSave"),
                "cancelButtonLabel": $A.get("$Label.c.stgBtnCancel"),
                "cancelButtonTitle": $A.get("$Label.c.stgBtnCancel"),
                "customModalFooterButtonClickEvent": component.getReference("c.handleModalEventMethod"),
            }]
        ],
            function (components, status) {
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    modalFooter = components[1];
                    component.find("edaSettingsOverlayLibrary").showCustomModal({
                        header: $A.get("$Label.c.stgAffiliationsEditModalTitle"),
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
        console.log("event detected");
        console.log(event.getParam("type"));
        console.log(event.getParams());
        switch(event.getParam("type")){
            case "cancel":
                console.log("cancel event detected!");
                component.find('primaryAffiliationsOverlayLibrary').notifyClose()
                break;
            case "change":
                console.log("change event detected!");
                component.set("v.accountRecordType", event.getParam("accountRecordType"));
                component.set("v.contactField", event.getParam("contactField"));
                break;
            case "save":
                console.log("save event detected!");
                component.find('primaryAffiliationsOverlayLibrary').notifyClose()
                break;
        }
    }
});
