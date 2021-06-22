({
    handleRelationshipMappingNameChange: function (component, relationshipMappingName) {
        component.set("v.relationshipMappingName", relationshipMappingName);
        this.dispatchDataChangeEvent(component, "relationshipMappingName", relationshipMappingName);
    },
    handleFemaleValueChange: function (component, femaleValue) {
        component.set("v.femaleValue", femaleValue);
        this.dispatchDataChangeEvent(component, "femaleValue", femaleValue);
    },
    handleMaleValueChange: function (component, maleValue) {
        component.set("v.maleValue", maleValue);
        this.dispatchDataChangeEvent(component, "maleValue", maleValue);
    },
    handleNeutralValueChange: function (component, neutralValue) {
        component.set("v.neutralValue", neutralValue);
        this.dispatchDataChangeEvent(component, "neutralValue", neutralValue);
    },
    handleIsActiveChange: function (component, isActive) {
        component.set("v.isActive", isActive);
        this.dispatchDataChangeEvent(component, "isActive", isActive);
    },
    dispatchDataChangeEvent: function (component, field, fieldValue) {
        let modalDataChangeEvent = component.getEvent("modalDataChangeEvent");
        modalDataChangeEvent.setParams({
            field: field,
            fieldValue: fieldValue
        });
        modalDataChangeEvent.fire();
    }
});
