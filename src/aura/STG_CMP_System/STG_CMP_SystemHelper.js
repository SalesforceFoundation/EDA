({
	errorToSelect : function(component, event, helper) {
		// console.log(event);
		// console.log( event.getParam("value") );
		var notifyLookup;
		var notifyType = component.get("v.errorNotificationType");

		if (notifyType=="User") {
			notifyLookup = component.find("errNoticeUserId");
		} else if (notifyType=="Chatter Group") {
			notifyLookup = component.find("errNoticeChatter");
		}

		console.log( notifyType );

		$A.util.removeClass(notifyLookup, "slds-hide");
		$A.util.addClass(notifyLookup, "slds-show");
	}
})