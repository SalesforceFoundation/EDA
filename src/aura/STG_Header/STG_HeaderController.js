({
	init : function(component, event, helper) {
		component.set("v.edit", true);
	},
	
	edit : function(component, event, helper) {
		console.log("Edit clicked");
		component.set("v.edit", false);
	},
	
	save : function(component, event, helper) {
		console.log("Save clicked");
		component.set("v.edit", true);
	}
})