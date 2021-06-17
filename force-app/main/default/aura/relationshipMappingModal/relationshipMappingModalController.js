({
    handleRelationshipMappingNameChange: function (component, event, helper) {
        helper.handleRelationshipMappingNameChange(component, event.getParam("relationshipMappingName"));
    },
    handleFemaleValueChange: function (component, event, helper) {
        helper.handleFemaleValueChange(component, event.getParam("femaleValue"));
    },
    handleMaleValueChange: function (component, event, helper) {
        helper.handleMaleValueChange(component, event.getParam("maleValue"));
    },
    handleNeutralValueChange: function (component, event, helper) {
        helper.handleNeutralValueChange(component, event.getParam("neutralValue"));
    },
    handleIsActiveChange: function (component, event, helper) {
        helper.handleIsActiveChange(component, event.getParam("isActive"));
    }
});
