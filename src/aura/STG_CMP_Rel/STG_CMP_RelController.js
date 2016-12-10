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

	toggleIsView : function(component, event) {
		component.set("v.isView", event.getParam("isView"));
	},

	saveRelSettings : function(component, event, helper) {
		helper.saveRelSettings(component);
	},

	newReciprocalStgBlur : function (component, event, helper) {
		var name = component.find("newName").get("v.value")|| "";
		var female = component.find("newFemale").get("v.value")|| "";
		var male = component.find("newMale").get("v.value")|| "";
		var neutral = component.find("newNeutral").get("v.value")|| "";

		if( name.length > 0 || female.length > 0 || male.length > 0 || neutral.length > 0 ) { 
			component.find("newReciprocalStgBtn").set("v.disabled", false);
		} else {
			component.find("newReciprocalStgBtn").set("v.disabled", true);	
		}
	},

	newReciprocalStg : function(component, event, helper) {
		helper.newReciprocalStg(component);
	},

	newAutoCreateBlur : function (component, event) {
		var object = component.find("newObject").get("v.value") || "";
		var field = component.find("newField").get("v.value") || "";
		var relType = component.find("newRelType").get("v.value") || "";
		var campaigns = component.find("newCpgTypes").get("v.value") || "";

		if( object.length > 0 || field.length > 0 || relType.length > 0 || campaigns.length > 0 ) { 
			component.find("newAutoCreateStgBtn").set("v.disabled", false);
		} else {
			component.find("newAutoCreateStgBtn").set("v.disabled", true);	
		}
	},

	newAutoCreateStg : function(component, event, helper) {
		helper.newAutoCreateStg(component);
	},

	deleteRecSettingRow : function(component, event, helper) {
		if(confirm("Are you sure you want to delete this row?")) {
			var id = event.getParam("id");
			var position = event.getParam("position");
			helper.deleteRecSettingRow(component, id, position);
		}
	},

	deleteAutoCreateRow : function(component, event, helper) {
		if(confirm("Are you sure you want to delete this row?")) {
			var id = event.getParam("id");
			var position = event.getParam("position");
			helper.deleteAutoCreateRow(component, id, position);
		}
	},

	resetSettings : function(component, event, helper) {
		helper.loadReciprocalSettings(component);
		helper.loadRelAutoCreateSettings(component);
	},

	changeReciprocalMethodStg : function(component, event, helper) {
		helper.changeReciprocalMethodStg(component);
	}
})