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
 * @description Service class which returns the list of ProductRegistryModel
 */
public virtual with sharing class ProductRegistryService {
    @TestVisible
    private static ProductRegistryService instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected ProductRegistryService() {
    }

    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    public static ProductRegistryService getInstance() {
        if (instance == null) {
            instance = new ProductRegistryService();
        }

        return instance;
    }

    /**********************************************************************************
     * @description Returns the list of ProductRegistryModel
     **********************************************************************************/
    public virtual List<ProductRegistryModel> getProductRegistrySettingsProductInformation() {
        return this.locateProductRegistryMapper().getProductRegistrySettingsProductInformation();
    }

    /**********************************************************************************
     * @description Returns the list of release gates
     **********************************************************************************/
    public virtual List<ProductRegistryModel> getProductRegistryReleaseGates() {
        return this.locateProductRegistryMapper().getProductRegistryReleaseGates();
    }

    /********************************************************************************************
     * @description Returns the ProductRegistryModel instance with the specified name
     * @param  developerName product registry developer name
     * @return   A list of ProductRegistryModel with all its properties populated
     ********************************************************************************************/
    public virtual ProductRegistryModel getProductRegistryModelByName(String developerName) {
        return this.locateProductRegistryMapper().getProductRegistryModelByName(developerName);
    }

    /**********************************************************************************
     * @description Locates and returns an instance of ProductRegistryMapper.
     **********************************************************************************/
    private ProductRegistryMapper locateProductRegistryMapper() {
        return ProductRegistryMapper.getInstance();
    }
}
