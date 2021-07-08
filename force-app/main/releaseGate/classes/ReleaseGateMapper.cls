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
 * @description Mapper class to retrieve data needed for ReleaseGate
 */
public virtual with sharing class ReleaseGateMapper {
    /**********************************************************************************
     * @description Instance for Singleton Pattern
     **********************************************************************************/
    @TestVisible
    private static ReleaseGateMapper instance;

    /**********************************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************************/
    protected ReleaseGateMapper() {
    }

    /**********************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of ReleaseGateMapper.
     **********************************************************************************/
    public static ReleaseGateMapper getInstance() {
        if (instance == null) {
            instance = new ReleaseGateMapper();
        }

        return instance;
    }

    /**
     * @description Retrieve a list of release gates
     * @param  productRegistryName product registry custom metadata type name
     * @return                     A ReleaseGateAPIModel.GetActionResult instance
     */
    public virtual ReleaseGateAPIModel.GetActionResult getReleaseGates(String productRegistryName) {
        //TODO: Create callable service from product registry CMT record
        //TODO: instead of String productRegistryName we should probably use product registry model instance which is to be created
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(
            'edainteropdemo',
            'DemoGlobalReleaseGateCallableImpl',
            1
        );
        return callableService.getReleaseGates();
    }

    /**
     * @description activateReleaseGate description
     * @param  productRegistryName product registry custom metadata type name
     * @param  productName         productName of the gate
     * @param  gateName            gateName to activate
     * @return                     A ReleaseGateAPIModel.GetActionResult instance
     */
    public virtual ReleaseGateAPIModel.ActivateActionResult activateReleaseGate(
        String productRegistryName,
        String productName,
        String gateName
    ) {
        //TODO: Create callable service from product registry CMT record
        //TODO: instead of String productRegistryName we should probably use product registry model instance which is to be created
        ReleaseGateAPIService callableService = new ReleaseGateAPIService(
            'edainteropdemo',
            'DemoGlobalReleaseGateCallableImpl',
            1
        );
        return callableService.activateReleaseGate(productName, gateName);
    }
}
