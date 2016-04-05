({
    toggleIsView : function(component, event, helper) {
		component.set("v.isView", event.getParam("isView"));
	},
	
	saveSettings : function(component, event, helper) {
		helper.saveSettings(component);
	}
})