/*
    Copyright (c) 2020, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
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
* @group 
* @group-content ../../ApexDocContent/
* @description Model class for Preferred Email functionality to store email field models, standard email field label
* Alternate Email preferred email, Preferred Email validaiton enabled custom setting's value and preferredEmailPicklistLabelByApiName map
*/
public class MODL_PreferredEmailSettings {

    public List<MODL_PreferredEmailField> preferredEmailFieldModels { get; private set; }
    public String alternateEmailPreferredLabel { get; private set; }
    public String emailLabel { get; private set; }
    public Boolean preferredEmailValidationEnabled { get; private set; }
    public Map<String, String> preferredEmailPicklistLabelByApiName { get; private set; }

    /* Constructor to set the properties */
    public MODL_PreferredEmailSettings(List<MODL_PreferredEmailField> preferredEmailFieldModels, String alternateEmailPreferredLabel, String emailLabel, 
                                       Boolean preferredEmailValidationEnabled, Map<String,String> preferredEmailPicklistLabelByApiName) {

        this.preferredEmailFieldModels = preferredEmailFieldModels;
        this.alternateEmailPreferredLabel = alternateEmailPreferredLabel;
        this.emailLabel = emailLabel;
        this.preferredEmailValidationEnabled = preferredEmailValidationEnabled;
        this.preferredEmailPicklistLabelByApiName = preferredEmailPicklistLabelByApiName;

    }
}