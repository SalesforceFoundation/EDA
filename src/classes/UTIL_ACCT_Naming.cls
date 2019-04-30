/*
    Copyright (c) 2018, Salesforce.org
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
* @date 2018
* @group Utilities
* @description Utility for Naming
*/
public class UTIL_ACCT_Naming {
    /*******************************************************************************************************
    * @description The user defined Administrative Account record type.
    */
    private static ID userDefinedAdminRecordTypeId = Util_Describe.getAdminAccRecTypeID();

    /*******************************************************************************************************
    * @description update admin account names if any changes made to contacts' lastname
    * @param listContactsChangedLastName list of contacts whose lastnames are changed
    * @return list<Account>
    */
    public static list<Account> updateAdminAccountsName(List<Contact> listContactsChangedLastName) {
        List<Account> listAccToUpdate = new List<Account>();
        Map<Id, Contact> mapAccIdToCon = new Map<Id, Contact>();
        for (Contact con : listContactsChangedLastName) {
            mapAccIdToCon.put(con.AccountId, con);
        }

        List<Account> listAcc = [SELECT Id, RecordTypeId
                                FROM Account
                                WHERE Id IN :mapAccIdToCon.keySet()];
        for (Account acc : listAcc) {
            // only consider Admin Accounts
            if (acc.RecordTypeId == userDefinedAdminRecordTypeId) {
                acc.Name = UTIL_ACCT_Naming.strNameAdmAccountForContact(mapAccIdToCon.get(acc.Id));
                listAccToUpdate.add(acc);
            }
        }

        return listAccToUpdate;
    }

    /*******************************************************************************************************
    * @description update account names if any changes made to contacts' names or a new contact is linked the account
    * @param accIdsToRename set of account ids whose name need to be updated
    * @return void
    */
    public static void updateHHAccountsName(Set<Id> accIdsToRename) {
        List<Account> listAccsToRename = new List<Account>();

        //Build dynamic query string
        string strSoql = 'SELECT id, RecordTypeId, ';
        strSoql += '(SELECT id, AccountId,' +
                'Account.RecordTypeID, ' +
                'Account.Primary_Contact__c, Account.Name,' +
                'firstname, lastname, OwnerId, Salutation,' +
                'MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, ' +
                'OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, ';

        if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled)
            strSoql += 'MailingCountryCode, MailingStateCode, OtherCountryCode, OtherStateCode, ';

        strSoql += 'Phone, Fax FROM Contacts WHERE Exclude_from_Household_Name__c != true)';
        strSoql += 'FROM Account WHERE Id IN :accIdsToRename';

        //Re-query to get correct Account values (and all the other fields we will look at)
        listAccsToRename = database.query(strSoql);

        //Loop through listAccsToRename and modify the name accordingly
        for (Account acc : listAccsToRename) {
            acc.Name = strNameHHAccountForContact(acc.Contacts);
        }

