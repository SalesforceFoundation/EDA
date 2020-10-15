/*
    Copyright (c) 2015, Salesforce.org
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
* @date 2015
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Populates default email and phone fields according to user preferences.
*/
public class CON_Preferred_TDTM extends TDTM_Runnable {

    /*******************************************************************************************************
    * @description Updates default email and phone fields based to the preferred email and preferred phone values.
    * @return dmlWrapper
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist,
                                   List<SObject> oldlist,
                                   TDTM_Runnable.Action triggerAction,
                                   Schema.DescribeSObjectResult objResult) {
            
        if (newList == null || newList.isEmpty()) {
            return null;
        }
        
        if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
            this.handleBeforeInsert(newList);
        }
        
        if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
            this.handleBeforeUpdate(newList, oldList);
        }
        
        return null;
    }

    private List<Contact> handleBeforeInsert(List<SObject> newList) {

        if (this.isRecursion() == true) {
            return new List<Contact>();
        }
        
        this.setRecursion();

        List<Contact> modifiedContactList = new List<Contact>();
        List<Contact> newContactList = (List<Contact>)newList;

        Boolean isNewPreferredPhoneFunctionalityEnabled = this.isNewPreferredPhoneFunctionalityEnabled();
        MODL_PreferredEmailSettings preferredEmailSettings = this.locatePreferredEmailMapper().getPreferredEmailSettingsModel();

        for (Contact eachContact: newContactList) {

            if (!String.isBlank(eachContact.PreferredPhone__c) && !isNewPreferredPhoneFunctionalityEnabled) {
                if(eachContact.PreferredPhone__c == 'Home' || eachContact.PreferredPhone__c == 'Home Phone') {
                    eachContact.Phone = eachContact.HomePhone;
                } else if(eachContact.PreferredPhone__c == 'Work' || eachContact.PreferredPhone__c == 'Work Phone') {
                    eachContact.Phone = eachContact.WorkPhone__c;
                } else if(eachContact.PreferredPhone__c == 'Mobile' || eachContact.PreferredPhone__c == 'Mobile Phone') {
                    eachContact.Phone = eachContact.MobilePhone;
                } else if(eachContact.PreferredPhone__c == 'Other' || eachContact.PreferredPhone__c == 'Other Phone') {
                    eachContact.Phone = eachContact.OtherPhone;
                }
            }

            contact modifiedContact = this.locateContactEmailService().processPreferredEmailForInsert(eachContact, preferredEmailSettings);
            
            if (modifiedContact != null) {
                modifiedContactList.add(modifiedContact);
            }
        }
        
        this.unsetRecursion();

        return modifiedContactList;
    }

    private List<Contact> handleBeforeUpdate(List<SObject> newList, List<SObject> oldList) {

        if (this.isRecursion() == true) {
            return new List<Contact>();
        }

        this.setRecursion();
        
        Map<Id, Contact> oldContactById = new Map<Id, Contact>((List<Contact>)oldList);
        Map<Id, Contact> newContactById = new Map<Id, Contact>((List<Contact>)newList);
        
        List<Contact> modifiedContactList = new List<Contact>();
        Boolean isNewPreferredPhoneFunctionalityEnabled = this.isNewPreferredPhoneFunctionalityEnabled();
        
        for (Contact eachContact: newContactById.values()) {
            
            if (!String.isBlank(eachContact.PreferredPhone__c) && !isNewPreferredPhoneFunctionalityEnabled) {
                if (eachContact.PreferredPhone__c == 'Home' || eachContact.PreferredPhone__c == 'Home Phone') {
                    eachContact.Phone = eachContact.HomePhone;
                } else if (eachContact.PreferredPhone__c == 'Work' || eachContact.PreferredPhone__c == 'Work Phone') {
                    eachContact.Phone = eachContact.WorkPhone__c;
                } else if (eachContact.PreferredPhone__c == 'Mobile' || eachContact.PreferredPhone__c == 'Mobile Phone') {
                    eachContact.Phone = eachContact.MobilePhone;
                } else if (eachContact.PreferredPhone__c == 'Other' || eachContact.PreferredPhone__c == 'Other Phone') {
                    eachContact.Phone = eachContact.OtherPhone;
                }
            }

            MODL_PreferredEmailSettings preferredEmailSettings = this.locatePreferredEmailMapper().getPreferredEmailSettingsModel();
            Contact modifiedContact = this.locateContactEmailService().processPreferredEmailForUpdate(eachContact, oldContactById.get(eachContact.Id), preferredEmailSettings);

            if (modifiedContact != null) {
                modifiedContactList.add(modifiedContact);
            }
        }

        this.unsetRecursion();

        return modifiedContactList;
        
    }

    public SRVC_Contact_PreferredEmail locateContactEmailService() {
        return SRVC_Contact_PreferredEmail.getInstance();
    }

    public MAPR_CON_PreferredEmailFields locatePreferredEmailMapper() {
        return MAPR_CON_PreferredEmailFields.getInstance();
    }

    public void setRecursion() {
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, true);
    }

    public void unsetRecursion() {
        TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM, false);
    }

    public boolean isRecursion() {
        return TDTM_ProcessControl.getRecursionFlag(TDTM_ProcessControl.registeredTrigger.CON_Preferred_TDTM);
    }

    public boolean isNewPreferredPhoneFunctionalityEnabled() {
        return (UTIL_CustomSettingsFacade.getSettings().Enable_New_Preferred_Phone_Sync__c == true);
    }


}