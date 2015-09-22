({
	init : function(component, event, helper) {
		$A.util.addClass(component.find("settsTab"), "slds-active");

		$A.util.addClass(component.find("settsTabContent"), "slds-show");
		$A.util.addClass(component.find("recSettsTabContent"), "slds-hide");
		$A.util.addClass(component.find("autocTabContent"), "slds-hide");

		//Load Relationship hierarchy settings
		var relSettingsAction = component.get("c.getSettings");
		relSettingsAction.setCallback(this, function(data) {
			component.set("v.relSettings", data.getReturnValue());
		});
		$A.enqueueAction(relSettingsAction);

		//Load Relationship Reciprocal list settings
		var reciprocalSettingsAction = component.get("c.getReciprocalSettings");
		reciprocalSettingsAction.setCallback(this, function(data) {
			component.set("v.reciprocalSettings", data.getReturnValue());
		});
		$A.enqueueAction(reciprocalSettingsAction);

		//Load Relationship Auto-Create list settings
		var autoCreateSettingsAction = component.get("c.getAutoCreateSettings");
		autoCreateSettingsAction.setCallback(this, function(data) {
			component.set("v.autoCreateSettings", data.getReturnValue());
		});
		$A.enqueueAction(autoCreateSettingsAction);
	},

	settsLinkClicked : function(component, event, helper) {
		$A.util.addClass(component.find("settsTab"), "slds-active");
		$A.util.removeClass(component.find("recSettsTab"), "slds-active");
		$A.util.removeClass(component.find("autocTab"), "slds-active");

		var settsTabContent = component.find("settsTabContent");
		$A.util.removeClass(settsTabContent, "slds-hide");
		$A.util.addClass(settsTabContent, "slds-show");

		var recSettsTabContent = component.find("recSettsTabContent");
		$A.util.removeClass(recSettsTabContent, "slds-show");
		$A.util.addClass(recSettsTabContent, "slds-hide");

		var autocTabContent = component.find("autocTabContent");
		$A.util.removeClass(autocTabContent, "slds-show");
		$A.util.addClass(autocTabContent, "slds-hide");
	},

	recSettsLinkClicked : function(component, event, helper) {
		$A.util.removeClass(component.find("settsTab"), "slds-active");
		$A.util.addClass(component.find("recSettsTab"), "slds-active");
		$A.util.removeClass(component.find("autocTab"), "slds-active");

		var settsTabContent = component.find("settsTabContent");
		$A.util.removeClass(settsTabContent, "slds-show");
		$A.util.addClass(settsTabContent, "slds-hide");

		var recSettsTabContent = component.find("recSettsTabContent");
		$A.util.removeClass(recSettsTabContent, "slds-hide");
		$A.util.addClass(recSettsTabContent, "slds-show");

		var autocTabContent = component.find("autocTabContent");
		$A.util.removeClass(autocTabContent, "slds-show");
		$A.util.addClass(autocTabContent, "slds-hide");
	},

	autocLinkClicked : function(component, event, helper) {
		$A.util.removeClass(component.find("settsTab"), "slds-active");
		$A.util.removeClass(component.find("recSettsTab"), "slds-active");
		$A.util.addClass(component.find("autocTab"), "slds-active");

		var settsTabContent = component.find("settsTabContent");
		$A.util.removeClass(settsTabContent, "slds-show");
		$A.util.addClass(settsTabContent, "slds-hide");

		var recSettsTabContent = component.find("recSettsTabContent");
		$A.util.removeClass(recSettsTabContent, "slds-show");
		$A.util.addClass(recSettsTabContent, "slds-hide");

		var autocTabContent = component.find("autocTabContent");
		$A.util.removeClass(autocTabContent, "slds-hide");
		$A.util.addClass(autocTabContent, "slds-show");
	}
})