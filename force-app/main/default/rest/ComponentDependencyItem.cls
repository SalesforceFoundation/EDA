public with sharing class ComponentDependencyItem {
    public String metadataComponentId;
    public String metadataComponentName;
    public String metadataComponentNamespace;
    public String metadataComponentType;
    public String refMetadataComponentId;
    public String refMetadataComponentName;
    public String refMetadataComponentNamespace;
    public String refMetadataComponentType;
    public ComponentDependencyItem(
        String componentId,
        String componentName,
        String componentNamespace,
        String componentType,
        String refComponentId,
        String refcomponentName,
        String refComponentNamespace,
        String refComponentType
    ) {
        this.metadataComponentId = componentId;
        this.metadataComponentName = componentName;
        this.metadataComponentNamespace = componentNamespace;
        this.metadataComponentType = componentType;
        this.refMetadataComponentId = refComponentId;
        this.refMetadataComponentName = refComponentName;
        this.refMetadataComponentNamespace = refComponentNamespace;
        this.refMetadataComponentType = refComponentType;
    }
    public String getMetadataComponentId() {
        return this.metadataComponentId;
    }
    public String getMetadataComponentName() {
        return this.metadataComponentName;
    }
    public String getMetadataComponentNamespace() {
        return this.metadataComponentNamespace;
    }
    public String getMetadataComponentType() {
        return this.metadataComponentType;
    }
    public String getRefMetadataComponentId() {
        return this.refMetadataComponentId;
    }
    public String getRefMetadataComponentName() {
        return this.refMetadataComponentName;
    }
    public String getRefMetadataComponentNamespace() {
        return this.refMetadataComponentNamespace;
    }
    public String getRefMetadataComponentType() {
        return this.refMetadataComponentType;
    }
}
