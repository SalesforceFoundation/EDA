({
    courseDescriptionCopy : function (component) {
        var runBatchAction = component.get("c.courseDescriptionCopy");
        runBatchAction.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                var descCopyMsg = component.find("descCopyMsg");
                $A.util.toggleClass(descCopyMsg, "slds-hide");

            } else if(response.getState() === "ERROR") {
                this.displayError(response);
            }
        });
        $A.enqueueAction(runBatchAction);
    },
})