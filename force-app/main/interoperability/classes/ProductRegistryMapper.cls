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
 * @description Mapper class to transform Product_Registry__mdt into ProductRegistryModel
 */
public virtual with sharing class ProductRegistryMapper {
    public static final string SETTINGS_INFORMATION_ACTION = 'Settings Product Information';
    public static final string RELEASE_GATING_ACTION = 'Release Gating';

    @TestVisible
    private static ProductRegistryMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected ProductRegistryMapper() {
    }

    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    public static ProductRegistryMapper getInstance() {
        if (instance == null) {
            instance = new ProductRegistryMapper();
        }

        return instance;
    }

    /********************************************************************************************
     * @description Returns the list of ProductRegistryModel based on the release gating Product Registries
     * @return   A list of ProductRegistryModel with all its properties populated
     ********************************************************************************************/
    public virtual List<ProductRegistryModel> getProductRegistryReleaseGates() {
        List<Product_Registry__mdt> productRegistryReleaseGatingList = this.getProductRegistriesByAction(
            RELEASE_GATING_ACTION
        );
        return this.mapProductRegistryModelList(productRegistryReleaseGatingList);
    }

    /********************************************************************************************
     * @description Returns the list of ProductRegistryModel based on the Product Registries loaded by DB
     * @return   A list of ProductRegistryModel with all its properties populated
     ********************************************************************************************/
    public virtual List<ProductRegistryModel> getProductRegistrySettingsProductInformation() {
        List<Product_Registry__mdt> productRegistrySettingsProductInformationList = this.getProductRegistriesByAction(
            SETTINGS_INFORMATION_ACTION
        );
        return this.mapProductRegistryModelList(productRegistrySettingsProductInformationList);
    }

    /********************************************************************************************
     * @description Returns the ProductRegistryModel instance with the specified name
     * @param  developerName product registry developer name
     * @return   A list of ProductRegistryModel with all its properties populated
     ********************************************************************************************/
    public virtual ProductRegistryModel getProductRegistryModelByName(String developerName) {
        return this.mapProductRegistryModel(this.getProductRegistryByName(developerName));
    }

    /**
     * @description Returns the list of ProductRegistryModel based on the list of Product Registry mdt
     * @param  productRegistryList list of Product Registry mdt
     * @return                     A list of ProductRegistryModel with all its properties populated
     */
    @TestVisible
    private List<ProductRegistryModel> mapProductRegistryModelList(List<Product_Registry__mdt> productRegistryList) {
        if (productRegistryList == null) {
            return null;
        }
        List<ProductRegistryModel> productRegistryModelList = new List<ProductRegistryModel>();

        for (Product_Registry__mdt productRegistry : productRegistryList) {
            productRegistryModelList.add(this.mapProductRegistryModel(productRegistry));
        }
        return productRegistryModelList;
    }

    /**
     * @description Creates a ProductRegistryModel instance from Product_Registry__mdt instance
     * @param  productRegistry Product_Registry__mdt instance to map
     * @return                 a ProductRegistryModel instance
     */
    private ProductRegistryModel mapProductRegistryModel(Product_Registry__mdt productRegistry) {
        if (productRegistry == null) {
            return null;
        }
        return new ProductRegistryModel(
            productRegistry.DeveloperName,
            productRegistry.Action__c,
            productRegistry.Namespace__c,
            productRegistry.Class_Name__c,
            productRegistry.API_Version__c
        );
    }

    /********************************************************************************************
     * @description Retrieves the list of Product_Registry__mdt where the record is enabled and the action patches
     * the provided parameter
     * @param  action A string representing the action or category to retrieve
     * @return        A list of Product_Registry__mdt retrieved from DB
     ********************************************************************************************/
    @TestVisible
    private virtual List<Product_Registry__mdt> getProductRegistriesByAction(String action) {
        List<Product_Registry__mdt> registriesList = [
            SELECT DeveloperName, Label, Action__c, API_Version__c, Class_Name__c, Enabled__c, Namespace__c
            FROM Product_Registry__mdt
            WHERE Action__c = :action AND Enabled__c = TRUE
            ORDER BY Label ASC
        ];
        return registriesList;
    }

    /********************************************************************************************
     * @description Retrieves the enabled Product_Registry__mdt record by name
     * @param  developerName A record's developer name
     * @return               A Product_Registry__mdt record retrieved from DB
     ********************************************************************************************/
    @TestVisible
    private Product_Registry__mdt getProductRegistryByName(String developerName) {
        List<Product_Registry__mdt> registriesList = [
            SELECT DeveloperName, Action__c, API_Version__c, Class_Name__c, Enabled__c, Namespace__c
            FROM Product_Registry__mdt
            WHERE DeveloperName = :developerName AND Enabled__c = TRUE
        ];
        return registriesList.isEmpty() ? null : registriesList[0];
    }
}
