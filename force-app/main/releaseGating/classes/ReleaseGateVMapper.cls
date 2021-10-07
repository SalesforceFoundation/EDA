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
 * @description View mapper to generate view models associated with ReleaseGate
 */
public virtual with sharing class ReleaseGateVMapper {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static ReleaseGateVMapper instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected ReleaseGateVMapper() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of ReleaseGateVMapper.
     **********************************************************************************/
    public static ReleaseGateVMapper getInstance() {
        if (instance != null) {
            return instance;
        }
        instance = new ReleaseGateVMapper();
        return instance;
    }

    /**********************************************************************************************************
     * @description Retrieves a list of ReleaseGateVModel for the specified product registry
     * @param  productRegistryName product registry developer name
     * @return A list of ReleaseGateVModel
     *********************************************************************************************************/
    public virtual List<ReleaseGateVModel> getReleaseGateVModel(String productRegistryName) {
        GetReleaseGateActionResultModel releaseGateModel = locateReleaseGateService()
            .getReleaseGateModel(productRegistryName);
        this.verifyCallableResult(releaseGateModel);
        return this.mapReleaseGateVModel(releaseGateModel);
    }

    /**
     * @description Activate a release gate
     * @param  productRegistryName Product registry name
     * @param  productName         Release gate product name
     * @param  gateName            Release gate name
     * @return                     A list of ActivateReleaseGateVModel instances
     */
    public virtual List<ActivateReleaseGateVModel> activateReleaseGate(
        String productRegistryName,
        String productName,
        String gateName
    ) {
        List<ActivateReleaseGateVModel> activateReleaseGateVModelList = new List<ActivateReleaseGateVModel>();
        ActivateReleaseGateActionResultModel activateModel = locateReleaseGateService()
            .activateReleaseGate(productRegistryName, productName, gateName);
        this.verifyCallableResult(activateModel);
        for (ActivateReleaseGateActionResultModel.ActivateReleaseGateResult activateResult : activateModel.result) {
            activateReleaseGateVModelList.add(
                new ActivateReleaseGateVModel(
                    activateResult.productName,
                    activateResult.gateName,
                    activateResult.status
                )
            );
        }
        return activateReleaseGateVModelList;
    }

    /**
     * @description maps GetReleaseGateActionResultModel to List<ReleaseGateVModel>
     * @param  getReleaseGateModel source GetReleaseGateActionResultModel instance
     * @return                     a list of ReleaseGateVModel instances
     */
    protected virtual List<ReleaseGateVModel> mapReleaseGateVModel(
        GetReleaseGateActionResultModel getReleaseGateModel
    ) {
        List<ReleaseGateVModel> releaseGateVModelList = new List<ReleaseGateVModel>();
        for (GetReleaseGateActionResultModel.GetReleaseGateResult releaseGateResult : getReleaseGateModel.result) {
            ReleaseGateVModel.ReleaseGateProduct releaseProduct = new ReleaseGateVModel.ReleaseGateProduct(
                releaseGateResult.product.name,
                releaseGateResult.product.label,
                releaseGateResult.product.nextReleaseDate
            );
            releaseGateVModelList.add(
                new ReleaseGateVModel(releaseProduct, this.mapReleaseGateList(releaseGateResult.gates))
            );
        }
        return releaseGateVModelList;
    }

    private List<ReleaseGateVModel.ReleaseGate> mapReleaseGateList(
        List<GetReleaseGateActionResultModel.ReleaseGate> releaseGateModelList
    ) {
        List<ReleaseGateVModel.ReleaseGate> releaseGateVModelList = new List<ReleaseGateVModel.ReleaseGate>();
        for (GetReleaseGateActionResultModel.ReleaseGate releaseGate : releaseGateModelList) {
            releaseGateVModelList.add(
                new ReleaseGateVModel.ReleaseGate(
                    releaseGate.name,
                    releaseGate.label,
                    releaseGate.description,
                    releaseGate.releaseDate,
                    releaseGate.dueDate,
                    releaseGate.dueDateInfoText,
                    releaseGate.activationDate,
                    releaseGate.status,
                    this.mapReleaseGateFeatureList(releaseGate.items)
                )
            );
        }
        return releaseGateVModelList;
    }

    private List<ReleaseGateVModel.ReleaseGateFeature> mapReleaseGateFeatureList(
        List<GetReleaseGateActionResultModel.ReleaseGateFeature> featureModelList
    ) {
        List<ReleaseGateVModel.ReleaseGateFeature> featureVModelList = new List<ReleaseGateVModel.ReleaseGateFeature>();
        if (featureModelList != null) {
            for (GetReleaseGateActionResultModel.ReleaseGateFeature feature : featureModelList) {
                featureVModelList.add(
                    new ReleaseGateVModel.ReleaseGateFeature(
                        feature.name,
                        feature.label,
                        feature.description,
                        feature.helpLink,
                        feature.helpLinkLabel
                    )
                );
            }
        }
        return featureVModelList;
    }

    /**
     * @description Verify if the result is successful, throw ReleaseGateCallableException if not
     * @param  resultModel Callable action result
     */
    private void verifyCallableResult(CallableResult resultModel) {
        if (resultModel.success) {
            return;
        }
        String errorMessage = resultModel.error != null
            ? String.format('{0} ({1})', new List<Object>{ resultModel.error.message, resultModel.error.code })
            : 'Unspecified error';
        UTIL_Debug.debug(System.LoggingLevel.ERROR, errorMessage);
        throw new ReleaseGateResultException(errorMessage);
    }

    /*****************************************************************************
     * @description Retrieve an instance of the ReleaseGateService class.
     * @return An instance of ReleaseGateService.
     *****************************************************************************/
    @TestVisible
    private ReleaseGateService locateReleaseGateService() {
        return ReleaseGateService.getInstance();
    }

    public class ReleaseGateResultException extends Exception {
    }
}
