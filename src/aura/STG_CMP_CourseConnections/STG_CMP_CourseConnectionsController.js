({
  settsLinkClicked : function(component, event, helper) {
    helper.settsLinkClicked(component);
  },

  backfillLinkClicked : function(component, event, helper) {
    helper.backfillLinkClicked(component);
  },

  startBackfill : function(component, event, helper) {
    helper.startBackfill(component);
  },

  handleAffiliationBackfill : function(component, event, helper) {
    console.log('affiliationBackfill JS -->'); 
    helper.handleAffiliationBackfill(component); 
  },
    
  closeToast : function(component, event, helper) {
    helper.closeToast(component); 
        
  },
})