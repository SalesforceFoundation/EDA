({
    setPageReference: function (component) {
        const componentPageReference = component.get("v.pageReference");
        component.set("v.pageReference", componentPageReference);
    },
    openPrimaryAffiliationModal: function (component, event) {
        console.log("opening modal 2");
        component.find("primaryAffiliationsModal").openPrimaryAffiliationsModal(event);
    }
});
