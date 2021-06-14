/*
    Copyright (c) 2021, Salesforce.org
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
 * @date 2021
 * @group
 * @group-content ../../ApexDocContent/
 * @description Apex controller for errorSettings LWC component
 */
public with sharing class ErrorSettingsController {
    /*********************************************************************************************
     * @description Retrieve a view model representing the error settings in hierarchy settings.
     * @return An ErrorSettingsVModel
     *********************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static ErrorSettingsVModel getErrorSettingsViewModel() {
        try {
            return ErrorSettingsController.locateErrorSettingsVMapper().getErrorSettingsViewModel();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************************************
     * @description Retrieve a list of sorted LookupResults representing a user
     * @param userNameMatch The string to match user names to
     * @return A list of Lookup Results with a name matching the search string
     ************************************************************************************************************/
    @AuraEnabled
    public static List<LookupResult> getLookupResultsLikeUserName(String userNameMatch) {
        try {
            return ErrorSettingsController.locateUserLookupResultVMapper()
                .getLookupResultsLikeUserName(userNameMatch, 5);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /************************************************************************************************************
     * @description Retrieve a list of sorted LookupResults representing a chatter group
     * @param chatterGroupNameMatch The string to match chatter groups names to
     * @return A list of Lookup Results with a name matching the search string
     ************************************************************************************************************/
    @AuraEnabled
    public static List<LookupResult> getLookupResultsLikeChatterGroupName(String chatterGroupNameMatch) {
        try {
            return ErrorSettingsController.locateChatterGroupLookupResultVMapper()
                .getLookupResultsLikeChatterGroupName(chatterGroupNameMatch, 5);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /******************************************************************************
     * @description Retrieve an instance of the ErrorSettingsVMapper class.
     * @return An instance of ErrorSettingsVMapper
     ******************************************************************************/
    @TestVisible
    private static ErrorSettingsVMapper locateErrorSettingsVMapper() {
        return ErrorSettingsVMapper.getInstance();
    }

    /******************************************************************************
     * @description Retrieve an instance of the UserLookupResultVMapper class.
     * @return An instance of UserLookupResultVMapper
     ******************************************************************************/
    @TestVisible
    private static UserLookupResultVMapper locateUserLookupResultVMapper() {
        return UserLookupResultVMapper.getInstance();
    }

    /******************************************************************************
     * @description Retrieve an instance of the ChatterGroupLookupResultVMapper class.
     * @return An instance of ChatterGroupLookupResultVMapper
     ******************************************************************************/
    @TestVisible
    private static ChatterGroupLookupResultVMapper locateChatterGroupLookupResultVMapper() {
        return ChatterGroupLookupResultVMapper.getInstance();
    }
}
