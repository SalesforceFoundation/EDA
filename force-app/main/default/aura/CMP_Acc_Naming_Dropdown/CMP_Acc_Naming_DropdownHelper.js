({
    onSelectChange : function(component) {
        var selectedVal = component.find("nameFormatDropDown").get("v.value");
        var prefix = component.get("v.namespacePrefix");
        var accNamingOther = $A.get("$Label.c.acctNamingOther");
        if(selectedVal === accNamingOther) {
            component.set("v.otherDisplay", true);
        } else {
            component.set("v.otherDisplay", false);
        }
        component.set("v.nameFormat", selectedVal);
    },
    
    saveSetting : function(component) {        
        //Get selected value
        var selectedVal = component.find("nameFormatDropDown").get("v.value");
        //Set the selected value in the settings (so it gets saved)
        component.set("v.setting", selectedVal);
        component.set("v.nameFormat", selectedVal);
        var prefix = component.get("v.namespacePrefix");
        var accNamingOther = $A.get("$Label.c.acctNamingOther");
        if (selectedVal === ($A.get("$Label.c.acctNamingOther")))
        {
            selectedVal = component.find("otherText").get("v.value");
            component.set("v.otherSetting", selectedVal);
        }
    }
})