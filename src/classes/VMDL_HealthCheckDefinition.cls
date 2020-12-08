public with sharing class VMDL_HealthCheckDefinition implements Comparable {

    @AuraEnabled 
    public String name { get; private set; }

    @AuraEnabled 
    public String className { get; private set; }

    @AuraEnabled 
    public String namespace { get; private set; }

    public VMDL_HealthCheckDefinition(String name, String className, String namespace) {
        this.name = name;
        this.className = className;
        this.namespace = namespace;
    }

    /**
    * @description Implementation of compareTo() to sort VMDL_HealthCheckDefinitions by name.
    * @param  objectToCompareTo A VMDL_HealthCheckDefinition to be used for comparison
    * @return 0 if names are equal, 1 if the current name is greater, -1 otherwise
    */ 
    public Integer compareTo(Object objectToCompareTo){
        VMDL_HealthCheckDefinition healthCheckDefToCompareTo = (VMDL_HealthCheckDefinition)objectToCompareTo;
        
        if (this.name == healthCheckDefToCompareTo.name){
            return 0;
        }

        if (this.name > healthCheckDefToCompareTo.name){
            return 1;
        }

        return -1;
    } 
}
