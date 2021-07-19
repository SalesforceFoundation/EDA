public virtual with sharing class EDCSettingsProductAPIService {
    public static final string PRODUCT_INFORMATION_ACTION = 'Settings Product Information';
    @TestVisible
    private static EDCSettingsProductAPIService instance;

    protected EDCSettingsProductAPIService() {
    }

    public static EDCSettingsProductAPIService getInstance() {
        if (instance == null) {
            instance = new EDCSettingsProductAPIService();
        }

        return instance;
    }

    public virtual EDCSettingsProductAPIModel.SettingsProductInformationActionResult getSettingsProductInformation(
        String className,
        String namespace,
        Decimal apiVersion
    ) {
        Callable settingsProductInformationAPIService = this.locateSettingsProductInformationAPIService(
            className,
            namespace
        );

        String settingsInformationJSON = (String) settingsProductInformationAPIService.call(
            PRODUCT_INFORMATION_ACTION,
            new Map<String, Object>{ 'Api Version' => apiVersion }
        );

        EDCSettingsProductAPIModel.SettingsProductInformationActionResult settingsProductAPIModel = (EDCSettingsProductAPIModel.SettingsProductInformationActionResult) JSON.deserialize(
            settingsInformationJSON,
            EDCSettingsProductAPIModel.SettingsProductInformationActionResult.class
        );
        return settingsProductAPIModel;
    }

    private virtual Callable locateSettingsProductInformationAPIService(String className, String namespace) {
        Callable settingsProductInformationAPIService;
        String nonEDANamespace = namespace;

        if (namespace.equalsIgnoreCase('hed')) {
            nonEDANamespace = '';
        }

        try {
            Type settingsProductInformationAPIServiceType = Type.forName(nonEDANamespace, className);
            settingsProductInformationAPIService = (Callable) settingsProductInformationAPIServiceType.newInstance();
        } catch (System.NullPointerException e) {
            throw new SettingsProductNotFoundException(
                'Class: ' +
                className +
                ' with namespace: ' +
                nonEDANamespace +
                ' could not get loaded',
                e
            );
        } catch (System.TypeException e) {
            throw new SettingsProductNotFoundException(
                'Class: ' +
                className +
                ' with namespace: ' +
                nonEDANamespace +
                ' could not get loaded',
                e
            );
        }
        return settingsProductInformationAPIService;
    }

    public class SettingsProductNotFoundException extends Exception {
    }
}
