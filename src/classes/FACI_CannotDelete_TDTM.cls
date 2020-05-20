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
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTEFACRRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2020
* @group Facilities
* @group-content ../../ApexDocContent/Facilities.htm
* @description Stops a Facilities from being deleted if it has any Facilities or Course Offering child records.
*/
public with sharing class FACI_CannotDelete_TDTM extends TDTM_Runnable {
    /*******************************************************************************************************
    * @description Get the setting of preventing Facilities deletion
    */
    private static Boolean enabledPreventFacilitiesDeletion = UTIL_CustomSettingsFacade.getSettings().Prevent_Facility_Deletion__c;

    /*******************************************************************************************************
    * @description Stops a Facility from being deleted if it has any Facility or Course Offering child records.
    * @param listNew the list of Facility from trigger new.
    * @param listOld the list of Facility from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Facility
    * @return dmlWrapper.
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        if (FACI_CannotDelete_TDTM.enabledPreventFacilitiesDeletion == False) {
            return new DmlWrapper(); 
        }

        Map<Id, Facility__c> oldMap = new Map<Id, Facility__c>((List<Facility__c>)oldList);

        if (triggerAction == TDTM_Runnable.Action.BeforeDelete) {
            for (Facility__c facility : [SELECT ID,
                                        (SELECT ID FROM Facility__c.Facilities__r LIMIT 1),
                                        (SELECT ID FROM Facility__c.Course_Offerings__r LIMIT 1)
                                        FROM Facility__c
                                        WHERE ID IN :oldlist])
            {
                if (this.hasChildRecords(facility)) {
                    Facility__c facilityInContext = oldmap.get(facility.ID);
                    facilityInContext.addError(Label.CannotDelete);
                }
            }
        }

        return new DmlWrapper();
    }

    /*******************************************************************************************************
    * @description Evaluates whether the Facilities has any child related records.
    * @param facility is the current Facilities record.
    * @return Boolean.
    ********************************************************************************************************/
    @testVisible
    private Boolean hasChildRecords(Facility__c facility) {
        return (!facility.Facilities__r.isEmpty() || !facility.Course_Offerings__r.isEmpty());
    }
}