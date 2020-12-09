public virtual with sharing class VMPR_HealthCheck {
    
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static VMPR_HealthCheck instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected VMPR_HealthCheck() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of VMPR_HealthCheck.
    **********************************************************************************/
    public static VMPR_HealthCheck getInstance() {
        if (instance == null) {
            instance = new VMPR_HealthCheck();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Locates and returns an instance of the FeatureParameterService Service
    **********************************************************************************/
    // private FeatureParameterService locateFeatureParameterService() {
    //     return FeatureParameterService.getInstance();
    // }

    /**********************************************************************************
    * @description Locates and returns an instance of the HealthCheckDefinitionService Service
    **********************************************************************************/
    // private HealthCheckDefinitionService locateHealthCheckDefinitionService() {
    //     return HealthCheckDefinitionService.getInstance();
    // }

    // public String updateHealthCheckLastRunDate(){
    //     // FeatureParameterModel featureParamDateModel = (FeatureParameterDateModel)this.locateFeatureParameterService().getFeatureParameterModel();
    //     // return featureParamDateModel.toString(); // returns string of date?
    // }

    // public VMDL_HealthCheck getHealthCheckViewModel(){
    //     FeatureParameterDateModel featureParamDateModel = (FeatureParameterDateModel)this.locateFeatureParameterService().getFeatureParameterModel();

    //     String lastRunDate = featureParamDateModel.toString(); 
    //     Integer numberOfRuns = healthChecksToRunList.size();
    //     List<VMDL_HealthCheckDefinition> healthChecksToRunList = new List<VMDL_HealthCheckDefinition>();

    //     VMDL_HealthCheck healthCheckViewModel = new VMDL_HealthCheck(lastRunDate, numberOfRuns, healthChecksToRunList);

    //     return healthCheckViewModel;
    // }
}
