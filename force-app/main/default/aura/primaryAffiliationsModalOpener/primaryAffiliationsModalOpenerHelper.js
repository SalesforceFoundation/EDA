({
    openPrimaryAffiliationsModal: function (component, event) {
        console.log("Mapping: " + event.getParam('affiliationsDetail')); 
        console.log("Parameters: " + JSON.stringify(event.getParams())); 
        /*const mappingName = event.getParam("mappingName");
        const accountRecordTypeName = event.getParam("primaryAffiliation.accountRecordTypeName");
        const contactFieldName = event.getParam("primaryAffiliation.contactFieldName");
        console.log("event params");
        console.log(JSON.stringify(event.getParams()));
        console.log(mappingName);
        console.log(accountRecordTypeName);
        console.log(contactFieldName);

        component.set("v.mappingName",mappingName);
        component.set("v.accountRecordType",accountRecordTypeName);
        component.set("v.contactField",contactFieldName);*/

        let modalBody;
        $A.createComponent(
            "c:primaryAffiliationsModal",
            {
                /*"accountRecordType": accountRecordTypeName,
                "contactField": contactFieldName,*/
                "affiliationsModalEvent": component.getReference("c.handleModalEventMethod"),
            },
            function (content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    /*modalBody.set("v.mappingName",mappingName);
                    modalBody.set("v.accountRecordType",accountRecordTypeName);
                    modalBody.set("v.contactField",contactFieldName);*/
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
    handleModalEventMethod: function (component, event) {
        console.log("Account Record Type " + event.getParam("accountRecordType"));
        console.log("Contact Field " + event.getParam("contactField"));    }
});
