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
 * @group EDA Settings
 * @group-content ../../ApexDocContent/EdaSettings.htm
 * @description Service class to handle business logic associated with ReleaseGate
 */
public virtual with sharing class ReleaseGateService {
    public class ReleaseGateException extends Exception {
    }
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static ReleaseGateService instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected ReleaseGateService() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of ReleaseGateService.
     **********************************************************************************/
    public static ReleaseGateService getInstance() {
        if (instance == null) {
            instance = new ReleaseGateService();
        }

        return instance;
    }

    /**
     * @description Retrieve a list of release gates
     * @param  productRegistryName product registry custom metadata type name
     * @return                     A list of ReleaseGateAPIModel.GetReleaseGateResult instances
     */
    public virtual ReleaseGateAPIModel.GetReleaseGateResult[] getReleaseGates(String productRegistryName) {
        //TODO: retrieve namespace and class name from product registry CMT, check if it is enabled
        ReleaseGateAPIModel.GetActionResult result = this.locateReleaseGateMapper()
            .getReleaseGates(productRegistryName);
        if (result.success) {
            return result.result;
        } else {
            //TODO: Create a custom callable release gate exception class
            throw new ReleaseGateException(result.error.message);
        }
    }

    /**
     * @description Activate a release gate
     * @param  productRegistryName product registry custom metadata type name
     * @param  productName         productName of the release gate
     * @param  gateName            release gate name to activate
     * @return                     A list of ReleaseGateAPIModel.ActivateReleaseGateResult instances
     */
    public virtual ReleaseGateAPIModel.ActivateReleaseGateResult[] activateReleaseGate(
        String productRegistryName,
        String productName,
        String gateName
    ) {
        //TODO: retrieve namespace and class name from product registry CMT, check if it is enabled
        ReleaseGateAPIModel.ActivateActionResult result = this.locateReleaseGateMapper()
            .activateReleaseGate(productRegistryName, productName, gateName);
        if (result.success) {
            return result.result;
        } else {
            //TODO: Create a custom callable release gate exception class
            throw new ReleaseGateException(result.error.message);
        }
    }

    /*****************************************************************************
     * @description Retrieve an instance of the ReleaseGateMapper class.
     * @return An instance of ReleaseGateMapper.
     *****************************************************************************/
    @TestVisible
    private ReleaseGateMapper locateReleaseGateMapper() {
        return ReleaseGateMapper.getInstance();
    }
}
