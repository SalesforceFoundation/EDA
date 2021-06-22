//Runs install apex scripts for any context
public static void executeInstallApex() {
    ArbitraryInstallContext installContext = new ArbitraryInstallContext();
    %%%NAMESPACE_DOT%%%STG_InstallScript install = new %%%NAMESPACE_DOT%%%STG_InstallScript();
    install.onInstall(installContext);
}