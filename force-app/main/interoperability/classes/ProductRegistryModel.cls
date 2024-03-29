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
 * @description Model to abstract data needed to populate Product Registries
 */
public virtual class ProductRegistryModel {
    public String name { get; private set; }
    public String action { get; private set; }
    public String namespace { get; private set; }
    public String classname { get; private set; }
    public Decimal apiVersion { get; private set; }

    /********************************************************************************************
     * @description Five argument constructor
     * @param  name A string representing the developer name of the record
     * @param  action A string representing the action or method this registry is about
     * @param  namespace A string representing the product namespace
     * @param  classname A string representing the class name to invoke
     * @param  apiVersion A decimal representing the apiVersion to request in the call
     * @return A ProductRegistryModel with all properties populated.
     ********************************************************************************************/
    public ProductRegistryModel(String name, String action, String namespace, String classname, Decimal apiVersion) {
        this.name = name;
        this.action = action;
        this.namespace = namespace;
        this.classname = classname;
        this.apiVersion = apiVersion;
    }
}
