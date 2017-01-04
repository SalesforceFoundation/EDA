({
	toggleIsView : function(component, event, helper) {
		component.set("v.isView", event.getParam("isView"));

		// setup the select for the error notificatio UI
		if( !event.getParam("isView") ) {
			var notifyTo = component.get("v.hierarchySettings.Error_Notifications_To__c"),
				type = "All Sys Admins";
			
			if (notifyTo.startsWith("005")) { // User
				type = "User";
			} else if ( notifyTo.startsWith("0F9") ) { // Chatter Group
				type = "Chatter Group";
			}
			
			component.set("v.errorNotificationType", type);

			// process dropdown to display select if necessary
			helper.errorToSelect(component);

		}
	},
	errorToSelect : function(component, event, helper) {
		helper.errorToSelect(component);
	},
    handleAutocomplete: function(component, event) {
        var selOpt = event.getParam('value');
        component.set("v.hierarchySettings.Error_Notifications_To__c", selOpt.value);
    }
})