({
    setPageReference: function (component) {
        const componentPageReference = component.get("v.pageReference");
        component.set("v.pageReference", componentPageReference);
    },
    openPrimaryAffiliationModal: function (component, event) {
        component.find("primaryAffiliationsModal").openPrimaryAffiliationsModal(event);
    }
});
