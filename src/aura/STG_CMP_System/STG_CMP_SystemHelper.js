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
    
    /*settsLinkClicked: function(component, event, helper) {
        console.log('InsideHP settsLinkClicked'); 
        var buttonClick = component.find("settsTabContent"); 
        var settsTabContent = component.find("settsTabContent");
        var bulkProcessTabContent = component.find("bulkProcessTabContent"); 
        console.log(buttonClick); 
        console.log(settsTabContent); 
        
        if (buttonClick === "settsTabContent") {
            console.log('settsIf -->' + buttonClick); 
            $A.util.addClass(component.find("settsTab"), "slds-active");
        	$A.util.removeClass(component.find("bulkTab"), "slds-active");
            //$A.util.removeClass(settsTabContent, "slds-hide");
            //$A.util.addClass(settsTabContent, "slds-show");
            //$A.util.removeClass(bulkProcessTabContent, "slds-hide");
        }
         console.log('InsideHP settsLinkClicked AFTER'); 
        //this.hideTabContent(component,"bulkProcessingTabContent");
    },
    
    bulkProcessLinkClicked: function(component, helper) {
        console.log('InsideHP bulkProcessLinkClicked'); 
        $A.util.addClass(component.find("bulkTab"), "slds-active");
        $A.util.removeClass(component.find("settsTab"), "slds-active");
        
        var bulkProcessTabContent = component.find("bulkProcessTabContent");
        $A.util.removeClass(bulkProcessTabContent, "slds-hide");
        $A.util.addClass(bulkProcessTabContent, "slds-show");

        this.hideTabContent(component,"settsTabContent");
        
    }, */
    
    handleRefreshHouseholdAccount: function(component, event, helper) {
        console.log('InsideHelperforHandleRefresh'); 
    	var action = component.get("c.executeRefreshHouseholdAccountBatch"); 
        console.log('InsideHelperforHandleRefresh AfterAction'); 
        action.setCallback(this, function(response) {
                            var state = response.getState(); 
        if (state === "SUCCESS") {
            console.log('InsideHelperforHandleRefresh Success'); 
            
            var toast = component.find("successToast"); 
        	$A.util.removeClass(toast,'slds-hide');
            $A.util.addClass(toast, 'slds-show'); 
            console.log('InsideHelperforHandleRefresh Success2'); 
        } else if (state ==="INCOMPLETE") {
            console.log('InsideHelperforHandleRefresh Incomplete'); 
        } else if (state ==="ERROR") {
            console.log('InsideHelperforHandleRefresh ERROR'); 
        }
        }); 
        
        $A.enqueueAction(action); 
    },
    
    handleRefreshAdminAccount: function(component, event, helper) {
    	    
    }

})