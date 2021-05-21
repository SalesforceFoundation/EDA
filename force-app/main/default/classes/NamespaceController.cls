public with sharing class NamespaceController {
    @AuraEnabled
    public static String getNamespaceName() {
        String nameSpacePrefix;
        ApexClass classNameSpace = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'STG_Base_CTRL'];
        if (classNameSpace.NamespacePrefix != null) {
            nameSpacePrefix = classNameSpace.NamespacePrefix + '__';
        } else {
            nameSpacePrefix = 'c__';
        }

        return nameSpacePrefix;
    }
}
