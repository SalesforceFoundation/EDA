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
 * @group
 * @group-content ../../ApexDocContent/
 * @description Class for EDA Winter'22 release gate
 */
public with sharing class EDAWinter22ReleaseGate extends ReleaseGateBase {
    @TestVisible
    private final static String RELEASE_GATE_NAME = 'winter22';
    @TestVisible
    private final static String RELEASE_GATE_FEATURE_NAME = 'winter22feature1';
    @TestVisible
    private final static String FEATURE_HELP_LINK = 'https://trailhead.salesforce.com/trailblazer-community/feed/0D54S00000BuNlcSAF';

    /**
     * @description Get the name of the release gate
     * @return   A string representing release gate name
     */
    public override String getReleaseGateName() {
        return RELEASE_GATE_NAME;
    }

    /**
     * @description Get a release gate instance
     * @param  version Callable API version
     * @return         A release gate instance
     */
    public override GetReleaseGateActionResultModel.ReleaseGate getReleaseGate(Decimal version) {
        return new GetReleaseGateActionResultModel.ReleaseGate(
            this.getReleaseGateName(),
            Label.stgReleaseGateEDAWinter22Label,
            Label.stgReleaseGateEDAWinter22Description,
            Date.newInstance(2021, 11, 16),
            null,
            '',
            null,
            ReleaseGateAPIService.ReleaseGateStatus.ACTIVE.name().toLowerCase(),
            new List<GetReleaseGateActionResultModel.ReleaseGateFeature>{
                new GetReleaseGateActionResultModel.ReleaseGateFeature(
                    RELEASE_GATE_FEATURE_NAME,
                    '',
                    Label.stgReleaseGateEDAWinter22FeatureDescription,
                    FEATURE_HELP_LINK,
                    Label.stgReleaseGateEDAFeatureHelpLabel
                )
            }
        );
    }

    /**
     * @description Activate a release gate
     * @param  version     Callable API version
     * @param  productName Release gate product name
     * @param  gateName    Release gate name
     * @return             Activate release gate result
     */
    public override ActivateReleaseGateActionResultModel activateReleaseGate(
        Decimal version,
        String productName,
        String gateName
    ) {
        throw new IllegalArgumentException(Label.stgErrorSettingsProductInvalidAction);
    }
}
