({
	init : function(component, event, helper) {
		helper.init(component);
	},

	saveSettings : function(component, event, helper) {
		helper.saveSettings(component);
	},

	resetSettings : function(component, event, helper) {
		helper.resetSettings(component);
	},

	tabNavigationClick : function(component, event, helper) {
        helper.tabNavClick(component, event);
    },
    
    closeToast: function(component, event, helper) {
        helper.closeToast(component);
    }
})