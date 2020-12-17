public virtual with sharing class HealthCheckGroupService {
    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static HealthCheckGroupService instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected HealthCheckGroupService() {}

    /******************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of HealthCheckGroupService.
    ******************************************************************************/
    public static HealthCheckGroupService getInstance() {

        if (instance == null) {
            instance = new HealthCheckGroupService();
        }

        return instance;
    }

    /**
    * getHealthCheckGroup description
    * @param  className className description
    * @param  namespace namespace description
    * @return           return description
    */
    public HealthCheckGroupVModel getHealthCheckGroup(String name, String className, String namespace){
        return this.locateHealthCheckGroupAPIService(className, namespace).getHealthCheckGroup(name);
    }

    private HealthCheckGroupAPIServiceInterface locateHealthCheckGroupAPIService(String className, String namespace){
        if (className.equalsIgnoreCase('EDAHealthCheckGroupAPIService') && namespace.equalsIgnoreCase('hed')){
            return EDAHealthCheckGroupAPIService.getInstance();
        }

        throw new HealthCheckNotFoundException('Health Check not found for className ' + className + ' and namespace ' + namespace);
    }

    public class HealthCheckNotFoundException extends Exception{}
}
