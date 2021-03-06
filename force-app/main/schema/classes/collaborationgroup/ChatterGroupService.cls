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
 * @description Service class to retrieve data needed for User Models
 */
public virtual with sharing class ChatterGroupService {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static ChatterGroupService instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected ChatterGroupService() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of ChatterGroupService.
     ******************************************************************************/
    public static ChatterGroupService getInstance() {
        if (instance == null) {
            instance = new ChatterGroupService();
        }

        return instance;
    }

    /************************************************************************************************************
     * @description Retrieve a ChatterGroupModel representing a chatter group and its basic fields
     * @param chatterGroupId The Id of the chatter group to retrieve
     * @return A ChatterGroupModel
     ************************************************************************************************************/
    public virtual ChatterGroupModel getChatterGroupModelById(Id chatterGroupId) {
        return this.locateChatterGroupMapper().getChatterGroupModelById(chatterGroupId);
    }

    /************************************************************************************************************
     * @description Retrieve a list of ChatterGroupModel representing a chatter group and their basic fields
     * @param chatterGroupNameMatch The string to match chatter group names to
     * @param recordLimit The number of records to limit the query to
     * @return A list of Chatter Group Models with names that match the search string
     ************************************************************************************************************/
    public virtual List<ChatterGroupModel> getChatterGroupModelsLikeName(
        String chatterGroupNameMatch,
        Integer recordLimit
    ) {
        return this.locateChatterGroupMapper().getChatterGroupModelsLikeName(chatterGroupNameMatch, recordLimit);
    }

    /******************************************************************************
     * @description Retrieves an instance of the ChatterGroupMapper class.
     * @return An instance of ChatterGroupMapper.
     ******************************************************************************/
    @TestVisible
    private ChatterGroupMapper locateChatterGroupMapper() {
        return ChatterGroupMapper.getInstance();
    }
}
