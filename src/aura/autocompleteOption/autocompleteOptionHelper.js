({
    fireOptionSelectedEvent : function(component) {
        var optionSelected = component.get('e.optionSelected');
        var componentValue = component.get('v.value');
        optionSelected.setParams({value: componentValue});
        optionSelected.fire();
    }
})