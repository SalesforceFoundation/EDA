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
     * @description The default Account type.
     */
    private static ID defaultRecTypeId = UTIL_CustomSettingsFacade.getSettings().Account_Processor__c;

    /*******************************************************************************************************
     * @description The Household Account record type.
     */
    private static ID hhAccountRecordTypeId = UTIL_Describe.getCustomHHAccRecTypeID();

    /*****************************************************************************************************************
     * @description The user defined Administrative Account record type in "ACCOUNTS AND CONTACTS" tab of EDA Settings.
     */
    private static ID userDefinedAdminRecordTypeId = UTIL_Describe.getCustomAdminAccRecTypeId();

    /******************************************************************************************************************
     * @description The default/selected Household Account name format.
     */
    private static String hhNameFormat = UTIL_CustomSettingsFacade.getSettings().Household_Account_Naming_Format__c;

    /*******************************************************************************************************
     * @description The default/selected Administrative Account name format.
     */
    private static String aaNameFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Account_Naming_Format__c;

    /*******************************************************************************************************
     * @description Update admin Account names if any changes made to Contacts' lastname.
     * @param contactsChangedLastName list of Contacts whose LastNames have changed.
     * @return List<Account>.
     */
    public static List<Account> updateAdminAccountsName(List<Contact> contactsChangedLastName) {
        List<Account> accountsToUpdate = new List<Account>();
        List<Account> accounts = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        Map<Account, Id> accountIdPrimaryContactId = new Map<Account, Id>();

        //Retrieve the AccountId from the Contact
        for (Contact con : contactsChangedLastName) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }

        //Retrieve the Primary_Contact__c from Account record
        if (accountIds.size() > 0) {
            accounts = retrievePrimaryContactFromAccount(accountIds);
        }

        //Set the Account and Primary ContactId to the map
        if (accounts.size() > 0) {
            for (Account acc : accounts) {
                if (acc.Primary_Contact__c != null) {
                    accountIdPrimaryContactId.put(acc, acc.Primary_Contact__c);
                }
            }
        }

        for (Account acc : [
            SELECT
                Id,
                Name,
                RecordTypeId,
                (
                    SELECT Id, FirstName, LastName, Salutation, AccountId, Account.RecordTypeId
                    FROM Contacts
                    WHERE Id IN :accountIdPrimaryContactId.values()
                )
            FROM Account
            WHERE Id IN :accountIds
        ]) {
            if (acc.RecordTypeId == userDefinedAdminRecordTypeId) {
                acc.Name = UTIL_ACCT_Naming.updateNameFromContact(acc.Contacts, acc);
                accountsToUpdate.add(acc);
            }
        }

        return accountsToUpdate;
    }

    /*******************************************************************************************************
     * @description queries the Account record with the Primary Contact associated to it.
     * @param accountIds the Ids of the Account record to query
     * @return List<Account>.
     */
    private static List<Account> retrievePrimaryContactFromAccount(Set<Id> accountIds) {
        return [SELECT Id, Primary_Contact__c, RecordTypeId FROM Account WHERE Id IN :accountIds];
    }

    /*******************************************************************************************************
     * @description Update household Account names if any changes made to Contacts' names or a new Contacts is linked the account
     * @param accIdsToRename a set of AccountIds whose name need to be updated.
     * @return void.
     */
    public static void updateHHAccountsName(Set<Id> accIdsToRename) {
        List<Account> accountsToRename = new List<Account>();

        accountsToRename = queryContacts(accIdsToRename);
        //Loop through accountsToRename and modify the name accordingly
        if (accountsToRename.size() > 0) {
            for (Account acc : accountsToRename) {
                acc.Name = UTIL_ACCT_Naming.updateNameFromContact(acc.Contacts, acc);
            }
        }

        //For now, we use direct DML statement to avoid duplicate Id issue
        update accountsToRename;
    }

    /*******************************************************************************************************
     * @description Retrieves additional Contact and Account information.
     * @param accIdsToRename a set of AccountIds that needs Name update.
     * @return List<Account>.
     */
    private static List<Account> queryContacts(Set<Id> accIdsToRename) {
        List<Account> returnedContacts = new List<Account>();
        String sortByLastName = 'LastName';
        String sortByFirstName = 'FirstName';

        //Build dynamic query string
        String dynamicSoql = 'SELECT Id, RecordTypeId, ';
        dynamicSoql +=
            '(SELECT Id, AccountId,' +
            'Account.RecordTypeID, ' +
            'Account.Primary_Contact__c, Account.Name,' +
            'firstname, lastname, OwnerId, Salutation,' +
            'MailingStreet, MailingCity, MailingState, ' +
            'MailingPostalCode, MailingCountry, MailingLatitude, ' +
            'MailingLongitude, OtherStreet, OtherCity, OtherState, ' +
            'OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, ' +
            'Phone, Fax';

        Set<String> objectFields = Schema.SObjectType.Contact.fields.getMap().keySet();
        Boolean ispersonNameSuffixEnabled = objectFields.contains('suffix');
        if (ispersonNameSuffixEnabled) {
            dynamicSoql += ', Suffix ';
        }

        if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
            dynamicSoql += ', MailingCountryCode, MailingStateCode, OtherCountryCode, OtherStateCode';
        }

        dynamicSoql += ' FROM Contacts WHERE Exclude_from_Household_Name__c != true AND Deceased__c != true)';
        dynamicSoql += ' FROM Account WHERE Id IN :accIdsToRename';

        //Re-query to get correct Account values (and all the other fields we will look at)
        returnedContacts = database.query(String.escapeSingleQuotes(dynamicSoql));

        return returnedContacts;
    }

    /*******************************************************************************************************
     * @description Main method that determines how the Account name should be updated.
     * @param cons a set of Contacts whose Account needs Name update.
     * @param acc is the Account record.
     * @return String.
     */
    public static String updateNameFromContact(List<Contact> cons, Account acc) {
        String accountNamingFormat;
        String finalAccountName;

        accountNamingFormat = checkAccountFormat(acc);
        List<Contact> returnSortedContacts = sortContacts(cons);

        if (accountNamingFormat != null) {
            NameSpec ns = new NameSpec(accountNamingFormat);
            finalAccountName = buildAccountName(returnSortedContacts, ns);
        } else {
            finalAccountName = defaultAccountName(returnSortedContacts, accountNamingFormat, acc);
        }

        return finalAccountName;
    }

    /*******************************************************************************************************
     * @description This checks and returns the current Account Model and Account name format.
     * @return String.
     */
    private static String checkAccountFormat(Account acc) {
        String accountNamingFormat;

        if (acc.RecordTypeId == hhAccountRecordTypeId) {
            accountNamingFormat = hhNameFormat;
            if (accountNamingFormat == Label.acctNamingOther) {
                accountNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Other_Name_Setting__c;
            }
        } else if (acc.RecordTypeId == userDefinedAdminRecordTypeId) {
            accountNamingFormat = aaNameFormat;
            if (accountNamingFormat == Label.acctNamingOther) {
                accountNamingFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Other_Name_Setting__c;
            }
        }

        return accountNamingFormat;
    }

    /*******************************************************************************************************
     * @description This calls the UTIL_SortContact to sort Contacts in alphabetical order.
     * @param cons a list of Contacts that needs to be alphabetized.
     * @return List<Contact>.
     */
    private static List<Contact> sortContacts(List<Contact> cons) {
        List<UTIL_SortContact> sortedContacts = new List<UTIL_SortContact>();
        List<Contact> finalSortedContacts = new List<Contact>();

        for (Contact c : cons) {
            sortedContacts.add(new UTIL_SortContact(c));
        }
        sortedContacts.sort();

        for (UTIL_SortContact us : sortedContacts) {
            finalSortedContacts.add(us.contactRecord);
        }

        return finalSortedContacts;
    }

    /*******************************************************************************************************
     * @description This sets the default Account name for each respective Account model.
     * @param cons a list of Contacts whose Account needs Name update.
     * @param accountNamingFormat is a string of the Account name format currently set in the org.
     * @return String.
     */
    private static String defaultAccountName(List<Contact> cons, String accountNamingFormat, Account theAccount) {
        Set<String> householdLastNames = new Set<String>();
        String finalAccountName;
        String name = '';
        String strAnd = ' ' + Label.defaultNamingConnector + ' ';
        Integer counter = 0;

        if (cons.isEmpty()) {
            return null;
        }

        if (theAccount.RecordTypeId == userDefinedAdminRecordTypeId) {
            return finalAccountName = cons[0].LastName + ' ' + System.label.DefaultAdminName;
        }

        if (theAccount.RecordTypeId != hhAccountRecordTypeId) {
            return finalAccountName = cons[0].LastName + ' ' + System.label.DefaultAccountName;
        }

        for (Contact aContact : cons) {
            name += aContact.lastName;
            counter++;
            if (counter < householdLastNames.size()) {
                name += strAnd;
            }
        }

        return name + ' ' + System.label.DefaultHouseholdName;
    }

    /*******************************************************************************************************
     * @description Given a NameSpec and a list of Contacts (assumed from a single household),
     * return the formated Account name.
     * This can be used for any of the household strings (name, formal greeting, informal greeting).
     * @param cons is the list of Contacts
     * @param ns the NameSpec class
     * return String.
     */
    private static String buildAccountName(List<Contact> cons, NameSpec ns) {
        Set<String> processedLastNames = new Set<String>();
        List<String> finalAccountName = new List<String>(0);
        String salutationSpec = '';
        Integer conSize = cons.size();
        Boolean isSalutationFormat = ns.salutationSpec == '' ? false : true;
        Boolean lastNameOnFullNameSpec = ns.fullNameSpec.toUpperCase().indexOf(chLToken + 'LASTNAME' + chRToken) == -1;
        Boolean lastNameOnlyFormat = !lastNameOnFullNameSpec && ns.returnNameFormat().size() == 1;
        Boolean lastNameNotIncludedInFormat =
            ns.acctNameFormat.toUpperCase().indexOf(chLToken + 'LASTNAME' + chRToken) == -1;

        for (Integer i = 0, next = 0; i < conSize; i = next) {
            String lastName = cons[i].LastName;
            next = i + 1;

            if (lastNameOnlyFormat && processedLastNames.contains(lastName)) {
                continue;
            }

            //Adds the lastName
            processedLastNames.add(lastName);

            //Retrieves Salutation
            List<String> additionalSalutations = new List<String>();
            if (isSalutationFormat) {
                salutationSpec = stringConNames(cons[i], ns.salutationSpec);
            }

            //Retrieves value of FirstName
            String firstName = stringConNames(cons[i], ns.firstNameSpec);

            //Retrieves additional Salutations/FirstNames if there are multiple Contact with same last name OR
            //if Contacts do not have same last name && the Account name format is not set to process {!LastName}.
            List<String> additionalFirstNames = new List<String>();

            for (; next < conSize && (lastNameOnFullNameSpec || cons[next].LastName == lastName); next++) {
                if (isSalutationFormat) {
                    String nextSalutation = stringConNames(cons[next], ns.salutationSpec);
                    if (nextSalutation != '') {
                        additionalSalutations.add(nextSalutation);
                    }
                }
                if (!lastNameNotIncludedInFormat) {
                    String nextFName = stringConNames(cons[next], ns.firstNameSpec);
                    if (nextFName != '') {
                        additionalFirstNames.add(nextFname);
                    }
                }

                //This is critical if the current Account name format is not set to process {!LastName}, then
                //all Contacts inserted will enter this loop and will need to stop the iteration of next so
                //that the next Contact will enter the outer loop. In short, this helps prevent deduplication
                //of Contacts on the Account name.
                if (lastNameNotIncludedInFormat) {
                    break;
                }
            }

            //Put together the Account name
            String name = processName(
                cons[i],
                lastName,
                firstName,
                salutationSpec,
                additionalFirstNames,
                additionalSalutations,
                ns
            );

            if (String.isNotBlank(name)) {
                finalAccountName.add(name);
            }
        }

        return ns.namePrefix + stringAccountName(finalAccountName, ns) + ns.nameSuffix;
    }

    private static String chLToken = '{!';
    private static String chRToken = '}';
    private static Boolean setFNSpec = false;

    /*******************************************************************************************************
     * @description Returns a set of clean field names from the NameSpec.
     * ie. {!LastName} {!FirstName} Family -> "LastName" "FirstName"
     * @param firstNameSpec is a string {!FirstName}
     * @return String.
     */
    private static Set<String> cleanNameFormat(String firstNameSpec) {
        Set<String> nameFormat = new Set<String>();

        // First, instantiate a new Pattern object looking for {...} without any nested {'s.
        Pattern myPattern = Pattern.compile('\\{![^\\{!]*\\}');
        // Then instantiate a new Matcher object
        Matcher myMatcher = myPattern.matcher(firstNameSpec);

        while (MyMatcher.find()) {
            // get the fieldname without the {!}'s
            string strField = firstNameSpec.substring(
                myMatcher.start() + chLToken.length(),
                myMatcher.end() - chRToken.length()
            );
            nameFormat.add(strField.trim());
        }
        return nameFormat;
    }

    /*******************************************************************************************************
     * @description Given an Account name format, returns the salutation demarcated by an outer {!} specified in the string.
     * @param acctNameFormat is a string of the Account name format currently set in the org.
     * @return String.
     */
    private static String cleanSalutationFormat(String acctNameFormat) {
        String regexPattern = '(?:^|\\W)Salutation(?:$|\\W)';
        Pattern myPattern = Pattern.compile(regexPattern);
        Matcher myMatcher = myPattern.matcher(acctNameFormat);

        if (myMatcher.find()) {
            return acctNameFormat.subString(myMatcher.start() - 1, myMatcher.end());
        } else {
            return '';
        }
    }

    /*******************************************************************************************************
     * @description Given an Account name format, return the FirstName demarcated by an outer {!} specified in the string.
     * @param acctNameFormat is a string of the Account name format currently set in the org.
     * @return String.
     */
    private static String cleanFirstNameFormat(String acctNameFormat) {
        String firstNameFormat = '';

        //Checks {!FirstName}
        String regexPattern = '(?:^|\\W)FirstName(?:$|\\W)';
        Pattern myPattern = Pattern.compile(regexPattern);
        Matcher myMatcher = myPattern.matcher(acctNameFormat);

        //Checks {!{!FirstName}}
        String regexPatternDoubleToken = '\\{![^\\}]*\\{!.*\\}[^\\{!]*\\}';
        Pattern myPatternDoubleTokenCheck = Pattern.compile(regexPatternDoubleToken);
        Matcher myMatcherDoubleTokenCheck = myPatternDoubleTokenCheck.matcher(acctNameFormat);

        if (myMatcherDoubleTokenCheck.find()) {
            //If it finds {!{!FirstName}}
            setFNSpec = true;
            firstNameFormat = acctNameFormat.subString(
                myMatcherDoubleTokenCheck.start(),
                myMatcherDoubleTokenCheck.end()
            );
        } else if (myMatcher.find()) {
            //If it finds  {!FirstName}
            firstNameFormat = acctNameFormat.subString(myMatcher.start() - 1, myMatcher.end());
        } else {
            firstNameFormat = '';
        }

        return firstNameFormat;
    }

    /*******************************************************************************************************
     * @description This method is reponsbile for concatenating all additional Salutations, FirstNames, and LastName
     * into a string to return the final Account name.
     * @param con is the Contact in the current trigger context.
     * @param lastName is the string for the current LastName that is in process.
     * @param firstName is the string for the current FirstName that is in process.
     * @param salutationSpec is the string for the current salutationSpec that is in process.
     * @param additionalFirstNames is the list of string for the additional Contacts' FirstNames.
     * @param additionalSalutations is the list of string for the additional Contacts' Salutations.
     * @param ns is the NameSpec class.
     * return String.
     */
    private static String processName(
        Contact con,
        String lastName,
        String firstName,
        String salutationSpec,
        List<String> additionalFirstNames,
        List<String> additionalSalutations,
        NameSpec ns
    ) {
        //Strings up the Salutations together
        for (Integer h = 0; h < additionalSalutations.size(); h++) {
            if (h == additionalSalutations.size() - 1) {
                if (salutationSpec == null || salutationSpec == '') {
                    salutationSpec = additionalSalutations[h];
                } else {
                    salutationSpec += ns.andConnector + additionalSalutations[h];
                }
            } else {
                if (salutationSpec == null || salutationSpec == '') {
                    salutationSpec = additionalSalutations[h];
                } else {
                    salutationSpec += ', ' + additionalSalutations[h];
                }
            }
        }

        //Strings up the FNames together
        for (Integer k = 0; k < additionalFirstNames.size(); k++) {
            if (k == additionalFirstNames.size() - 1) {
                if (firstName == null || firstName == '') {
                    firstName = ' ' + additionalFirstNames[k];
                } else {
                    firstName += ns.andConnector + additionalFirstNames[k];
                }
            } else {
                if (firstName == null || firstName == '') {
                    firstName = ' ' + additionalFirstNames[k];
                } else {
                    firstName += ', ' + additionalFirstNames[k];
                }
            }
        }

        //Handles processing fullNameSpec
        String acctName = stringConNames(con, ns.fullNameSpec);
        acctName = acctName.replace('FirstNameSpec', firstName);

        if (firstName == '') {
            acctName = acctName.trim();
        }

        return acctName;
    }

    /*******************************************************************************************************
     * @description Given a single Contact and a NameSpec string, returns the formatted string filling
     * in fields in the NameSpec from the Contact.
     * @param con the Contact in the current process.
     * @param fullNameSpec is the string Account name format. ie. {!Salutation} {!FirstName}
     * return String
     */
    private static String stringConNames(Contact con, String fullNameSpec) {
        String currentFormatValue = fullNameSpec;

        // First, instantiate a new Pattern object looking for {...} without any nested {'s.
        Pattern myPattern = Pattern.compile('\\{![^\\{!]*\\}');
        // Then instantiate a new Matcher object
        Matcher myMatcher = myPattern.matcher(fullNameSpec);

        while (myMatcher.find()) {
            //Get the fieldname without the {}'s, ie. {!LastName} -> LastName
            String strField = fullNameSpec.substring(
                myMatcher.start() + chLToken.length(),
                myMatcher.end() - chRToken.length()
            );

            //Separate cross object references, ie. (LastName)
            List<String> splitField = (strField.split('\\.', 0));

            //Remove the field name itself to only include parent object references. ie.  {!LastName} -> LastName
            String fieldName = splitField[splitField.size() - 1].trim();
            splitField.remove(splitField.size() - 1);

            //Use the correct sObject
            sObject thisObj;
            if (!splitField.isEmpty()) {
                thisObj = con.getsObject(splitField[0]);
                splitField.remove(0);
            } else {
                thisObj = con;
            }

            //Traverse parent relationships until the last one
            for (String parentObj : splitField) {
                if (thisObj != null) {
                    thisObj = thisObj.getsObject(parentObj);
                }
            }

            String val;
            if (thisObj != null) {
                //Assigns the actual value of the Salutation/FN/LN to val
                val = String.valueOf(thisObj.get(fieldName));
            }

            //Add back the {}'s for string substitution
            strField = chLToken + strField + chRToken;

            if (val == null) {
                // eat potential trailing space
                currentFormatValue = currentFormatValue.replace(strField + ' ', '');
                // eat potential leading space
                currentFormatValue = currentFormatValue.replace(' ' + strField, '');
            }

            //Replaces the string format with the actual value of FN/LN/Salutation
            currentFormatValue = currentFormatValue.replace(strField, val == null ? '' : val);
        }

        return currentFormatValue;
    }

    /*******************************************************************************************************
     * @description Concatenate string out of individual formatted names.
     * @param finalAccountName is the list of strings of the Account name.
     * @param ns the NameSpec class
     * return String, concatented string where names are separated by comma except
     * the last string is linked with the namespec's AND delimiter
     */
    private static String stringAccountName(List<String> finalAccountName, NameSpec ns) {
        String name = '';
        String delimeter = '';
        Integer size = finalAccountName.size();

        for (Integer i = 0; i < size; i++) {
            if (i > 0 && i == size - 1) {
                delimeter = ns.andConnector;
            } else if (i > 0) {
                delimeter = ', ';
            }
            name += delimeter + finalAccountName[i];
        }

        return name;
    }

    /*******************************************************************************************************
     * @description Class that supports the parsing of Account name format set in the current org and Account model.
     * NameSpec looks like: Prefix {LastName} {{FirstName}} Suffix
     * firstNameSpec is a combo of fields and literals like: {Salutation} {FirstName} Family
     * @return NameSpec.
     */
    private class NameSpec {
        private String namePrefix { get; set; }
        private String nameSuffix { get; set; }
        private String firstNameSpec { get; set; }
        private String fullNameSpec { get; set; }
        private String andConnector { get; set; }
        private string acctNameFormat { get; set; }
        private String salutationSpec { get; set; }

        /*******************************************************************************************************
         * @description NameSpec Constructor
         * @param accountNamingFormat is a string of the Account name format currently set in the org.
         */
        private NameSpec(String accountNamingFormat) {
            String strNameSpec;

            if (accountNamingFormat != null) {
                strNameSpec = String.valueOf(accountNamingFormat);
                parseNameSpec(strNameSpec);
            }
        }

        /*******************************************************************************************************
         * @description Given the strNameSpec string value, parse out its constituent parts, and sets them in the class.
         * @param strNameSpec a string value of the Account name format. ie. {!FirstName} {!LastName} Family.
         */
        private void parseNameSpec(String strNameSpec) {
            namePrefix = '';
            nameSuffix = '';
            firstNameSpec = '';
            fullNameSpec = '';
            andConnector = ' ' + Label.defaultNamingConnector + ' ';

            if (strNameSpec == null) {
                return;
            }

            Integer indexFirstParenthesis = strNameSpec.indexOf(chLToken);
            Integer indexAfterLastParenthesis = strNameSpec.lastIndexOf(chRToken);

            //Retrieve Prefix without the token
            if (indexFirstParenthesis > 0) {
                namePrefix = strNameSpec.left(indexFirstParenthesis);
                acctNameFormat = strNameSpec.subString(indexFirstParenthesis);
            }

            //Retrieve Suffix without the token
            if (indexAfterLastParenthesis > 0) {
                while (
                    indexAfterLastParenthesis < strNameSpec.length() - 1 &&
                    strNameSpec.subString(indexAfterLastParenthesis + 1, indexAfterLastParenthesis + 2) != ' '
                ) {
                    indexAfterLastParenthesis++;
                }
                nameSuffix = strNameSpec.subString(indexAfterLastParenthesis + 1);
                acctNameFormat = strNameSpec.left(indexAfterLastParenthesis + 1);
            }

            //Remove prefix from acctNameFormat so that it doesn't cause a duplicate of Prefix on rename
            if (namePrefix != '') {
                acctNameFormat = acctNameFormat.subString(indexFirstParenthesis);
            }

            //Retrieve  FirstNameSpec ie. {!FirstName}
            String strFirstName = cleanFirstNameFormat(acctNameFormat);

            //Retrieve Salutation
            salutationSpec = cleanSalutationFormat(acctNameFormat);

            Integer indexOfLeft = strFirstName.indexOf(chLToken);
            Integer indexOfRight = strFirstName.lastIndexOf(chRToken);

            //Retrieve full Account name format with a token
            if (indexOfLeft >= 0 && indexOfRight > 0) {
                fullNameSpec = acctNameFormat.replace(strFirstName, 'FirstNameSpec');
                //Do a check if it's {!{!FirstName}} instead of {!FirstName}
                if (setFNSpec) {
                    firstNameSpec = strFirstName.subString(indexOfLeft + chLToken.length(), indexOfRight);
                } else {
                    firstNameSpec = strFirstName;
                }
            } else {
                fullNameSpec = acctNameFormat;
            }
        }

        /*******************************************************************************************************
         * @description Returns a set of all field names in all parts of the namespec without token.
         * @return string
         */
        public Set<String> returnNameFormat() {
            Set<String> nameFormat = new Set<String>();

            if (firstNameSpec != null) {
                nameFormat.addAll(cleanNameFormat(firstNameSpec));
            }

            if (fullNameSpec != null) {
                nameFormat.addAll(cleanNameFormat(fullNameSpec));
            }

            nameFormat.add('LastName');
            return nameFormat;
        }
    }
}
