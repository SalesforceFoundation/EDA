({
    fireButtonClickEvent: function (component, buttonClicked) {
        let customModalFooterButtonClickEvent = $A.get("e.c:CustomModalFooterButtonClickEvent");
        customModalFooterButtonClickEvent.setParams({
            buttonClicked: buttonClicked,
            sourceName: component.get("v.sourceName")
        });

        try {
            customModalFooterButtonClickEvent.fire();
        } catch (e) {
            //save for validation handling
            //console.error(e);
        }
    }
});
