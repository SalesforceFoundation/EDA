({
   init : function(component, event, helper) {
	   helper.init(component);
   },
	
	toggleIsView : function(component, event, helper) {
		component.set("v.isView", event.getParam("isView"));
	}
})