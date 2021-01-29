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
* @description Service class for Health Check
*/
public virtual with sharing class HealthCheckDefinitionService {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static HealthCheckDefinitionService instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected HealthCheckDefinitionService() {}

    /******************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of HealthCheckDefinitionService.
    ******************************************************************************/
    public static HealthCheckDefinitionService getInstance() {
        if (instance == null) {
            instance = new HealthCheckDefinitionService();
        }

        return instance;
    }

    /******************************************************************************
    * @description Get a list of Health Check Definition models
    * @return A list of HealthCheckDefinitionModel.
    ******************************************************************************/
    public virtual List<HealthCheckDefinitionModel> getHealthCheckDefinitionModels() {
        return this.locateHealthCheckDefinitionMapper().getHealthCheckDefinitionModels();
    }

    /******************************************************************************
    * @description Retrieves an instance of the HealthCheckDefinitionMapper class.
    * @return An instance of HealthCheckDefinitionMapper.
    ******************************************************************************/
    @TestVisible
    private HealthCheckDefinitionMapper locateHealthCheckDefinitionMapper() {
        return HealthCheckDefinitionMapper.getInstance();
    }
}