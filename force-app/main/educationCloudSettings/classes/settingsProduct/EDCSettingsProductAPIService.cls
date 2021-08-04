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
 * @description Service class which instantiates a class implementing the Callable interface and calls its call method, it returns
 * an instance of EDCSettingsProdInfoActionResultModel
 */
public virtual with sharing class EDCSettingsProductAPIService {
    public static final string PRODUCT_INFORMATION_ACTION = 'Settings Product Information';
    @TestVisible
    private static EDCSettingsProductAPIService instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected EDCSettingsProductAPIService() {
    }

    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    public static EDCSettingsProductAPIService getInstance() {
        if (instance == null) {
            instance = new EDCSettingsProductAPIService();
        }

        return instance;
    }

    /********************************************************************************************
     * @description Returns a EDCSettingsProdInfoActionResultModel by making a call
     * to a callable class given the provided namespace and apiVersion
     * @param  className  A string representing the classname to call
     * @param  namespace  A string representing the the product namespace
     * @param  apiVersion A decimal representing the specific api version to use
     * @return A EDCSettingsProdInfoActionResultModel with its properties populated
     ********************************************************************************************/
    public virtual EDCSettingsProdInfoActionResultModel getSettingsProductInformation(
        String className,
        String namespace,
        Decimal apiVersion
    ) {
        Callable settingsProductInformationAPIService = this.locateSettingsProductInformationAPIService(
            className,
            namespace
        );

        String settingsInformationJSON = this.makeCall(settingsProductInformationAPIService, apiVersion);
        EDCSettingsProdInfoActionResultModel actionResult;

        try {
            actionResult = (EDCSettingsProdInfoActionResultModel) JSON.deserialize(
                settingsInformationJSON,
                EDCSettingsProdInfoActionResultModel.class
            );
        } catch (System.JSONException je) {
            throw new SettingsInvalidResponseException(
                this.locateStringHandlingService()
                    .formatStringWithApostrophesAndParameters(
                        Label.stgErrorSettingsProductInvalidResponse,
                        new List<Object>{ namespace }
                    ),
                je
            );
        }
        return actionResult;
    }

    /********************************************************************************************
     * @description Returns a Callable instance based on the provided namespace and classname
     * @param  className A string representing the class to instantiate
     * @param  namespace A string representing the product namespace
     * @return A Callable instance
     ********************************************************************************************/
    @TestVisible
    private Callable locateSettingsProductInformationAPIService(String className, String namespace) {
        Callable settingsProductInformationAPIService;
        String nonEDANamespace = namespace;

        if (String.isNotBlank(namespace) && namespace.equalsIgnoreCase('hed')) {
            nonEDANamespace = '';
        }

        try {
            Type settingsProductInformationAPIServiceType = Type.forName(nonEDANamespace, className);
            settingsProductInformationAPIService = (Callable) settingsProductInformationAPIServiceType.newInstance();
        } catch (System.NullPointerException npe) {
            throw new SettingsProductNotFoundException(
                this.locateStringHandlingService()
                    .formatStringWithApostrophesAndParameters(
                        Label.stgErrorSettingsProductInvalidClass,
                        new List<Object>{ (String.isBlank(nonEDANamespace) ? 'hed' : nonEDANamespace) }
                    ),
                npe
            );
        } catch (System.TypeException te) {
            throw new SettingsProductNotFoundException(
                this.locateStringHandlingService()
                    .formatStringWithApostrophesAndParameters(
                        Label.stgErrorSettingsProductInvalidClass,
                        new List<Object>{ (String.isBlank(nonEDANamespace) ? 'hed' : nonEDANamespace) }
                    ),
                te
            );
        }
        return settingsProductInformationAPIService;
    }

    /********************************************************************************************
     * @description Returns a serialized string representing the Callable result
     * @param  settingsProductInformationAPIService A Callable instance to call
     * @param  apiVersion A string representing the apiVersion to use
     * @return A string representing the serialized Callable response
     ********************************************************************************************/
    @TestVisible
    private virtual String makeCall(Callable settingsProductInformationAPIService, Decimal apiVersion) {
        String settingsInformationJSON = (String) settingsProductInformationAPIService.call(
            PRODUCT_INFORMATION_ACTION,
            new Map<String, Object>{ 'Api Version' => apiVersion }
        );
        return settingsInformationJSON;
    }

    /***************************************************************************
     * @description Retrieves an instance of StringHandlingService.
     * @return An instance of StringHandlingService.
     ***************************************************************************/
    @TestVisible
    private StringHandlingService locateStringHandlingService() {
        return StringHandlingService.getInstance();
    }

    public class SettingsProductNotFoundException extends Exception {
    }
    public class SettingsInvalidResponseException extends Exception {
    }
}
