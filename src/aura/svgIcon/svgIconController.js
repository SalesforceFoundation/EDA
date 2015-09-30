({
	press : function(component, event, helper) {
		console.log("firing");
		component.getEvent("svgIcon_EVT_Press").setParams({"Id": component.get("v.Id")}).fire();
	}
})