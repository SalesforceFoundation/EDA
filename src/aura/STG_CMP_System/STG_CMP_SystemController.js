({
	toggleIsView : function(component, event) {
		component.set("v.isView", event.getParam("isView"));

		// setup the select for the error notificatio UI
		// if( component.get("v.isView") ) {
			var notifyTo = component.get("v.hierarchySettings.Error_Notifications_To__c"),
				type = "All Sys Admins";
			
			if (notifyTo.startsWith("005")) { // User
				type = "User";
			} else if ( notifyTo.startsWith("0F9") ) { // Chatter Group
				type = "Chatter Group";
			}
			
			component.set("v.errorNotificationType", type);
		// }
	},
	errorToSelect : function(component, event, helper) {
		helper.errorToSelect(component, event, helper);
	}
})