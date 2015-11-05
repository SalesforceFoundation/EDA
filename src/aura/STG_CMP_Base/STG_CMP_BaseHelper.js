({
	addPrefixListSettings : function(settings, namespacePrefix) {
		if(namespacePrefix && namespacePrefix.length > 0) {
			//We need to end up with an array of objects, because the settings param is an array of objects
    		var settings_w_prefix = []; //create array
    		//Add package prefix to each custom field
    		for(var key in settings) { //Iterate over each row - key is just a numeric index here
    			var obj = {}; //create object
    			for(var key2 in settings[key]) { //Iterate over each field in each row - key2 is the actual field name
    				if(key2.endsWith('__c')) { 
	    				var key2_w_prefix = namespacePrefix + key;
	    				obj[key2_w_prefix] = settings[key][key2];
	    			} else {
	    				obj[key2] = settings[key][key2];
	    			}
    			}
    			settings_w_prefix.push(obj);
    		}
    		return settings_w_prefix;
		} else {
			return settings;
		}
	},
	
	removePrefixListSettings : function(settings, namespacePrefix) {
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
	
	addPrefixHierarchySettings : function(settings, namespacePrefix) {
		if(namespacePrefix && namespacePrefix.length > 0) {
    		var settings_w_prefix = {};
    		//Add package prefix to each custom field
    		for(var key in settings) { //Iterate over each row
    			if(key.endsWith('__c')) {
    				var key_w_prefix = namespacePrefix + key;
	    			settings_w_prefix[key_w_prefix] = settings[key];
    			} else {
    				settings_w_prefix[key] = settings[key];
    			}
    		}
    		return settings_w_prefix;
		} else {
			return settings;
		}
	},
	
	removePrefixHierarchySettings : function(settings, namespacePrefix) {
		if(namespacePrefix && namespacePrefix.length > 0) {
    		var settings_no_prefix = {};
    		//Remove package prefix from each custom field
    		for(var key in settings) { //Iterate over each row
    			if(key.endsWith('__c')) {
    				var key_no_prefix = key.replace(namespacePrefix, '');
	    			settings_no_prefix[key_no_prefix] = settings[key];
    			} else {
    				settings_no_prefix[key] = settings[key];
    			}
    		}
    		return settings_no_prefix;
		} else {
			return settings;
		}
	},
	
	displayError : function(response) {
		var errors = response.getError();
		if (errors && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
			$A.error("Error message: " + errors[0].pageErrors[0].message);
		} else if(errors && errors[0].fieldErrors && errors[0].fieldErrors.Name[0] && errors[0].fieldErrors.Name[0].message) {
			$A.error("Error message: " + errors[0].fieldErrors[0].Name[0].message);
		} else {
			$A.error("Unknown error");
		}
	}
})