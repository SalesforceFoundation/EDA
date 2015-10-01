({
	init: function(component) {
		$A.util.addClass(component.find("settsTab"), "slds-active");

		$A.util.addClass(component.find("settsTabContent"), "slds-show");
		$A.util.addClass(component.find("recSettsTabContent"), "slds-hide");
		$A.util.addClass(component.find("autocTabContent"), "slds-hide");

		//Load Relationship Reciprocal list settings
		this.loadReciprocalSettings(component);

		//Load Relationship Auto-Create list settings
		this.loadRelAutoCreateSettings(component);
	},
	
	loadReciprocalSettings : function(component, event, helper) {
		var reciprocalSettingsAction = component.get("c.getReciprocalSettings");
		reciprocalSettingsAction.setCallback(this, function(data) {
			component.set("v.reciprocalSettings", data.getReturnValue());
		});
		$A.enqueueAction(reciprocalSettingsAction);
	},
	
	loadRelAutoCreateSettings : function(component) {
		var autoCreateSettingsAction = component.get("c.getAutoCreateSettings");
		autoCreateSettingsAction.setCallback(this, function(data) {
			component.set("v.autoCreateSettings", data.getReturnValue());
		});
		$A.enqueueAction(autoCreateSettingsAction);
	},
})