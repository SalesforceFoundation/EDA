({
    handleShowModal: function (component, evt, helper) {
        let modalBody;
        $A.createComponent(
            "c:primaryAffiliationsModal",
            {
                "affiliationsModalEvent": component.getReference("c.handleModalEventMethod"),
            },
            function (content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find("primaryAffiliationsOverlayLibrary").showCustomModal({
                        header: "Application Confirmation",
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: "mymodal"
                    });
                }
            }
        );
    },
    handleModalEventMethod: function (component, event, helper) {
        console.log("Account Record Type " + event.getParam("accountRecordType"));
        console.log("Contact Field " + event.getParam("contactField"));    }
});
