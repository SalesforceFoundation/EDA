({
	init : function(component, event, helper) {
		helper.init(component);
	},

	settsLinkClicked : function(component, event, helper) {
		helper.settsLinkClicked(component);
	},

	mappingsLinkClicked : function(component, event, helper) {
		helper.mappingsLinkClicked(component);
	},

	toggleIsView : function(component, event) {
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
	},
    closeErrorToast: function(component, event, helper) {
        helper.closeErrorToast(component);
    },	

	newAfflMappingKeyup : function (component, event) {
		// accRecType && primaryField are  required fields
		var accRecType = component.find("accRecType").get("v.value") || "";
		var primaryField = component.find("primaryField").get("v.value") || "";

		if( accRecType.length > 0 && primaryField.length > 0  ) { 
			component.find("newAfflMappingBtn").set("v.disabled", false);
		} else {
			component.find("newAfflMappingBtn").set("v.disabled", true);	
		}
	},
})