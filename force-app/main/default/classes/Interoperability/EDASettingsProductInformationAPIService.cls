public virtual with sharing class EDASettingsProductInformationAPIService implements Callable {
    public static final string PRODUCT_INFORMATION_ACTION = 'Settings Product Information';

    public EDASettingsProductInformationAPIService() {
    }

    public Object call(String action, Map<String, Object> args) {
        String result;

        if (args.get('Api Version') == null) {
            throw new IllegalArgumentException('You gotta have an API version!');
        }

        if (action == PRODUCT_INFORMATION_ACTION) {
            EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult = this.getSettingsProductInformation();
            result = JSON.serialize(actionResult);
        } else {
            //Need to build an EDCSettingsProductAPIModel.SettingsProductInformationActionResult which returns an error
            //Instead of throwing the IllegalArgumentException
            throw new IllegalArgumentException('Method not implemented');
        }
        return result;
    }

    public EDCSettingsProductAPIModel.SettingsProductInformationActionResult getSettingsProductInformation() {
        EDCSettingsProductAPIModel.SettingsProductInformationActionResult actionResult = new EDCSettingsProductAPIModel.SettingsProductInformationActionResult();
        actionResult.success = true;

        EDCSettingsProductAPIModel.SettingsProductinformationResult productInformationResult = new EDCSettingsProductAPIModel.SettingsProductinformationResult();
        actionResult.result = productInformationResult;

        EDCSettingsProductAPIModel.SettingsProductInformation productInformation = new EDCSettingsProductAPIModel.SettingsProductInformation();
        productInformation.initials = 'EDA';
        productInformation.name = 'Education Data Architecture';
        productInformation.description = 'Education Data Architecture (EDA) is the foundation of the Education Cloud. Its flexible data architecture is designed to configure Salesforce for education.';
        productInformation.settingsComponent = 'EdaSettingsContainer';
        productInformation.documentationUrl = 'https://powerofus.force.com/s/article/EDA-Documentation';
        productInformation.trailheadUrl = 'https://trailhead.salesforce.com/en/content/learn/trails/highered_heda';
        productInformation.icon = 'standard:avatar';
        productInformationResult.productInformation = productInformation;

        return actionResult;
    }
}
