({
	init : function(component) {
		$A.util.addClass(component.find("afflTab"), "slds-active");

		$A.util.addClass(component.find("afflTabContent"), "slds-show");
		$A.util.addClass(component.find("relTabContent"), "slds-hide");
		$A.util.addClass(component.find("addrTabContent"), "slds-hide");
		$A.util.addClass(component.find("systemTabContent"), "slds-hide");
		
		//Retrieving hierarchy settings
		this.getHierarchySettings(component);
	},
	
	getHierarchySettings : function(component) {
		var prefix = component.get("v.namespacePrefix");
		var action = component.get("c.getSettings");
	    action.setCallback(this, function(response) {
	    	if(response.getState() === "SUCCESS") {
	    		var settings = response.getReturnValue();
	    		var settingsNoPrefix = this.removePrefixHierarchySettings(settings, prefix);
	    		component.set("v.hierarchySettings", settingsNoPrefix);
	    		//Even though this property is only used but the CMP_System component, we set it here
	    		//because this method is called after the init method of that component.
	    		component.set("v.accRecTypeId", settingsNoPrefix.Account_Processor__c);
	    		//Get account record types
	    		this.getAccountRecordTypes(component, settingsNoPrefix.Accounts_to_Delete__c, settingsNoPrefix.Account_Processor__c);	    		
	    	} else if(response.getState() === "ERROR") {
	    		this.displayError(response);
			}
	    });
	    $A.enqueueAction(action);
	},
	
	//We want to compare the list of all available Account Record Types with the list of those that have been
	//marked as "Account types that can be deleted if they have no children" in the Accounts_to_Delete__c setting.
	getAccRecTypesSelectdDel : function(component, accsToDelete, accRecTypes) {
		//We need to call this method here because this logic is called after the init method in STG_CMP_AddrController
		var accTypesToDelete = this.getTokenizedAccsToDelete(accsToDelete);
		accTypesToDeleteSelected = [];
		for(var i = 0; i < accRecTypes.length; i++) {
			accTypeToDelete = {};
			accTypeToDelete.name = accRecTypes[i].name;
			accTypeToDelete.id = accRecTypes[i].id;
			accTypeToDelete.selected = false; //we set it to false initially
			for(var j = 0; j < accTypesToDelete.length; j++) {
				if(accRecTypes[i].name == accTypesToDelete[j]) {
					accTypeToDelete.selected = true;
				}
			}
			accTypesToDeleteSelected.push(accTypeToDelete);
		}
		component.set("v.accTypesToDeleteSelected", accTypesToDeleteSelected);
	},
	
	//We are calling this method here instead of in STG_CMP_SystemHelper because if we do so, the action
	//getAccountRecordTypes in STG_CMP_SystemHelper gets called before the action getHierarchySettings in 
	//this helper. And we need the Account Processor value from HierarchySettings.
	getAccountRecordTypes : function(component, accsToDelete, accTypeId) {
		//Get all available account record types
		var action = component.get("c.getRecTypesMapByName");
		action.setParams({ "objectName" : 'Account'});
		action.setCallback(this, function(response) {
	    	if(response.getState() === "SUCCESS") {
	    		var recTypesObj = response.getReturnValue();
	    		var accRecTypes = [];
	    		for(var property in recTypesObj) {
	    			if (recTypesObj.hasOwnProperty(property)) {
	    				accRecTypes.push({name: property, id: recTypesObj[property]});
	    				//Find the name of the account record type that matches the stored ID.
	    				//We check if one string is contained in the other because in one case we have
	    				//the 15 digit id, and in the other the 18 digit one.
	    				if(recTypesObj[property].indexOf(accTypeId) > -1) {
	    					component.set("v.accRecTypeName", property);
	    				}
	    			}
	    		}
	    		component.set("v.accRecTypes", accRecTypes);
	    		//Get record types of account that can be deleted if all their children have been deleted
	    		this.getAccRecTypesSelectdDel(component, accsToDelete, accRecTypes);
	    	} else if(response.getState() === "ERROR") {
	    		this.displayError(response);
			}
	    });
	    $A.enqueueAction(action);
	},
	
	saveSettings : function(component) {
		var prefix = component.get("v.namespacePrefix");
		var saveAction = component.get("c.saveHierarchySettings");
		var hierarchySettings = this.addPrefixHierarchySettings(component.get("v.hierarchySettings"), prefix);
		saveAction.setParams({"hierarchySettings" : hierarchySettings});
		saveAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				component.set("v.isView", true);
			} else if(response.getState() === "ERROR") {
				component.set("v.isView", false);
				this.displayError(response);
			}
		});
		$A.enqueueAction(saveAction);
	},
	
	resetSettings : function(component) {
		this.getHierarchySettings(component);
	}
})