({
	onSelectChange : function(component, event, helper) {
	   helper.onSelectChange(component);
   },

	toggleIsView : function(component, event) {
		component.set("v.isView", event.getParam("isView"));
	},

	saveAccRecType : function(component, event, helper) {
		helper.saveAccRecType(component, event);
	}
})