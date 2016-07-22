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

	newReciprocalStg : function(component, event, helper) {
		helper.newReciprocalStg(component);
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