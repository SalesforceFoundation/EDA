/*
    Copyright (c) 2019, Salesforce.org
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
* @date 2019
* @group Languages
* @group-content ../../ApexDocContent/Languages.htm
* @description TODO - FILL THIS IN
*/
public with sharing class CLAN_PrimaryLanguage_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description TODO - FILL THIS IN AND UPDATE PARAM DESCRIPTIONS
    * @param listNew the list of Contact Languages from trigger new.
    * @param listOld the list of Contact Languages from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Contact Languages.
    * @return dmlWrapper
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        DmlWrapper dmlWrapper = new DmlWrapper();

        if (newlist != null && newlist.size() > 0) {
            if (triggerAction == TDTM_Runnable.Action.AfterInsert) {
                // For all new Contact Language records that are marked as the Primary Language, query for other
                // existing Contact Language records that are already marked as the Primary Language for that
                // Contact and unset them. Update the Primary Language lookup on the Contact to the Language 
                // record of the Primary Language.
            }

            if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
                // For all updated Contact Language records that are marked as the Primary Language, query for other
                // existing Contact Language records that are already marked as the Primary Language for that
                // Contact and unset them. Update the Primary Language lookup on the Contact to the Language 
                // record of the Primary Language.

                // For all updated Contact Language records that are no longer marked as the Primary Language,
                // query for the Contact associated to those Primary Language records and unset the Primary Language
                // lookup (if the Language matches the Language of the Contact Language being updated.)
            }

            if (triggerAction == TDTM_Runnable.Action.AfterDelete) {
                // For all Contact Language records that are being deleted that were set as the Primary Language,
                // query for the Contact associated to those Primary Language records and unset the Primary Language
                // lookup (if the Language matches the Language of the Contact Language being deleted.)
            }
        }

        // TODO: Remember to set recursion flag so that if we're updating contact language records we don't run through this trigger again?
        //dmlWrapper.objectsToUpdate.addAll((List<SObject>)courseOfferingsToUpdate);

        return dmlWrapper;
    }
}