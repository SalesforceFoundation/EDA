public virtual with sharing class HealthCheckVMapper {
    
    /**********************************************************************************
    * @description Instance for Singleton Pattern
    **********************************************************************************/
    @TestVisible
    private static HealthCheckVMapper instance;

    /**********************************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************************/
    protected HealthCheckVMapper() {}

    /**********************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of HealthCheckVMapper.
    **********************************************************************************/
    public static HealthCheckVMapper getInstance() {
        if (instance == null) {
            instance = new HealthCheckVMapper();
        }

        return instance;
    }

    /**********************************************************************************
    * @description Locates and returns an instance of the FeatureParameterService Service
    **********************************************************************************/
    private FeatureParameterService locateFeatureParameterService() {
        return FeatureParameterService.getInstance();
    }

    /**********************************************************************************
    * @description Locates and returns an instance of the HealthCheckDefinitionService Service
    **********************************************************************************/
    // private HealthCheckDefinitionService locateHealthCheckDefinitionService() {
    //     return HealthCheckDefinitionService.getInstance();
    // }

    /**********************************************************************************
    * @description Retrieves the current date associated with a feature model.
    * @return A string representing the current date.
    **********************************************************************************/
    public String updateHealthCheckLastRunDate(){
        FeatureParameterModel featureParamDateModel = (FeatureParameterDateModel)this.locateFeatureParameterService().getFeatureParameterModel();
        return featureParamDateModel.convertToString(); 
    }

    /**********************************************************************************
    * getHealthCheckViewModel description
    * @return   return description
    **********************************************************************************/
    public HealthCheckVModel getHealthCheckViewModel(){
        FeatureParameterDateModel featureParamDateModel = (FeatureParameterDateModel)this.locateFeatureParameterService().getFeatureParameterModel();
        String lastRunDate = featureParamDateModel.convertToString(); 
        // List<HealthCheckDefinitionVModel> healthCheckDefinitionList = this.locateHealthCheckDefinitionService().getHealthCheckDefinitionModels();
        // Integer numberOfRuns = healthCheckDefinitionList.size();


        // TODO: delete the next 2 lines when HealtCheckDefinition Service is complete
        List<HealthCheckDefinitionVModel> healthCheckDefinitionList = new List<HealthCheckDefinitionVModel>();
        Integer numberOfRuns = 5;

        return new HealthCheckVModel(lastRunDate, numberOfRuns, healthCheckDefinitionList);
    }
}
