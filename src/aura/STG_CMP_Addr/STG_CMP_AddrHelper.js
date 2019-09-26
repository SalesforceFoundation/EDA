({
	runBackfill : function (component) {
		var runBatchAction = component.get("c.executeEthnicityRaceBatch");
		runBatchAction.setCallback(this, function(response) {
	        if(response.getState() === "SUCCESS") {

			    var backfillStatusMsg = component.find("ethnicRaceMsg");
			    $A.util.toggleClass(backfillStatusMsg, "slds-hide");

	        } else if(response.getState() === "ERROR") {
	        	this.displayError(response);
		    }
		});
		$A.enqueueAction(runBatchAction);
	},
	runCleanUp : function (component) {
		var runBatchAction = component.get("c.executePreferredEmailCleanUpBatch");
		runBatchAction.setCallback(this, function(response) {
	        if(response.getState() === "SUCCESS") {

			    var statusMsg = component.find("cleanUpMsg");
			    $A.util.toggleClass(statusMsg, "slds-hide");

            } else if(response.getState() === "ERROR") {
	        	this.displayError(response);
		    }
		});
		$A.enqueueAction(runBatchAction);
    },
    handlePhoneSync : function (component, event) {
        var enablePrefPhone = event.getSource().get("v.value");
        
        if(enablePrefPhone) {
        	component.set("v.prefPhoneErrorsDisabled", false);
        } else {
        	component.set("v.prefPhoneErrorsDisabled", true);
        }
        
        $A.get('e.force:refreshView').fire();
    },
})