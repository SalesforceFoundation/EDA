public virtual class ProductRegistryModel {
    public String action { get; private set; }
    public String namespace { get; private set; }
    public String classname { get; private set; }
    public Decimal apiVersion { get; private set; }

    public ProductRegistryModel(String action, String namespace, String classname, Decimal apiVersion) {
        this.action = action;
        this.namespace = namespace;
        this.classname = classname;
        this.apiVersion = apiVersion;
    }
}
