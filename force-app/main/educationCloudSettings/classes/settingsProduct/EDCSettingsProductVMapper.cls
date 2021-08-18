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
 * @description Mapper class for retrieving the EDCSettingsProductVModel based on the productRegistry parameter
 */
public virtual with sharing class EDCSettingsProductVMapper {
    @TestVisible
    private static EDCSettingsProductVMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected EDCSettingsProductVMapper() {
    }

    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    public static EDCSettingsProductVMapper getInstance() {
        if (instance == null) {
            instance = new EDCSettingsProductVMapper();
        }

        return instance;
    }

    /********************************************************************************************
     * @description Returns an EDCSettingsProductVModel based on the information from an
     * EDCSettingsProductInformationModel for an specific product registry
     * @param  classname A string representing the product class name to call
     * @param  namespace A string representing the product namespace
     * @param  apiVersion A decimal representing the api version
     * @return An instance of EDCSettingsProductVModel with all its properties populated
     ********************************************************************************************/
    public virtual EDCSettingsProductVModel getEDCSettingsProductVModel(
        String classname,
        String namespace,
        Decimal apiVersion
    ) {
        EDCSettingsProductInformationModel productInformation = this.getSettingsProductInformation(
            classname,
            namespace,
            apiVersion
        );

        if (productInformation == null) {
            return null;
        }

        return new EDCSettingsProductVModel(
            productInformation.initials,
            productInformation.name,
            productInformation.description,
            productInformation.settingsComponent,
            productInformation.settingsButtonA11y,
            productInformation.documentationUrl,
            productInformation.documentationButtonA11y,
            productInformation.trailheadUrl,
            productInformation.trailheadButtonA11y,
            productInformation.icon
        );
    }

    /********************************************************************************************
     * @description Returns an EDCSettingsProductInformationModel based on an
     * EDCSettingsProdInfoActionResultModel, if the SettingsProductInformationActionResult
     * is successful, then it returns the SettingsProductInformationResult, otherwise it throws a SettingsProductException
     * @param  className  A string representing the classname to call
     * @param  namespace  A string representing the the product namespace
     * @param  apiVersion A decimal representing the specific api version to use
     * @return A EDCSettingsProductInformationModel with all its values populated
     ********************************************************************************************/
    @TestVisible
    private virtual EDCSettingsProductInformationModel getSettingsProductInformation(
        String className,
        String namespace,
        Decimal apiVersion
    ) {
        EDCSettingsProdInfoActionResultModel actionResult = this.locateSettingsProductAPIService()
            .getSettingsProductInformation(className, namespace, apiVersion);

        EDCSettingsProductInformationModel result;

        if (actionResult == null) {
            return null;
        }

        if (actionResult.success == false) {
            throw new SettingsProductException(actionResult.error.message);
        }

        return actionResult.result;
    }

    /**********************************************************************************
     * @description Locates and returns an instance of EDCSettingsProductAPIService
     **********************************************************************************/
    @TestVisible
    private EDCSettingsProductAPIService locateSettingsProductAPIService() {
        return EDCSettingsProductAPIService.getInstance();
    }

    public class SettingsProductException extends Exception {
    }
}
