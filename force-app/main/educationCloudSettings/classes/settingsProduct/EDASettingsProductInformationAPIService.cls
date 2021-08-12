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
 * @description Service class to simulate an API which provides the Settings Product Information for EDA
 */
public virtual with sharing class EDASettingsProductInformationAPIService implements Callable {
    @TestVisible
    private static final String PRODUCT_INFORMATION_ACTION = 'Settings Product Information';

    /********************************************************************************************
     * @description Returns an object which is a serialized version of
     * EDCSettingsProdInfoActionResultModel
     * @param  action A string representing the specific action or method to execute
     * @param  args   A map of String and Object representing the parameters provided for this call
     * @return An object which is a serialized version of
     * EDCSettingsProdInfoActionResultModel
     ********************************************************************************************/
    public Object call(String action, Map<String, Object> args) {
        EDCSettingsProdInfoActionResultModel actionResult;
        Decimal apiVersion;

        try {
            apiVersion = this.getApiVersion(args);
        } catch (ApiVersionNotFoundException avnfe) {
            actionResult = this.createErrorActionResult(400, avnfe.getMessage());
            return JSON.serialize(actionResult);
        }

        try {
            actionResult = this.handleAction(action, apiVersion);
        } catch (InvalidActionException iae) {
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
    public EDCSettingsProdInfoActionResultModel getSettingsProductInformation() {
        EDCSettingsProductInformationModel productInformationModel = this.locateEDCSettingsProductInformationMapper()
            .getProductInformationModel();
        EDCSettingsProdInfoActionResultModel actionResult = new EDCSettingsProdInfoActionResultModel(
            productInformationModel,
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
    private virtual EDCSettingsProdInfoActionResultModel createErrorActionResult(Integer code, String errorMessage) {
        CallableError error = new CallableError(code, errorMessage);

        EDCSettingsProdInfoActionResultModel actionResult = new EDCSettingsProdInfoActionResultModel(
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
            throw new ApiVersionNotFoundException(Label.stgErrorSettingsProductInvalidApiVersion);
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
    private EDCSettingsProdInfoActionResultModel handleAction(String action, Decimal apiVersion) {
        if (action == PRODUCT_INFORMATION_ACTION) {
            return this.getSettingsProductInformation();
        }
        throw new InvalidActionException(Label.stgErrorSettingsProductInvalidAction);
    }

    /**********************************************************************************
     * @description Locates and returns an instance of ProductRegistryMapper.
     **********************************************************************************/
    private EDCSettingsProductInformationMapper locateEDCSettingsProductInformationMapper() {
        return EDCSettingsProductInformationMapper.getInstance();
    }

    @TestVisible
    private class ApiVersionNotFoundException extends Exception {
    }
    @TestVisible
    private class InvalidActionException extends Exception {
    }
}
