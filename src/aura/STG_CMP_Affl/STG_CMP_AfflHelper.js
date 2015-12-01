({
	init : function(component) {
		component.set("v.isView", true);
		this.loadAfflMappings(component);		
	},

	loadAfflMappings : function(component) {
		var action = component.get("c.getAfflMappings");
		action.setCallback(this, function(response) {		
			if(response.getState() === "SUCCESS") {
				var settings = response.getReturnValue();
				component.set("v.afflMappings", this.removePrefixListSettings(settings, namespacePrefix));
	    	} else if(response.getState() === "ERROR") {
	    		this.displayError(response);
	    	}	
		});
		$A.enqueueAction(action);
	},
	
	resetSettings : function(component) {
		this.loadAfflMappings(component);
	},
	
	saveMappings : function(component) {
		var saveAction = component.get("c.saveAfflMappings");
		var settings = this.addPrefixListSettings(component.get("v.afflMappings"), namespacePrefix);
		saveAction.setParams({"afflMappings" : settings});
		saveAction.setCallback(this, function(response) {
			if(response.getState() === "ERROR") {
				this.displayError(response);
			}
		});
		$A.enqueueAction(saveAction);
	},
	
	newAfflMapping : function(component) {
		var accRecType = component.find("accRecType").get("v.value");
		var primaryField = component.find("primaryField").get("v.value");
		var autoEnroll = component.find("autoEnroll").get("v.value");
		var autoEnrollStatus = component.find("autoEnrollStatus").get("v.value");
		var autoEnrollRole = component.find("autoEnrollRole").get("v.value");
		
		var newMappingAction = component.get("c.newAfflMpg");
		newMappingAction.setParams({ "accRecType" : accRecType, "primaryField" : primaryField, "autoEnroll" : autoEnroll, 
			"autoEnrollStatus" : autoEnrollStatus, "autoEnrollRole" : autoEnrollRole });
		newMappingAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				var afflMappings = component.get("v.afflMappings");
				afflMappings.push({ "Id" : response.getReturnValue(), "Account_Record_Type__c" : accRecType, "Primary_Affl_Field__c" : primaryField, 
								"Auto_Program_Enrollment__c" : autoEnroll, "Auto_Program_Enrollment_Status__c" : autoEnrollStatus, 
								"Auto_Program_Enrollment_Role__c" : autoEnrollRole });
				component.set("v.afflMappings", afflMappings);
				this.clearNewStgBoxes(component, ["accRecType", "primaryField", "autoEnroll", "autoEnrollStatus", "autoEnrollRole"]);
			} else if(response.getState() === "ERROR") {
				this.displayError(response);
			}
		});
		$A.enqueueAction(newMappingAction);
	},
	
	deleteAfflMappingRow : function(component, id, position) {
		this.deleteRow(component, "c.deleteAfflMappingRecord", "v.afflMappings", id, position);
	}
})