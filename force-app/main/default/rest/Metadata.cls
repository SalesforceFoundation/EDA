public with sharing class Metadata {
    public String refMetadataComponentId;
    public String refMetadataComponentName;
    public String refMetadataComponentType;
    public String refMetadataComponentNamespace;
    public String metadataComponentId;
    public String metadataComponentName;
    public String metadataComponentType;
    public String metadataComponentNamespace;

    public Metadata(String rId, String rName, String rType, String cId, String cName, String cType) {
        this.refMetadataComponentId = rId;
        this.refMetadataComponentName = rName;
        this.refMetadataComponentType = rType;
        this.refMetadataComponentNamespace = null;
        this.metadataComponentId = cId;
        this.metadataComponentName = cName;
        this.metadataComponentType = cType;
        this.metadataComponentNamespace = null;
    }
}
