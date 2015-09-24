({
   init : function(component, event, helper) {
	   component.set("v.isView", true);
	   
	   var action = component.get("c.getAfflMappings");
	   action.setCallback(this, function(data) {
           component.set("v.afflMappings", data.getReturnValue());
       });
       $A.enqueueAction(action);
   },
   
   toggleIsView : function(component, event, helper) {
	   console.log('reading edit/save event');
	   component.set("v.isView", event.getParam("isView"));
   }
})