({
	init : function(component) {
		$A.util.addClass(component.find("afflTab"), "slds-active");

		$A.util.addClass(component.find("afflTabContent"), "slds-show");
		$A.util.addClass(component.find("relTabContent"), "slds-hide");
		$A.util.addClass(component.find("addrTabContent"), "slds-hide");
		$A.util.addClass(component.find("systemTabContent"), "slds-hide");
		
		//Retrieving hierarchy settings.
		this.getHierarchySettings(component);
	},
	
	getHierarchySettings : function(component) {
		var action = component.get("c.getSettings");
		var namespacePrefix = component.get("v.namespacePrefix");
	    action.setCallback(this, function(response) {
	    	if(response.getState() === "SUCCESS") {
	    		var settings = response.getReturnValue();
	    		var settings_no_prefix = {};
	    		for(var key in settings) {
	    			if(key.endsWith('__c')) {
	    				var key_no_prefix = key.replace(namespacePrefix, '');
		    			settings_no_prefix[key_no_prefix] = settings[key];
	    			}
	    		}
	    		component.set("v.hierarchySettings", settings_no_prefix);
	    	} else if(response.getState() === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
						$A.error("Error message: " + errors[0].message);
					}
				} else {
					$A.error("Unknown error");
				}
			}
	    });
	    $A.enqueueAction(action);
	},
	
	resetSettings : function(component) {
		this.getHierarchySettings(component);
	}
})