public virtual with sharing class HealthCheckGroupAPIServiceInterface {
    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static HealthCheckGroupAPIServiceInterface instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected HealthCheckGroupAPIServiceInterface() {}

    /*****************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of HealthCheckGroupAPIServiceInterface.
    ******************************************************************************/
    public static HealthCheckGroupAPIServiceInterface getInstance() {
        if (instance == NULL) {
            instance = new HealthCheckGroupAPIServiceInterface();
        }
        return instance;
    }

    /**
    * getHealthCheckGroup description
    * @param  name name description
    * @return      return description
    */
    public HealthCheckGroupVModel getHealthCheckGroup(String name){
        return new HealthCheckGroupVModel(name);
    }
