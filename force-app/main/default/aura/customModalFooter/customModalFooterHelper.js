({
    fireButtonClickEvent: function (component, buttonClicked) {
        let customModalFooterEvent = component.getEvent("customModalFooterEvent");
        customModalFooterEvent.setParams({
            action: buttonClicked
        });

        try {
            customModalFooterEvent.fire();
            component.find("edaSettingsOverlayLibrary").notifyClose();
        } catch (e) {
            //save for validation handling
            //console.error(e);
        }
    },
    handleToggleSaveButtonVisibility: function (component, sourceName) {
        if (event.getParam("sourceName") === component.get("v.sourceName")) {
            event.stopPropagation();
            const disableSaveButton = event.getParam("disableSaveButton");
            component.set("v.disableSaveButton", disableSaveButton);
        }
    }
});
