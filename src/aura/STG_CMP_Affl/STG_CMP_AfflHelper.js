({
	init : function(component) {
		component.set("v.isView", true);
		this.loadAfflMappings(component);		
	},

	loadAfflMappings : function(component) {
		var action = component.get("c.getAfflMappings");
		action.setCallback(this, function(response) {
			component.set("v.afflMappings", response.getReturnValue());
		});
		$A.enqueueAction(action);
	},
	
	resetSettings : function(component) {
		this.loadAfflMappings(component);
	},
	
	saveAfflSettings : function(component) {
		var saveAction = component.get("c.saveAfflMappings");
		saveAction.setParams({"afflMappings" : component.get("v.afflMappings")});
		saveAction.setCallback(this, function(response) {
			if(response.getState() === "ERROR") {
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
					$A.error("Error message: " + errors[0].message);
				} else {
					$A.error("Unknown error");
				}
			}
		});
		$A.enqueueAction(saveAction);
	}
})