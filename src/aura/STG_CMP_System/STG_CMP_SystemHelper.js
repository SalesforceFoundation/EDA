({
	init : function(component) { },
	
	saveAccRecType : function(component, event) {
		//Get selected value
		var accRecTypesDropDown = component.find("accRecTypes");
		var selectedAccRecTypeId = accRecTypesDropDown.get("v.value");
		
		//Set the selected value in the settings (so it gets saved)
		var hierarchySettings = component.get("v.hierarchySettings");
		hierarchySettings.Account_Processor__c = selectedAccRecTypeId;
		component.set("v.hierarchySettings", hierarchySettings);
		
		//Set the value to display after save
		component.set("v.accRecTypeId", selectedAccRecTypeId);
		var accRecTypes = component.get("v.accRecTypes");
		//we do this because we cannot get the selected name from the drop-down, only the ID
		for(var i = 0; i <accRecTypes.length; i++) {
			var recType = accRecTypes[i];
			if(recType.id == selectedAccRecTypeId) {
				var selectedAccRecTypeName = recType.devName;
			}
		}
		component.set("v.accRecTypeName", selectedAccRecTypeName);
	}
})