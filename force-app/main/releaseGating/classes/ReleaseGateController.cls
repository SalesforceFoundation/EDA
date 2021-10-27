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
 * @description Apex controller for ReleaseGate.
 */
public with sharing class ReleaseGateController {
    /********************************************************************************************
     * @description Returns the list of release gates ProductRegistryVModel based on the Product Registry CMT records
     * @return A list of ProductRegistryVModel with all the properties populated
     ********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<ProductRegistryVModel> getProductRegistryReleaseGateVModels() {
        try {
            return ReleaseGateController.locateProductRegistryVMapper().getProductRegistryReleaseGates();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************
     * @description Retrieve a list of ReleaseGateVModel from the specified productRegistryName
     * @param  productRegistryName product registry developer name
     * @return A list of ReleaseGateVModel instances
     ************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<ReleaseGateVModel> getReleaseGateVModel(String productRegistryName) {
        try {
            return ReleaseGateController.locateReleaseGateVMapper().getReleaseGateVModel(productRegistryName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Activate a release gate
     * @param  productRegistryName Product registry name
     * @param  productName         Release gate product name
     * @param  gateName            Release gate name
     * @return                     A list of ActivateReleaseGateVModel instances
     */
    @AuraEnabled
    public static List<ActivateReleaseGateVModel> activateReleaseGate(
        String productRegistryName,
        String productName,
        String gateName
    ) {
        try {
            return ReleaseGateController.locateReleaseGateVMapper()
                .activateReleaseGate(productRegistryName, productName, gateName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************************
     * @description Retrieve an instance of the ReleaseGateService class.
     * @return An instance of ReleaseGateService.
     *****************************************************************************/
    @TestVisible
    private static ReleaseGateService locateReleaseGateService() {
        return ReleaseGateService.getInstance();
    }

    /**********************************************************************************
     * @description Locates and returns an instance of ReleaseGateVMapper.
     * @return An instance of ReleaseGateVMapper
     **********************************************************************************/
    @TestVisible
    private static ReleaseGateVMapper locateReleaseGateVMapper() {
        return ReleaseGateVMapper.getInstance();
    }

    /**********************************************************************************
     * @description Locates and returns an instance of ProductRegistryVMapper.
     **********************************************************************************/
    private static ProductRegistryVMapper locateProductRegistryVMapper() {
        return ProductRegistryVMapper.getInstance();
    }
}
