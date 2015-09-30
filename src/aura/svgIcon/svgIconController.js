({
	pressIcon : function(component, event, helper) {
		console.log("firing svgIcon Press Event");
		component.getEvent("pressIcon").setParams({"Id": component.get("v.Id")}).fire();
    }
})