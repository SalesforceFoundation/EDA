({
    handleAccountRecordTypeChange: function (component, event, helper) {
        helper.handleAccountRecordTypeChange(component, event.getParam("accountRecordType"));
    },
    handleContactFieldChange: function (component, event, helper) {
        helper.handleContactFieldChange(component, event.getParam("contactField"));
    }
});
