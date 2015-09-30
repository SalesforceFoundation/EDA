({
	init : function(component, event, helper) {
		$A.util.addClass(component.find("settsTab"), "slds-active");

		$A.util.addClass(component.find("settsTabContent"), "slds-show");
		$A.util.addClass(component.find("recSettsTabContent"), "slds-hide");
		$A.util.addClass(component.find("autocTabContent"), "slds-hide");

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
	},
	
	toggleIsView : function(component, event, helper) {
		component.set("v.isView", event.getParam("isView"));
	}, 
	   
	saveRelSettings : function(component, event, helper) {
		var saveRecSettingsAction = component.get("c.saveReciprocalSettings");
		saveRecSettingsAction.setParams({"reciprocalSettings" : component.get("v.reciprocalSettings")});
		saveRecSettingsAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				//component.set("v.isView", true);
			} else if(response.getState() === "ERROR") {
				//component.set("v.isView", false);
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
		$A.enqueueAction(saveRecSettingsAction);
		
		var saveAutoCreateSettingsAction = component.get("c.saveAutoCreateSettings");
		saveAutoCreateSettingsAction.setParams({"autoCreateSettings" : component.get("v.autoCreateSettings")});
		saveAutoCreateSettingsAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				//component.set("v.isView", true);
			} else if(response.getState() === "ERROR") {
				//component.set("v.isView", false);
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
		$A.enqueueAction(saveAutoCreateSettingsAction);
	},
	
	newReciprocalStg : function(component, event, helper) {
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
				reciprocalSettings.push({ "Name" : name, "Female__c" : female, "Male__c" : male, "Neutral__c" : neutral, "Active__c" : active });
				component.set("v.reciprocalSettings", reciprocalSettings);
			} else if(response.getState() === "ERROR") {
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
		$A.enqueueAction(newStgAction);
	},
	
	newAutoCreateStg : function(component, event, helper) {
		var object = component.find("newObject").get("v.value");
		var field = component.find("newField").get("v.value");
		var relType = component.find("newRelType").get("v.value");
		var campaigns = component.find("newCpgTypes").get("v.value");
		
		var newStgAction = component.get("c.newAutoCreateSetting");
		newStgAction.setParams({ "obj" : object, "field" : field, "relType" : relType, "campaigns" : campaigns });
		newStgAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				var autoCreateSettings = component.get("v.autoCreateSettings");
				autoCreateSettings.push({ "Object__c" : object, "Field__c" : field, "Relationship_Type__c" : relType, 
										"Campaign_Types__c" : campaigns });
				component.set("v.autoCreateSettings", autoCreateSettings);
			} else if(response.getState() === "ERROR") {
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
		$A.enqueueAction(newStgAction);
	},
	
	deleteRow : function(component, event, helper) {
		console.log("deleting row");
	}
})