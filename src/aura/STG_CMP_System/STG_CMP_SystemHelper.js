({
	errorToSelect : function(component) {
		var errNoticeUserId = component.find("errNoticeUserId");
		var errNoticeChatter = component.find("errNoticeChatter");
		var	notifyType = component.get("v.errorNotificationType");

		if (notifyType==="User") {

			$A.util.removeClass(errNoticeUserId, "slds-hide");
			$A.util.addClass(errNoticeUserId, "slds-show");
			// Hide other field if shown
			$A.util.removeClass(errNoticeChatter, "slds-show");
			$A.util.addClass(errNoticeChatter, "slds-hide");

		} else if (notifyType==="Chatter Group") {

			$A.util.removeClass(errNoticeChatter, "slds-hide");
			$A.util.addClass(errNoticeChatter, "slds-show");
			// Hide other field if shown
			$A.util.removeClass(errNoticeUserId, "slds-show");
			$A.util.addClass(errNoticeUserId, "slds-hide");

		} else {
			// User selected "All Sys Admins"
			component.set("v.hierarchySettings.Error_Notifications_To__c","All Sys Admins");

			// Hide other fields
			$A.util.addClass(errNoticeChatter, "slds-hide");
			$A.util.removeClass(errNoticeChatter, "slds-show");
			$A.util.removeClass(errNoticeUserId, "slds-show");
			$A.util.addClass(errNoticeUserId, "slds-hide");
		}
	},

    handleRefreshHouseholdAccount: function(component, event, helper) {
    	var action = component.get("c.executeRefreshHouseholdAccountBatch");
        action.setCallback(this, function(response) {
                            var state = response.getState();
        if (state === "SUCCESS") {
            var toast = component.find("successToast");
        	$A.util.removeClass(toast,'slds-hide');
            $A.util.addClass(toast, 'slds-show');
        } else if (state ==="INCOMPLETE") {
            console.log('InsideHelperforHandleRefresh Incomplete');
        } else if (state ==="ERROR") {
            console.log('InsideHelperforHandleRefresh ERROR');
        }
        });

        $A.enqueueAction(action);
    },

    handleRefreshAdminAccount: function(component, event, helper) {
    	var action = component.get("c.executeRefreshAdminAccountBatch");
        action.setCallback(this, function(response) {
                            var state = response.getState();
        if (state === "SUCCESS") {
            var toast = component.find("successToast");
        	$A.util.removeClass(toast,'slds-hide');
            $A.util.addClass(toast, 'slds-show');
        } else if (state ==="INCOMPLETE") {
            console.log('InsideHelperforHandleRefresh Incomplete');
        } else if (state ==="ERROR") {
            console.log('InsideHelperforHandleRefresh ERROR');
        }
        });

        $A.enqueueAction(action);
    },

    closeToast: function(component) {
        var tst = component.find("successToast");
        $A.util.removeClass(tst, "slds-show");
        $A.util.addClass(tst, "slds-hide");
    },

})