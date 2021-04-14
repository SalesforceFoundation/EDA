({
    setPageReference: function (component) {
        const componentPageReference = component.get("v.pageReference");
        component.set("v.pageReference", componentPageReference);
    },
    openPrimaryAffiliationModal: function (component, eventParameters) {
        const mappingName = eventParameters.mappingName;
        const affiliationsAction = eventParameters.affiliationsAction;
        const accountRecordType = eventParameters.accountRecordType;
        const contactField = eventParameters.contactField;

        component
            .find("primaryAffiliationsModal")
            .openPrimaryAffiliationsModal(affiliationsAction, mappingName, accountRecordType, contactField);
    },
    openSettingsBatchJobModal: function (component, eventParameters) {
        window.alert("2 inside container helper");
        const batchJobToRun = eventParameters.batchJobToRun;
        component.find("settingBatchJobModal").openSettingsBatchJobModal(batchJobToRun);
    },
    handleModalSaveEvent: function (component, saveModel) {
        const edaSettings = component.find("edaSettings");
        const edaSettingsElement = edaSettings.getElement();
        edaSettingsElement.modalSave(saveModel);
    }
});
