({
	init : function(component) {
		component.set("v.isView", true);
		this.loadAfflMappings(component);		
	},

	loadAfflMappings : function(component) {
		var action = component.get("c.getAfflMappings");
		action.setCallback(this, function(response) {		
			if(response.getState() === "SUCCESS") {
				if(namespace_prefix && namespace_prefix.length > 0) {
		    		var settings = response.getReturnValue();
		    		var settings_no_prefix = {};
		    		//Remove package prefix from each custom field
		    		for(var key in settings) {
		    			if(key.endsWith('__c') && namespace_prefix && namespace_prefix.length > 0) {
		    				var key_no_prefix = key.replace(namespace_prefix, '');
			    			settings_no_prefix[key_no_prefix] = settings[key];
		    			} else {
		    				settings_no_prefix[key] = settings[key];
		    			}
		    		}
		    		component.set("v.afflMappings", settings_no_prefix);
				} else {
					component.set("v.afflMappings", response.getReturnValue());
				}
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
		var settings = component.get("v.afflMappings");
		if(namespace_prefix && namespace_prefix.length > 0) {
			var settings_w_prefix = {};
			//Add package prefix to each custom field
			for(var key in settings) {
				if(key.endsWith('__c')) {
					var key_w_prefix = namespace_prefix + key;
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
	},
	
	displayError : function(response) {
		var errors = response.getError();
		if (errors && errors[0] && errors[0].message) {
			$A.error("Error message: " + errors[0].message);
		} else {
			$A.error("Unknown error");
		}
	}
})