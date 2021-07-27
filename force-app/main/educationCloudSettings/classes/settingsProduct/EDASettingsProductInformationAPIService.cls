public virtual with sharing class EDASettingsProductInformationAPIService implements Callable {
    public static final String PRODUCT_INFORMATION_ACTION = 'Settings Product Information';
    public static final String PRODUCT_EDA_INITIALS = 'EDA';
    public static final String PRODUCT_EDA_NAME = 'Education Data Architecture';
    public static final String PRODUCT_EDA_DESCRIPTION = 'Education Data Architecture (EDA) is the foundation of the Education Cloud. Its flexible data architecture is designed to configure Salesforce for education.';
    public static final String PRODUCT_EDA_SETTINGSCOMPONENT = 'EdaSettingsContainer';
    public static final String PRODUCT_EDA_DOCUMENTATIONURL = 'https://powerofus.force.com/s/article/EDA-Documentation';
    public static final String PRODUCT_EDA_TRAILHEADURL = 'https://trailhead.salesforce.com/en/content/learn/trails/highered_heda';
    public static final String PRODUCT_EDA_ICON = 'standard:avatar';

    public EDASettingsProductInformationAPIService() {
    }

    public Object call(String action, Map<String, Object> args) {
        EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult;
        String result;
        if (args.get('Api Version') == null) {
            actionResult = this.createErrorActionResult(400, 'You gotta have an API version!');
        } else {
            if (action == PRODUCT_INFORMATION_ACTION) {
                actionResult = this.getSettingsProductInformation();
            } else {
                actionResult = this.createErrorActionResult(400, 'Method: ' + action + ' not implemented');
            }
        }

        result = JSON.serialize(actionResult);
        return result;
    }

    public EDCSettingsProductAPIModel.SettingsProductInformationActionResult getSettingsProductInformation() {
        EDCSettingsProductAPIModel.SettingsProductInformation productInformation = new EDCSettingsProductAPIModel.SettingsProductInformation(
            PRODUCT_EDA_INITIALS,
            PRODUCT_EDA_NAME,
            PRODUCT_EDA_DESCRIPTION,
            PRODUCT_EDA_SETTINGSCOMPONENT,
            PRODUCT_EDA_DOCUMENTATIONURL,
            PRODUCT_EDA_TRAILHEADURL,
            PRODUCT_EDA_ICON
        );

        EDCSettingsProductAPIModel.SettingsProductinformationResult productInformationResult = new EDCSettingsProductAPIModel.SettingsProductinformationResult(
            productInformation
        );

        EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult = new EDCSettingsProductAPIModel.SettingsProductInformationActionResult(
            productInformationResult,
            true,
            null
        );

        return actionResult;
    }

    private virtual EDCSettingsProductAPIModel.SettingsProductInformationActionResult createErrorActionResult(
        Integer code,
        String errorMessage
    ) {
        CallableError error = new CallableError(code, errorMessage);

        EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult = new EDCSettingsProductAPIModel.SettingsProductInformationActionResult(
            null,
            false,
            error
        );
        return actionResult;
    }
}
