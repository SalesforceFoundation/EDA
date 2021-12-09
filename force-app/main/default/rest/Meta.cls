public with sharing class Meta {
    public String componentNamespace;
    public String componentName;
    public String componentType;

    public Meta(String namespace, String name, String type) {
        this.componentNamespace = namespace != null ? namespace : '';
        this.componentName = name != null ? name : '';
        this.componentType = type;
    }

    public String toKey() {
        return this.componentType + ': ' + this.componentNamespace + this.componentName;
    }
}
