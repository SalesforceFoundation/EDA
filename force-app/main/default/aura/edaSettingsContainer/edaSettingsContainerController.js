({
    init: function (component, event, helper) {
        helper.setPageReference(component);
    },
    primaryAffiliationModalRequestHandler: function (component, event, helper) {
        console.log("opening modal");
        helper.openPrimaryAffiliationModal(component, event);
    }
});
