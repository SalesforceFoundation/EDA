({
    init : function(component) {
        //Retrieving account naming options
        this.getAdminAccNameFormatOptions(component);
        this.getHHAccNameFormatOptions(component);
    },
    onSelectChange : function(component) {
        var selectedVal = component.find("nameFormatDropDown").get("v.value");
        var prefix = component.get("v.namespacePrefix");
        if (prefix === 'hed__') {
            var accNamingOther = $A.get("$Label.hed.acctNamingOther");
        } else {
            var accNamingOther = $A.get("$Label.c.acctNamingOther");
        }
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
        if (prefix === 'hed__') {
            var accNamingOther = $A.get("$Label.hed.acctNamingOther");
        } else {
            var accNamingOther = $A.get("$Label.c.acctNamingOther");
        }
        if (selectedVal === ($A.get("$Label.c.acctNamingOther")))
        {
            selectedVal = component.find("otherText").get("v.value");
            component.set("v.otherSetting", selectedVal);
        }
    },

    getAdminAccNameFormatOptions : function(component) {
        var adminAccNameFormatOptions = [];
        var prefix = component.get("v.namespacePrefix");
        if (prefix === 'hed__')
        {
            adminAccNameFormatOptions.push($A.get("$Label.hed.lastNameAdminAcc"));
            adminAccNameFormatOptions.push($A.get("$Label.hed.firstNameLastNameAdminACC"));
            adminAccNameFormatOptions.push($A.get("$Label.hed.lastNameFirstNameAdminAcc"));
            adminAccNameFormatOptions.push($A.get("$Label.hed.acctNamingOther"));
        }else{
            adminAccNameFormatOptions.push($A.get("$Label.c.lastNameAdminAcc"));
            adminAccNameFormatOptions.push($A.get("$Label.c.firstNameLastNameAdminACC"));
            adminAccNameFormatOptions.push($A.get("$Label.c.lastNameFirstNameAdminAcc"));  
            adminAccNameFormatOptions.push($A.get("$Label.c.acctNamingOther"));
          
        }
        component.set("v.adminAccNameFormatOptions", adminAccNameFormatOptions);
    },

    getHHAccNameFormatOptions : function(component) {
        var hhNameFormatOptions = [];
        var prefix = component.get("v.namespacePrefix");
        if (prefix === 'hed__')
        {
            hhNameFormatOptions.push($A.get("$Label.hed.lastNameHH"));
            hhNameFormatOptions.push($A.get("$Label.hed.lastNameFirstNameHH"));
            hhNameFormatOptions.push($A.get("$Label.hed.firstNameLastNameHH"));
            hhNameFormatOptions.push($A.get("$Label.hed.lastNameFamily"));
            hhNameFormatOptions.push($A.get("$Label.hed.lastNameFirstNameFamily"));
            hhNameFormatOptions.push($A.get("$Label.hed.firstNameLastNameFamily"));
            hhNameFormatOptions.push($A.get("$Label.hed.acctNamingOther"));
        }else{
            hhNameFormatOptions.push($A.get("$Label.c.lastNameHH"));
            hhNameFormatOptions.push($A.get("$Label.c.lastNameFirstNameHH"));
            hhNameFormatOptions.push($A.get("$Label.c.firstNameLastNameHH"));
            hhNameFormatOptions.push($A.get("$Label.c.lastNameFamily"));
            hhNameFormatOptions.push($A.get("$Label.c.lastNameFirstNameFamily"));
            hhNameFormatOptions.push($A.get("$Label.c.firstNameLastNameFamily"));
            hhNameFormatOptions.push($A.get("$Label.c.acctNamingOther"));
        }
        component.set("v.hhNameFormatOptions", hhNameFormatOptions);
    }
})