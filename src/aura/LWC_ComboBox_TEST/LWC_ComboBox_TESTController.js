({
    handlePicklistItemSelected : function(component, event, helper) {
        console.log('Handling picklist selection in parent component');
        var selectedItem = event.getParam('selectedItem');
        console.log('you selected: ' + selectedItem);

        component.set('v.selectedItem', selectedItem);
    }
})
