/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group Health Check
* @group-content ../../ApexDocContent/HealthCheck.htm
* @description Service class for Health Check Group.
*/
public virtual with sharing class HealthCheckGroupService {
    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static HealthCheckGroupService instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected HealthCheckGroupService() {}

    /******************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of HealthCheckGroupService.
    ******************************************************************************/
    public static HealthCheckGroupService getInstance() {
        if (instance == null) {
            instance = new HealthCheckGroupService();
        }

        return instance;
    }

    /********************************************************************************************
    * @description Retrieves the HealthCheckGroup view model for a specified 
    * HealthCheckDefinitionModel.
    * @param  name The name corresponding to a specified HealthCheckDefinitionModel
    * @param  className The className corresponding to a specified HealthCheckDefinitionModel
    * @param  namespace The namespace corresponding to a specified HealthCheckDefinitionModel
    * @return A HealthCheckGroupVModel representing the specified HealthCheckDefinitionModel.
    ********************************************************************************************/
    public virtual HealthCheckGroupVModel getHealthCheckGroup(String name, String className, String namespace){
        HealthCheckGroupAPIServiceInterface healthCheckGroupServiceInterface = 
            this.locateHealthCheckGroupAPIService(className, namespace);

        return healthCheckGroupServiceInterface.getHealthCheckGroup(name);
    }

    /********************************************************************************************
    * @description Dynamically instantiates a HealthCheckGroupAPIServiceInterface based on a 
    * specified classname and namespace.
    * @param  className The classname of a HealthCheckDefinitionModel
    * @param  namespace The namespace of a HealthCheckDefinitionModel
    * @return A HealthCheckGroupAPIServiceInterface corresponding to the specified classname and namespace.
    ********************************************************************************************/
    @TestVisible
    private virtual HealthCheckGroupAPIServiceInterface locateHealthCheckGroupAPIService(String className, String namespace){
        HealthCheckGroupAPIServiceInterface healthCheckGroupServiceInterface;
        String nonEDANamespace = namespace;
        
        if (namespace.equalsIgnoreCase('hed')){
            nonEDANamespace = '';
        }

        try{
            Type healthCheckGroupType = Type.forName(nonEDANamespace, className);
            healthCheckGroupServiceInterface = (HealthCheckGroupAPIServiceInterface)healthCheckGroupType.newInstance();
        } catch (System.NullPointerException e){
            throw new HealthCheckNotFoundException(e.getMessage());
        } catch (System.TypeException e){
            throw new HealthCheckNotFoundException(e.getMessage());
        }

        return healthCheckGroupServiceInterface.getInstance();
    }

    /********************************************************************************************
    * @description A custom exception class to represent Health Check Not Found errors.
    ********************************************************************************************/
    public class HealthCheckNotFoundException extends Exception{}
}
