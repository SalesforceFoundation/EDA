({
   onSelectChange : function(component) {
        var selectedVal = component.find("picklistDropDown").get("v.value");
        component.set("v.picklistValue", selectedVal);
    },
    
   saveSetting : function(component) {        
        //Get selected value
        var picklistDropDown = component.find("picklistDropDown");
        var selectedPicklistValue = recTypesDropDown.get("v.value");

        //Set the selected value in the settings (so it gets saved)
        component.set("v.setting", selectedPicklistValue);

        //Set the value to display after save. 
        //We do this because we cannot get the selected label from the drop-down, only the value
        var picklistEntries = component.get("v.recTypes");
        var selectedRecTypeLabel = '';
        for(var i = 0; i <picklistEntries.length; i += 1) {
            if(picklistEntries[i].picklistValue === selectedPicklistValue) {
                selectedPicklistValue = picklistEntries[i].picklistLabel;
            }
        }
        component.set("v.picklistLabel", selectedRecTypeLabel);
    }
})