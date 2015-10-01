({
	init : function(component) {
		component.set("v.isView", true);
		this.loadAfflMappings(component);		
	},

	loadAfflMappings : function(component) {
		var action = component.get("c.getAfflMappings");
		action.setCallback(this, function(data) {
			component.set("v.afflMappings", data.getReturnValue());
		});
		$A.enqueueAction(action);
	},
	
	resetSettings : function(component) {
		this.loadAfflMappings(component);
	}
})