        //TODO: We will need to work on DMLWrapper enhancements to check if a certain record is already in DMLwrapper
        //For now, we use direct DML statement to avoid duplicate id issue
        update listAccsToRename;
    }

    /*******************************************************************************************************
    * @description returns the default name for a new HH Account. Custom household naming will update this
    * account later if enabled, but we still need one if not enabled.
    * @param con the Contact
    * @return string. the Household account name
    */
    public static String strNameHHAccountForContact(List<Contact> cons) {
        String hhAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Account_Naming_Format__c;
        if (hhAccNamingFormat == Label.acctNamingOther) {
            hhAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Other_Name_Setting__c;
        }
        if (hhAccNamingFormat!= null) {
            return buildAccountName(cons, hhAccNamingFormat);
        } else {
            Set<String> householdLastNames = new Set<String>();
            for (Contact con : cons) {
                householdLastNames.add(con.LastName);
            }
            String name = '';
            Integer counter = 0;
            for (String lastName : householdLastNames) {
                name += lastName;
                counter++;
                if (counter < householdLastNames.size()) {
                    name += ' ' + Label.defaultNamingConnector +' ';
                }
            }
            return name + ' ' + System.label.DefaultHouseholdName;
        }
    }

    /*******************************************************************************************************
    * @description returns the default name for a new Administrative Account.
    * @param con the Contact
    * @return string. the Admin account name
    */
    public static String strNameAdmAccountForContact(Contact con) {
        String adminAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Account_Naming_Format__c;
        if (adminAccNamingFormat == Label.acctNamingOther) {
            adminAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Other_Name_Setting__c;
        }
        if (adminAccNamingFormat != null) {
            List<Contact> cons = new List<Contact>();
            cons.add(con);
            return buildAccountName(cons, adminAccNamingFormat);
        } else {
            return con.LastName + ' ' + System.label.DefaultAdminName;
        }
    }

    /*******************************************************************************************************
    * @description returns the default name for a new generic Account.
    * @param con the Contact
    * @return string. the generic account name
    */
    public static String strNameAccountForContact(Contact con) {
        return con.LastName + ' ' + System.label.DefaultAccountName;
    }

    /*******************************************************************************************************
    * @description format the account name based on naming settings
    * @param cons the Contacts need to format Account Name
    * @param setting the Account naming setting
    * @return string. the formatted account name
    */

    private static String buildAccountName(List<Contact> cons, String setting) {
        String nameContactFieldsString = '';
        String namePrefix = '';
        String nameSuffix = '';
        List<String> settingsSplitRightParenthesis = new List<String>();
        List<String> settingsSplitLeftParenthesis = new List<String>();
        Map<String, List<Contact>> mapLastNameContacts = new Map<String, List<Contact>>();
        Set<String> setContactFields = new Set<String>();
        List<String> listNameStrings = new List<String>();

        //Build the map of lastname and contacts
        mapLastNameContacts = buildMapLastNameContacts(cons);
        //get index of first parenthesis
        Integer indexFirstParenthesis = setting.indexOf('{!') > 0 ? setting.indexOf('{!') : 0;
        //get index of last parenthesis
        Integer indexAfterLastParenthesis = setting.lastIndexOf('}') > 0 ? setting.lastIndexOf('}') : setting.length()-1;
        while (indexAfterLastParenthesis < setting.length()-1
                && setting.subString(indexAfterLastParenthesis+1, indexAfterLastParenthesis+2) != ' ') {
            indexAfterLastParenthesis++;
        }
        //Build prefix
        namePrefix = setting.substring(0, indexFirstParenthesis);
        //Build Suffix
        nameSuffix = setting.substring(indexAfterLastParenthesis+1, setting.length());
        setting = setting.substring(indexFirstParenthesis, indexAfterLastParenthesis+1);

        //Split strings into a list
        List<String> settingsSplitSpace= setting.split(' ');
        for (String settingSplitSpace : settingsSplitSpace) {
            if (settingSplitSpace.contains('{!') && settingSplitSpace.contains('}')) {

                settingsSplitRightParenthesis = settingSplitSpace.split('}');

                for (String settingSplitRightParenthesis : settingsSplitRightParenthesis) {
                    if (settingSplitRightParenthesis.contains('{!')) {
                        settingsSplitLeftParenthesis = settingSplitRightParenthesis.split('\\{!');
                        for (String settingSplitLeftParenthesis : settingsSplitLeftParenthesis) {
                            if (UTIL_Describe.isValidField('Contact', settingSplitLeftParenthesis.toLowerCase())) {
                                setContactFields.add(settingSplitLeftParenthesis.toLowerCase());
                            }
                            if (settingSplitLeftParenthesis != '')
                                listNameStrings.add(settingSplitLeftParenthesis);
                        }
                    } else {
                        if (settingSplitRightParenthesis != '')
                            listNameStrings.add(settingSplitRightParenthesis);
                    }
                }
            } else {
                if (settingSplitSpace != '')
                    listNameStrings.add(settingSplitSpace);
            }
            listNameStrings.add(' ');
        }
        
        //Build nameContactFieldsString
        //If setContactFields has lastname, we need to group contacts by lastname
        if (setContactFields.contains('lastname')) {
            //Counter for last name loop
            Integer lnCounter = 0;
            for (String lastName : mapLastNameContacts.keySet()) {
                lnCounter++;
                //Adding connector only if a last name has more than two contacts
                //Starting at the second contact
                if (nameContactFieldsString != null
                    && nameContactFieldsString != ''
                    && mapLastNameContacts.keySet().size() > 1 
                    && lnCounter > 1) {
                    if (lnCounter != mapLastNameContacts.keySet().size()) {
                        nameContactFieldsString += ', ';
                    } else {
                        nameContactFieldsString += Label.defaultNamingConnector + ' ';
                    }
                }

                for (String nameString : listNameStrings) {
                    String conNameString = '';
                    if (UTIL_Describe.isValidField('Contact', nameString.toLowerCase())) {
                        if (nameString == 'lastname') {
                            conNameString += lastname;
                        } else {
                            Integer conCounter = 0;
                            for (Contact con : mapLastNameContacts.get(lastName)) {
                                conCounter++;
                                if (con.get(nameString) != null) {
                                    if (conNameString != null
                                            && conNameString != ''
                                            && mapLastNameContacts.get(lastName).size() > 1
                                            && conCounter > 1) {
                                        if (conCounter != mapLastNameContacts.get(lastName).size()) {
                                            conNameString += ', ';
                                        } else {
                                            conNameString += ' ' + Label.defaultNamingConnector + ' ';
                                        }
                                    }
                                    conNameString += con.get(nameString);
                                }
                            }
                        }
                        if (conNameString != null
                                && conNameString != '') {
                            nameContactFieldsString += conNameString;
                        }
                    } else {
                        nameContactFieldsString += nameString;
                    }
                }
            }
        } else {
            for (String nameString : listNameStrings) {
                String conNameString = '';
                Integer conCounter = 0;
                if (UTIL_Describe.isValidField('Contact', nameString.toLowerCase())) {
                    for (Contact con : cons) {
                        conCounter++;
                        if (con.get(nameString) != null) {
                            if (conNameString != null
                                    && conNameString != ''
                                    && cons.size() > 1
                                    && conCounter > 1) {
                                if (conCounter != cons.size()) {
                                    conNameString += ', ';
                                } else {
                                    conNameString += ' ' + Label.defaultNamingConnector + ' ';
                                }
                            }
                            conNameString += con.get(nameString);
                        }
                    }
                } else {
                    conNameString += nameString;
                }
                if (conNameString != null
                        && conNameString != '') {
                    nameContactFieldsString += conNameString;
                }
            }
        }
        nameContactFieldsString = nameContactFieldsString.trim();
        String accountName = namePrefix + nameContactFieldsString + nameSuffix;
        return accountName.trim();

    }

    /*******************************************************************************************************
    * @description build the name Map of last name and contacts with the same last names
    * @param cons list of sibling contacts
    * @return map<String, List<Contact>. the map of last name and list of contacts
    */
    private static Map<String, List<Contact>> buildMapLastNameContacts(List<Contact> cons) {
        Map<String, List<Contact>> mapLastNameContacts = new Map<String, List<Contact>>();
        for (Contact con : cons) {
            if (mapLastNameContacts.containsKey(con.LastName)) {
                mapLastNameContacts.get(con.LastName).add(con);
            } else {
                mapLastNameContacts.put(con.LastName, new List<Contact>{con});
            }
        }
        return mapLastNameContacts;
    }
}