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
		var namespace_prefix = component.get("v.namespace_prefix");
	    action.setCallback(this, function(response) {
	    	if(response.getState() === "SUCCESS") {
	    		var settings = response.getReturnValue();
	    		var settings_w_prefix = {};
	    		for(var key in settings) {
	    			console.log('Setting ' + namespace_prefix + key + ' to ' + settings[key]);
	    			settings_w_prefix[namespace_prefix + key] = settings[key];
	    		}
	    		component.set("v.hierarchySettings", settings_w_prefix);
	    	} else if(response.getState() === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
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