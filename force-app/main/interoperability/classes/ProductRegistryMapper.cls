public virtual with sharing class ProductRegistryMapper {
    public static final string PRODUCT_INFORMATION_ACTION = 'Settings Product Information';

    @TestVisible
    private static ProductRegistryMapper instance;

    protected ProductRegistryMapper() {
    }

    public static ProductRegistryMapper getInstance() {
        if (instance == null) {
            instance = new ProductRegistryMapper();
        }

        return instance;
    }

    public List<ProductRegistryModel> getProductRegistrySettingsProductInformation() {
        List<ProductRegistryModel> productRegistryModelList = new List<ProductRegistryModel>();
        List<Product_Registry__mdt> productRegistrySettingsProductInformationList = this.getProductRegistriesByAction(
            PRODUCT_INFORMATION_ACTION
        );

        if (productRegistrySettingsProductInformationList != null) {
            for (Product_Registry__mdt productRegistry : productRegistrySettingsProductInformationList) {
                ProductRegistryModel prodRegistryModel = new ProductRegistryModel(
                    productRegistry.Action__c,
                    productRegistry.Namespace__c,
                    productRegistry.Class_Name__c,
                    productRegistry.API_Version__c
                );
                productRegistryModelList.add(prodRegistryModel);
            }
        }
        return productRegistryModelList;
    }

    private List<Product_Registry__mdt> getProductRegistriesByAction(String action) {
        List<Product_Registry__mdt> registriesList = [
            SELECT Action__c, API_Version__c, Class_Name__c, Enabled__c, Namespace__c
            FROM Product_Registry__mdt
            WHERE Action__c = :action AND Enabled__c = TRUE
        ];
        return registriesList;
    }
}
