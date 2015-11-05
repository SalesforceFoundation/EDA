({
   init : function(component, event, helper) {
	   helper.init(component);
   },
   
   toggleIsView : function(component, event, helper) {
	   component.set("v.isView", event.getParam("isView"));
   }, 
   
   saveAfflMappings : function(component, event, helper) {
		helper.saveAfflMappings(component);
	},
	
	resetSettings : function(component, event, helper) {
		helper.resetSettings(component);
	}
})