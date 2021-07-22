public virtual with sharing class ProductRegistryService {
    @TestVisible
    private static ProductRegistryService instance;

    protected ProductRegistryService() {
    }

    public static ProductRegistryService getInstance() {
        if (instance == null) {
            instance = new ProductRegistryService();
        }

        return instance;
    }

    public List<ProductRegistryModel> getProductRegistrySettingsProductInformation() {
        return this.locateProductRegistryMapper().getProductRegistrySettingsProductInformation();
    }

    @TestVisible
    private ProductRegistryMapper locateProductRegistryMapper() {
        return ProductRegistryMapper.getInstance();
    }
}
