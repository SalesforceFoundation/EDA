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
		var prefix = component.get("v.namespacePrefix");
		var action = component.get("c.getSettings");
	    action.setCallback(this, function(response) {
	    	if(response.getState() === "SUCCESS") {
	    		var settings = response.getReturnValue();
	    		component.set("v.hierarchySettings", this.removePrefixHierarchySettings(settings, prefix));
	    	} else if(response.getState() === "ERROR") {
	    		this.displayError(response);
			}
	    });
	    $A.enqueueAction(action);
	},
	
	saveSettings : function(component) {
		var prefix = component.get("v.namespacePrefix");
		var saveAction = component.get("c.saveHierarchySettings");
		var hierarchySettings = this.addPrefixHierarchySettings(component.get("v.hierarchySettings"), prefix);
		saveAction.setParams({"hierarchySettings" : hierarchySettings});
		saveAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				component.set("v.isView", true);
			} else if(response.getState() === "ERROR") {
				component.set("v.isView", false);
				this.displayError(response);
			}
		});
		$A.enqueueAction(saveAction);
	},
	
	resetSettings : function(component) {
		this.getHierarchySettings(component);
	}
})