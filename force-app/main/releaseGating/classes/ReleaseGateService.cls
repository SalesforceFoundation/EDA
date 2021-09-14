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
 * @group EDA Settings
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description Service class to handle business logic associated with ReleaseGate
 */
public virtual with sharing class ReleaseGateService {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static ReleaseGateService instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected ReleaseGateService() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of ReleaseGateService.
     **********************************************************************************/
    public static ReleaseGateService getInstance() {
        if (instance != null) {
            return instance;
        }
        instance = new ReleaseGateService();
        return instance;
    }

    /************************************************************************************************************
     * @description Retrieve a GetReleaseGateActionResultModel representing the release gates from the specified
     * product registry name
     * @param  productRegistryName product registry developer name
     * @return A GetReleaseGateActionResultModel
     ************************************************************************************************************/
    public virtual GetReleaseGateActionResultModel getReleaseGateModel(String productRegistryName) {
        ProductRegistryModel productRegistry = this.getProductRegistryModel(productRegistryName);
        return this.locateReleaseGateAPIService(productRegistry).getReleaseGates();
    }

    /**
     * @description Activate a release gate
     * @param  productRegistryName Product registry name
     * @param  productName         Release gate product name
     * @param  gateName            Release gate name
     * @return                     An ActivateReleaseGateActionResultModel instance
     */
    public virtual ActivateReleaseGateActionResultModel activateReleaseGate(
        String productRegistryName,
        String productName,
        String gateName
    ) {
        ProductRegistryModel productRegistry = this.getProductRegistryModel(productRegistryName);
        return this.locateReleaseGateAPIService(productRegistry).activateReleaseGate(productName, gateName);
    }

    /**
     * @description returns ProductRegistryModel from a product registry name
     * @throws ReleaseGateAPIService.ReleaseGateProductNotFoundException if product registry doesn't exist
     * @param  productRegistryName product registry developer name
     * @return                     A ProductRegistryModel
     */
    private ProductRegistryModel getProductRegistryModel(String productRegistryName) {
        ProductRegistryModel productRegistry = this.locateProductRegistryService()
            .getProductRegistryModelByName(productRegistryName);
        if (productRegistry == null) {
            throw new ReleaseGateAPIService.ReleaseGateProductNotFoundException(
                String.format(Label.stgErrorSettingsProductInvalidClass, new List<Object>{ productRegistryName }),
                null,
                null
            );
        }
        return productRegistry;
    }

    /**
     * @description Creates a new ReleaseGateAPIService instance
     * @param  productRegistry product registry meta data
     * @return                 a ReleaseGateAPIService instance
     */
    @TestVisible
    protected virtual ReleaseGateAPIService locateReleaseGateAPIService(ProductRegistryModel productRegistry) {
        return new ReleaseGateAPIService(productRegistry);
    }

    /*****************************************************************************
     * @description Retrieve an instance of the ProductRegistryService class.
     * @return An instance of ProductRegistryService.
     *****************************************************************************/
    @TestVisible
    private ProductRegistryService locateProductRegistryService() {
        return ProductRegistryService.getInstance();
    }
}
