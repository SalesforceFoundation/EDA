({
	pressIcon : function(component, event, helper) {
		console.log("firing svgIcon Press Event");
		component.getEvent("pressIcon").setParams({"id": component.get("v.id"), "position" : component.get("v.position")}).fire();
    }
})