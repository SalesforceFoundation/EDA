({
	init : function(component, event, helper) {
		helper.init(component);
		var namespace_prefix = document.getElementById("namespace_prefix").value;
		console.log("Namespace read in Tabs component: " + namespace_prefix);
		component.set("v.namespace_prefix", namespace_prefix);
	},
	
	saveSettings : function(component, event, helper) {
		var saveAction = component.get("c.saveHierarchySettings");
		saveAction.setParams({"hierarchySettings" : component.get("v.hierarchySettings")});
		saveAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				component.set("v.isView", true);
			} else if(response.getState() === "ERROR") {
				component.set("v.isView", false);
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						$A.error("Error message: " + errors[0].message);
					}
				} else {
					$A.error("Unknown error");
				}
			}
		});
		$A.enqueueAction(saveAction);
	},

	afflLinkClicked : function(component, event, helper) {
		$A.util.addClass(component.find("afflTab"), "slds-active");
		$A.util.removeClass(component.find("relTab"), "slds-active");
		$A.util.removeClass(component.find("addrTab"), "slds-active");
		$A.util.removeClass(component.find("sysTab"), "slds-active");

		var afflTabContent = component.find("afflTabContent");
		$A.util.removeClass(afflTabContent, "slds-hide");
		$A.util.addClass(afflTabContent, "slds-show");

		var relTabContent = component.find("relTabContent");
		$A.util.removeClass(relTabContent, "slds-show");
		$A.util.addClass(relTabContent, "slds-hide");

		var addrTabContent = component.find("addrTabContent");
		$A.util.removeClass(addrTabContent, "slds-show");
		$A.util.addClass(addrTabContent, "slds-hide");

		var systemTabContent = component.find("systemTabContent");
		$A.util.removeClass(systemTabContent, "slds-show");
		$A.util.addClass(systemTabContent, "slds-hide");
	},

	relLinkClicked : function(component, event, helper) {
		$A.util.removeClass(component.find("afflTab"), "slds-active");
		$A.util.addClass(component.find("relTab"), "slds-active");
		$A.util.removeClass(component.find("addrTab"), "slds-active");
		$A.util.removeClass(component.find("sysTab"), "slds-active");

		var afflTabContent = component.find("afflTabContent");
		$A.util.removeClass(afflTabContent, "slds-show");
		$A.util.addClass(afflTabContent, "slds-hide");

		var relTabContent = component.find("relTabContent");
		$A.util.removeClass(relTabContent, "slds-hide");
		$A.util.addClass(relTabContent, "slds-show");

		var addrTabContent = component.find("addrTabContent");
		$A.util.removeClass(addrTabContent, "slds-show");
		$A.util.addClass(addrTabContent, "slds-hide");

		var systemTabContent = component.find("systemTabContent");
		$A.util.removeClass(systemTabContent, "slds-show");
		$A.util.addClass(systemTabContent, "slds-hide");
	},

	addrLinkClicked : function(component, event, helper) {
		$A.util.removeClass(component.find("afflTab"), "slds-active");
		$A.util.removeClass(component.find("relTab"), "slds-active");
		$A.util.addClass(component.find("addrTab"), "slds-active");
		$A.util.removeClass(component.find("sysTab"), "slds-active");

		var afflTabContent = component.find("afflTabContent");
		$A.util.removeClass(afflTabContent, "slds-show");
		$A.util.addClass(afflTabContent, "slds-hide");

		var relTabContent = component.find("relTabContent");
		$A.util.removeClass(relTabContent, "slds-show");
		$A.util.addClass(relTabContent, "slds-hide");

		var addrTabContent = component.find("addrTabContent");
		$A.util.removeClass(addrTabContent, "slds-hide");
		$A.util.addClass(addrTabContent, "slds-show");

		var systemTabContent = component.find("systemTabContent");
		$A.util.removeClass(systemTabContent, "slds-show");
		$A.util.addClass(systemTabContent, "slds-hide");
	},

	sysLinkClicked : function(component, event, helper) {
		$A.util.removeClass(component.find("afflTab"), "slds-active");
		$A.util.removeClass(component.find("relTab"), "slds-active");
		$A.util.removeClass(component.find("addrTab"), "slds-active");
		$A.util.addClass(component.find("sysTab"), "slds-active");

		var afflTabContent = component.find("afflTabContent");
		$A.util.removeClass(afflTabContent, "slds-show");
		$A.util.addClass(afflTabContent, "slds-hide");

		var relTabContent = component.find("relTabContent");
		$A.util.removeClass(relTabContent, "slds-show");
		$A.util.addClass(relTabContent, "slds-hide");

		var addrTabContent = component.find("addrTabContent");
		$A.util.removeClass(addrTabContent, "slds-show");
		$A.util.addClass(addrTabContent, "slds-hide");

		var systemTabContent = component.find("systemTabContent");
		$A.util.removeClass(systemTabContent, "slds-hide");
		$A.util.addClass(systemTabContent, "slds-show");
	},
	
	resetSettings : function(component, event, helper) {
		helper.resetSettings(component);
	}
})