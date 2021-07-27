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
 * @description Mapper class for retrieving the EDCSettingsProductVModel based on the productRegistry parameter
 */
public virtual with sharing class EDCSettingsProductVMapper {
    @TestVisible
    private static EDCSettingsProductVMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected EDCSettingsProductVMapper() {
    }

    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    public static EDCSettingsProductVMapper getInstance() {
        if (instance == null) {
            instance = new EDCSettingsProductVMapper();
        }

        return instance;
    }

    /********************************************************************************************
     * @description Returns an EDCSettingsProductVModel based on the information from an
     * EDCSettingsProductAPIModel.SettingsProductInformationResult for an specific product registry
     * @param  productRegistry A string representing the serialized product registry information
     * @return An instance of EDCSettingsProductVModel with all its properties populated
     ********************************************************************************************/
    public virtual EDCSettingsProductVModel getEDCSettingsProductVModel(String productRegistry) {
        ProductRegistryVModel prodRegistryVModel = (ProductRegistryVModel) JSON.deserialize(
            productRegistry,
            ProductRegistryVModel.class
        );

        EDCSettingsProductAPIModel.SettingsProductInformationResult productInformationResult = this.getSettingsProductInformation(
            prodRegistryVModel.classname,
            prodRegistryVModel.namespace,
            prodRegistryVModel.apiVersion
        );

        EDCSettingsProductVModel settingsProductVModel;

        if (productInformationResult != null) {
            String navigationPrefix = this.getEDAComponentNavigationPrefix();
            settingsProductVModel = new EDCSettingsProductVModel(
                productInformationResult.productInformation.initials,
                productInformationResult.productInformation.name,
                productInformationResult.productInformation.description,
                navigationPrefix + productInformationResult.productInformation.settingsComponent,
                productInformationResult.productInformation.documentationUrl,
                productInformationResult.productInformation.trailheadUrl,
                productInformationResult.productInformation.icon
            );
        }

        return settingsProductVModel;
    }

    /********************************************************************************************
     * @description Returns an EDCSettingsProductAPIModel.SettingsProductInformationResult based on an
     * EDCSettingsProductAPIModel.SettingsProductInformationActionResult, if the SettingsProductInformationActionResult
     * is successful, then it returns the SettingsProductInformationResult, otherwise it throws a SettingsProductException
     * @param  className  A string representing the classname to call
     * @param  namespace  A string representing the the product namespace
     * @param  apiVersion A decimal representing the specific api version to use
     * @return A EDCSettingsProductAPIModel.SettingsProductInformationResult with all its values populated
     ********************************************************************************************/
    private virtual EDCSettingsProductAPIModel.SettingsProductInformationResult getSettingsProductInformation(
        String className,
        String namespace,
        Decimal apiVersion
    ) {
        EDCSettingsProductAPIModel.SettingsProductInformationActionResult settingsProductInformationActionResult = this.locateSettingsProductAPIService()
            .getSettingsProductInformation(className, namespace, apiVersion);

        EDCSettingsProductAPIModel.SettingsProductInformationResult result;

        if (settingsProductInformationActionResult != null) {
            if (settingsProductInformationActionResult.success) {
                result = settingsProductInformationActionResult.result;
            } else {
                throw new SettingsProductException(settingsProductInformationActionResult.error.message);
            }
        }
        return result;
    }

    /**********************************************************************************
     * @description Locates and returns an instance of EDCSettingsProductAPIService
     **********************************************************************************/
    @TestVisible
    private EDCSettingsProductAPIService locateSettingsProductAPIService() {
        return EDCSettingsProductAPIService.getInstance();
    }

    /**********************************************************************************
     * @description Returns a string representing the prefix needed for the settings component
     **********************************************************************************/
    private virtual String getEDAComponentNavigationPrefix() {
        String courseOfferingName = Course_Offering_Schedule__c.Course_Offering__c.getDescribe().getName();
        String navigationPrefix = courseOfferingName.replace('Course_Offering__c', '');
        String prefix;

        if (String.isBlank(navigationPrefix)) {
            navigationPrefix = 'c__';
        }

        return navigationPrefix;
    }

    public class SettingsProductException extends Exception {
    }
}
