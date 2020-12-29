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
    * @description
    * @param  className className description
    * @param  namespace namespace description
    * @return           return description
    */
    public virtual HealthCheckGroupVModel getHealthCheckGroup(String name, String className, String namespace){
        HealthCheckGroupAPIServiceInterface hlthChkGroupServInterface = 
            this.locateHealthCheckGroupAPIService(className, namespace);

        return hlthChkGroupServInterface.getHealthCheckGroup(name);
    }

    /**
    * locateHealthCheckGroupAPIService description
    * @param  className className description
    * @param  namespace namespace description
    * @return           return description
    */
    @TestVisible
    private HealthCheckGroupAPIServiceInterface locateHealthCheckGroupAPIService(String className, String namespace){
        HealthCheckGroupAPIServiceInterface hlthChkGroupServInterface;
        String namespacedClassName = className;

        if (String.isNotBlank(namespace) && !namespace.equalsIgnoreCase('hed')){
            namespacedClassName = namespace + '.' + className;
        }

        try{
            Type healthCheckGroupType = Type.forName(namespacedClassName);
            hlthChkGroupServInterface = (HealthCheckGroupAPIServiceInterface)healthCheckGroupType.newInstance();
        } catch (System.NullPointerException e){
            throw new HealthCheckNotFoundException(e.getMessage());
        } catch (System.TypeException e){
            throw new HealthCheckNotFoundException(e.getMessage());
        }

        return hlthChkGroupServInterface.getInstance();
    }

    public class HealthCheckNotFoundException extends Exception{}
}
