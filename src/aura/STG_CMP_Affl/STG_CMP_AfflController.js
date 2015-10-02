({
   init : function(component, event, helper) {
	   helper.init(component);
   },
   
   toggleIsView : function(component, event, helper) {
	   component.set("v.isView", event.getParam("isView"));
   }, 
   
   saveAfflSettings : function(component, event, helper) {
		helper.saveAfflSettings(component);
	},
	
	resetSettings : function(component, event, helper) {
		helper.resetSettings(component);
	}
})