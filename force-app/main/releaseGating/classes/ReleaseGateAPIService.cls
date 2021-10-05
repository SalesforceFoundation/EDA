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
 * @description Service class to call Release Gate Callable API classes
 */
public virtual with sharing class ReleaseGateAPIService {
    public static final String GET_ACTION = 'releasegate.get';
    public static final String ACTIVATE_ACTION = 'releasegate.activate';
    public static final String VERSION_PARAMETER = 'version';
    public static final String PRODUCT_PARAMETER = 'product';
    public static final String GATE_PARAMETER = 'gate';
    private static final String EDA_NAMESPACE = 'hed';

    public enum ReleaseGateStatus {
        DISABLED,
        INACTIVE,
        INPROGRESS,
        ACTIVE
    }

    @TestVisible
    private ProductRegistryModel releaseGateRegistry;
    @TestVisible
    private Callable callableInstance;

    /**
     * @description ReleaseGateAPIService constructor
     * @param  releaseGateRegistry ProductRegistryModel instance which describes the Callable class
     */
    public ReleaseGateAPIService(ProductRegistryModel releaseGateRegistry) {
        if (releaseGateRegistry.action != ProductRegistryMapper.RELEASE_GATING_ACTION) {
            throw new ReleaseGateProductRegistryException(
                Label.stgErrorSettingsProductInvalidAction,
                releaseGateRegistry
            );
        }
        this.releaseGateRegistry = releaseGateRegistry;
    }

    /**
     * @description create a new Callable instance or retrieve previously created one
     * @return           Callable instance
     */
    protected virtual Callable locateReleaseGateCallable() {
        if (this.callableInstance == null) {
            try {
                UTIL_Debug.debug(
                    String.format(
                        'Creating release gate API callable instance, namespace: {0}, class name {1}',
                        new List<Object>{ this.releaseGateRegistry.namespace, this.releaseGateRegistry.classname }
                    )
                );
                this.callableInstance = this.createReleaseGateCallableInstance();
            } catch (System.NullPointerException npe) {
                String errorMessage = String.format(
                    Label.stgErrorSettingsProductInvalidClass,
                    new List<object>{ this.releaseGateRegistry.classname, this.releaseGateRegistry.namespace }
                );
                UTIL_Debug.debug(System.LoggingLevel.ERROR, errorMessage);
                throw new ReleaseGateProductNotFoundException(errorMessage, npe, this.releaseGateRegistry);
            } catch (System.TypeException te) {
                String errorMessage = String.format(
                    Label.stgErrorSettingsProductInvalidClass,
                    new List<object>{ this.releaseGateRegistry.classname, this.releaseGateRegistry.namespace }
                );
                UTIL_Debug.debug(System.LoggingLevel.ERROR, errorMessage);
                throw new ReleaseGateProductNotFoundException(errorMessage, te, this.releaseGateRegistry);
            }
        }
        return this.callableInstance;
    }

    /**
     * @description Creates a new Callable instance from a provided product registry metadata
     * @return   A new Callable instance
     */
    private Callable createReleaseGateCallableInstance() {
        String namespace = this.getCallableNamespace();
        return (Callable) Type.forName(namespace, this.releaseGateRegistry.classname).newInstance();
    }

    /**
     * @description Checks and converts a callable namespace
     * @return   A converted namespace
     */
    @TestVisible
    private String getCallableNamespace() {
        String namespace = this.releaseGateRegistry.namespace == null ? '' : this.releaseGateRegistry.namespace;
        if (UTIL_Namespace.getNamespace() == '' && namespace.toLowerCase() == EDA_NAMESPACE) {
            //If we are not in a managed context (dev scratch org without a namespace) the 'hed' namespace will not work
            //we need to remove it
            namespace = '';
        }
        return namespace;
    }

    /**
     * @description Retrieve a GetReleaseGateActionResultModel representing the release gates
     * @return           A GetReleaseGateActionResultModel
     */
    public virtual GetReleaseGateActionResultModel getReleaseGates() {
        //Customize application perm is required for all release gating actions
        this.locateUserPermissionService().checkCustomizeApplicationForCurrentUser();
        try {
            Object result = this.makeCall(
                GET_ACTION,
                new Map<String, Object>{ VERSION_PARAMETER => this.releaseGateRegistry.apiVersion }
            );
            GetReleaseGateActionResultModel resultModel = (GetReleaseGateActionResultModel) JSON.deserialize(
                (String) result,
                GetReleaseGateActionResultModel.class
            );
            return resultModel;
        } catch (System.JSONException je) {
            String errorMessage = String.format(
                Label.stgErrorSettingsProductInvalidResponse,
                new List<Object>{ this.releaseGateRegistry.name }
            );
            UTIL_Debug.debug(System.LoggingLevel.ERROR, je.getMessage());
            throw new ReleaseGateCallableException(errorMessage, je, this.releaseGateRegistry, null);
        } catch (ReleaseGateException rge) {
            throw rge;
        } catch (Exception ex) {
            UTIL_Debug.debug(System.LoggingLevel.ERROR, ex.getMessage());
            throw new ReleaseGateCallableException(ex.getMessage(), ex, this.releaseGateRegistry, null);
        }
    }

    /**
     * @description Activate a release gate
     * @param  productName Release gate product name
     * @param  gateName    Release gate name
     * @return             A ActivateReleaseGateActionResultModel instance
     */
    public virtual ActivateReleaseGateActionResultModel activateReleaseGate(String productName, String gateName) {
        //Customize application perm is required for all release gating actions
        this.locateUserPermissionService().checkCustomizeApplicationForCurrentUser();
        try {
            Object result = this.makeCall(
                ACTIVATE_ACTION,
                new Map<String, Object>{
                    VERSION_PARAMETER => this.releaseGateRegistry.apiVersion,
                    PRODUCT_PARAMETER => productName,
                    GATE_PARAMETER => gateName
                }
            );
            ActivateReleaseGateActionResultModel resultModel;
            try {
                resultModel = (ActivateReleaseGateActionResultModel) JSON.deserialize(
                    (String) result,
                    ActivateReleaseGateActionResultModel.class
                );
            } catch (System.JSONException je) {
                String errorMessage = String.format(
                    Label.stgErrorReleaseGateActivateErrorResponse,
                    new List<Object>{ gateName + ' (' + productName + ')', je.getMessage() }
                );
                UTIL_Debug.debug(System.LoggingLevel.ERROR, errorMessage);
                throw new ReleaseGateCallableException(errorMessage, je, this.releaseGateRegistry, null);
            }
            if (!resultModel.success) {
                if (resultModel.error != null) {
                    resultModel.error.message = String.format(
                        Label.stgErrorReleaseGateActivateErrorResponse,
                        new List<Object>{ gateName + ' (' + productName + ')', resultModel.error.message }
                    );
                }
            }
            return resultModel;
        } catch (ReleaseGateException rge) {
            throw rge;
        } catch (Exception ex) {
            String errorMessage = String.format(
                Label.stgErrorReleaseGateActivateErrorResponse,
                new List<Object>{ gateName + ' (' + productName + ')', ex.getMessage() }
            );
            UTIL_Debug.debug(System.LoggingLevel.ERROR, errorMessage);
            throw new ReleaseGateCallableException(errorMessage, ex, this.releaseGateRegistry, null);
        }
    }

    /**
     * @description Calls the specified callable action
     * @param  action     action name to call
     * @param  parameters action parameters
     * @return            Callable return result
     */
    protected virtual Object makeCall(String action, Map<String, Object> parameters) {
        Callable callableInstance = this.locateReleaseGateCallable();
        UTIL_Debug.debug(
            String.format(
                'Calling {0}.{1} action, version {2}',
                new List<Object>{ this.releaseGateRegistry.name, action, parameters.get(VERSION_PARAMETER) }
            )
        );
        Object result;
        result = callableInstance.call(action, parameters);
        UTIL_Debug.debug(
            String.format(
                'Finished {0}.{1}, got the following response: \r\n {2}',
                new List<Object>{ this.releaseGateRegistry.name, action, result }
            )
        );
        return result;
    }

    /*****************************************************************************
     * @description Retrieves an instance of the UserPermissionService.
     * @return The instance of UserPermissionService.
     ******************************************************************************/
    @TestVisible
    private UserPermissionService locateUserPermissionService() {
        return UserPermissionService.getInstance();
    }

    /**
     * Base release gate exception class
     */
    public abstract class ReleaseGateException extends Exception {
        public ProductRegistryModel productRegistry { get; protected set; }
    }

    /**
     * ReleaseGating product registry validation exception
     */
    public class ReleaseGateProductRegistryException extends ReleaseGateException {
        /**
         * @description custom three parameter constructor
         * @param  message         Exception message
         * @param  productRegistry product registry associated with the exception
         */
        public ReleaseGateProductRegistryException(String message, ProductRegistryModel productRegistry) {
            this.setMessage(message);
            this.productRegistry = productRegistry;
        }
    }

    /**
     * ReleaseGating product/class not found custom exception class
     */
    public class ReleaseGateProductNotFoundException extends ReleaseGateException {
        /**
         * @description custom three parameter constructor
         * @param  message         Exception message
         * @param  cause           Exception cause
         * @param  productRegistry product registry associated with the exception
         */
        public ReleaseGateProductNotFoundException(
            String message,
            Exception cause,
            ProductRegistryModel productRegistry
        ) {
            this.setMessage(message);
            if (cause != null) {
                this.initCause(cause);
            }
            this.productRegistry = productRegistry;
        }
    }

    /**
     * ReleaseGating callable exception class
     */
    public class ReleaseGateCallableException extends ReleaseGateException {
        public CallableResult result { get; private set; }

        /**
         * @description custom four parameter constructor
         * @param  message         Exception message
         * @param  cause           Exception cause
         * @param  productRegistry product registry associated with the exception
         * @param  result          CallableResult associated with the exception
         */
        public ReleaseGateCallableException(
            String message,
            Exception cause,
            ProductRegistryModel productRegistry,
            CallableResult result
        ) {
            this.setMessage(message);
            if (cause != null) {
                this.initCause(cause);
            }
            this.productRegistry = productRegistry;
            this.result = result;
        }
    }
}
