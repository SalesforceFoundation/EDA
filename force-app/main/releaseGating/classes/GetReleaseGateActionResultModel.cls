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
 * @description Model to represent Release gate get action result
 */
public with sharing class GetReleaseGateActionResultModel extends CallableResult {
    public GetReleaseGateResult[] result;

    public GetReleaseGateActionResultModel(GetReleaseGateResult[] result, Boolean success, CallableError error) {
        super(success, error);
        this.result = result;
    }

    public class GetReleaseGateResult {
        public ReleaseGateProduct product;
        public ReleaseGate[] gates;

        /*****************************************************************************************************************
         * @description Two argument constructor
         *****************************************************************************************************************/
        public GetReleaseGateResult(ReleaseGateProduct product, ReleaseGate[] gates) {
            this.product = product;
            this.gates = gates;
        }
    }

    public class ReleaseGateProduct {
        public String name;
        public String label;
        public String nextReleaseDate;

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
        public String name;
        public String label;
        public String description;
        public Date releaseDate;
        public Date dueDate;
        public String dueDateInfoText;
        public DateTime activationDate;
        public ReleaseGateFeature[] items;
        public String status;

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
            this.items = features;
        }
    }

    public class ReleaseGateFeature {
        public String name;
        public String label;
        public String description;
        public String helpLink;
        public String helpLinkLabel;

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
