({
  settsLinkClicked : function(component) {
    $A.util.addClass(component.find("settsTab"), "slds-active");
    $A.util.removeClass(component.find("backfillTab"), "slds-active");

    var settsTabContent = component.find("settsTabContent");
    $A.util.removeClass(settsTabContent, "slds-hide");
    $A.util.addClass(settsTabContent, "slds-show");

    var backfillTabContent = component.find("backfillTabContent");
    $A.util.removeClass(backfillTabContent, "slds-show");
    $A.util.addClass(backfillTabContent, "slds-hide");
  },

  backfillLinkClicked : function(component) {
    $A.util.removeClass(component.find("settsTab"), "slds-active");
    $A.util.addClass(component.find("backfillTab"), "slds-active");

    var settsTabContent = component.find("settsTabContent");
    $A.util.removeClass(settsTabContent, "slds-show");
    $A.util.addClass(settsTabContent, "slds-hide");

    var backfillTabContent = component.find("backfillTabContent");
    $A.util.removeClass(backfillTabContent, "slds-hide");
    $A.util.addClass(backfillTabContent, "slds-show");
  },

  startBackfill : function(component) {
    component.set('v.backfillStarted', true);
    var action = component.get("c.getEnqueueCourseConnectionsBackfill");
    action.setCallback(this, function(response) {
        if(response.getState() === "SUCCESS") {
            var successMessage = $A.get("$Label.c.stgCourseConnBackFillSuccess");
            component.set('v.startBackfillMessage', successMessage);           
            component.set('v.backFillToastIcon', 'success');
            component.set('v.backFillToastClass', 'slds-notify slds-notify_toast slds-theme_success');
            var tst = component.find("backFillToast");
            $A.util.removeClass(tst, "slds-hide");
            $A.util.addClass(tst, "slds-show");
        
            window.setTimeout(
                $A.getCallback(function() {
                $A.util.removeClass(tst, "slds-show");
                $A.util.addClass(tst, "slds-hide");    
                }), 5000
            );

        } else if(response.getState() === "ERROR") {
              var errorMessage = $A.get("$Label.c.stgCourseConnBackFillError");
              component.set('v.startBackfillMessage', errorMessage);
              component.set('v.backFillToastIcon', 'error');
              component.set('v.backFillToastClass', 'slds-notify slds-notify_toast slds-theme_error');
              var tst = component.find("backFillToast");
              $A.util.removeClass(tst, "slds-hide");
              $A.util.addClass(tst, "slds-show");

              window.setTimeout(
                  $A.getCallback(function() {
                  $A.util.removeClass(tst, "slds-show");
                  $A.util.addClass(tst, "slds-hide");    
                  }), 5000
              );
          }
    });
    $A.enqueueAction(action);
  },
  
  closeBackFillToast: function(component) {
    var tst = component.find("backFillToast");
    $A.util.removeClass(tst, "slds-show");
    $A.util.addClass(tst, "slds-hide");
  },
})