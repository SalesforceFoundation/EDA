({
	saveSettings : function(component) {
		var selectedAccsToDelete = "";
		var typesToDelete = component.find("accDel");

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