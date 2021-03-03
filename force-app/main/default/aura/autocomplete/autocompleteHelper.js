({
    handleInputChange: function(component) {
        this.setListVisibility(component, false);

        var keyword = component.find('input').get('v.value');

        // IE 11 fires the input event when we tab off,
        // causing it to reopen.
        //
        // if this event is fired and the element is not focused, ignore
        if (component.get('v.inputFocused')) {
            component.set('v.keyword', keyword);

            if (!keyword) {
                // user has cleared the textbox, so clear our results
                component.set('v.items', []);
                return;
            }

            this.setListVisibility(component, true);
            component.set('v.showLoadingIndicator', true);

            var dataProvider = component.get('v.dataProvider')[0];
            var idDataCallback = component.get('v.idDataCallback');
            idDataCallback++;
            component.set('v.idDataCallback', idDataCallback);

            dataProvider.provide(
                keyword,
                idDataCallback,
                $A.getCallback(function (err, idDataCallback, items) {
                    if (!component || !component.isValid()) {
                        return;
                    }
                    if (err) {
                        component.set('v.showLoadingIndicator', false);
                        throw err;
                    }
                    var id = component.get('v.idDataCallback');
                    // only refresh the list if this callback is the most recent
                    if (idDataCallback >= id) {
                        component.set('v.items', items);
                        component.set('v.idDataCallback', idDataCallback);
                        component.set('v.showLoadingIndicator', false);
                    }
                })
            );

        }
    },

    setListVisibilityDelayed: function (component, visible) {
        var helper = this;
        if (component._focus) {
            component._focus(
                $A.getCallback(
                    function() {
                        if (component && component.isValid()) {
                            helper.setListVisibility(component, visible);
                        }
                    }
                ),
                250 // too small a number caused issues in IE and Firefox on Windows
            );
        } else {
            helper.setListVisibility(component, visible);
        }
    },

    setListVisibility: function (component, visible) {
        var listComponent = component.find('list');
        $A.util.toggleClass(listComponent, "slds-hide", !visible);
        component.set('v.isListVisible', visible);
    }
})