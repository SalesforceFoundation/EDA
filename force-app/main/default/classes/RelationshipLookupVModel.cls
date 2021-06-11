public with sharing class RelationshipLookupVModel {
    @AuraEnabled
    public String name { get; private set; }

    @AuraEnabled
    public String femaleValue { get; private set; }

    @AuraEnabled
    public String maleValue { get; private set; }

    @AuraEnabled
    public String neutralValue { get; private set; }

    @AuraEnabled
    public Boolean isActive { get; private set; }

    /**
     * @description Constructor to assign values to the properties
     * @param  name         reciprocal relationship mapping name
     * @param  femaleValue  female gender value
     * @param  maleValue    male gender value
     * @param  neutralValue neutral gender value
     * @param  isActive     is lookup active
     */
    public RelationshipLookupVModel(
        String name,
        String femaleValue,
        String maleValue,
        String neutralValue,
        Boolean isActive
    ) {
        this.name = name;
        this.femaleValue = femaleValue;
        this.maleValue = maleValue;
        this.neutralValue = neutralValue;
        this.isActive = isActive;
    }
}
