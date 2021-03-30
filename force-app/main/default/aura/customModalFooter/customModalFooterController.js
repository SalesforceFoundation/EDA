({
    handleCancelButtonClick: function (component, event, helper) {
        helper.fireButtonClickEvent(component, "cancel");
    },
    handleConfirmButtonClick: function (component, event, helper) {
        helper.fireButtonClickEvent(component, "confirm");
    },
    handleToggleSaveButtonVisibility: function (component, event, helper) {
        const sourceName = event.getParam("sourceName");
        helper.handleToggleSaveButtonVisibility(component, sourceName);
    }
});
