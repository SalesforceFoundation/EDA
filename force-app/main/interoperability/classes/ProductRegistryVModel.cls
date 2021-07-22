public virtual class ProductRegistryVModel {
    @AuraEnabled
    public String action { get; private set; }
    @AuraEnabled
    public String namespace { get; private set; }
    @AuraEnabled
    public String classname { get; private set; }
    @AuraEnabled
    public Decimal apiVersion { get; private set; }

    public ProductRegistryVModel(String action, String namespace, String classname, Decimal apiVersion) {
        this.action = action;
        this.namespace = namespace;
        this.classname = classname;
        this.apiVersion = apiVersion;
    }
}
