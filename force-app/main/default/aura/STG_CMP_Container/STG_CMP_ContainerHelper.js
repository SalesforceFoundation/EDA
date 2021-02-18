({
	showToast: function(component, event, helper, message) {
		$A.util.addClass(component.find("notificationToast"), "slds-show");
		$A.util.removeClass(component.find("notificationToast"), "slds-hide");
	},
	
	hideToast: function(component) {
		$A.util.addClass(component.find("notificationToast"), "slds-hide");
		$A.util.removeClass(component.find("notificationToast"), "slds-show");
	}
})