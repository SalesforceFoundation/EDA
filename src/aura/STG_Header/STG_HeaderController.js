({
	init : function(component, event, helper) {
		component.set("v.isView", true);
	},
	
	edit : function(component, event, helper) {
		component.set("v.isView", false);
		console.log('firing edit');
		var editEvent = $A.get("e.c:editEvent");
		console.log(JSON.parse(JSON.stringify(editEvent)));
		editEvent.setParams({"isView": false});
		console.log(JSON.parse(JSON.stringify(editEvent)));
		editEvent.fire();
	},
	
	save : function(component, event, helper) {
		component.set("v.isView", true);
		console.log('firing save');
		$A.get("e.c:editEvent").setParams({"isView": true}).fire();
	}
})