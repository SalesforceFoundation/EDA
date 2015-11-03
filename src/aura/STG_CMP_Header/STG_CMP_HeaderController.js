({
	init : function(component, event, helper) {
		component.set("v.isView", true);
		//var namespace_prefix = document.getElementById("namespace_prefix").value;
		var namespace_prefix = component.get("v.namespace_prefix");
		console.log("Namespace read in Header component: " + namespace_prefix);
		//component.set("v.namespace_prefix", namespace_prefix);
	},
	
	edit : function(component, event, helper) {
		component.set("v.isView", false);
		$A.get("e.c:STG_EVT_Edit").setParams({"isView": false}).fire();
	},
	
	save : function(component, event, helper) {
		component.set("v.isView", true);
		$A.get("e.c:STG_EVT_Save").setParams({"save": true}).fire();
	},
	
	cancel : function(component, event, helper) {
		component.set("v.isView", true);
		$A.get("e.c:STG_EVT_Edit").setParams({"isView": true}).fire();
		$A.get("e.c:STG_EVT_Cancel").fire();
	}
})