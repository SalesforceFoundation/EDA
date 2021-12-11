public with sharing class Meta {
    // TODO: componentNamespace potentially not needed -- componentName seems to already include the namespace, if there is one
    public String componentNamespace;
    public String componentName;
    public String componentType;

    public Meta(String namespace, String name, String type) {
        this.componentNamespace = namespace != null ? namespace : '';
        this.componentName = name != null ? name : '';
        this.componentType = type;
    }

    public String toKey() {
        return this.componentType + ': ' + this.componentName;//this.componentNamespace + this.componentName;
    }
}
