public with sharing class CMP_SettingsDataProvider {
    /*******************************************************************************************************
    * @description Returns a list of results for use in the autocomplete component
    * @return List<ProviderResult>
    */
    @AuraEnabled
    public static List<ProviderResult> getAutocompleteResults(String sObjectType, String term) {
        List<ProviderResult> providerResults = new List<ProviderResult>();
        try {
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Boolean objectAccessible = false;
            Boolean nameFieldAccessible = false;
            if (gd.containsKey(sObjectType) && gd.get(sObjectType).getDescribe().fields.getMap().containsKey('Name')) {
                Map<String, SObjectField> fields = gd.get(sObjectType).getDescribe().fields.getMap();
                DescribeFieldResult fieldDescribe = fields.get('Name').getDescribe();
                objectAccessible = gd.get(sObjectType).getDescribe().isAccessible();
                nameFieldAccessible = fields.get('Name').getDescribe().isAccessible();
            }

            if (!objectAccessible || !nameFieldAccessible) {
                return new List<ProviderResult>();
            }

            // '%', '_', and '\' all are special characters in LIKE syntax.
            // We escape them here by prepending those characters with a backslash
            String preparedTerm = '%' + term.replaceAll('([%_\\\\])', '\\\\$0') + '%';
            String soql = 'SELECT Name FROM {0} WHERE Name LIKE :preparedTerm ORDER BY Name LIMIT 10';
            String query = String.format(soql, new List<String>{sObjectType});
            List<SObject> results = Database.query(query);

            for (SObject so : results) {
                ProviderResult result = new ProviderResult();
                result.value = so.Id;
                result.label = (String) so.get('Name');
                providerResults.add(result);
            }

            return providerResults;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*******************************************************************************************************
    * @description helper class that holds the display string and sobject to return to the
    * autocomplete lightning component
    */
    public class ProviderResult {
        @AuraEnabled
        public String label;

        @AuraEnabled
        public Id value;
    }
}