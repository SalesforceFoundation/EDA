({
	init: function(component) {
		$A.util.addClass(component.find("settsTab"), "slds-active");

		$A.util.addClass(component.find("settsTabContent"), "slds-show");
		$A.util.addClass(component.find("recSettsTabContent"), "slds-hide");
		$A.util.addClass(component.find("autocTabContent"), "slds-hide");

		//Load list settings
		this.loadReciprocalSettings(component);
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
	
	settsLinkClicked : function(component) {
		$A.util.addClass(component.find("settsTab"), "slds-active");
		$A.util.removeClass(component.find("recSettsTab"), "slds-active");
		$A.util.removeClass(component.find("autocTab"), "slds-active");

		var settsTabContent = component.find("settsTabContent");
		$A.util.removeClass(settsTabContent, "slds-hide");
		$A.util.addClass(settsTabContent, "slds-show");

		this.hideRecSettsTabContent(component);

		this.hideAutoCTabContent(component);
	},
	
	recSettsLinkClicked : function(component) {
		$A.util.removeClass(component.find("settsTab"), "slds-active");
		$A.util.addClass(component.find("recSettsTab"), "slds-active");
		$A.util.removeClass(component.find("autocTab"), "slds-active");

		this.hideSettsTabContent(component);

		var recSettsTabContent = component.find("recSettsTabContent");
		$A.util.removeClass(recSettsTabContent, "slds-hide");
		$A.util.addClass(recSettsTabContent, "slds-show");

		this.hideAutoCTabContent(component);
	},

	autocLinkClicked : function(component) {
		$A.util.removeClass(component.find("settsTab"), "slds-active");
		$A.util.removeClass(component.find("recSettsTab"), "slds-active");
		$A.util.addClass(component.find("autocTab"), "slds-active");

		this.hideSettsTabContent(component);

		this.hideRecSettsTabContent(component);

		var autocTabContent = component.find("autocTabContent");
		$A.util.removeClass(autocTabContent, "slds-hide");
		$A.util.addClass(autocTabContent, "slds-show");
	},
	
	hideSettsTabContent : function(component) {
		var settsTabContent = component.find("settsTabContent");
		$A.util.removeClass(settsTabContent, "slds-show");
		$A.util.addClass(settsTabContent, "slds-hide");
	},
	
	hideRecSettsTabContent : function(component) {
		var recSettsTabContent = component.find("recSettsTabContent");
		$A.util.removeClass(recSettsTabContent, "slds-show");
		$A.util.addClass(recSettsTabContent, "slds-hide");
	},
	
	hideAutoCTabContent : function(component) {
		var autocTabContent = component.find("autocTabContent");
		$A.util.removeClass(autocTabContent, "slds-show");
		$A.util.addClass(autocTabContent, "slds-hide");
	},
	
	saveRelSettings : function(component) {
		var saveRecSettingsAction = component.get("c.saveReciprocalSettings");
		this.callServerVoidMethod(saveRecSettingsAction, {"reciprocalSettings" : component.get("v.reciprocalSettings")});
		
		var saveAutoCreateSettingsAction = component.get("c.saveAutoCreateSettings");		
		this.callServerVoidMethod(saveAutoCreateSettingsAction, {"autoCreateSettings" : component.get("v.autoCreateSettings")});
	},
	
	callServerVoidMethod : function(action, params) {
		action.setParams(params);
		action.setCallback(this, function(response) {
			if(response.getState() === "ERROR") {
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
	
	newReciprocalStg : function(component) {
		var name = component.find("newName").get("v.value");
		var female = component.find("newFemale").get("v.value");
		var male = component.find("newMale").get("v.value");
		var neutral = component.find("newNeutral").get("v.value");
		var active = component.find("newActive").get("v.value");
		
		var newStgAction = component.get("c.newReciprocalSetting");
		newStgAction.setParams({ "name" : name, "female" : female, "male" : male, "neutral" : neutral, "active" : active });
		newStgAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				var reciprocalSettings = component.get("v.reciprocalSettings");
				reciprocalSettings.push({ "Id" : response.getReturnValue(), "Name" : name, "Female__c" : female, 
										"Male__c" : male, "Neutral__c" : neutral, "Active__c" : active });
				component.set("v.reciprocalSettings", reciprocalSettings);
				this.clearNewSettingBoxes(component);
			} else if(response.getState() === "ERROR") {
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
					$A.error("Error message: " + errors[0].message);
				} else {
					$A.error("Unknown error");
				}
			}
		});
		$A.enqueueAction(newStgAction);
	},
	
	clearNewSettingBoxes : function(component) {
		component.find("newName").set("v.value", "");
		component.find("newFemale").set("v.value", "");
		component.find("newMale").set("v.value", "");
		component.find("newNeutral").set("v.value", "");
		component.find("newActive").set("v.value", "");
	}
})