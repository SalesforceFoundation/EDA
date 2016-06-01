({
	pressIcon : function(component) {
		component.getEvent("pressIcon").setParams({"id": component.get("v.id"), "position" : component.get("v.position")}).fire();
    }
})