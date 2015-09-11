({
	init : function(component, event, helper) {
		   $A.util.addClass(component.find("settsTab"), "slds-active");  

		   $A.util.addClass(component.find("settsTabContent"), "slds-show");
		   $A.util.addClass(component.find("recSettsTabContent"), "slds-hide");
		   $A.util.addClass(component.find("autocTabContent"), "slds-hide");
	    },

	    settsLinkClicked : function(component, event, helper) {
			$A.util.addClass(component.find("settsTab"), "slds-active");
			$A.util.removeClass(component.find("recSettsTab"), "slds-active");
			$A.util.removeClass(component.find("autocTab"), "slds-active");
			
			var settsTabContent = component.find("settsTabContent");
		    $A.util.removeClass(settsTabContent, "slds-hide");
		    $A.util.addClass(settsTabContent, "slds-show");
		    
		    var recSettsTabContent = component.find("recSettsTabContent");
		    $A.util.removeClass(recSettsTabContent, "slds-show");
		    $A.util.addClass(recSettsTabContent, "slds-hide");
		   
		    var autocTabContent = component.find("autocTabContent");
		    $A.util.removeClass(autocTabContent, "slds-show");
		    $A.util.addClass(autocTabContent, "slds-hide");
		},
	   
		recSettsLinkClicked : function(component, event, helper) {
			$A.util.removeClass(component.find("settsTab"), "slds-active");
			$A.util.addClass(component.find("recSettsTab"), "slds-active");
			$A.util.removeClass(component.find("autocTab"), "slds-active"); 
			
			var settsTabContent = component.find("settsTabContent");
		    $A.util.removeClass(settsTabContent, "slds-show");
		    $A.util.addClass(settsTabContent, "slds-hide");
		    
		    var recSettsTabContent = component.find("recSettsTabContent");
		    $A.util.removeClass(recSettsTabContent, "slds-hide");
		    $A.util.addClass(recSettsTabContent, "slds-show");
		   
		    var autocTabContent = component.find("autocTabContent");
		    $A.util.removeClass(autocTabContent, "slds-show");
		    $A.util.addClass(autocTabContent, "slds-hide");
		},
		
		autocLinkClicked : function(component, event, helper) {
			$A.util.removeClass(component.find("settsTab"), "slds-active");
			$A.util.removeClass(component.find("recSettsTab"), "slds-active");
			$A.util.addClass(component.find("autocTab"), "slds-active"); 
			
			var settsTabContent = component.find("settsTabContent");
		    $A.util.removeClass(settsTabContent, "slds-show");
		    $A.util.addClass(settsTabContent, "slds-hide");
		    
		    var recSettsTabContent = component.find("recSettsTabContent");
		    $A.util.removeClass(recSettsTabContent, "slds-show");
		    $A.util.addClass(recSettsTabContent, "slds-hide");
		   
		    var autocTabContent = component.find("autocTabContent");
		    $A.util.removeClass(autocTabContent, "slds-hide");
		    $A.util.addClass(autocTabContent, "slds-show");
		}
})