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
    * @description Utility to copy Address fields between to Address objects.
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
    public static void copyAddressStdSObj(sobject sobjSrc, string strFieldPrefixSrc, sobject sobjDst, string strFieldPrefixDst) {
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
    public static void copyAddressStdSObjAddr(sobject sobjSrc, string strFieldPrefixSrc, Address__c addr, string strAddrType) {
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
    public static void copyAddressAddrSObj(Address__c addr, sobject sobjDst, string strFieldPrefix, string strFieldAddrType) {
        sobjDst.put(strFieldPrefix + 'Street', getMultilineStreet(addr));
        sobjDst.put(strFieldPrefix + 'City', addr.MailingCity__c);
        sobjDst.put(strFieldPrefix + 'PostalCode', addr.MailingPostalCode__c);        
        sobjDst.put(strFieldPrefix + 'Latitude', addr.Geolocation__Latitude__s);
        sobjDst.put(strFieldPrefix + 'Longitude', addr.Geolocation__Longitude__s); 

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
    public static void createNonDuplicateAddresses(list<Address__c> listAddr, TDTM_Runnable.DmlWrapper dmlWrapper, 
    Boolean includeAddressType) {  
        
        map<Address__c, Address__c> mapAddrDupAddr= findDuplicateAddresses(listAddr);
        for (Address__c addrNew : listAddr) {
            Address__c addrDup = mapAddrDupAddr.get(addrNew);
            if (addrDup != null) {
                // if it is a fuzzy match, not exact, then we want to update the existing address.
                if (isAddressChanged(addrNew, addrDup, includeAddressType)) {
                    copyAddressObj(addrNew, addrDup);
                    if (addrNew.Default_Address__c)
                        addrDup.Default_Address__c = true;
                    dmlWrapper.objectsToUpdate.add(addrDup);
                } else if (addrNew.Default_Address__c && !addrDup.Default_Address__c) {
                    addrDup.Default_Address__c = true;
                    dmlWrapper.objectsToUpdate.add(addrDup);
               }
            } else {
                dmlWrapper.objectsToInsert.add(addrNew);
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
        // for each address, create a map of HHId to lists of Addresses
        list<Id> listAccId = new list<Id>();
        for (Address__c addr : listAddr)
           listAccId.add(addr.Parent_Account__c);
        map<Id, list<Address__c>> mapAccIdListAddrs = getmapAccIdListAddrs(listAccId);
        Boolean tryFuzzy = UTIL_CustomSettingsFacade.getSettings().Simple_Address_Change_Treated_as_Update__c;
        
        // create our map for returning information in
        map<Address__c, Address__c> mapAddrDupAddr = new map<Address__c, Address__c>();
        
        // now compare our Addresses to the existing Addresses
        for (Address__c addr : listAddr) {
            list<Address__c> listAddrHH = mapAccIdListAddrs.get(addr.Parent_Account__c);
            Boolean hasMatch = false;
            if (listAddrHH != null) {
                Address__c addrMatch = null;
                for (Address__c addrHH : listAddrHH) {
                    // only include address type in the test if the new one isn't empty.
                    if (!isAddressChanged(addr, addrHH, addr.Address_Type__c != null)) {
                        // found exact match, record it and bail out
                        addrMatch = addrHH;
                        break;
                    }
                    if (tryFuzzy && isAddressMatchFuzzy(addr, addrHH, addr.Address_Type__c != null)) {
                        // found fuzzy match, remember it and continue searching
                        addrMatch = addrHH;
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
    * @description utility to create a map of HH Account Id to a list of Addresses in that HH, given a list of HH Account Id.
    * @param listAccId the list of Account Id's
    * @return map<Id, list<Address__c>> map that contains the Addresses for each HH Account Id
    */ 
    public static map<Id, list<Address__c>> getmapAccIdListAddrs(list<Id> listAccId) {
        map<Id, list<Address__c>> mapAccIdListAddrs = new map<Id, list<Address__c>>();  
        list<Address__c> listAddrOther = [select Id, Default_Address__c, Parent_Account__c, Address_Type__c,
            MailingStreet__c, MailingStreet2__c, MailingCity__c, MailingState__c, MailingPostalCode__c, MailingCountry__c, Seasonal_Start_Year__c, Seasonal_End_Year__c,
            Seasonal_Start_Month__c, Seasonal_Start_Day__c, Seasonal_End_Month__c, Seasonal_End_Day__c, Geolocation__Latitude__s, Geolocation__Longitude__s
            from Address__c 
            where Parent_Account__c in :listAccId
            order by Default_Address__c desc, LastModifiedDate asc]; // ordering needed by cleanupAccountAddresses().
        for (Address__c addr : listAddrOther) {
            list<Address__c> listAddrHH = mapAccIdListAddrs.get(addr.Parent_Account__c);
            if (listAddrHH == null) {
                listAddrHH = new list<Address__c>();
                mapAccIdListAddrs.put(addr.Parent_Account__c, listAddrHH);
            }
            listAddrHH.add(addr);
        }
        return mapAccIdListAddrs;
    }
}