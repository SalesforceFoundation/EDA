({
    setPageReference: function (component) {
        const componentPageReference = component.get("v.pageReference");
        component.set("v.pageReference", componentPageReference);
    },
    openPrimaryAffiliationModal: function (component, eventParameters) {
        const mappingName = eventParameters.mappingName;
        const affiliationsAction = eventParameters.affiliationsAction;
        const accountRecordType = eventParameters.accountRecordType;
        const contactField = eventParameters.contactField;

        console.log("pre-modal");
        console.log(mappingName);
        console.log(accountRecordType);
        console.log(affiliationsAction);
        console.log(contactField);

        component
            .find("primaryAffiliationsModal")
            .openPrimaryAffiliationsModal(affiliationsAction, accountRecordType, contactField);
    }
});
