({
   init : function(component, event, helper) {
	   helper.init(component);
   },
   
   toggleIsView : function(component, event, helper) {
	   component.set("v.isView", event.getParam("isView"));
   }, 
   
   saveMappings : function(component, event, helper) {
		helper.saveMappings(component);
	},
	
	resetSettings : function(component, event, helper) {
		helper.resetSettings(component);
	},
	
	newAfflMapping : function(component, event, helper) {
		helper.newAfflMapping(component);
	},
})