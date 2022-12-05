/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
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
 * @group-content
 * @description A demo service class to simulate an API which provides the Settings Product Information for
 * Test Advisor Link product
 */
global virtual with sharing class TALDemoSettingsProductInfoAPIService implements Callable {
    public static final string PRODUCT_INFORMATION_ACTION = 'Settings Product Information';

    public TALDemoSettingsProductInfoAPIService() {
    }

    /********************************************************************************************
     * @description Returns an object which is a serialized version of
     * EDCSettingsProdInfoActionResultModel
     * @param  action A string representing the specific action or method to execute
     * @param  args   A map of String and Object representing the parameters provided for this call
     * @return An object which is a serialized version of
     * EDCSettingsProdInfoActionResultModel
     ********************************************************************************************/
    public Object call(String action, Map<String, Object> args) {
        TALDemoSettingsProductInfoAPIService.EDCSettingsProdInfoActionResultModel actionResult;
        Decimal apiVersion;

        try {
            apiVersion = this.getApiVersion(args);
        } catch (TALDemoSettingsProductInfoAPIService.ApiVersionNotFoundException avnfe) {
            actionResult = this.createErrorActionResult(400, avnfe.getMessage());
            return JSON.serialize(actionResult);
        }

        try {
            actionResult = this.handleAction(action, apiVersion);
        } catch (TALDemoSettingsProductInfoAPIService.InvalidActionException iae) {
            actionResult = this.createErrorActionResult(400, iae.getMessage());
            return JSON.serialize(actionResult);
        }

        return JSON.serialize(actionResult);
    }

    /********************************************************************************************
     * @description Returns an instance of EDCSettingsProdInfoActionResultModel
     * containing the product information related to EDA
     * @return An instance of EDCSettingsProdInfoActionResultModel
     ********************************************************************************************/
    public TALDemoSettingsProductInfoAPIService.EDCSettingsProdInfoActionResultModel getSettingsProductInformation() {
        Boolean managedEnv;
        String namespace = 'hed';
        try {
            managedEnv = Userinfo.isCurrentUserLicensed(namespace);
        } catch (System.TypeException te) {
            managedEnv = false;
        }

        String settingsContainerPrefix;
        if (managedEnv) {
            settingsContainerPrefix = namespace + '__';
        } else {
            settingsContainerPrefix = 'c__';
        }

        //Instead of building the model directly, use a mapper for building the model
        TALDemoSettingsProductInfoAPIService.EDCSettingsProductInformationModel productInformation = new TALDemoSettingsProductInfoAPIService.EDCSettingsProductInformationModel(
            'TAL',
            'Advisor Link (Mocked)',
            'Advisor Link (Mocked) gives advisors and advisees new tools to help foster focused conversations about education success. With Advisor Link, advisees can book advising appointments online, right from their smartphones. While advisors can spend more time on strategic engagement, support, and follow-up, and less time on getting advisees in the door.',
            settingsContainerPrefix + 'EdaSettingsContainer',
            'Go to Advisor Link (Mocked) Settings',
            '',
            'Go to Advisor Link (Mocked) Documentation',
            'https://trailhead.salesforce.com/en/content/learn/modules/student-advising-with-salesforce-advisor-link',
            'Go to Advisor Link (Mocked) Trailhead',
            'standard:avatar'
        );

        TALDemoSettingsProductInfoAPIService.EDCSettingsProdInfoActionResultModel actionResult = new TALDemoSettingsProductInfoAPIService.EDCSettingsProdInfoActionResultModel(
            productInformation,
            true,
            null
        );

        return actionResult;
    }

    /********************************************************************************************
     * @description Constructs and returns an instance of EDCSettingsProdInfoActionResultModel
     * with success set to false and a CallableError instance to provide details about the error
     * @param  code         code description
     * @param  errorMessage errorMessage description
     * @return              return description
     ********************************************************************************************/
    @TestVisible
    private virtual TALDemoSettingsProductInfoAPIService.EDCSettingsProdInfoActionResultModel createErrorActionResult(
        Integer code,
        String errorMessage
    ) {
        TALDemoSettingsProductInfoAPIService.CallableError error = new TALDemoSettingsProductInfoAPIService.CallableError(
            code,
            errorMessage
        );

        TALDemoSettingsProductInfoAPIService.EDCSettingsProdInfoActionResultModel actionResult = new TALDemoSettingsProductInfoAPIService.EDCSettingsProdInfoActionResultModel(
            null,
            false,
            error
        );
        return actionResult;
    }

    /********************************************************************************************
     * @description Returns the decimal Api Version provided as parameter, otherwise it throws
     * an ApiVersionNotFoundException
     * @param  args A map of String and Object which contain the parameters needed for this call
     * @return A decimal Api Version retrieved from the parameters
     ********************************************************************************************/
    @TestVisible
    private Decimal getApiVersion(Map<String, Object> args) {
        if (args.containsKey('Api Version') == false || args.get('Api Version') == null) {
            throw new TALDemoSettingsProductInfoAPIService.ApiVersionNotFoundException(
                'You gotta have an API version!'
            );
        }
        return (Decimal) args.get('Api Version');
    }

    /********************************************************************************************
     * @description Returns the EDCSettingsProdInfoActionResultModel
     * for the specified action, if the action is not valid an InvalidActionException is thrown
     * @param  action     A string representing the specific action or method to execute
     * @param  apiVersion A decimal representing the api version needed for this call
     * @return            return description
     ********************************************************************************************/
    @TestVisible
    private TALDemoSettingsProductInfoAPIService.EDCSettingsProdInfoActionResultModel handleAction(
        String action,
        Decimal apiVersion
    ) {
        if (action == PRODUCT_INFORMATION_ACTION) {
            return this.getSettingsProductInformation();
        }
        throw new TALDemoSettingsProductInfoAPIService.InvalidActionException('Action: ' + action + ' not implemented');
    }

    @TestVisible
    private class ApiVersionNotFoundException extends Exception {
    }
    @TestVisible
    private class InvalidActionException extends Exception {
    }

    public class EDCSettingsProdInfoActionResultModel extends TALDemoSettingsProductInfoAPIService.CallableResult {
        public TALDemoSettingsProductInfoAPIService.EDCSettingsProductInformationModel result;

        public EDCSettingsProdInfoActionResultModel(
            TALDemoSettingsProductInfoAPIService.EDCSettingsProductInformationModel result,
            Boolean success,
            TALDemoSettingsProductInfoAPIService.CallableError error
        ) {
            super(success, error);
            this.result = result;
        }
    }

    public class EDCSettingsProductInformationModel {
        public String initials { get; private set; }
        public String name { get; private set; }
        public String description { get; private set; }
        public String settingsComponent { get; private set; }
        public String settingsButtonA11y { get; private set; }
        public String documentationUrl { get; private set; }
        public String documentationButtonA11y { get; private set; }
        public String trailheadUrl { get; private set; }
        public String trailheadButtonA11y { get; private set; }
        public String icon { get; private set; }

        /********************************************************************************************
         * @description Ten argument constructor
         * @param  initials             A string representing the product initials
         * @param  name                 A string representing the product name
         * @param  description          A string representing the product description
         * @param  settingsComponent    A string representing the component the Settings link will redirect to
         * @param  settingsButtonA11y   A string representing the title property value for the settings button
         * @param  documentationUrl     A string representing the url to the documentation
         * @param  documentationButtonA11y A string representing the title property value for the documentation button
         * @param  trailheadUrl         A string representing the trailhead url
         * @param  trailheadButtonA11y  A string representing the title property value for the trailhead button
         * @param  icon                 A string representing the icon to use
         * @return                      A EDCSettingsProductInformationModel with all its properties populated
         ********************************************************************************************/
        public EDCSettingsProductInformationModel(
            String initials,
            String name,
            String description,
            String settingsComponent,
            String settingsButtonA11y,
            String documentationUrl,
            String documentationButtonA11y,
            String trailheadUrl,
            String trailheadButtonA11y,
            String icon
        ) {
            this.initials = initials;
            this.name = name;
            this.description = description;
            this.settingsComponent = settingsComponent;
            this.settingsButtonA11y = settingsButtonA11y;
            this.documentationUrl = documentationUrl;
            this.documentationButtonA11y = documentationButtonA11y;
            this.trailheadUrl = trailheadUrl;
            this.trailheadButtonA11y = trailheadButtonA11y;
            this.icon = icon;
        }
    }

    public virtual class CallableResult {
        public Boolean success;
        public TALDemoSettingsProductInfoAPIService.CallableError error;

        /********************************************************************************************
         * @description Two argument constructor
         * @param  success A boolean representing if the call was successful or not
         * @param  error A CallableError representing the error in case the call was not successful
         * @return A CallableResult with all properties populated.
         ********************************************************************************************/
        public CallableResult(Boolean success, TALDemoSettingsProductInfoAPIService.CallableError error) {
            this.success = success;
            this.error = error;
        }
    }

    public class CallableError {
        public Integer code;
        public String message;

        /********************************************************************************************
         * @description Two argument constructor
         * @param  code An Integer representing the error code
         * @param  message A string representing the error message
         * @return A CallableError with all properties populated.
         ********************************************************************************************/
        public CallableError(Integer code, String message) {
            this.code = code;
            this.message = message;
        }
    }
}
