({
    init : function(component) {
        //Retrieving hierarchy settings
        this.getHierarchySettings(component);
        this.getAdminAccNameFormatOptions(component);
        this.getHHAccNameFormatOptions(component);

        // since we can't call this.processTabs(component, 'afflTabBtn') from here
        // well process the tabs manually here.
        $A.util.addClass(component.find("afflTab"), "slds-active");

        $A.util.addClass(component.find("afflTabContent"), "slds-show");
        $A.util.addClass(component.find("relTabContent"), "slds-hide");
        $A.util.addClass(component.find("addrTabContent"), "slds-hide");
        $A.util.addClass(component.find("coursesTabContent"), "slds-hide");
        $A.util.addClass(component.find("courseConTabContent"), "slds-hide");
        $A.util.addClass(component.find("programPlanTabContent"), "slds-hide");
        $A.util.addClass(component.find("systemTabContent"), "slds-hide");
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
                component.set("v.householdRecTypeId", settingsNoPrefix.Household_Addresses_RecType__c);
                component.set("v.adminAccRecTypeId", settingsNoPrefix.Administrative_Account_Record_Type__c);
                component.set("v.studentRecTypeId", settingsNoPrefix.Student_RecType__c);
                component.set("v.facultyRecTypeId", settingsNoPrefix.Faculty_RecType__c);
                component.set("v.affiliationRoleMapValue", settingsNoPrefix.Affl_ProgEnroll_Role_Map__c);
                component.set("v.affiliationStatusMapValue", settingsNoPrefix.Affl_ProgEnroll_Status_Map__c);
                component.set("v.affiliationStatusDeleteMapValue", settingsNoPrefix.Affl_ProgEnroll_Del_Status__c);
                component.set("v.defaultContactLanguageFluencyValue", settingsNoPrefix.Default_Contact_Language_Fluency__c);
                component.set("v.defaultReciprocalMethodValue", settingsNoPrefix.Reciprocal_Method__c);
                component.set("v.defaultPreferredPhoneValue", settingsNoPrefix.Preferred_Phone_Selection__c );
                component.set("v.adminNameFormat", settingsNoPrefix.Admin_Account_Naming_Format__c);
                component.set("v.hhNameFormat", settingsNoPrefix.Household_Account_Naming_Format__c);
                component.set("v.adminOtherDisplay", this.getOtherDisplay(component, settingsNoPrefix.Admin_Account_Naming_Format__c));
                component.set("v.hhOtherDisplay", this.getOtherDisplay(component, settingsNoPrefix.Household_Account_Naming_Format__c));

                //Get account record types
                this.getAccountRecordTypes(component, settingsNoPrefix.Accounts_to_Delete__c,
                        settingsNoPrefix.Accounts_Addresses_Enabled__c, settingsNoPrefix.Account_Processor__c,
                        settingsNoPrefix.Household_Addresses_RecType__c, settingsNoPrefix.Administrative_Account_Record_Type__c);
                // Get Affiliation Role Picklist
                this.getAffiliationRolePicklistEntries(component, settingsNoPrefix.Affl_ProgEnroll_Role_Map__c);
                // Get Affiliation Status Picklist
                this.getAffiliationStatusPicklistEntries(component, settingsNoPrefix.Affl_ProgEnroll_Status_Map__c, settingsNoPrefix.Affl_ProgEnroll_Del_Status__c);
                // Get Course Connection Record Types
                this.getCourseConnectionRecordTypes(component, settingsNoPrefix.Student_RecType__c,
                        settingsNoPrefix.Faculty_RecType__c);
                // Get Contact Language Fluency Picklist
                this.getFluencyPicklistEntries(component, settingsNoPrefix.Default_Contact_Language_Fluency__c);
                // Get Preferrd Phone Picklists
                this.getPreferredPhonePicklistEntries(component, settingsNoPrefix.Preferred_Phone_Selection__c);
                // Get ReciprocalMethod Picklist Entries
                this.getReciprocalMethodOptions(component, settingsNoPrefix.Reciprocal_Method__c);
            } else if(response.getState() === "ERROR") {
                this.displayError(response);
            }
        });
        $A.enqueueAction(action);
    },

    //We are calling this method here instead of in STG_CMP_SystemHelper because if we do so, the action
    //getAccountRecordTypes in STG_CMP_SystemHelper gets called before the action getHierarchySettings in
    //this helper. And we need the Account Processor value from HierarchySettings.
    getAccountRecordTypes : function(component, accsToDelete, accsMultiAddr, accTypeId, householdTypeId, adminTypeId) {
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
                        if(recTypesObj[property].indexOf(householdTypeId) > -1) {
                            component.set("v.householdRecTypeName", property);
                        }
                        if(recTypesObj[property].indexOf(adminTypeId) > -1) {
                            component.set("v.adminAccRecTypeName", property);
                        }
                    }
                }
                component.set("v.accRecTypes", accRecTypes);

                //Get record types of accounts that can be deleted if all their children have been deleted. We need to call this
                //method here because this logic is called after the init method in STG_CMP_AddrController.
                var accTypesToDeleteSelected = this.getRecTypesSelected(component, accsToDelete, accRecTypes);
                component.set("v.accTypesToDeleteSelected", accTypesToDeleteSelected);

                //Get record types of accounts that have multi-address support enabled. We need to call this method here because this
                //logic is called after the init method in STG_CMP_AddrController.
                var accTypesAddrSelected = this.getRecTypesSelected(component, accsMultiAddr, accRecTypes);
                component.set("v.accTypesAddrSelected", accTypesAddrSelected);

            } else if(response.getState() === "ERROR") {
                this.displayError(response);
            }
        });
        $A.enqueueAction(action);
    },

    getAffiliationRolePicklistEntries : function(component, roleValue) {
        //Get all active affiliation role picklist entries
        var action = component.get("c.getPicklistActiveValuesMap");
        var prefix = component.get("v.namespacePrefix");
        var objectName = prefix + 'Affiliation__c';
        var fieldName = prefix + 'Role__c';
        
        action.setParams({ "objectName" : objectName,"fieldName" : fieldName});
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                var picklistValues = response.getReturnValue();
                var affiliationRolePicklistEntries = [];
                
                for(var property in picklistValues) {
                    if (picklistValues.hasOwnProperty(property)) {
                        affiliationRolePicklistEntries.push({picklistLabel: property, picklistValue : picklistValues[property]});
                        
                        if(property.indexOf(roleValue) > -1) {
                            component.set("v.affiliationRoleMapLabel", property);
                        }   
                    }
                }

                component.set("v.affiliationRolePicklistEntries", affiliationRolePicklistEntries);

            } else if(response.getState() === "ERROR") {
                this.displayError(response);
            }
        });
        $A.enqueueAction(action);
    },

    getAffiliationStatusPicklistEntries : function(component, statusValue, deleteValue) {
        //Get all active affiliation status picklist entries
        var action = component.get("c.getPicklistActiveValuesMap");
        var prefix = component.get("v.namespacePrefix");
        var objectName = prefix + 'Affiliation__c';
        var fieldName = prefix + 'Status__c';

        action.setParams({ "objectName" : objectName,"fieldName" : fieldName});
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                var picklistValues = response.getReturnValue();
                var affiliationStatusPicklistEntries = [];
        
                for(var property in picklistValues) {
                    
                    if (picklistValues.hasOwnProperty(property)) {
                        affiliationStatusPicklistEntries.push({picklistLabel: property, picklistValue: picklistValues[property]});
                        
                        if(property.indexOf(statusValue) > -1) { 
                            component.set("v.affiliationStatusMapLabel", property);
                        }

                        if(property.indexOf(deleteValue) > -1) {
                            component.set("v.affiliationStatusDeleteMapLabel", property);
                        }

                    }
                }

                component.set("v.affiliationStatusPicklistEntries", affiliationStatusPicklistEntries);

            } else if(response.getState() === "ERROR") {
                this.displayError(response);
            }
        });
        $A.enqueueAction(action);
    },

    getCourseConnectionRecordTypes : function(component, studentTypeId, facultyTypeId) {
        //Get all available course connection record types
        var action = component.get("c.getRecTypesMapByName");
        var prefix = component.get("v.namespacePrefix");
        var objectName = prefix + 'Course_Enrollment__c';
        action.setParams({ "objectName" : objectName});
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                var recTypesObj = response.getReturnValue();
                var courseConnectionRecTypes = [];
                for(var property in recTypesObj) {
                    if (recTypesObj.hasOwnProperty(property)) {
                        courseConnectionRecTypes.push({name: property, id: recTypesObj[property]});
                        if(recTypesObj[property].indexOf(studentTypeId) > -1) {
                            component.set("v.studentRecTypeName", property);
                        }
                        if(recTypesObj[property].indexOf(facultyTypeId) > -1) {
                            component.set("v.facultyRecTypeName", property);
                        }
                    }
                }
                component.set("v.courseConnectionRecTypes", courseConnectionRecTypes);

            } else if(response.getState() === "ERROR") {
              this.displayError(response);
            }
        });
        $A.enqueueAction(action);
    },

    getFluencyPicklistEntries : function(component, fluencyValue) {
        //Get all active Contact Language Fluency picklist entries
        var action = component.get("c.getPicklistActiveValuesMap");
        var prefix = component.get("v.namespacePrefix");
        var objectName = prefix + 'Contact_Language__c';
        var fieldName = prefix + 'Fluency__c';
        
        action.setParams({ "objectName" : objectName,"fieldName" : fieldName});
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                var picklistValues = response.getReturnValue();
                var fluencyPicklistEntries = [];
                
                for(var property in picklistValues) {
                    if (picklistValues.hasOwnProperty(property)) {
                        fluencyPicklistEntries.push({picklistLabel: property, picklistValue : picklistValues[property]});
                        
                        if(property.indexOf(fluencyValue) > -1) {
                            component.set("v.defaultContactLanguageFluencyLabel", property);
                        }   
                    }
                }

                component.set("v.fluencyPicklistEntries", fluencyPicklistEntries);

            } else if(response.getState() === "ERROR") {
                this.displayError(response);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPreferredPhonePicklistEntries : function(component, preferredValue) {
        //Get all active Contact Phone data type picklist entries
        var action = component.get("c.getFieldsOfTypeAura");
        var objectName = 'Contact';
        var type = 'Phone';
        
        action.setParams({ "objectName" : objectName,"type" : type});
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                var picklistValues = response.getReturnValue();
                var preferredPhonePicklistEntries = [];
                
                for(var property in picklistValues) {                     
                   
                    if (picklistValues.hasOwnProperty(property) && property != 'Business Phone') {
                        preferredPhonePicklistEntries.push({picklistLabel: property, picklistValue : property});  
                        
                        if(preferredValue == undefined || (preferredValue != undefined && property.indexOf(preferredValue)) > -1) {
                            component.set("v.defaultPreferredPhoneLabel", property);                        
                        } 
                    }
                    
                }

                component.set("v.preferredPhonePicklistEntries", preferredPhonePicklistEntries);
				
            } else if(response.getState() === "ERROR") {
                this.displayError(response);
            }
        });
        $A.enqueueAction(action);
    },

    getReciprocalMethodOptions : function(component, reciprocalMethodValue) {

        // Load Reciprocal Method Options
        var reciprocalMethodOptions = [];
        reciprocalMethodOptions.push({picklistLabel: $A.get("$Label.c.stgReciprocalMethodListSetting"), picklistValue: "List Setting"});
        reciprocalMethodOptions.push({picklistLabel: $A.get("$Label.c.stgReciprocalMethodValueInversion"), picklistValue: "Value Inversion"});

        // Load default Reciprocal Label (List Setting)
        if (reciprocalMethodValue == 'List Setting') {
            component.set("v.defaultReciprocalMethodLabel", $A.get("$Label.c.stgReciprocalMethodListSetting"));                        
        } else {
            component.set("v.defaultReciprocalMethodLabel", $A.get("$Label.c.stgReciprocalMethodValueInversion")); 
        }

        // Set reciprocalMethodOptions
        component.set('v.reciprocalMethodOptions', reciprocalMethodOptions);
    },

    //We want to compare the list of all available Account Record Types with the list of those that have been
    //marked as having enabled in the setting. The setting stores a semi-colon separated list of record type IDs.
    getRecTypesSelected : function(component, setting, recTypes) {
        var settingArray = this.getTokenized(setting);
        var recTypesSelected = [];
        for(var i = 0; i < recTypes.length; i += 1) {
            var recTypeSelected = {};
            recTypeSelected.name = recTypes[i].name;
            recTypeSelected.id = recTypes[i].id;
            recTypeSelected.selected = false; //we set it to false initially
            for(var j = 0; j < settingArray.length; j += 1) {
                if(recTypes[i].id === settingArray[j]) {
                    recTypeSelected.selected = true;
                }
            }
            recTypesSelected.push(recTypeSelected);
        }
        return recTypesSelected;
    },

    saveSettings : function(component) {
        var prefix = component.get("v.namespacePrefix");
        var saveAction = component.get("c.saveHierarchySettings");
        var hierarchySettings = this.addPrefixHierarchySettings(component.get("v.hierarchySettings"), prefix);
        saveAction.setParams({"hierarchySettings" : hierarchySettings});
        saveAction.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.isView", true);
                var tst = component.find("successToast");
                $A.util.removeClass(tst, "slds-hide");
                $A.util.addClass(tst, "slds-show");
                
                //show manual toast
                window.setTimeout(
                    $A.getCallback(function() {
                        $A.util.removeClass(tst, "slds-show");
                        $A.util.addClass(tst, "slds-hide");    
                    }), 5000
                );

            } else if(response.getState() === "ERROR") {
                component.set("v.isView", false);
                this.displayError(response);
            }
        });
        $A.enqueueAction(saveAction);
    },

    closeToast: function(component) {
        var tst = component.find("successToast");
        $A.util.removeClass(tst, "slds-show");
        $A.util.addClass(tst, "slds-hide");
    },

    resetSettings : function(component) {
        this.getHierarchySettings(component);
    },

    tabNavClick : function(component, event) {
        this.processTabs(component, event.getSource().getLocalId() );
    },

    processTabs : function(component, btnId) {
        // Since this method uses querySelector we can't use this method until the DOM is initialized.

        let tabNav = component.find('tabs').getElement().querySelector('ul.slds-tabs--default__nav'); 
        let contId =  btnId.replace('Btn', 'Content'); // content to show Id
        let tabId  =  btnId.replace('Btn', ''); // clicked tab
        let tabItem  = component.find(tabId);
        let contItem = component.find(contId);
        let matches = tabNav.querySelectorAll('li.slds-tabs__item');

        // Process all Tabs and content
        matches.forEach(function(element) {

            // Link Aura to DOM via GlobalId
            let selectedTab = element.dataset.auraRenderedBy == tabItem.getGlobalId() || false;

            // link this is the clicked element make active, otherwise remove the class
            element.classList.toggle('slds-active', selectedTab );

            // Process Content Tabs
            if( selectedTab ) {
                // Since this is the elected tab, we show that content
                $A.util.removeClass(contItem, "slds-hide");
                $A.util.addClass(contItem, "slds-show");
            } else {
                let tmpComp = component.find(element.getAttribute('id')+'Content');
                // Since we are in a loop we can hide all the other items except those we selected
                $A.util.removeClass(tmpComp, "slds-show");
                $A.util.addClass(tmpComp, "slds-hide");
            }            

        });
    },

    getOtherDisplay : function(component, value) {
        var prefix = component.get("v.namespacePrefix");
        var label = '';
        label = $A.get("$Label.c.acctNamingOther");
        if (value === label) {
            return true;
        }else{
            return false;
        }
    },

    getAdminAccNameFormatOptions : function(component) {
        var adminAccNameFormatOptions = [];
        var prefix = component.get("v.namespacePrefix");
        adminAccNameFormatOptions.push($A.get("$Label.c.lastNameAdminAcc"));
        adminAccNameFormatOptions.push($A.get("$Label.c.firstNameLastNameAdminACC"));
        adminAccNameFormatOptions.push($A.get("$Label.c.lastNameFirstNameAdminAcc"));
        adminAccNameFormatOptions.push($A.get("$Label.c.acctNamingOther"));
        component.set("v.adminAccNameFormatOptions", adminAccNameFormatOptions);
    },

    getHHAccNameFormatOptions : function(component) {
        var hhNameFormatOptions = [];
        var prefix = component.get("v.namespacePrefix");
        hhNameFormatOptions.push($A.get("$Label.c.lastNameHH"));
        hhNameFormatOptions.push($A.get("$Label.c.lastNameFirstNameHH"));
        hhNameFormatOptions.push($A.get("$Label.c.firstNameLastNameHH"));
        hhNameFormatOptions.push($A.get("$Label.c.lastNameFamily"));
        hhNameFormatOptions.push($A.get("$Label.c.lastNameFirstNameFamily"));
        hhNameFormatOptions.push($A.get("$Label.c.firstNameLastNameFamily"));
        hhNameFormatOptions.push($A.get("$Label.c.acctNamingOther"));
        component.set("v.hhNameFormatOptions", hhNameFormatOptions);
    }

})