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
 * @description Service class to handle business logic associated with ReleaseGateAPI
 */
public virtual with sharing class ReleaseGateAPIService {
    public static final String GET_ACTION = 'releasegate.get';
    public static final String ACTIVATE_ACTION = 'releasegate.activate';
    public static final String VERSION_PARAMETER = 'version';
    public static final String PRODUCT_PARAMETER = 'product';
    public static final String GATE_PARAMETER = 'gate';

    @TestVisible
    private String namespace;
    @TestVisible
    private String className;
    @TestVisible
    private Decimal version;
    @TestVisible
    private Callable callableInstance;

    /**
     * @description ReleaseGateAPIService constructor
     * @param  namespace Apex class namespace
     * @param  className Apex class name
     * @param  version   API version
     */
    public ReleaseGateAPIService(String namespace, String className, Decimal version) {
        this.namespace = namespace;
        this.className = className;
        this.version = version;
    }

    /**
     * @description create a new Callable instance or retrieve previously created one
     * @return           Callable instance
     */
    public Callable getCallable() {
        if (this.callableInstance == null) {
            UTIL_Debug.debug(
                'Creating release gate API callable instance, namespace: ' +
                this.namespace +
                ', class name: ' +
                this.className
            );
            this.callableInstance = (Callable) Type.forName(this.namespace, this.className).newInstance();
        }
        return this.callableInstance;
    }

    /**
     * @description Retrieve a ReleaseGateAPIModel.GetActionResult representing the release gates
     * @return           A ReleaseGateAPIModel.GetActionResult
     */
    public virtual ReleaseGateAPIModel.GetActionResult getReleaseGates() {
        Callable callableInstance = this.getCallable();
        UTIL_Debug.debug('Calling ' + GET_ACTION + ' action, version ' + this.version);
        Object result = callableInstance.call(GET_ACTION, new Map<String, Object>{ VERSION_PARAMETER => version });
        UTIL_Debug.debug('Finished ' + GET_ACTION + ', got the following response: \r\n ' + result);
        return (ReleaseGateAPIModel.GetActionResult) JSON.deserialize(
            (String) result,
            ReleaseGateAPIModel.GetActionResult.class
        );
    }

    /**
     * @description Retrieve a ReleaseGateAPIModel.ActivateActionResult representing the activated release gates
     * @param  productName product name from GetActionResult
     * @param  gateName    gate name from GetActionResult
     * @return             A ReleaseGateAPIModel.ActivateActionResult
     */
    public virtual ReleaseGateAPIModel.ActivateActionResult activateReleaseGate(String productName, String gateName) {
        Callable callableInstance = this.getCallable();
        UTIL_Debug.debug(
            'Calling ' +
            ACTIVATE_ACTION +
            ' action, version: ' +
            this.version +
            ', productName: ' +
            productName +
            ', gateName: ' +
            gateName
        );
        Object result = callableInstance.call(
            ACTIVATE_ACTION,
            new Map<String, Object>{
                VERSION_PARAMETER => version,
                PRODUCT_PARAMETER => productName,
                GATE_PARAMETER => gateName
            }
        );
        UTIL_Debug.debug('Finished ' + ACTIVATE_ACTION + ', got the following response: \r\n ' + result);
        return (ReleaseGateAPIModel.ActivateActionResult) JSON.deserialize(
            (String) result,
            ReleaseGateAPIModel.ActivateActionResult.class
        );
    }
}
