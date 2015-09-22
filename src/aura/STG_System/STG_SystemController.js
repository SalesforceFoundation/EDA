({
   init : function(component, event, helper) {
	   
	   var action = component.get("c.getSettings");
	   action.setCallback(this, function(data) {
           component.set("v.hierarchySettings", data.getReturnValue());
       });
       $A.enqueueAction(action);
   }
})