({
	init : function(component, event, helper) {
		component.set("v.isView", true);
	},
	
	edit : function(component, event, helper) {
		component.set("v.isView", false);
		$A.get("e.c:STG_editEvent").setParams({"isView": false}).fire();
	},
	
	save : function(component, event, helper) {
		component.set("v.isView", true);
		$A.get("e.c:STG_editEvent").setParams({"isView": true}).fire();
	}
})