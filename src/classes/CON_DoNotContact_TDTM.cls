/*
    Copyright (c) 2015, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
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
* @author Salesforce.com Foundation
* @date 2015
* @group Contacts
* @group-content ../../ApexDocContent/Contacts.htm
* @description Handles changes to the deceased and do not contact fields on Contact.
*/
public class CON_DoNotContact_TDTM extends TDTM_Runnable {
    
    /*******************************************************************************************************
    * @description Handles deceased and do not contact fields.
    * @param listNew the list of Accounts from trigger new. 
    * @param listOld the list of Accounts from trigger old. 
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.). 
    * @param objResult the describe for Accounts 
    * @return dmlWrapper.  
    ********************************************************************************************************/
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        for (integer i=0; i<newlist.size();i++) {

            Contact con = (Contact)newlist[i];
            
            if (triggerAction == TDTM_Runnable.Action.BeforeInsert) {
                if (con.Deceased__c)
                    markContactDeceased(con);
                else if (con.Do_Not_Contact__c)
                    markContactDoNotContact(con);
            }
            
            if (triggerAction == TDTM_Runnable.Action.BeforeUpdate) {
                Contact oldCon = (Contact)oldlist[i];

                //deceased and do not contact: updates related fields for both checking and unchecking the box.
                //prefers deceased as the deceased already marks the Do Not Contact fields, in case the user changes both values.
                if (con.Deceased__c != oldCon.Deceased__c)
                    markContactDeceased(con);
                else if (con.Do_Not_Contact__c != oldCon.Do_Not_Contact__c)
                    markContactDoNotContact(con);
            }
        }
        
        return new DmlWrapper();
	}
    
    /*******************************************************************************************************
    * @description Toggles additional Contact fields as necessary when a contact is flagged as deceased. 
    * @param con The Contact record.
    * @return void.  
    ********************************************************************************************************/
    public void markContactDeceased(Contact con) {

        con.Do_Not_Contact__c = con.Deceased__c;
        markContactDoNotContact(con);

        con.Exclude_from_Household_Name__c = con.Deceased__c;
        con.Exclude_from_Household_Formal_Greeting__c = con.Deceased__c;
        con.Exclude_from_Household_Informal_Greeting__c = con.Deceased__c;
        
        copyNamingExclusionsFromCheckboxes(con);
    }

	/*******************************************************************************************************
    * @description Toggles additional Contact fields as necessary when a contact is flagged as "do not contact". 
    * @param con The Contact record.
    * @return void.  
    ********************************************************************************************************/
    public void markContactDoNotContact(Contact con) {

        con.HasOptedOutOfEmail = con.Do_Not_Contact__c;
        con.DoNotCall = con.Do_Not_Contact__c;

    }
    
    /*******************************************************************************************************
    * @description Copies the values from the naming exclusions checkboxes to the multiselect picklist.
    * @param con The Contact 
    * @return void
    ********************************************************************************************************/
    public static void copyNamingExclusionsFromCheckboxes(Contact con) {
        string mspValue = '';
        
        if (con.Exclude_from_Household_Name__c)
            mspValue += 'Household__c.Name;';
        if (con.Exclude_from_Household_Formal_Greeting__c)
            mspValue += 'Household__c.Formal_Greeting__c;';
        if (con.Exclude_from_Household_Informal_Greeting__c)
            mspValue += 'Household__c.Informal_Greeting__c;';
        
        if (mspValue.endsWith(';'))
            mspValue = mspValue.substring(0,mspValue.length()-1);

        con.Naming_Exclusions__c = mspValue;
    }
}