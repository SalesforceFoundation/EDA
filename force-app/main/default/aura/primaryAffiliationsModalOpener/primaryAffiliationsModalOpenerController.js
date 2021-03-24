({
    handleShowModal: function (component, evt, helper) {
        let modalBody;
        $A.createComponent(
            "c:primaryAffiliationsModal",
            {
                primaryAffiliationsModalSave: component.getReference("c.primaryAffiliationsSave")
            },
            function (content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find("primaryAffiliationsOverlayLibrary").showCustomModal({
                        header: "Application Confirmation",
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: "mymodal",
                        closeCallback: function () {
                            alert("You closed the alert");
                        }
                    });
                }
            }
        );
    },
    handleSaveEvent: function (component, event, helper) {
        console.log("mid level save");
    }
});
