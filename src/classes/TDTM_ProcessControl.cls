/*
    Copyright (c) 2017, Salesforce.org
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
* @date 2017
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description Primary class for recursion process control logic shared across all TDTM classes
*/
public class TDTM_ProcessControl {
  	/*******************************************************************************************************
  	* @description Enum to define the various recursion prevention types used by all the related TDTM classes
  	*/
    public enum registeredTrigger {
        ACCT_IndividualAccounts_TDTM_After_Delete,
        ACCT_IndividualAccounts_TDTM_After_Insert,
        ACCT_IndividualAccounts_TDTM_After_Update,
        ADDR_Account_TDTM_After_Insert,
        ADDR_Account_TDTM_After_Update,
        ADDR_Addresses_TDTM_Before_Insert,
        ADDR_Addresses_TDTM_Before_Update,
        ADDR_Addresses_TDTM_After_Insert,
        ADDR_Addresses_TDTM_After_Update,
        ADDR_Addresses_TDTM_After_Delete,
        ADDR_Contact_TDTM_After_Insert,
        ADDR_Contact_TDTM_After_Update,
        AFFL_AccChange_TDTM,
        AFFL_ContactChange_TDTM,
        AFFL_MultiRecordType_TDTM_Before_Insert,
        AFFL_MultiRecordType_TDTM_After_Insert,
        AFFL_MultiRecordType_TDTM_After_Update,
        COFF_Affiliation_TDTM,
        CON_Preferred_TDTM,
        CON_PrimaryAffls_TDTM_After_Insert,
        CON_PrimaryAffls_TDTM_After_Update,
        AFFL_MultiRecordType_TDTM_afflMadePrimary,
        CON_PrimaryAffls_TDTM_keyAfflLookupUpdated
    }

    /*******************************************************************************************************
    * @description Map to track the specific recursion type status
    */
    private static Map<registeredTrigger, Integer> recursionMap = new Map<registeredTrigger, Integer>();

    public static void setRecursionFlag(registeredTrigger f, boolean b){
       Integer recursionFlag = (recursionMap.containsKey(f) ? recursionMap.get(f) : 0);
       recursionFlag += (b ? 1 : -1);
       if (recursionFlag < 0){
           recursionFlag = 0;
       }
       recursionMap.put(f, recursionFlag);
    }

    /*******************************************************************************************************
    * @description Map to track the specific recursion type status
    */
    public static Boolean getRecursionFlag(registeredTrigger f) {
       return (recursionMap.containsKey(f) ? recursionMap.get(f) : 0) > 0;
    }

    /*******************************************************************************************************
    * @description turn off the recursion flag manually. Set as 1001 because the limit is 1000 dml per transaction
    */
    public static void turnOffRecursionFlag(registeredTrigger f){
       recursionMap.put(f, 1001);
    }

    /*******************************************************************************************************
    * @description reset the recursion flag
    */
    public static void resetRecursionFlag(registeredTrigger f){
       recursionMap.put(f, 0);
    }  
}