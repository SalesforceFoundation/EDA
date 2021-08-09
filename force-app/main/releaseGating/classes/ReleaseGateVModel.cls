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
 * @description VModel to represent data required for ReleaseGate.
 */
public with sharing class ReleaseGateVModel {
    @AuraEnabled
    public ReleaseGateProduct product { get; private set; }
    @AuraEnabled
    public List<ReleaseGate> gates { get; private set; }

    /*****************************************************************************************************************
     * @description Two argument constructor
     *****************************************************************************************************************/
    public ReleaseGateVModel(ReleaseGateProduct product, List<ReleaseGate> gates) {
        this.product = product;
        this.gates = gates;
    }

    public class ReleaseGateProduct {
        @AuraEnabled
        public String name { get; private set; }
        @AuraEnabled
        public String label { get; private set; }
        @AuraEnabled
        public String nextReleaseDate { get; private set; }

        /*****************************************************************************************************************
         * @description Three argument constructor
         *****************************************************************************************************************/
        public ReleaseGateProduct(String name, String label, String nextReleaseDate) {
            this.name = name;
            this.label = label;
            this.nextReleaseDate = nextReleaseDate;
        }
    }

    public class ReleaseGate {
        @AuraEnabled
        public String name { get; private set; }
        @AuraEnabled
        public String label { get; private set; }
        @AuraEnabled
        public String description { get; private set; }
        @AuraEnabled
        public Date releaseDate { get; private set; }
        @AuraEnabled
        public Date dueDate { get; private set; }
        @AuraEnabled
        public String dueDateInfoText { get; private set; }
        @AuraEnabled
        public Datetime activationDate { get; private set; }
        @AuraEnabled
        public String status { get; private set; }
        @AuraEnabled
        public List<ReleaseGateFeature> features { get; private set; }

        /*****************************************************************************************************************
         * @description Nine argument constructor
         *****************************************************************************************************************/
        public ReleaseGate(
            String name,
            String label,
            String description,
            Date releaseDate,
            Date dueDate,
            String dueDateInfoText,
            Datetime activationDate,
            String status,
            List<ReleaseGateFeature> features
        ) {
            this.name = name;
            this.label = label;
            this.description = description;
            this.releaseDate = releaseDate;
            this.dueDate = dueDate;
            this.dueDateInfoText = dueDateInfoText;
            this.activationDate = activationDate;
            this.status = status;
            this.features = features;
        }
    }

    public class ReleaseGateFeature {
        @AuraEnabled
        public String name { get; private set; }
        @AuraEnabled
        public String label { get; private set; }
        @AuraEnabled
        public String description { get; private set; }
        @AuraEnabled
        public String helpLink { get; private set; }
        @AuraEnabled
        public String helpLinkLabel { get; private set; }

        /*****************************************************************************************************************
         * @description Five argument constructor
         *****************************************************************************************************************/
        public ReleaseGateFeature(
            String name,
            String label,
            String description,
            String helpLink,
            String helpLinkLabel
        ) {
            this.name = name;
            this.label = label;
            this.description = description;
            this.helpLink = helpLink;
            this.helpLinkLabel = helpLinkLabel;
        }
    }
}
