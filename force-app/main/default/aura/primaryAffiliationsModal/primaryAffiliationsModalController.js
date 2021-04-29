({
    handleAccountRecordTypeChange: function (component, event, helper) {
        console.log("controller " + event.getParam("accountRecordType"));

        helper.handleAccountRecordTypeChange(component, event.getParam("accountRecordType"));
    },
    handleContactFieldChange: function (component, event, helper) {
        helper.handleContactFieldChange(component, event.getParam("contactField"));
    }
});
