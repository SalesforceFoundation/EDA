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
          component.set('v.startBackfillMessage', 'Backfill was successfully started.');
        } else if(response.getState() === "ERROR") {
          component.set('v.startBackfillMessage', 'There was an error when starting the backfill.');
      }
      });
      $A.enqueueAction(action);
  },

  handleAffiliationBackfill : function(component, event, helper) {
    console.log('affiliationBackfill HS -->');
    var action = component.get("c.executeAffiliationBackfillOnCourseConnection");
    action.setCallback(this, function(response) {
    if(response.getState() === "SUCCESS") {
        var toast = component.find("successToast");
        $A.util.removeClass(toast,'slds-hide');
        $A.util.addClass(toast, 'slds-show');
      } else if(response.getState() === "ERROR") {
        console.log('affiliationBackfill HS ERROR -->');
        component.set('v.startBackfillMessageForAffiliation', 'There was an error when starting the backfill.');
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