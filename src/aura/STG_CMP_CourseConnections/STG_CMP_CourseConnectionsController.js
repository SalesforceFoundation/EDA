({

  init : function(component, event, helper) {
    helper.init(component, event);
  },

  onStudentSelectChange : function(component, event, helper) {
    helper.onStudentSelectChange(component);
  },

  onFacultySelectChange : function(component, event, helper) {
    helper.onFacultySelectChange(component);
  },

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
	}
})