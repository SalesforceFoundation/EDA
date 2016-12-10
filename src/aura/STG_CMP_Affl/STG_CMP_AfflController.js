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

	newAfflMappingBlur : function (component, event) {
		var accRecType = component.find("accRecType").get("v.value") || "";
		var primaryField = component.find("primaryField").get("v.value") || "";
		var autoEnrollStatus = component.find("autoEnrollStatus").get("v.value") || "";
		var autoEnrollRole = component.find("autoEnrollRole").get("v.value") || "";
		var autoEnroll = component.find("autoEnroll").get("v.value") || ""; // boolean

		if( accRecType.length > 0 || primaryField.length > 0 || autoEnrollStatus.length > 0 || autoEnrollRole.length > 0 ) { 
			component.find("newAfflMappingBtn").set("v.disabled", false);
		} else {
			component.find("newAfflMappingBtn").set("v.disabled", true);	
		}
	},
})