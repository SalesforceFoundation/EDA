({
   init : function(component, event, helper) {
	   
	   var action = component.get("c.getAfflMappings");
	   action.setCallback(this, function(data) {
		   console.log("Mappings: " + data.getReturnValue());
           component.set("v.afflMappings", data.getReturnValue());
       });
       $A.enqueueAction(action);
   }
})