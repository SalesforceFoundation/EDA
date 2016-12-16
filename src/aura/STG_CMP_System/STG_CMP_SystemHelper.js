({
	errorToSelect : function(component) {
		var errNoticeUserId = component.find("errNoticeUserId");
		var errNoticeChatter = component.find("errNoticeChatter");
		var	notifyType = component.get("v.errorNotificationType");

		if (notifyType=="User") {

			$A.util.removeClass(errNoticeUserId, "slds-hide");
			$A.util.addClass(errNoticeUserId, "slds-show");
			// Hide other field if shown
			$A.util.removeClass(errNoticeChatter, "slds-show");
			$A.util.addClass(errNoticeChatter, "slds-hide");

		} else if (notifyType=="Chatter Group") {
			
			$A.util.removeClass(errNoticeChatter, "slds-hide");
			$A.util.addClass(errNoticeChatter, "slds-show");
			// Hide other field if shown
			$A.util.removeClass(errNoticeUserId, "slds-show");
			$A.util.addClass(errNoticeUserId, "slds-hide");

		}
	}

})