({
	addPrefixListSettings : function(settings, namespacePrefix) {
		return this.processPrefixListSettings(settings, namespacePrefix, this.addPrefix);
	},

	removePrefixListSettings : function(settings, namespacePrefix) {
		return this.processPrefixListSettings(settings, namespacePrefix, this.removePrefix);
	},

	processPrefixListSettings : function(settings, namespacePrefix, prefixHandlingFunc) {
		if(namespacePrefix && namespacePrefix.length > 0) {
			//We need to end up with an array of objects, because the settings param is an array of objects
    		var settingsNoPrefix = []; //create array
    		//Remove package prefix from each custom field
    		for(var key in settings) { //Iterate over each row - key is just a numeric index here
    		    if(settings.hasOwnProperty(key)) {
        			var obj = {}; //create object
        			for(var key2 in settings[key]) { //Iterate over each field in each row - key2 is the actual field name
        				if(key2.endsWith('__c')) {
    	    				var key2NoPrefix = prefixHandlingFunc(namespacePrefix, key2);
    	    				obj[key2NoPrefix] = settings[key][key2];
    	    			} else {
    	    				obj[key2] = settings[key][key2];
    	    			}
        			}
        			settingsNoPrefix.push(obj);
    		    }
    		}
    		return settingsNoPrefix;
		} else {
			return settings;
		}
	},

	addPrefixHierarchySettings : function(settings, namespacePrefix) {
		return this.processPrefixHierarchySettings(settings, namespacePrefix, this.addPrefix);
	},

	removePrefixHierarchySettings : function(settings, namespacePrefix) {
		return this.processPrefixHierarchySettings(settings, namespacePrefix, this.removePrefix);
	},

	processPrefixHierarchySettings : function(settings, namespacePrefix, prefixHandlingFunc) {
		if(namespacePrefix && namespacePrefix.length > 0) {
    		var settingsNoPrefix = {};
    		//Remove or add package prefix from each custom field
    		for(var key in settings) { //Iterate over each row
    			if(key.endsWith('__c')) {
    				var keyNoPrefix = prefixHandlingFunc(namespacePrefix, key);
    				settingsNoPrefix[keyNoPrefix] = settings[key];
    			} else {
    			    settingsNoPrefix[key] = settings[key];
    			}
    		}
    		return settingsNoPrefix;
		} else {
			return settings;
		}
	},

	addPrefix : function(namespacePrefix, key) {
		return namespacePrefix + key;
	},

	removePrefix : function(namespacePrefix, key) {
		return key.replace(namespacePrefix, '');
	},

	clearNewStgBoxes : function(component, fields) {
		for(var key in fields) {
		    if(fields.hasOwnProperty(key)) {
		        component.find(fields[key]).set("v.value", "");
		    }
		}
	},

	displayError : function(response) {
		var errors = response.getError();
		if (errors && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
			throw new Error("Error message: " + errors[0].pageErrors[0].message);
		} else if(errors && errors[0].fieldErrors && errors[0].fieldErrors.Name[0] && errors[0].fieldErrors.Name[0].message) {
			throw new Error("Error message: " + errors[0].fieldErrors[0].Name[0].message);
		} else {
			throw new Error("Unknown error");
		}
	},

	deleteRow : function(component, serverMethod, stgsUiElement, id, position, errorElement, errorLabel, namespacePrefix) {
		var action = component.get(serverMethod);
		action.setParams({ "idString" : id });
		action.setCallback(this, function(response) {
			if (response.getState() === "SUCCESS") {
				var settings = component.get(stgsUiElement);
				settings.splice(position, 1);
				component.set(stgsUiElement, settings);
				if(settings.length === 0) {
					this.setMessageLabel(component, errorElement, namespacePrefix, errorLabel);
				}
			} else if (response.getState() === "ERROR") {
				this.displayError(response);
			}
		});
		$A.enqueueAction(action);
	},

	hideTabContent : function(component, element) {
		var autocTabContent = component.find(element);
		$A.util.removeClass(autocTabContent, "slds-show");
		$A.util.addClass(autocTabContent, "slds-hide");
	},

	setMessageLabel : function(component, messageElement, namespacePrefix, label) {
		var labels = $A.get("$Label");
		var prefix;
		if(!namespacePrefix || namespacePrefix.length === 0) {
			prefix = "c";
		} else {
			prefix = namespacePrefix.replace('__', '');
		}
		component.set(messageElement, labels[prefix][label]);
	},

	//The Account Record Types are stored as a comma-separated string in the settings. We need to tokenize it.
	getTokenized : function(setting) {
		var settingArrayTrim = [];
		if(setting) {
			var settingArray = setting.split(';');
			for(var i = 0; i < settingArray.length; i += 1) {
				settingArrayTrim.push(settingArray[i].trim());
			}
		}
		return settingArrayTrim;
	},

	//Labels built dynamically will only be available if they are being referenced somewhere in the code.
	//Note that this method isn't even called from anywhere.
	hugeHack : function() {
		try {
			$A.get("$Label.hed.noAfflMappings");
			$A.get("$Label.hed.noRecSettings");
			$A.get("$Label.hed.noAutoCreateSettings");
		} catch(e) {
			$A.get("$Label.c.noAfflMappings");
			$A.get("$Label.c.noRecSettings");
			$A.get("$Label.c.noAutoCreateSettings");
		}
	}
})