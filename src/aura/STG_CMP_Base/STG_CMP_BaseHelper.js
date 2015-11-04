({
	getProcessedListSettings : function(settings, namespacePrefix) {
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
	
	displayError : function(response) {
		var errors = response.getError();
		if (errors && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
			$A.error("Error message: " + errors[0].message);
		} else {
			$A.error("Unknown error");
		}
	}
})