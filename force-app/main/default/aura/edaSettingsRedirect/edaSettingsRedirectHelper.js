({
    handleEdaSettingsRedirect: function (event, component) {
        // const pageReference = {
        //     type: "standard__component",
        //     attributes: {
        //         componentName: "c__EducationCloudSettingsContainer"
        //     }
        // };
        // var pageReference = {
        //     type: "standard__objectPage",
        //     attributes: {
        //         objectApiName: "Account",
        //         actionName: "home"
        //     }
        // };
        window.alert("helper pageReference: " + pageReference);
        var navService = component.find("navService");
        event.preventDefault();
        navService.navigate(pageReference);
    }
});
