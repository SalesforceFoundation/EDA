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

	loadReciprocalSettings : function(component) {
		var prefix = component.get("v.namespacePrefix");
		var reciprocalSettingsAction = component.get("c.getReciprocalSettings");
		reciprocalSettingsAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				var settings = response.getReturnValue();
				if(settings.length === 0) {
					this.setMessageLabel(component, "v.noRecSettings", prefix, "noRecSettings");
				}
				component.set("v.reciprocalSettings", this.removePrefixListSettings(settings, prefix));
			} else if(response.getState() === "ERROR") {
			    this.displayError(response);
	    	}
		});
		$A.enqueueAction(reciprocalSettingsAction);
	},

	loadRelAutoCreateSettings : function(component) {
		var prefix = component.get("v.namespacePrefix");
		var autoCreateSettingsAction = component.get("c.getAutoCreateSettings");
		autoCreateSettingsAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				var settings = response.getReturnValue();
				if(settings.length === 0) {
					component.set("v.noAutoCreateSettings", $A.get("$Label.c.noAutoCreateSettings"));
				}
				component.set("v.autoCreateSettings", this.removePrefixListSettings(settings, prefix));
	    	} else if(response.getState() === "ERROR") {
	    		this.displayError(response);
	    	}
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

		this.hideTabContent(component, "recSettsTabContent");
		this.hideTabContent(component, "autocTabContent");
	},

	recSettsLinkClicked : function(component) {
		$A.util.removeClass(component.find("settsTab"), "slds-active");
		$A.util.addClass(component.find("recSettsTab"), "slds-active");
		$A.util.removeClass(component.find("autocTab"), "slds-active");

		this.hideTabContent(component, "settsTabContent");

		var recSettsTabContent = component.find("recSettsTabContent");
		$A.util.removeClass(recSettsTabContent, "slds-hide");
		$A.util.addClass(recSettsTabContent, "slds-show");

		this.hideTabContent(component, "autocTabContent");
	},

	autocLinkClicked : function(component) {
		$A.util.removeClass(component.find("settsTab"), "slds-active");
		$A.util.removeClass(component.find("recSettsTab"), "slds-active");
		$A.util.addClass(component.find("autocTab"), "slds-active");

		this.hideTabContent(component, "settsTabContent");
		this.hideTabContent(component, "recSettsTabContent");

		var autocTabContent = component.find("autocTabContent");
		$A.util.removeClass(autocTabContent, "slds-hide");
		$A.util.addClass(autocTabContent, "slds-show");
	},

	saveRelSettings : function(component) {
		var prefix = component.get("v.namespacePrefix");
		var saveRecSettingsAction = component.get("c.saveReciprocalSettings");
		var reciprocalSettings = this.addPrefixListSettings(component.get("v.reciprocalSettings"), prefix);
		this.callServerVoidMethod(saveRecSettingsAction, {"reciprocalSettings" : reciprocalSettings});

		var saveAutoCreateSettingsAction = component.get("c.saveAutoCreateSettings");
		var autoCreateSettings = this.addPrefixListSettings(component.get("v.autoCreateSettings"), prefix);
		this.callServerVoidMethod(saveAutoCreateSettingsAction, {"autoCreateSettings" : autoCreateSettings});
	},

	callServerVoidMethod : function(action, params) {
		action.setParams(params);
		action.setCallback(this, function(response) {
			if(response.getState() === "ERROR") {
				this.displayError(response);
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
				component.set("v.noRecSettings", "");
				var reciprocalSettings = component.get("v.reciprocalSettings");
				reciprocalSettings.push({ "Id" : response.getReturnValue(), "Name" : name, "Female__c" : female,
										"Male__c" : male, "Neutral__c" : neutral, "Active__c" : active });
				component.set("v.reciprocalSettings", reciprocalSettings);
				this.clearNewStgBoxes(component, ["newName", "newFemale", "newMale", "newNeutral", "newActive"]);

				// Re-Disable Add Setting button after successful completion
				component.find("newReciprocalStgBtn").set("v.disabled", true);
			} else if(response.getState() === "ERROR") {
				this.displayError(response);
			}
		});
		$A.enqueueAction(newStgAction);
	},

	newAutoCreateStg : function(component) {
		var object = component.find("newObject").get("v.value");
		var field = component.find("newField").get("v.value");
		var relType = component.find("newRelType").get("v.value");
		var campaigns = component.find("newCpgTypes").get("v.value");

		var newStgAction = component.get("c.newAutoCreateSetting");
		newStgAction.setParams({ "obj" : object, "field" : field, "relType" : relType, "campaigns" : campaigns });
		newStgAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				component.set("v.noAutoCreateSettings", "");
				var autoCreateSettings = component.get("v.autoCreateSettings");
				autoCreateSettings.push({ "Id" : response.getReturnValue(), "Object__c" : object, "Field__c" : field,
											"Relationship_Type__c" : relType, "Campaign_Types__c" : campaigns });
				component.set("v.autoCreateSettings", autoCreateSettings);
				this.clearNewStgBoxes(component, ["newObject", "newField", "newRelType", "newCpgTypes"]);
				
				// Re-Disable Add Setting button after successful completion
				component.find("newAutoCreateStgBtn").set("v.disabled", true);

			} else if(response.getState() === "ERROR") {
				this.displayError(response);
			}
		});
		$A.enqueueAction(newStgAction);
	},

	deleteRecSettingRow : function(component, id, position) {
		this.deleteRow(component, "c.deleteRecSettingRecord", "v.reciprocalSettings", id, position, "v.noRecSettings",
				"noRecSettings", component.get("v.namespacePrefix"));
	},

	deleteAutoCreateRow : function(component, id, position) {
		this.deleteRow(component, "c.deleteAutoCreateRecord", "v.autoCreateSettings", id, position, "v.noAutoCreateSettings",
				"noAutoCreateSettings", component.get("v.namespacePrefix"));
	},

	changeReciprocalMethodStg : function(component) {
		var value = component.find("reciprocalMethodSelect").get("v.value");
		component.set("v.hierarchySettings.Reciprocal_Method__c", value);
	}
})