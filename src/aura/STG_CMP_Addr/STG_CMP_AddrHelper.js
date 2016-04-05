({
	saveSettings : function(component) {
		var accTypesCount = component.get("v.accTypesCount");
		var selectedAccsToDelete = "";
		var typesToDelete = component.find("accDel");
		//starting loop at 1 because the indexVar property starts at 1 in the view
		for(var i = 0; i <= typesToDelete.length; i++) {
			var checkbox = typesToDelete[i];
			if(typeof checkbox != 'undefined') {
				var checkboxLabel = checkbox.get("v.label");
				var checkboxVal = checkbox.get("v.value");
				if(checkboxVal == true) {
					var checkboxText = checkbox.get("v.text");
					selectedAccsToDelete += checkboxText + '; ';
				}
			}
		}
		var hierarchySettings = component.get("v.hierarchySettings");
		hierarchySettings.Accounts_to_Delete__c = selectedAccsToDelete;
		component.set("v.hierarchySettings", hierarchySettings);
	}
})