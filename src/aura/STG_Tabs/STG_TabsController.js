({
   init : function(component, event, helper) {
	   var afflTopTab = component.find("afflTab");
	   $A.util.addClass(afflTopTab, "slds-active");
	   
	   var afflTabContent = component.find("afflTabContent");
	   $A.util.addClass(afflTabContent, "slds-show");
	   
	   var relTabContent = component.find("relTabContent");
	   $A.util.addClass(relTabContent, "slds-hide");
	   
	   var addrTabContent = component.find("addrTabContent");
	   $A.util.addClass(addrTabContent, "slds-hide");
	   
	   var systemTabContent = component.find("systemTabContent");
	   $A.util.addClass(systemTabContent, "slds-hide");
   }
})