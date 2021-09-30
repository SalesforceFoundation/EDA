public with sharing class EDAWinter22ReleaseGate extends ReleaseGateBase {
    private final static String RELEASE_GATE_NAME = 'winter22';
    private final static String RELEASE_GATE_FEATURE_NAME = 'winter22feature1';
    private final static String FEATURE_HELP_LINK = 'https://powerofus.force.com/s/group/0F980000000DA0QCAW/eda-release-announcements';

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
                    Label.stgReleaseGateEDAWinter22FeatureHelpLabel
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
    public override ActivateReleaseGateActionResultModel activateReleaseGate(Decimal version) {
        throw new IllegalArgumentException(Label.stgErrorSettingsProductInvalidAction);
    }
}
