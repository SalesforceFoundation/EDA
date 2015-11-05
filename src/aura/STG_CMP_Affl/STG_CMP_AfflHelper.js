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
	
	saveAfflMappings : function(component) {
		var saveAction = component.get("c.saveAfflMappings");
		var settings = component.get("v.afflMappings");
		saveAction.setParams({"afflMappings" : this.addPrefixListSettings(settings, namespacePrefix)});
		saveAction.setCallback(this, function(response) {
			if(response.getState() === "ERROR") {
				this.displayError(response);
			}
		});
		$A.enqueueAction(saveAction);
	}
})