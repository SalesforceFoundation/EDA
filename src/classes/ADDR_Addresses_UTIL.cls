/*
    Copyright (c) 2016, Salesforce.org
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
* @date 2016 
* @group Addresses
* @group-content ../../ApexDocContent/Addresses.htm
* @description Addresses utility methods.
*/
public with sharing class ADDR_Addresses_UTIL {
    
    /* @description map from Country name to Country Code */
    private static Map<String, String> validCountriesByLabel = new Map<String, String>();

    /* @description map from State name to State Code */
    private static Map<String, String> validStatesByLabel = new Map<String, String>();

    /* @description map from Country Code to Country Name */
    private static Map<String, String> validCountriesByCode = new Map<String, String>();
    
    /*******************************************************************************************************
    * @description returns whether the Address's mailing fields are null
    * @param addr the Address
    * @return Boolean. true if all of the Mailing fields are empty
    */ 
    public static Boolean isAddressEmpty(Address__c addr) {
        if (addr == null)
           return false;        
        return (addr.MailingStreet__c == Null && addr.MailingStreet2__c == Null && addr.MailingCity__c == Null &&
           addr.MailingState__c == Null && addr.MailingPostalCode__c == Null && addr.MailingCountry__c == Null);
    }
    
    /*******************************************************************************************************
    * @description utility to compare two address objects address fields
    * @param addrNew the new version of the Address
    * @param addrOld the old version of the Address
    * @param includeAddressType whether to include comparing the AddressType field
    * @return Boolean. true if any of the fields fields have changed on the Address
    */ 
    public static Boolean isAddressChanged(Address__c addrNew, Address__c addrOld, Boolean includeAddressType) {
        UTIL_Debug.debug('****isAddressChanged addrNew: ' + JSON.serializePretty(addrNew));
        UTIL_Debug.debug('****isAddressChanged addrOld: ' + JSON.serializePretty(addrOld));
        if (addrNew == null || addrOld == null) 
           return false;        
        return (
            addrNew.Default_Address__c != addrOld.Default_Address__c ||
           !equalsCaseSensitive(addrNew.MailingStreet__c, addrOld.MailingStreet__c) ||
           !equalsCaseSensitive(addrNew.MailingStreet2__c, addrOld.MailingStreet2__c) ||
           !equalsCaseSensitive(addrNew.MailingCity__c, addrOld.MailingCity__c) ||
           !equalsCaseSensitive(addrNew.MailingState__c, addrOld.MailingState__c) ||
           !equalsCaseSensitive(addrNew.MailingPostalCode__c, addrOld.MailingPostalCode__c) ||
           !equalsCaseSensitive(addrNew.MailingCountry__c, addrOld.MailingCountry__c) ||
           (includeAddressType && (!equalsCaseSensitive(addrNew.Address_Type__c, addrOld.Address_Type__c))));
    }
    
    /*******************************************************************************************************
    * @description compares two contacts' addresses
    * @param con1 a Contact
    * @param con2 a Contact
    * @return Boolean. true if the Mailing Address fields have changed 
    ********************************************************************************************************/
    public static Boolean isContactAddressChanged(Contact con1, Contact con2) {
        // if both null, no change
        if (con1 == null && con2 == null) 
           return false;

        // if one null, make sure other has at least one address field set
        if (con1 == null || con2 == null) {
            if (con1 == null) 
               con1 = con2;
            return (!isContactAddressEmpty(con1) ||
               con1.Primary_Address_Type__c != null);
        }
        
        // both provided, so look for at least one change between address fields
        Boolean isChanged = 
           !ADDR_Addresses_UTIL.equalsCaseSensitive(con1.MailingStreet, con2.MailingStreet) ||
           !ADDR_Addresses_UTIL.equalsCaseSensitive(con1.MailingCity, con2.MailingCity) ||
           !ADDR_Addresses_UTIL.equalsCaseSensitive(con1.MailingState, con2.MailingState) ||
           !ADDR_Addresses_UTIL.equalsCaseSensitive(con1.MailingPostalCode, con2.MailingPostalCode) ||
           !ADDR_Addresses_UTIL.equalsCaseSensitive(con1.MailingCountry, con2.MailingCountry) ||
           !ADDR_Addresses_UTIL.equalsCaseSensitive(con1.Primary_Address_Type__c, con2.Primary_Address_Type__c);
           
        if (!isChanged && ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
            isChanged = 
                !ADDR_Addresses_UTIL.equalsCaseSensitive(string.valueOf(con1.get('MailingStateCode')), string.valueOf(con2.get('MailingStateCode'))) || 
                !ADDR_Addresses_UTIL.equalsCaseSensitive(string.valueOf(con1.get('MailingCountryCode')), string.valueOf(con2.get('MailingCountryCode')));
        }    
        UTIL_Debug.debug('****Contact address changed: ' + isChanged);
        return isChanged;   
    }
    
    /*******************************************************************************************************
    * @description utility to compare two Accounts' (billing) addresses
    * @param acc1 an Account
    * @param acc2 an Account
    * @return Boolean. true if there are any changes between the two accounts.
    ********************************************************************************************************/
    public static Boolean isAccountAddressChanged(Account acc1, Account acc2) {
        if (acc1 == null || acc2 == null) 
           return false;
        
        Boolean isChanged = 
           !ADDR_Addresses_UTIL.equalsCaseSensitive(acc1.BillingStreet, acc2.BillingStreet) ||
           !ADDR_Addresses_UTIL.equalsCaseSensitive(acc1.BillingCity, acc2.BillingCity) ||
           !ADDR_Addresses_UTIL.equalsCaseSensitive(acc1.BillingState, acc2.BillingState) ||
           !ADDR_Addresses_UTIL.equalsCaseSensitive(acc1.BillingPostalCode, acc2.BillingPostalCode) ||
           !ADDR_Addresses_UTIL.equalsCaseSensitive(acc1.BillingCountry, acc2.BillingCountry);

        if (!isChanged && ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
            isChanged = 
                !ADDR_Addresses_UTIL.equalsCaseSensitive(string.valueOf(acc1.get('BillingStateCode')), string.valueOf(acc2.get('BillingStateCode'))) || 
                !ADDR_Addresses_UTIL.equalsCaseSensitive(string.valueOf(acc1.get('BillingCountryCode')), string.valueOf(acc2.get('BillingCountryCode')));
        }
        UTIL_Debug.debug('****Address changed: ' + isChanged);
        return isChanged;   

    }
    
    /*******************************************************************************************************
    * @description returns whether the contact's mailing address is empty
    * @param con1 a Contact
    * @return Boolean. true if the Mailing Address fields are all empty 
    ********************************************************************************************************/
    public static Boolean isContactAddressEmpty(Contact con1) {
        if(con1 == null)
            return true;
            
        Boolean isEmpty = 
            con1.MailingStreet == null &&
            con1.MailingCity == null &&
            con1.MailingState == null &&
            con1.MailingPostalCode == null &&
            // note that we decided to ignore country so that a default value won't create unnecessary address objects
            (con1.MailingCountry == null || ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) &&
            // only test StateCode if picklists enabled.
            (!ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled || con1.get('MailingStateCode') == null);
        return isEmpty;   
           
    }
    
    /*******************************************************************************************************
    * @description utility to see if an address is specified
    * @param acc1 an Account
    * @return Boolean.  true if an address is specified in any of the Account Billing fields
    ********************************************************************************************************/
    public static Boolean isAccAddressEmpty(Account acc1) {
        if (acc1 == null) 
           return true;
        
        Boolean isEmpty = 
           acc1.BillingStreet == null &&
           acc1.BillingCity == null &&
           acc1.BillingState == null &&
           acc1.BillingPostalCode == null &&
            // note that we decided to ignore country so that a default value won't create unnecessary address objects
           (acc1.BillingCountry == null || ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) &&
           // only test StateCode if picklists enabled.
           (!ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled || acc1.get('BillingStateCode') == null);
        return isEmpty;   
    }
    
    /*******************************************************************************************************
    * @description Returns whether two strings are equal, using a case sensitve comparison
    * @param str1 The first string
    * @param str2 The second string
    * @return Boolean 
    ********************************************************************************************************/
    public static Boolean equalsCaseSensitive(string str1, string str2) {
        if (str1 == null)
            return str2 == null;
        if (str2 == null)
            return false;
        return str1.equals(str2);
    }
    
    /*******************************************************************************************************
    * @description Compare two address objects address fields and support fuzzy matching; our definition of 
    * fuzzy is: only one field has changed, ignoring whitespace and letter casing changes.
    * @param addrNew the new version of the Address
    * @param addrOld the old version of the Address
    * @param includeAddressType whether to include comparing the AddressType field
    * @return Boolean true if no more than one of the fields have changed on the Address, ignoring whitespace and case changes
    */     
    private static Boolean isAddressMatchFuzzy(Address__c addrNew, Address__c addrOld, Boolean includeAddressType) {
        if (addrNew == null || addrOld == null) 
           return false;
           
        integer cChange = 0;
        if (strCleanup(addrNew.MailingStreet__c) != strCleanup(addrOld.MailingStreet__c) && addrOld.MailingStreet__c != null)
            cChange++;
        if (strCleanup(addrNew.MailingStreet2__c) != strCleanup(addrOld.MailingStreet2__c) && addrOld.MailingStreet2__c != null)
            cChange++;
        if (strCleanup(addrNew.MailingCity__c) != strCleanup(addrOld.MailingCity__c) && addrOld.MailingCity__c != null)
            cChange++;
        if (strCleanup(addrNew.MailingState__c) != strCleanup(addrOld.MailingState__c) && addrOld.MailingState__c != null)
            cChange++;
        if (strCleanup(addrNew.MailingPostalCode__c) != strCleanup(addrOld.MailingPostalCode__c) && addrOld.MailingPostalCode__c != null)
            cChange++;
        if (strCleanup(addrNew.MailingCountry__c) != strCleanup(addrOld.MailingCountry__c) && addrOld.MailingCountry__c != null)
            cChange++;
        if (includeAddressType && strCleanup(addrNew.Address_Type__c) != strCleanup(addrOld.Address_Type__c) && addrOld.Address_Type__c != null)
            cChange++;
        return cChange <= 1;
    }
    
    /*******************************************************************************************************
    * @description utility to remove all whitespace and to lowercase the string
    * @param str the string to clean up
    * @return string
    */ 
    private static string strCleanup(string str) {
        if (str != null) return str.replace(' ', '').toLowerCase();
        else return '';
    }
    
    /*******************************************************************************************************
    * @description Utility to copy Address fields between Address objects.
    * @param addrSrc the source Address
    * @param addrSrc the destination Address
    * @return void
    */ 
    public static void copyAddressObj(Address__c addrSrc, Address__c addrDst) {
        addrDst.MailingStreet__c = addrSrc.MailingStreet__c;
        addrDst.MailingStreet2__c = addrSrc.MailingStreet2__c;
        addrDst.MailingCity__c = addrSrc.MailingCity__c;
        addrDst.MailingState__c = addrSrc.MailingState__c;
        addrDst.MailingPostalCode__c = addrSrc.MailingPostalCode__c;
        addrDst.MailingCountry__c = addrSrc.MailingCountry__c;
        addrDst.Geolocation__Latitude__s = addrSrc.Geolocation__Latitude__s;
        addrDst.Geolocation__Longitude__s = addrSrc.Geolocation__Longitude__s;
        if (addrSrc.Address_Type__c != null)
            addrDst.Address_Type__c = addrSrc.Address_Type__c;
    }
    
     /*******************************************************************************************************
    * @description Utility to copy Address fields between Contacts and Accounts (or vice-versa).
    * Handles instances where State and Country picklists are enabled, and multiline street addresses.
    * @param sobjSrc the source Contact or Account
    * @param strFieldPrefixSrc the address fields to copy from, ie., Mailing, Other, Shipping, Billing
    * @param sobjDst the destination Contact or Account
    * @param strFieldPrefixDst the address fields to copy to, ie., Mailing, Other, Shipping, Billing
    * @return void
    */ 
    public static void copyAddressStdSObj(SObject sobjSrc, String strFieldPrefixSrc, SObject sobjDst, String strFieldPrefixDst) {
        sobjDst.put(strFieldPrefixDst + 'Street', sobjSrc.get(strFieldPrefixSrc + 'Street'));
        sobjDst.put(strFieldPrefixDst + 'City', sobjSrc.get(strFieldPrefixSrc + 'City'));
        sobjDst.put(strFieldPrefixDst + 'PostalCode', sobjSrc.get(strFieldPrefixSrc + 'PostalCode'));
        sobjDst.put(strFieldPrefixDst + 'State', sobjSrc.get(strFieldPrefixSrc + 'State'));
        sobjDst.put(strFieldPrefixDst + 'Country', sobjSrc.get(strFieldPrefixSrc + 'Country'));
        sobjDst.put(strFieldPrefixDst + 'Latitude', sobjSrc.get(strFieldPrefixSrc + 'Latitude'));
        sobjDst.put(strFieldPrefixDst + 'Longitude', sobjSrc.get(strFieldPrefixSrc + 'Longitude'));
        
        if (isStateCountryPicklistsEnabled) {
            sobjDst.put(strFieldPrefixDst + 'StateCode', sobjSrc.get(strFieldPrefixSrc + 'StateCode'));
            sobjDst.put(strFieldPrefixDst + 'CountryCode', sobjSrc.get(strFieldPrefixSrc + 'CountryCode'));
        }    
    }
    
    /*******************************************************************************************************
    * @description utility to copy Address fields from a Contact or Account to an Address object.
    * Handles instances where State and Country picklists are enabled, and multiline street addresses.
    * @param sobjSrc the source Contact or Account
    * @param strFieldPrefixSrc the address fields to copy from, ie., Mailing, Other, Shipping, Billing
    * @param addr the Address object to copy to
    * @param strAddrType if not null, copy to address.Address_Type__c
    * @return void
    */ 
    public static void copyAddressStdSObjAddr(SObject sobjSrc, string strFieldPrefixSrc, Address__c addr, string strAddrType) {
        addr.MailingStreet__c = (string)sobjSrc.get(strFieldPrefixSrc + 'Street');
        handleMultilineStreet(addr);
        addr.MailingCity__c = (string)sobjSrc.get(strFieldPrefixSrc + 'City');
        addr.MailingPostalCode__c = (string)sobjSrc.get(strFieldPrefixSrc + 'PostalCode');
        addr.MailingState__c = (string)sobjSrc.get(strFieldPrefixSrc + 'State');
        addr.MailingCountry__c = (string)sobjSrc.get(strFieldPrefixSrc + 'Country');
        addr.Geolocation__Latitude__s = (decimal)sobjSrc.get(strFieldPrefixSrc + 'Latitude');
        addr.Geolocation__Longitude__s = (decimal)sobjSrc.get(strFieldPrefixSrc + 'Longitude');
        
        // try to find state and country by code if they aren't specified?
        if (isStateCountryPicklistsEnabled) {

            // lookup country if needed, by country code
            string strCountryCode = (string)sobjSrc.get(strFieldPrefixSrc + 'CountryCode');
            if (addr.MailingCountry__c == null && strCountryCode != null) {
                addr.MailingCountry__c = validCountriesByCode.get(strCountryCode);
            }
            
            // lookup state if needed, by country code and state code.
            string strStateCode = (string)sobjSrc.get(strFieldPrefixSrc + 'StateCode');
            if (addr.MailingState__c == null && strCountryCode != null && strStateCode != null) {
                // assume it's a valid statecode
                addr.MailingState__c = strStateCode;
            }
        }
        
        // if specified, also include Address Type
        if (strAddrType != null) 
            addr.Address_Type__c = strAddrType;
    }

    /*******************************************************************************************************
    * @description Utility to copy Address fields from an Address object to a Contact or Account.
    * Handles instances where State and Country picklists are enabled, and multiline street addresses.
    * @param addr the Address object to copy from
    * @param sobjDst the destination Contact or Account
    * @param strFieldPrefix the address fields to copy to, ie., Mailing, Other, Shipping, Billing
    * @param strFieldAddrType an optional Address Type field on sobjDst to copy to 
    * @return void
    */ 
    public static void copyAddressAddrSObj(Address__c addr, SObject sobjDst, string strFieldPrefix, string strFieldAddrType, 
    TDTM_Runnable.DmlWrapper dmlWrapper) {
        sobjDst.put(strFieldPrefix + 'Street', getMultilineStreet(addr));
        sobjDst.put(strFieldPrefix + 'City', addr.MailingCity__c);
        sobjDst.put(strFieldPrefix + 'PostalCode', addr.MailingPostalCode__c);
        sobjDst.put(strFieldPrefix + 'Latitude', addr.Geolocation__Latitude__s);
        sobjDst.put(strFieldPrefix + 'Longitude', addr.Geolocation__Longitude__s);
        sobjDst.put('Current_Address__c', addr.Id);
        
        if (!isStateCountryPicklistsEnabled) {
            sobjDst.put(strFieldPrefix + 'State', addr.MailingState__c);
            sobjDst.put(strFieldPrefix + 'Country', addr.MailingCountry__c);
        } else {
            if (addr.MailingCountry__c != null) {
                if (validCountriesByLabel.containsKey(addr.MailingCountry__c)) {
                    sobjDst.put(strFieldPrefix + 'Country', addr.MailingCountry__c);
                    sobjDst.put(strFieldPrefix + 'CountryCode', validCountriesByLabel.get(addr.MailingCountry__c));
                } else if (validCountriesByCode.containsKey(addr.MailingCountry__c.toUpperCase())) {
                    sobjDst.put(strFieldPrefix + 'CountryCode', addr.MailingCountry__c.toUpperCase());
                    sobjDst.put(strFieldPrefix + 'Country', validCountriesByCode.get(addr.MailingCountry__c.toUpperCase()));
                } else {
                    // allow the invalid country to be placed in the country field, so Salesforce will generate the error.
                    sobjDst.put(strFieldPrefix + 'Country', addr.MailingCountry__c);
                }
            } else { // MailingCountry = null
                sobjDst.put(strFieldPrefix + 'CountryCode', null);
                sobjDst.put(strFieldPrefix + 'Country', null);
            }
            if (addr.MailingState__c != null) {             
                if (validStatesByLabel.containsKey(addr.MailingState__c)) {
                    sobjDst.put(strFieldPrefix + 'State', addr.MailingState__c);
                    sobjDst.put(strFieldPrefix + 'StateCode', validStatesByLabel.get(addr.MailingState__c));
                } else {
                    // too expensive for us to create the map of CountryCode|StateCode to StateLabel
                    // so we will just try to save any state that isn't a label as a code.
                    sobjDst.put(strFieldPrefix + 'StateCode', addr.MailingState__c.toUpperCase());
                }
            } else { // MailingState = null
                sobjDst.put(strFieldPrefix + 'StateCode', null);
                sobjDst.put(strFieldPrefix + 'State', null);   
            }
        }
        
        if (strFieldAddrType != null)
            sobjDst.put(strFieldAddrType, addr.Address_Type__c);
          
        UTIL_Debug.debug('****Object with copied address info: ' + JSON.serializePretty(sobjDst));
        if(dmlWrapper != null)
            dmlWrapper.objectsToUpdate.add(sobjDst);
    }
    
    /*******************************************************************************************************
    * @description utility to determine if the "State and Country Picklist" field feature is enabled in Salesforce
    * @return true if enabled; Fills 4 sets<> with a list of value codes and labels for each field
    */ 
    private static Boolean initValidStateCountryCodes() {

        // If State & Country Picklists are enabled in the org, build maps of the
        // valid Labels and Codes for each field to use for validation
        map<String, Schema.SObjectField> acctFields = Account.getSobjectType().getDescribe().fields.getMap();
        Boolean isCodesEnabled = acctFields.containsKey('BillingCountryCode');
        if (isCodesEnabled) {
            list<Schema.Picklistentry> countryPLValues = acctFields.get('BillingCountryCode').getDescribe().getPicklistValues();
            for (Schema.Picklistentry p : countryPLValues) {
                if (p.isActive()) { 
                    validCountriesByLabel.put(p.getLabel(), p.getValue()); 
                    validCountriesByCode.put(p.getValue(), p.getLabel());
                }
            }
            list<Schema.Picklistentry> statePLValues = acctFields.get('BillingStateCode').getDescribe().getPicklistValues();
            for (Schema.Picklistentry p : statePLValues) {
                if (p.isActive()) { 
                    validStatesByLabel.put(p.getLabel(), p.getValue());
                    // we can't have a map of valid StateCodes, because they are not unique.
                    // ideally we would have a map of CountryCode + StateCode -> StateLabel
                    // but Salesforce provides us no way of figuring out picklist dependencies efficiently. 
                }
            }
        }
        return isCodesEnabled;
    }
    
    /*******************************************************************************************************
    * @description utility to see if the address has only a subset of its seasonal fields set
    * @param addr the Address to look at
    * @return Boolean
    */ 
    public static void handleMultilineStreet(Address__c addr) {
    
        if (addr.MailingStreet__c == null)
            return;
        
        // handle CR NL
        integer ich = addr.MailingStreet__c.indexOf('\r\n');
        if (ich > -1) {
            addr.MailingStreet2__c = addr.MailingStreet__c.substring(ich+2);
            addr.MailingStreet__c = addr.MailingStreet__c.left(ich);
            return;
        }
        
        // handle just NL
        ich = addr.MailingStreet__c.indexOf('\n');
        if (ich > -1) {
            addr.MailingStreet2__c = addr.MailingStreet__c.substring(ich+1);
            addr.MailingStreet__c = addr.MailingStreet__c.left(ich);
            return;
        }
    }
    
    /*******************************************************************************************************
    * @description utility to see if the address has only a subset of its seasonal fields set
    * @param addr the Address to look at
    * @return Boolean
    */ 
    public static string getMultilineStreet(Address__c addr) {
        string str = addr.MailingStreet__c;
        if (addr.MailingStreet2__c != null && addr.MailingStreet2__c.length() > 0)
            str += '\r\n' + addr.MailingStreet2__c;
        return str;
    }
    
    /*******************************************************************************************************
    * @description specifies whether state and country picklists are enabled in this org.
    * @return true if enabled
    */ 
    public static Boolean isStateCountryPicklistsEnabled {
        get {
            if (isStateCountryPicklistsEnabled == null)
                isStateCountryPicklistsEnabled = initValidStateCountryCodes();
            return isStateCountryPicklistsEnabled;
        }
        private set;
    }
    
    /*******************************************************************************************************
    * @description For the list of Addresses, sees if there is already an existing Address in the Account that
    * matches. Creates only unique addresses from their respective household, and mark any existing matches 
    * as Default if the caller specifies it on the new address.
    * @param listAddr a list of Addresses to update
    * @param dmlWrapper the Addresses to update
    * @param includeAddressType whether to include comparing the AddressType field
    * @return void
    */ 
    public static NonDupeAddrs getNonDuplicateAddresses(list<Address__c> listAddr, Boolean includeAddressType) {  
        
        NonDupeAddrs nonDupeAddrs = new NonDupeAddrs();
        map<Address__c, Address__c> mapAddrDupAddr= findDuplicateAddresses(listAddr);
        for (Address__c addrNew : listAddr) {
            Address__c addrDup = mapAddrDupAddr.get(addrNew);
            if (addrDup != null) {
                // if it is a fuzzy match, not exact, then we want to update the existing address.
                if (isAddressChanged(addrNew, addrDup, includeAddressType)) {
                    copyAddressObj(addrNew, addrDup);
                    if (addrNew.Default_Address__c) {
                        addrDup.Default_Address__c = true;
                    }
                    nonDupeAddrs.updatedAddrs.add(addrDup);
                } else if (addrNew.Default_Address__c && !addrDup.Default_Address__c) {
                    addrDup.Default_Address__c = true;
                    nonDupeAddrs.updatedAddrs.add(addrDup);
               }
            } else { 
                 nonDupeAddrs.newAddrs.add(addrNew);
            } 
        }

        UTIL_Debug.debug('****addrsToInsert: ' + JSON.serializePretty(nonDupeAddrs.newAddrs));
        UTIL_Debug.debug('****addrsToUpdate: ' + JSON.serializePretty(nonDupeAddrs.updatedAddrs));
        return nonDupeAddrs;
    }
    
    public class NonDupeAddrs {
        public List<Address__c> newAddrs;
        public List<Address__c> updatedAddrs;
        
        public NonDupeAddrs() {
            newAddrs = new List<Address__c>();
            updatedAddrs = new List<Address__c>();
        }
        
        public void performDml() {
            if(newAddrs.size() > 0) {
                insert newAddrs;
            }
            if(updatedAddrs.size() > 0) {
                update updatedAddrs;
            }
        }
    }
    
    /*******************************************************************************************************
    * @description for the given addresses, find if they have a match, and return a map that
    * has null for no match, and the matching address if there is a match.
    * @param listAddr a list of Addresses to update
    * @return map<Address__c, Address__c>
    */ 
    public static map<Address__c, Address__c> findDuplicateAddresses(list<Address__c> listAddr) {      
        // for each address, create a map of Parent ID to lists of Addresses
        list<Id> listParentId = new list<Id>();
        for (Address__c addr : listAddr) {
            if(addr.Parent_Account__c != null) {
                listParentId.add(addr.Parent_Account__c);
            } else if(addr.Parent_Contact__c != null) {
                listParentId.add(addr.Parent_Contact__c);
            }
        }
        map<Id, list<Address__c>> mapParentIdToAddrs = getMapParentIdListAddrs(listParentId);
        Boolean tryFuzzy = UTIL_CustomSettingsFacade.getSettings().Simple_Address_Change_Treated_as_Update__c;
        
        // create our map for returning information in
        map<Address__c, Address__c> mapAddrDupAddr = new map<Address__c, Address__c>();
        
        // now compare our Addresses to the existing Addresses
        for (Address__c addr : listAddr) {
            list<Address__c> childAddrs;
            if(addr.Parent_Account__c != null) {
                childAddrs = mapParentIdToAddrs.get(addr.Parent_Account__c);
            } else if(addr.Parent_Contact__c != null) {
                childAddrs = mapParentIdToAddrs.get(addr.Parent_Contact__c);
            }
            
            Boolean hasMatch = false;
            if (childAddrs != null) {
                Address__c addrMatch = null;
                for (Address__c childAddr : childAddrs) {
                    // only include address type in the test if the new one isn't empty.
                    if (!isAddressChanged(addr, childAddr, addr.Address_Type__c != null)) {
                        // found exact match, record it and bail out
                        addrMatch = childAddr;
                        break;
                    }
                    if (tryFuzzy && isAddressMatchFuzzy(addr, childAddr, addr.Address_Type__c != null)) {
                        // found fuzzy match, remember it and continue searching
                        addrMatch = childAddr;
                        continue;
                    }
                }
                if (addrMatch != null) {
                    hasMatch = true;
                    mapAddrDupAddr.put(addr, addrMatch);
                }
            }
            if (!hasMatch)
                mapAddrDupAddr.put(addr, null);
        }
        return mapAddrDupAddr;               
    }
    
    /*******************************************************************************************************
    * @description utility to create a map of parent Id to a list of Addresses in that record, given a list of parent Ids.
    * @param listAccId the list of Account Id's
    * @return map<Id, list<Address__c>> map that contains the Addresses for each HH Account Id
    */ 
    public static map<Id, list<Address__c>> getMapParentIdListAddrs(list<Id> listParentId) {
          
        list<Address__c> listAddrOther = [select Id, Default_Address__c, Parent_Account__c, Parent_Contact__c, Address_Type__c,
            MailingStreet__c, MailingStreet2__c, MailingCity__c, MailingState__c, MailingPostalCode__c, MailingCountry__c, 
            Seasonal_Start_Year__c, Seasonal_End_Year__c, Seasonal_Start_Month__c, Seasonal_Start_Day__c, Seasonal_End_Month__c, 
            Seasonal_End_Day__c, Geolocation__Latitude__s, Geolocation__Longitude__s from Address__c where Parent_Account__c 
            IN :listParentId or Parent_Contact__c in :listParentID order by Default_Address__c desc, LastModifiedDate asc]; // ordering needed by cleanupAccountAddresses().
        
        map<Id, list<Address__c>> mapParentIdListAddrs = new map<Id, list<Address__c>>();   
        for (Address__c addr : listAddrOther) { 
            if(addr.Parent_Account__c != null) {
                list<Address__c> listAddrParentAccs = mapParentIdListAddrs.get(addr.Parent_Account__c);
                if (listAddrParentAccs == null) {
                    listAddrParentAccs = new List<Address__c>();
                    mapParentIdListAddrs.put(addr.Parent_Account__c, listAddrParentAccs);
                }
                listAddrParentAccs.add(addr);
            }
            
            if(addr.Parent_Contact__c != null) {
                list<Address__c> listAddrParentContacts = mapParentIdListAddrs.get(addr.Parent_Contact__c);
                if (listAddrParentContacts == null) {
                    listAddrParentContacts = new List<Address__c>();
                    mapParentIdListAddrs.put(addr.Parent_Contact__c, listAddrParentContacts);
                }
                listAddrParentContacts.add(addr);
            } 
        }
        return mapParentIdListAddrs;
    }
    
    /*******************************************************************************************************
    * @description Updates the Latest date fields on any address overrides
    * @param mapAddrIdIsOverride map of Address Id's to an isOverride boolean
    * @param dmlWrapper to hold the Addresses that need updating 
    * @return void  
    ********************************************************************************************************/
    public static void updateAddrIsOverride(Map<Id, boolean> mapAddrIdIsOverride, TDTM_Runnable.DmlWrapper dmlWrapper) {
        UTIL_Debug.debug('****mapAddrIdIsOverride: ' + JSON.serializePretty(mapAddrIdIsOverride));
        for (ID id : mapAddrIdIsOverride.keySet()) {
            Address__c addr = new Address__c();
            addr.Id = id;
            if (mapAddrIdIsOverride.get(id) == true) {
                UTIL_Debug.debug('****Updating latest start date and latest end date');
                addr.Latest_Start_Date__c = system.today();
                addr.Latest_End_Date__c = null;
            } else {
                UTIL_Debug.debug('****Updating only latest end date');
                addr.Latest_End_Date__c = system.today();
            }
            dmlWrapper.objectsToUpdate.add(addr);
        }
    }
    
    public static void clearAddrInfo(Account acc) {
        acc.BillingStreet = null;
        acc.BillingCity = null;
        acc.BillingState = null;
        acc.BillingPostalCode = null;
        acc.BillingCountry = null;
        acc.BillingLatitude = null;
        acc.BillingLongitude = null;
        if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
            acc.BillingCountry = null;
            acc.BillingState = null;   
        }
    }
    
    public static void clearAddrInfo(Contact contact) {
        contact.MailingStreet = null;
        contact.MailingCity = null;
        contact.MailingState = null;
        contact.MailingPostalCode = null;
        contact.MailingCountry = null;
        contact.MailingLatitude = null;
        contact.MailingLongitude = null;
    }
    
    
}