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
	   component.set("v.isView", event.getParam("isView"));
   }, 
   
   saveAfflSettings : function(component, event, helper) {
		var saveAction = component.get("c.saveAfflMappings");
		saveAction.setParams({"afflMappings" : component.get("v.afflMappings")});
		saveAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				//component.set("v.isView", true);
			} else if(response.getState() === "ERROR") {
				//component.set("v.isView", false);
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						$A.error("Error message: " + errors[0].message);
					}
				} else {
					$A.error("Unknown error");
				}
			}
		});
		$A.enqueueAction(saveAction);
	}
})