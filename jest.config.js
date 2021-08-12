const { jestConfig } = require("@salesforce/sfdx-lwc-jest/config");

const setupFilesAfterEnv = jestConfig.setupFilesAfterEnv || [];
setupFilesAfterEnv.push("<rootDir>/jest.setup.js");

module.exports = {
    ...jestConfig,
    setupFilesAfterEnv,
    moduleNameMapper: {
        "^lightning/platformShowToastEvent$": "<rootDir>/force-app/test/jest-mocks/lightning/platformShowToastEvent",
        "^lightning/navigation$": "<rootDir>/force-app/test/jest-mocks/lightning/navigation",
        "^c/EducationCloudSettings$":
            "<rootDir>/force-app/main/educationCloudSettings/lwc/educationCloudSettings/educationCloudSettings",
        "^c/EdcSettingsProductCard$":
            "<rootDir>/force-app/main/educationCloudSettings/lwc/edcSettingsProductCard/edcSettingsProductCard",
    },
};
