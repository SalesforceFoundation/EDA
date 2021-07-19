public virtual with sharing class SALSettingsProductInformationAPIService implements Callable {
    public static final string PRODUCT_INFORMATION_ACTION = 'Settings Product Information';

    public SALSettingsProductInformationAPIService() {
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
        productInformation.initials = 'SAL';
        productInformation.name = 'Advisor Link';
        productInformation.description = 'Advisor Link gives advisors and advisees new tools to help foster focused conversations about education success. With Advisor Link, advisees can book advising appointments online, right from their smartphones. While advisors can spend more time on strategic engagement, support, and follow-up, and less time on getting advisees in the door.';
        productInformation.settingsComponent = 'EdaSettingsContainer';
        productInformation.documentationUrl = 'https://powerofus.force.com/s/article/SAL-Documentation';
        productInformation.trailheadUrl = 'https://trailhead.salesforce.com/en/content/learn/modules/student-advising-with-salesforce-advisor-link';
        productInformation.icon = 'standard:avatar';
        productInformationResult.productInformation = productInformation;

        return actionResult;
    }
}
