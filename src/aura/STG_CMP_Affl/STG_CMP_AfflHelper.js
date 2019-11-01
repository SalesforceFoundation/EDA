({
    init : function(component) {
        component.set("v.isView", true);
        $A.util.addClass(component.find("settsTab"), "slds-active");
        $A.util.addClass(component.find("settsTabContent"), "slds-show");
        $A.util.addClass(component.find("mappingsTabContent"), "slds-hide");
        this.loadAfflMappings(component);
    },

    loadAfflMappings : function(component) {
        var prefix = component.get("v.namespacePrefix");
        var action = component.get("c.getAfflMappings");
        
        action.setCallback(this, function(response) {
            
            if(response.getState() === "SUCCESS") {
                
                var settings = response.getReturnValue();
                if(settings.length === 0) {
                    this.setMessageLabel(component, "v.noAfflMappings", prefix, "noAfflMappings");
                }

                component.set("v.afflMappings", this.removePrefixListSettings(settings, prefix));
            
            } else if(response.getState() === "ERROR") {
                this.displayError(response);
            }
            
        });

        $A.enqueueAction(action);
    },

    settsLinkClicked : function(component) {
        $A.util.addClass(component.find("settsTab"), "slds-active");
        $A.util.removeClass(component.find("mappingsTab"), "slds-active");

        var settsTabContent = component.find("settsTabContent");
        $A.util.removeClass(settsTabContent, "slds-hide");
        $A.util.addClass(settsTabContent, "slds-show");

        this.hideTabContent(component, "mappingsTabContent");
    },

    mappingsLinkClicked : function(component) {
        $A.util.removeClass(component.find("settsTab"), "slds-active");
        $A.util.addClass(component.find("mappingsTab"), "slds-active");

        this.hideTabContent(component, "settsTabContent");

        var mappingsTabContent = component.find("mappingsTabContent");
        $A.util.removeClass(mappingsTabContent, "slds-hide");
        $A.util.addClass(mappingsTabContent, "slds-show");
    },

    resetSettings : function(component) {
        this.loadAfflMappings(component);
    },

    saveMappings : function(component) {
        var saveAction = component.get("c.saveAfflMappings");
        var settings = this.addPrefixListSettings(component.get("v.afflMappings"), component.get("v.namespacePrefix"));
        
        saveAction.setParams({"mappings" : settings});
        saveAction.setCallback(this, function(response) {
            if(response.getState() === "ERROR") {
                this.displayError(response);
            }
        });

        $A.enqueueAction(saveAction);
    },

    newAfflMapping : function(component) {
        var accRecType = component.find("accRecType").get("v.value");
        var primaryField = component.find("primaryField").get("v.value");
        var autoEnroll = component.find("autoEnroll").get("v.value");
        var autoEnrollStatus = component.find("autoEnrollStatus").get("v.value");
        var autoEnrollRole = component.find("autoEnrollRole").get("v.value");

        var newMappingAction = component.get("c.newAfflMpg");
        newMappingAction.setParams({ "accRecType" : accRecType, "primaryField" : primaryField, "autoEnroll" : autoEnroll,
            "autoEnrollStatus" : autoEnrollStatus, "autoEnrollRole" : autoEnrollRole });
        
        newMappingAction.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.noAfflMappings", "");
                var afflMappings = component.get("v.afflMappings");
                afflMappings.push({ "Id" : response.getReturnValue(), "Account_Record_Type__c" : accRecType, "Primary_Affl_Field__c" : primaryField,
                                "Auto_Program_Enrollment__c" : autoEnroll, "Auto_Program_Enrollment_Status__c" : autoEnrollStatus,
                                "Auto_Program_Enrollment_Role__c" : autoEnrollRole });
                component.set("v.afflMappings", afflMappings);
                this.clearNewStgBoxes(component, ["accRecType", "primaryField", "autoEnroll", "autoEnrollStatus", "autoEnrollRole"]);
                
                // Re-Disable Add Setting button after successful completion
                component.find("newAfflMappingBtn").set("v.disabled", true);
                
                // Re-Hide error message
                component.set("v.showAfflError", false);
            } else if(response.getState() === "ERROR") {
                var errors = JSON.stringify(response.getError());
                if (errors.includes('There is already an item in this list with the name')) {                
                    component.set("v.showAfflError", true);
                }    
                this.displayError(response);
            }
        });
        $A.enqueueAction(newMappingAction);
    },

    deleteAfflMappingRow : function(component, id, position) {
        this.deleteRow(component, "c.deleteAfflMappingRecord", "v.afflMappings", id, position, "v.noAfflMappings", "noAfflMappings",
                component.get("v.namespacePrefix"));
    }
})