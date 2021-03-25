({
    handleCancelButtonClick: function (component, event, helper) {
        helper.fireButtonClickEvent(component, "cancel");
    },
    handleConfirmButtonClick: function (component, event, helper) {
        helper.fireButtonClickEvent(component, "confirm");
    },
    handletoggleSaveButtonVisibility: function (component, event, helper) {
        if (event.getParam("sourceName") === component.get("v.sourceName")) {
            event.stopPropagation();
            const disableSaveButton = event.getParam("disableSaveButton");
            component.set("v.disableSaveButton", disableSaveButton);
        }
    }
});
