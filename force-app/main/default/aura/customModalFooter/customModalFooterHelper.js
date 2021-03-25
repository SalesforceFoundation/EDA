({
    fireButtonClickEvent: function (component, buttonClicked) {
        let customModalFooterButtonClickEvent = component.getEvent("customModalFooterButtonClickEvent");
        customModalFooterButtonClickEvent.setParams({
            type: buttonClicked
        });

        try {
            customModalFooterButtonClickEvent.fire();
            component.find("edaSettingsOverlayLibrary").notifyClose();
        } catch (e) {
            //save for validation handling
            //console.error(e);
        }
    }
});
