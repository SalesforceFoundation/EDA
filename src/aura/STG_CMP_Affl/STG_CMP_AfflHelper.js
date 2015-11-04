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
				component.set("v.afflMappings", this.getProcessedSettings(settings));
	    	} else if(response.getState() === "ERROR") {
	    		this.displayError(response);
	    	}	
		});
		$A.enqueueAction(action);
	},
	
	getProcessedSettings : function(settings) {
		if(namespacePrefix && namespacePrefix.length > 0) {
			//We need to end up with an array of objects, because the settings param is an array of objects
    		var settings_no_prefix = []; //create array
    		//Remove package prefix from each custom field
    		for(var key in settings) { //Iterate over each row - key is just a numeric index here
    			var obj = {}; //create object
    			for(var key2 in settings[key]) { //Iterate over each field in each row - key2 is the actual field name
    				if(key2.endsWith('__c')) { 
	    				var key2_no_prefix = key2.replace(namespacePrefix, '');
	    				obj[key2_no_prefix] = settings[key][key2];
	    			} else {
	    				obj[key2] = settings[key][key2];
	    			}
    			}
    			settings_no_prefix.push(obj);
    		}
    		return settings_no_prefix;
		} else {
			return settings;
		}
	},
	
	resetSettings : function(component) {
		this.loadAfflMappings(component);
	},
	
	saveAfflSettings : function(component) {
		var saveAction = component.get("c.saveAfflMappings");
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
	},
	
	displayError : function(response) {
		var errors = response.getError();
		if (errors && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
			$A.error("Error message: " + errors[0].message);
		} else {
			$A.error("Unknown error");
		}
	}
})