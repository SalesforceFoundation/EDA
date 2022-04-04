/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
 * @group EDA Setup
 * @group-content
 * @description EDA release gate provider callable class
 */
public with sharing class EDAReleaseGateProvider implements Callable {
    @TestVisible
    private final static String PRODUCT_NAME = 'EDA';

    @TestVisible
    private Map<String, ReleaseGateBase> releaseGatesMap;

    public EDAReleaseGateProvider() {
        this.releaseGatesMap = new Map<String, ReleaseGateBase>();
        EDALatestReleaseGate latestReleaseGate = new EDALatestReleaseGate();
        this.releaseGatesMap.put(latestReleaseGate.getReleaseGateName(), latestReleaseGate);
    }

    /**
     * @description Get a list of release gates
     * @param  version API version
     * @return         A list of ReleaseGate models
     */
    private List<GetReleaseGateActionResultModel.ReleaseGate> getReleaseGateList(Decimal version) {
        List<GetReleaseGateActionResultModel.ReleaseGate> releaseGateList = new List<GetReleaseGateActionResultModel.ReleaseGate>();
        for (ReleaseGateBase releaseGate : this.releaseGatesMap.values()) {
            releaseGateList.add(releaseGate.getReleaseGate(version));
        }
        return releaseGateList;
    }

    /**
     * @description Get a list of products with release gates
     * @param  version Callable API version
     * @return         A list of products and release gates in json format
     */
    public virtual GetReleaseGateActionResultModel getReleaseGates(Decimal version) {
        List<GetReleaseGateActionResultModel.GetReleaseGateResult> resultList = new List<GetReleaseGateActionResultModel.GetReleaseGateResult>{
            new GetReleaseGateActionResultModel.GetReleaseGateResult(
                new GetReleaseGateActionResultModel.ReleaseGateProduct(PRODUCT_NAME, Label.stgEDAAppTitle, ''),
                this.getReleaseGateList(version)
            )
        };
        return new GetReleaseGateActionResultModel(resultList, true, null);
    }

    /**
     * @description Activate a release gate
     * @param  version     Callable API version
     * @param  productName Release gate product name
     * @param  gateName    Release gate name
     * @return             Activate release gate result in json format
     */
    public virtual ActivateReleaseGateActionResultModel activateReleaseGate(
        Decimal version,
        String productName,
        String gateName
    ) {
        if (productName != PRODUCT_NAME) {
            throw new IllegalArgumentException(
                String.format(Label.stgErrorSettingsProductInvalidResponse, new List<Object>{ productName })
            );
        }
        ReleaseGateBase releaseGate = this.releaseGatesMap.get(gateName);
        if (releaseGate == null) {
            throw new IllegalArgumentException(
                String.format(Label.stgErrorSettingsProductInvalidResponse, new List<Object>{ gateName })
            );
        }
        return releaseGate.activateReleaseGate(version, productName, gateName);
    }

    /**
     * @description Call a release gating action
     * @param  action Release gating action name
     * @param  args   Additional action parameters
     * @return        Action result in json format
     */
    public Object call(String action, Map<String, Object> args) {
        UTIL_Debug.debug('Executing callable action: ' + action);
        if (action == ReleaseGateAPIService.GET_ACTION) {
            Object result = this.getReleaseGates((Decimal) args.get(ReleaseGateAPIService.VERSION_PARAMETER));
            String resultJson = JSON.serialize(result);
            UTIL_Debug.debug('Action finished, result: \r\n' + resultJson);
            return resultJson;
        }
        if (action == ReleaseGateAPIService.ACTIVATE_ACTION) {
            Object result = this.activateReleaseGate(
                (Decimal) args.get(ReleaseGateAPIService.VERSION_PARAMETER),
                (String) args.get(ReleaseGateAPIService.PRODUCT_PARAMETER),
                (String) args.get(ReleaseGateAPIService.GATE_PARAMETER)
            );
            String resultJson = JSON.serialize(result);
            UTIL_Debug.debug('Action finished, result: \r\n' + resultJson);
            return resultJson;
        }
        throw new IllegalArgumentException(Label.stgErrorSettingsProductInvalidAction);
    }
}
