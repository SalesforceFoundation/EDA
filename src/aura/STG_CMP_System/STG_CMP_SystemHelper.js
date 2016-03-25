({
	init : function(component) {
		var action = component.get("c.getRecTypesMapByName");
		action.setParams({ "objectName" : 'Account'});
		action.setCallback(this, function(response) {
	    	if(response.getState() === "SUCCESS") {
	    		var recTypesObj = response.getReturnValue();
	    		var accRecTypes = [];
	    		for(var property in recTypesObj) {
	    			if (recTypesObj.hasOwnProperty(property)) {
	    				accRecTypes.push({devName: property, id: recTypesObj[property]});
	    			}
	    		}
	    		component.set("v.accRecTypes", accRecTypes);
	    	} else if(response.getState() === "ERROR") {
	    		this.displayError(response);
			}
	    });
	    $A.enqueueAction(action);
	}
})