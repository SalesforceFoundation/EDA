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
		reciprocalSettingsAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				var settings = response.getReturnValue();
				component.set("v.reciprocalSettings", this.removePrefixListSettings(settings, namespacePrefix));
	    	} else if(response.getState() === "ERROR") {
	    		this.displayError(response);
	    	}
		});
		$A.enqueueAction(reciprocalSettingsAction);
	},
	
	loadRelAutoCreateSettings : function(component) {
		var autoCreateSettingsAction = component.get("c.getAutoCreateSettings");
		autoCreateSettingsAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				var settings = response.getReturnValue();
				component.set("v.autoCreateSettings", this.removePrefixListSettings(settings, namespacePrefix));
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
				component.set("v.namespacePrefix", namespacePrefix);
				var reciprocalSettings = component.get("v.reciprocalSettings");
				reciprocalSettings.push({ "Id" : response.getReturnValue(), "Name" : name, "Female__c" : female, 
										"Male__c" : male, "Neutral__c" : neutral, "Active__c" : active });
				component.set("v.reciprocalSettings", reciprocalSettings);
				this.clearNewStgBoxes(component, ["newName", "newFemale", "newMale", "newNeutral", "newActive"]);
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
				component.set("v.namespacePrefix", namespacePrefix);
				var autoCreateSettings = component.get("v.autoCreateSettings");
				autoCreateSettings.push({ "Id" : response.getReturnValue(), "Object__c" : object, "Field__c" : field, 
											"Relationship_Type__c" : relType, "Campaign_Types__c" : campaigns });
				component.set("v.autoCreateSettings", autoCreateSettings);
				this.clearNewStgBoxes(component, ["newObject", "newField", "newRelType", "newCpgTypes"]);
			} else if(response.getState() === "ERROR") {
				this.displayError(response);
			}
		});
		$A.enqueueAction(newStgAction);
	},
	
	clearNewStgBoxes : function(component, fields) {
		for(var key in fields) {
			component.find(fields[key]).set("v.value", "");
		}
	},
	
	deleteRecSettingRow : function(component, id, position) {		
		this.deleteRow(component, "c.deleteRecSettingRecord", "v.reciprocalSettings", id, position);
	},
	
	deleteAutoCreateRow : function(component, id, position) {
		this.deleteRow(component, "c.deleteAutoCreateRecord", "v.autoCreateSettings", id, position);
	},
	
	deleteRow : function(component, serverMethod, stgsUiElement, id, position) {
		var action = component.get(serverMethod);
		action.setParams({ "idString" : id });
		action.setCallback(this, function(response) {
			if (response.getState() === "SUCCESS") {
				var settings = component.get(stgsUiElement);
				settings.splice(position, 1);
				component.set(stgsUiElement, settings);
			} else if (response.getState() === "ERROR") {
				this.displayError(response);
			}
		});
		$A.enqueueAction(action);
	}
})