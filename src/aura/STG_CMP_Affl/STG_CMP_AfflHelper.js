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
	}
})