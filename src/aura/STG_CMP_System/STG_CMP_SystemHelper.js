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
                var toast = component.find("hhSuccessToast"); 
                $A.util.removeClass(toast,'slds-hide');
                $A.util.addClass(toast, 'slds-show'); 
                
                var tst = component.find("hhSuccessToast");
            	$A.util.removeClass(tst, "slds-hide");
            	$A.util.addClass(tst, "slds-show");
        
            	window.setTimeout(
                $A.getCallback(function() {
                $A.util.removeClass(tst, "slds-show");
                $A.util.addClass(tst, "slds-hide");    
                }), 5000);
            }
        }); 
        
        $A.enqueueAction(action); 
    },
    
    handleRefreshAdminAccount: function(component, event, helper) {
        var action = component.get("c.executeRefreshAdminAccountBatch"); 
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {            
                var toast = component.find("adminSuccessToast"); 
                $A.util.removeClass(toast,'slds-hide');
                $A.util.addClass(toast, 'slds-show'); 
                
                var tst = component.find("adminSuccessToast");
            	$A.util.removeClass(tst, "slds-hide");
            	$A.util.addClass(tst, "slds-show");
        
            	window.setTimeout(
                $A.getCallback(function() {
                $A.util.removeClass(tst, "slds-show");
                $A.util.addClass(tst, "slds-hide");    
                }), 5000);
            }
        }); 
        
        $A.enqueueAction(action);	    
    },
    
    closeToast: function(component) {
        var adminToast = component.find("adminSuccessToast");
        var hhToast = component.find("hhSuccessToast"); 
        $A.util.removeClass(adminToast, "slds-show");
        $A.util.addClass(adminToast, "slds-hide");
        $A.util.removeClass(hhToast, "slds-show");
        $A.util.addClass(hhToast, "slds-hide");
    },

})