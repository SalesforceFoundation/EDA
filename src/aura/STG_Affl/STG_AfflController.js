({
   init : function(component, event, helper) {
	   
	   var action = component.get("c.getAfflMappings");
	   action.setCallback(this, function(data) {
           component.set("v.afflMappings", data.getReturnValue());
       });
       $A.enqueueAction(action);
   }
})