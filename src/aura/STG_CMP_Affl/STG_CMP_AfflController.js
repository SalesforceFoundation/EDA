({
	init : function(component, event, helper) {
		helper.init(component);
	},
	
	setAfflProgEnrollDel : function(component, event, helper) {
		helper.setAfflProgEnrollDel(component, event);
		
	},
	
	settsLinkClicked : function(component, event, helper) {
		helper.settsLinkClicked(component);
	},

	mappingsLinkClicked : function(component, event, helper) {
		helper.mappingsLinkClicked(component);
	},

	toggleIsView : function(component, event, helper) {
		component.set("v.isView", event.getParam("isView"));
	},

	saveMappings : function(component, event, helper) {
		helper.saveMappings(component);
	},

	resetSettings : function(component, event, helper) {
		helper.resetSettings(component);
	},

	newAfflMapping : function(component, event, helper) {
		helper.newAfflMapping(component);
	},

	deleteAfflMappingRow : function(component, event, helper) {
		if (confirm("Are you sure you want to delete this row?")) {
			var id = event.getParam("id");
			var position = event.getParam("position");
			helper.deleteAfflMappingRow(component, id, position);
		}
	}
})