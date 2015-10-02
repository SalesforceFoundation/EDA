({
	init : function(component, event, helper) {
		helper.init(component);
	},

	settsLinkClicked : function(component, event, helper) {
		helper.settsLinkClicked(component);
	},

	recSettsLinkClicked : function(component, event, helper) {
		helper.recSettsLinkClicked(component);
	},

	autocLinkClicked : function(component, event, helper) {
		helper.autocLinkClicked(component);
	},
	
	toggleIsView : function(component, event, helper) {
		component.set("v.isView", event.getParam("isView"));
	}, 
	   
	saveRelSettings : function(component, event, helper) {
		helper.saveRelSettings(component);
	},
	
	newReciprocalStg : function(component, event, helper) {
		helper.newReciprocalStg(component);
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
				autoCreateSettings.push({ "Id" : response.getReturnValue(), "Object__c" : object, "Field__c" : field, 
											"Relationship_Type__c" : relType, "Campaign_Types__c" : campaigns });
				component.set("v.autoCreateSettings", autoCreateSettings);
				component.find("newObject").set("v.value", "");
				component.find("newField").set("v.value", "");
				component.find("newRelType").set("v.value", "");
				component.find("newCpgTypes").set("v.value", "");
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
	
	deleteRecSettingRow : function(component, event) {
		var id = event.getParam("id");
		var position = event.getParam("position");

		var action = component.get("c.deleteRecSettingRecord");
		action.setParams({ "idString" : id });
		action.setCallback(this, function(response) {
			if (response.getState() === "SUCCESS") {
				var reciprocalSettings = component.get("v.reciprocalSettings");
				reciprocalSettings.splice(position, 1);
				component.set("v.reciprocalSettings", reciprocalSettings);
			} else if (response.getState() === "ERROR") {
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
					$A.error("Error message: " + errors[0].message);
				} else {
					$A.error("Unknown error");
				}
			}
		});
		$A.enqueueAction(action);
	},

	deleteAutoCreateRow : function(component, event) {
		var id = event.getParam("id");
		var position = event.getParam("position");

		var action = component.get("c.deleteAutoCreateRecord");
		action.setParams({ "idString" : id });
		action.setCallback(this, function(response) {
			if (response.getState() === "SUCCESS") {
				var autoCreateSettings = component.get("v.autoCreateSettings");
				autoCreateSettings.splice(position, 1);
				component.set("v.autoCreateSettings", autoCreateSettings);
			} else if (response.getState() === "ERROR") {
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
					$A.error("Error message: " + errors[0].message);
				} else {
					$A.error("Unknown error");
				}
			}
		});
		$A.enqueueAction(action);
	},
	
	resetSettings : function(component, event, helper) {
		helper.loadReciprocalSettings(component);
		helper.loadRelAutoCreateSettings(component);
	}
})