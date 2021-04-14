({
    fireButtonClickEvent: function (component, buttonClicked) {
        let customModalFooterEvent = component.getEvent("customModalFooterEvent");
        customModalFooterEvent.setParams({
            action: buttonClicked
        });

        try {
            customModalFooterEvent.fire();
            window.alert("&&&& inside confirm TRY");
            component.find("edaOverlayLibrary").notifyClose();
        } catch (e) {
            window.alert("&&&& inside confirm CATCH: " + e);
            //save for validation handling
            //console.error(e);
        }
    },
    handleToggleSaveButtonVisibility: function (component, sourceName, disableSaveButton) {
        if (sourceName === component.get("v.sourceName")) {
            component.set("v.disableSaveButton", disableSaveButton);
        }
    }
});
