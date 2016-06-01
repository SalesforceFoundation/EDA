({
	onSelectChange : function(component) {
		var selectedVal = component.find("accRecTypes").get("v.value");
		component.set("v.accRecTypeId", selectedVal);
	},

	saveAccRecType : function(component) {
		//Get selected value
		var accRecTypesDropDown = component.find("accRecTypes");
		var selectedAccRecTypeId = accRecTypesDropDown.get("v.value");

		//Set the selected value in the settings (so it gets saved)
		var hierarchySettings = component.get("v.hierarchySettings");
		hierarchySettings.Account_Processor__c = selectedAccRecTypeId;
		component.set("v.hierarchySettings", hierarchySettings);

		//Set the value to display after save
		var accRecTypes = component.get("v.accRecTypes");
		//we do this because we cannot get the selected name from the drop-down, only the ID
		var selectedAccRecTypeName = '';
		for(var i = 0; i <accRecTypes.length; i += 1) {
			if(accRecTypes[i].id === selectedAccRecTypeId) {
				selectedAccRecTypeName = accRecTypes[i].name;
			}
		}
		component.set("v.accRecTypeName", selectedAccRecTypeName);
	}
})