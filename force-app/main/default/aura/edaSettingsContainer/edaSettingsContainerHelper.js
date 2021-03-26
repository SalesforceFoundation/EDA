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

        component.set("v.mappingName", mappingName);
        component.set("v.accountRecordType", accountRecordType);
        component.set("v.affiliationsAction", affiliationsAction);
        component.set("v.contactField", contactField);

        component
            .find("primaryAffiliationsModal")
            .openPrimaryAffiliationsModal(affiliationsAction, accountRecordType, contactField);
    }
});
