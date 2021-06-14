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
 * @description View Mapper class for Chatter Group Lookup Search functionality in EDA settings
 */
public virtual with sharing class ChatterGroupLookupResultVMapper {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static ChatterGroupLookupResultVMapper instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected ChatterGroupLookupResultVMapper() {
    }

    /******************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of ChatterGroupLookupResultVMapper.
     ******************************************************************************/
    public static ChatterGroupLookupResultVMapper getInstance() {
        if (instance == null) {
            instance = new ChatterGroupLookupResultVMapper();
        }

        return instance;
    }

    /************************************************************************************************************
     * @description Retrieve a list of sorted LookupResults representing a chatter group
     * @param chatterGroupNameMatch The string to match chatter group names to
     * @param recordLimit The number of records to limit the query to
     * @return A list of Lookup Results with a name matching the search string
     ************************************************************************************************************/
    public virtual List<LookupResult> getLookupResultsLikeChatterGroupName(
        String chatterGroupNameMatch,
        Integer recordLimit
    ) {
        List<ChatterGroupModel> chatterGroupModelList = this.locateChatterGroupService()
            .getChatterGroupModelsLikeName(chatterGroupNameMatch, recordLimit);
        List<LookupResult> lookupResultList = new List<LookupResult>();

        for (ChatterGroupModel chatterGroupModel : chatterGroupModelList) {
            lookupResultList.add(this.getLookupResultFromChatterGroupModel(chatterGroupModel));
        }

        lookupResultList.sort();
        return lookupResultList;
    }

    /************************************************************************************************************
     * @description Creates a lookup result from a chatter group model
     * @param ChatterGroupModel The chatter group model to convert to a Lookup Result
     * @return The lookup result
     ************************************************************************************************************/
    public virtual LookupResult getLookupResultFromChatterGroupModel(ChatterGroupModel chatterGroupModel) {
        return new LookupResult(
            chatterGroupModel.name,
            chatterGroupModel.id,
            'standard:groups',
            chatterGroupModel.smallPhotoUrl,
            Label.stgOptChatterGroup,
            this.truncateDescription(chatterGroupModel.description)
        );
    }

    /******************************************************************************
     * @description Truncates a string to 80 characters
     * @param description The description to truncate
     * @return The truncated string.
     ******************************************************************************/
    @TestVisible
    private String truncateDescription(String description) {
        if (String.isBlank(description) == false && description.length() > 80) {
            return description.substring(0, 77) + '...';
        }

        return description;
    }

    /******************************************************************************
     * @description Retrieves an instance of the ChatterGroupService class.
     * @return An instance of ChatterGroupService.
     ******************************************************************************/
    @TestVisible
    private ChatterGroupService locateChatterGroupService() {
        return ChatterGroupService.getInstance();
    }
}
