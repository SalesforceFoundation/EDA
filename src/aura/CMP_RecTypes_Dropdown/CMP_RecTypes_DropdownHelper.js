({
   onSelectChange : function(component) {
        var selectedVal = component.find("recTypesDropDown").get("v.value");
        component.set("v.recTypeId", selectedVal);
    },
    
   saveSetting : function(component) {        
        //Get selected value
        var recTypesDropDown = component.find("recTypesDropDown");
        var selectedRecTypeId = recTypesDropDown.get("v.value");

        //Set the selected value in the settings (so it gets saved)
        component.set("v.setting", selectedRecTypeId);

        //Set the value to display after save. 
        //We do this because we cannot get the selected name from the drop-down, only the ID
        var recTypes = component.get("v.recTypes");
        var selectedRecTypeName = '';
        for(var i = 0; i <recTypes.length; i += 1) {
            if(recTypes[i].id === selectedRecTypeId) {
                selectedRecTypeName = recTypes[i].name;
            }
        }
        component.set("v.recTypeName", selectedRecTypeName);
    }
})