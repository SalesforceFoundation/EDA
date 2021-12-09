public with sharing class ComponentDependency {
    public Integer size { get; set; }
    public Integer totalSize { get; set; }
    public Boolean done { get; set; }
    public Object queryLocator { get; set; }
    public String entityTypeName { get; set; }
    public List<Record> records { get; set; }
    public class Record {
        public Attributes attributes { get; set; }
        public String MetadataComponentId { get; set; }
        public String MetadataComponentName { get; set; }
        public String MetadataComponentNamespace { get; set; }
        public String MetadataComponentType { get; set; }
        public String RefMetadataComponentId { get; set; }
        public String RefMetadataComponentName { get; set; }
        public String RefMetadataComponentNamespace { get; set; }
        public String RefMetadataComponentType { get; set; }
    }
    public class Attributes {
        public String type_Z { get; set; }
        public String url { get; set; }
    }
    public static ComponentDependency parse(String json) {
        return (ComponentDependency) System.JSON.deserialize(json, ComponentDependency.class);
    }
}
