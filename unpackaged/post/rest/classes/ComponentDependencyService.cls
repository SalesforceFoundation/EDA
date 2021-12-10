public with sharing class ComponentDependencyService {
    public ComponentDependencyService() {
    }
    public List<ComponentDependencyItem> getComponentDependency() {
        string theQuery =
            'SELECT MetadataComponentId, ' +
            'MetadataComponentName, ' +
            'MetadataComponentNamespace, ' +
            'MetadataComponentType, ' +
            'RefMetadataComponentId, ' +
            'RefMetadataComponentName, ' +
            'RefMetadataComponentNamespace, ' +
            'RefMetadataComponentType ' +
            'FROM MetadataComponentDependency limit 750';
        String responseStr = queryComponentDependency(theQuery);
        system.debug('***** res' + responseStr);
        if (string.isNotBlank(responseStr)) {
            ComponentDependency cd = ComponentDependency.parse(responseStr);
            List<ComponentDependencyItem> cdItems = new List<ComponentDependencyItem>();
            for (ComponentDependency.Record record : cd.records) {
                ComponentDependencyItem theItem = new ComponentDependencyItem(
                    record.MetadataComponentId,
                    record.MetadataComponentName,
                    record.MetadataComponentNamespace,
                    record.MetadataComponentType,
                    record.RefMetadataComponentId,
                    record.RefMetadataComponentName,
                    record.RefMetadataComponentNamespace,
                    record.RefMetadataComponentType
                );
                cdItems.add(theItem);
                system.debug('***** item' + theItem);
            }
            system.debug('***** items' + cdItems);
            return cdItems;
        } else {
            system.debug('***** blank response');
            return new List<ComponentDependencyItem>();
        }
    }
    public String queryComponentDependency(string theQuery) {
        String baseURL = 'callout:ToolNC?';
        return componentDependencyRest(baseURL + 'q=' + (theQuery.replace(' ', '+')), 'GET');
    }
    public String componentDependencyRest(String endPoint, String method) {
        try {
            Http h = new Http();
            HttpRequest theRequest = new HttpRequest();
            theRequest.setTimeout(10000);
            theRequest.setEndpoint(endPoint);
            theRequest.setMethod(method);
            HttpResponse theResponse = h.send(theRequest);
            return theResponse.getBody();
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
}
