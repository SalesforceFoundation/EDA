public virtual with sharing class ProductRegistryVMapper {
    @TestVisible
    private static ProductRegistryVMapper instance;

    protected ProductRegistryVMapper() {
    }

    public static ProductRegistryVMapper getInstance() {
        if (instance == null) {
            instance = new ProductRegistryVMapper();
        }

        return instance;
    }

    public virtual List<ProductRegistryVModel> getProductRegistrySettingsProductInformation() {
        List<ProductRegistryVModel> productRegistryVModelList = new List<ProductRegistryVModel>();
        List<ProductRegistryModel> productRegistryModelList = new List<ProductRegistryModel>();

        productRegistryModelList = this.locateProductRegistryService().getProductRegistrySettingsProductInformation();

        if (productRegistryModelList != null && !productRegistryModelList.isEmpty()) {
            for (ProductRegistryModel prodRegistryModel : productRegistryModelList) {
                ProductRegistryVModel prodRegistryVModel = new ProductRegistryVModel(
                    prodRegistryModel.action,
                    prodRegistryModel.namespace,
                    prodRegistryModel.classname,
                    prodRegistryModel.apiVersion
                );
                productRegistryVModelList.add(prodRegistryVModel);
            }
        }

        return productRegistryVModelList;
    }

    @TestVisible
    private ProductRegistryService locateProductRegistryService() {
        return ProductRegistryService.getInstance();
    }
}
