/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
    its contributors may be used to endorse or promote products derived
    from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
 * @author Salesforce.org
 * @date 2021
 * @group
 * @group-content
 * @description Mapper class to transform ProductRegistryModel into ProductRegistryVModel
 */
public virtual with sharing class ProductRegistryVMapper {
    @TestVisible
    private static ProductRegistryVMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected ProductRegistryVMapper() {
    }

    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    public static ProductRegistryVMapper getInstance() {
        if (instance == null) {
            instance = new ProductRegistryVMapper();
        }

        return instance;
    }

    /********************************************************************************************
     * @description Returns the list of release gates ProductRegistryVModel based on the list of ProductRegistryModel
     * @return   A list of release gates ProductRegistryVModel with all its properties populated
     ********************************************************************************************/
    public virtual List<ProductRegistryVModel> getProductRegistryReleaseGates() {
        List<ProductRegistryModel> productRegistryModelList = this.locateProductRegistryService()
            .getProductRegistryReleaseGates();
        return this.getProductRegistryVModelList(productRegistryModelList);
    }

    /********************************************************************************************
     * @description Returns the list of ProductRegistryVModel based on the list of ProductRegistryModel
     * @return   A list of ProductRegistryVModel with all its properties populated
     ********************************************************************************************/
    public virtual List<ProductRegistryVModel> getProductRegistrySettingsProductInformation() {
        List<ProductRegistryModel> productRegistryModelList = this.locateProductRegistryService()
            .getProductRegistrySettingsProductInformation();
        return this.getProductRegistryVModelList(productRegistryModelList);
    }

    /**
     * @description Maps a List<ProductRegistryModel> to List<ProductRegistryVModel>
     * @param  productRegistryModelList A list of ProductRegistryModel items
     * @return                          A list of ProductRegistryVModel items
     */
    private List<ProductRegistryVModel> getProductRegistryVModelList(
        List<ProductRegistryModel> productRegistryModelList
    ) {
        List<ProductRegistryVModel> productRegistryVModelList = new List<ProductRegistryVModel>();
        if (productRegistryModelList == null) {
            return null;
        }

        for (ProductRegistryModel prodRegistryModel : productRegistryModelList) {
            ProductRegistryVModel prodRegistryVModel = new ProductRegistryVModel(
                prodRegistryModel.name,
                prodRegistryModel.action,
                prodRegistryModel.namespace,
                prodRegistryModel.classname,
                prodRegistryModel.apiVersion
            );
            productRegistryVModelList.add(prodRegistryVModel);
        }

        return productRegistryVModelList;
    }

    /**********************************************************************************
     * @description Locates and returns an instance of ProductRegistryService.
     **********************************************************************************/
    @TestVisible
    private ProductRegistryService locateProductRegistryService() {
        return ProductRegistryService.getInstance();
    }
}
