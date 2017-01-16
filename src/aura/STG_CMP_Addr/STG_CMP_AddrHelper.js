({
	runBackfill : function (component, event, helper) {
		// console.log();
		var runBatchAction = component.get("c.executeEthnicityRaceBatch");
		runBatchAction.setCallback(this, function(response) {
	        if(response.getState() === "SUCCESS") {

			    var backfillBtn = component.find("ethnicRaceMsg");
			    $A.util.toggleClass(backfillBtn, "slds-hide");

	        } else if(response.getState() === "ERROR") {
	        	this.displayError(response);
		    }
		});
		$A.enqueueAction(runBatchAction);
	}
})