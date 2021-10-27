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
 * @description View model to abstract data needed to populate a Settings Product Information (product tiles) in
 * the Education Cloud Settings page.
 */
public virtual class EDCSettingsProductVModel {
    @AuraEnabled
    public String initials { get; private set; }
    @AuraEnabled
    public String name { get; private set; }
    @AuraEnabled
    public String description { get; private set; }
    @AuraEnabled
    public String settingsComponent { get; private set; }
    @AuraEnabled
    public String settingsButtonA11y { get; private set; }
    @AuraEnabled
    public String documentationUrl { get; private set; }
    @AuraEnabled
    public String documentationButtonA11y { get; private set; }
    @AuraEnabled
    public String trailheadUrl { get; private set; }
    @AuraEnabled
    public String trailheadButtonA11y { get; private set; }
    @AuraEnabled
    public String icon { get; private set; }

    /********************************************************************************************
     * @description Ten argument constructor
     * @param  initials             A string representing the product initials
     * @param  name                 A string representing the product name
     * @param  description          A string representing the product description
     * @param  settingsComponent    A string representing the component the Settings link will redirect to
     * @param  settingsButtonA11y   A string representing the title property value for the settings button
     * @param  documentationUrl     A string representing the url to the documentation
     * @param  documentationButtonA11y A string representing the title property value for the documentation button
     * @param  trailheadUrl         A string representing the trailhead url
     * @param  trailheadButtonA11y  A string representing the title property value for the trailhead button
     * @param  icon                 A string representing the icon to use
     * @return                      A EDCSettingsProductVModel with all its properties populated
     ********************************************************************************************/
    public EDCSettingsProductVModel(
        String initials,
        String name,
        String description,
        String settingsComponent,
        String settingsButtonA11y,
        String documentationUrl,
        String documentationButtonA11y,
        String trailheadUrl,
        String trailheadButtonA11y,
        String icon
    ) {
        this.initials = initials;
        this.name = name;
        this.description = description;
        this.settingsComponent = settingsComponent;
        this.settingsButtonA11y = settingsButtonA11y;
        this.documentationUrl = documentationUrl;
        this.documentationButtonA11y = documentationButtonA11y;
        this.trailheadUrl = trailheadUrl;
        this.trailheadButtonA11y = trailheadButtonA11y;
        this.icon = icon;
    }
}
