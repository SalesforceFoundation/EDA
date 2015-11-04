({
	init : function(component) {
		component.set("v.isView", true);
		this.loadAfflMappings(component);		
	},

	loadAfflMappings : function(component) {
		var action = component.get("c.getAfflMappings");
		var namespacePrefix = component.get("v.namespacePrefix");
		action.setCallback(this, function(response) {		
			if(response.getState() === "SUCCESS") {
				var settings = response.getReturnValue();
				component.set("v.afflMappings", this.getProcessedListSettings(settings, namespacePrefix));
	    	} else if(response.getState() === "ERROR") {
	    		this.displayError(response);
	    	}	
		});
		$A.enqueueAction(action);
	},
	
	resetSettings : function(component) {
		this.loadAfflMappings(component);
	},
	
	saveAfflSettings : function(component) {
		var saveAction = component.get("c.saveAfflMappings");
		var namespacePrefix = component.get("v.namespacePrefix");
		var settings = component.get("v.afflMappings");
		if(namespacePrefix && namespacePrefix.length > 0) {
			var settings_w_prefix = {};
			//Add package prefix to each custom field
			for(var key in settings) {
				if(key.endsWith('__c')) {
					var key_w_prefix = namespacePrefix + key;
	    			settings_w_prefix[key_w_prefix] = settings[key];
				} else {
					settings_w_prefix[key] = settings[key];
				}
			}
			saveAction.setParams({"afflMappings" : settings_w_prefix});
		} else {
			saveAction.setParams({"afflMappings" : settings});
		}
		saveAction.setCallback(this, function(response) {
			if(response.getState() === "ERROR") {
				this.displayError(response);
			}
		});
		$A.enqueueAction(saveAction);
	}
})