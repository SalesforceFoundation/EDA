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
	private static ID hhAccountRecordTypeId = UTIL_Describe.getHhAccRecTypeID();

    /*******************************************************************************************************
    * @description The Administrative Account record type.
    */
	private static ID adminAccountRecordTypeId = UTIL_Describe.getAdminAccRecTypeID();

    /*******************************************************************************************************
    * @description The default/selected Household Account name format.
    */
    public static String hhNameFormat = UTIL_CustomSettingsFacade.getSettings().Household_Account_Naming_Format__c;

    /*******************************************************************************************************
    * @description The default/selected Administrative Account name format.
    */
    public static String aaNameFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Account_Naming_Format__c;

    /*******************************************************************************************************
	* @description Update admin Account names if any changes made to Contacts' lastname.
    * @param listContactsChangedLastName list of Contacts whose LastNames have changed.
    * @return List<Account>.
	*/
	public static List<Account> updateAdminAccountsName(List<Contact> listContactsChangedLastName) {
        List<Account> listAccToUpdate = new List<Account>();
        Map<Id, List<Contact>> mapAccIdToCon = new Map<Id, List<Contact>>();

        for (Contact con : listContactsChangedLastName) {
            if (mapAccIdToCon.containsKey(con.AccountId)) {
                mapAccIdToCon.get(con.AccountId).add(con);
            } else {
                mapAccIdToCon.put(con.AccountId, new List<Contact> {con});
            }

        }

        for (Account acc: [SELECT Id, Name, RecordTypeId,
                           (SELECT Id, LastName, Salutation, FirstName FROM Contacts WHERE AccountId IN :mapAccIdToCon.keySet())
                           FROM Account WHERE Id IN: mapAccIdToCon.keySet()])
        {
            if (acc.RecordTypeId == adminAccountRecordTypeId) {
                acc.Name = UTIL_ACCT_Naming_DF.updateName(acc.Contacts);
                listAccToUpdate.add(acc);
            }
        }

        return listAccToUpdate;
    }

    /*******************************************************************************************************
    * @description Update Account names if any changes made to Contacts' names or a new Contacts is linked the account
    * @param accIdsToRename a set of AccountIds whose name need to be updated.
    * @return void.
    */
	public static void updateHHAccountsName(Set<Id> accIdsToRename) {
    	List<Account> listAccsToRename = new List<Account>();

		listAccsToRename = queryContacts(accIdsToRename);

        //Loop through listAccsToRename and modify the name accordingly
		if (listAccsToRename.size() > 0) {
			for (Account acc : listAccsToRename) {
            	acc.Name = UTIL_ACCT_Naming_DF.updateName(acc.Contacts);
        	}
		}

        //For now, we use direct DML statement to avoid duplicate id issue
        update listAccsToRename;
    }

    /*******************************************************************************************************
	* @description Retrieves additional Contact and Account information.
	* @param accIdsToRename a set of AccountIds that needs Name update.
	* @return List<Account>.
	*/
	private static List<Account> queryContacts(Set<Id> accIdsToRename) {
		List<Account> returnedContacts = new List<Account>();

        //Build dynamic query string
        String strSoql = 'SELECT id, RecordTypeId, ';
        strSoql += '(SELECT Id, AccountId,' +
                'Account.RecordTypeID, ' +
                'Account.Primary_Contact__c, Account.Name,' +
                'firstname, lastname, OwnerId, Salutation,' +
                'MailingStreet, MailingCity, MailingState, ' +
            	'MailingPostalCode, MailingCountry, MailingLatitude, ' +
            	'MailingLongitude, OtherStreet, OtherCity, OtherState, ' +
                'OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, ';

        if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
			strSoql += 'MailingCountryCode, MailingStateCode, OtherCountryCode, OtherStateCode, ';
		}

        if (defaultRecTypeId == hhAccountRecordTypeId) {
            strSoql += 'Phone, Fax FROM Contacts WHERE Exclude_from_Household_Name__c != true)';
        }

        strSoql += 'FROM Account WHERE Id IN :accIdsToRename';

        //Re-query to get correct Account values (and all the other fields we will look at)
        returnedContacts = database.query(strSoql);

		return returnedContacts;
	}

    /*******************************************************************************************************
	* @description Main method that determines how the Account name should be updated.
	* @param cons a set of Contacts whose Account needs Name update.
	* @return String.
	*/
	public static String updateName(Contact[] cons) {
		String accountNamingFormat;
		String finalAccountName;

        accountNamingFormat = checkAccountFormat();

		NameSpec ns;
		if (accountNamingFormat != NULL) {
			ns = new NameSpec(accountNamingFormat);
			finalAccountName = buildAccountName(cons, ns);
		} else {
			finalAccountName = defaultAccountName(cons, accountNamingFormat);

		}

		return finalAccountName;
	}

    /*******************************************************************************************************
	* @description This checks and returns the current Account Model and Account name format.
	* @return String.
	*/
	public static String checkAccountFormat () {
		String accountNamingFormat;

		if (defaultRecTypeId == hhAccountRecordTypeId) {

            accountNamingFormat = hhNameFormat;

            if (accountNamingFormat == Label.acctNamingOther) {
                accountNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Other_Name_Setting__c;
            }
		} else if (defaultRecTypeId == adminAccountRecordTypeId) {

			accountNamingFormat = aaNameFormat;

            if (accountNamingFormat == Label.acctNamingOther) {
                accountNamingFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Other_Name_Setting__c;
            }
		}

		return accountNamingFormat;
	}

    /*******************************************************************************************************
	* @description This sets the default Account name for each respective Account model.
	* @param cons a list of Contacts whose Account needs Name update.
	* @param accountNamingFormat is a string of the Account name format currently set in the org.
	* @return String.
	*/
	public static String defaultAccountName(Contact[] cons, String accountNamingFormat) {
		Set<String> householdLastNames = new Set<String>();
		String finalAccountName;

		for (Contact con : cons) {
            if (defaultRecTypeId == hhAccountRecordTypeId) {
				householdLastNames.add(con.LastName);
			} else if (defaultRecTypeId == adminAccountRecordTypeId) {
				finalAccountName = con.LastName + ' ' + System.label.DefaultAdminName;
				break;
			} else {
				finalAccountName = con.LastName + ' ' + System.label.DefaultAccountName;
				break;
			}
        }

        if (householdLastNames.size() > 0) {
            String name = '';
			String strAnd = ' ' + Label.defaultNamingConnector + ' ';
        	Integer counter = 0;

            for (String lastName : householdLastNames) {
            	name += lastName;
            	counter++;
            	if (counter < householdLastNames.size()) {
                	name += strAnd;
            	}
        	}

			if (accountNamingFormat == hhNameFormat) {
				finalAccountName =  name + ' ' + System.label.DefaultHouseholdName;
    		}
        }

		return finalAccountName;
	}

	private static String chLToken = '{!';
    private static String chRToken = '}';
    public static Boolean setFNSpec = false;

    /*******************************************************************************************************
	* @description Class that supports the parsing of Account name format set in the current org and Account model.
	* NameSpec looks like: Prefix {LastName} {{FirstName}} Suffix
	* strFirstNameSpec is a combo of fields and literals like: {Salutation} {FirstName} Family
	* @return NameSpec.
	*/
	private class NameSpec {
		private String namePrefix { get; set; }
        private String nameSuffix { get; set; }
        private String strFirstNameSpec { get; set; }
        private String strFullNameSpec { get; set; }
        private String strAnd { get; set; }
        private string strAcctNameFormat { get; set; }
        private String strSalutation {get; set; }

        /*******************************************************************************************************
        * @description NameSpec Constructor
        * @param accountNamingFormat is a string of the Account name format currently set in the org.
        */
		private NameSpec(String accountNamingFormat) {
            String strNameSpec;

			if (accountNamingFormat != NULL) {
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
            strFirstNameSpec = '';
            strFullNameSpec = '';
			strAnd = ' ' + Label.defaultNamingConnector + ' ';

			if (strNameSpec == NULL) {
				return;
			}

			Integer indexFirstParenthesis = strNameSpec.indexOf(chLToken);
			Integer indexAfterLastParenthesis = strNameSpec.lastIndexOf(chRToken);

			//Retrieve Prefix without the token
			if (indexFirstParenthesis > 0) {
				namePrefix = strNameSpec.left(indexFirstParenthesis);
				strAcctNameFormat = strNameSpec.subString(indexFirstParenthesis);
			}

			//Retrieve Suffix without the token
			if (indexAfterLastParenthesis > 0) {
				while (indexAfterLastParenthesis < strNameSpec.length()-1 &&
                       strNameSpec.subString(indexAfterLastParenthesis+1, indexAfterLastParenthesis+2) != ' ') {
					indexAfterLastParenthesis++;
				}
				nameSuffix = strNameSpec.subString(indexAfterLastParenthesis+1);
				strAcctNameFormat = strNameSpec.left(indexAfterLastParenthesis+1);
			}

            //Retrieve  FirstNameSpec ie. {!FirstName}
			String strFirstName = strFNameSpecFromStrNameSpec(strAcctNameFormat);

            //Retrieve Salutation
            strSalutation = strSalutationFromStrNameSpec(strAcctNameFormat);

            Integer indexOfLeft = strFirstName.indexOf(chLToken);
			Integer indexOfRight = strFirstName.lastIndexOf(chRToken);

            //Retrieve full Account name format with a token
            if (indexOfLeft >= 0 && indexOfRight > 0) {
               	if (strSalutation == NULL || strSalutation == '') {
                    strFullNameSpec = strAcctNameFormat.replace(strFirstName, 'FirstNameSpec');
                } else {
                    strFullNameSpec = strAcctNameFormat;
                }

                //Do a check if it's {!{!FirstName}} instead of {!FirstName}
                if (setFNSpec) {
                	strFirstNameSpec = strFirstName.subString(indexOfLeft + chLToken.length(), indexOfRight);
                } else {
                   	strFirstNameSpec =  strFirstName;
                }
			} else {
				strFullNameSpec = strAcctNameFormat;
			}
		}

        /*******************************************************************************************************
        * @description Returns a set of all field names in all parts of the namespec without token.
        * @return string
        */
		public set<string> setStrFieldsInNameSpec() {
            Set<String> setStrField = new Set<String>();

            if (strFirstNameSpec != null) {
                setStrField.addAll(setStrFieldFromStrFSpec(strFirstNameSpec));
            }

            if (strFullNameSpec != null){
               	setStrField.addAll(setStrFieldFromStrFSpec(strFullNameSpec));
            }

            setStrField.add('LastName');
            return setStrField;
        }

	}

    /*******************************************************************************************************
    * @description Returns a set of clean field names from the NameSpec.
	* ie. {!LastName} {!FirstName} Family -> "LastName" "FirstName"
	* @param strFirstNameSpec is a string {!FirstName}
    * @return String.
    */
    private static Set<String> setStrFieldFromStrFSpec(String strFirstNameSpec) {
        Set<String> setStrField = new Set<String>();

        // First, instantiate a new Pattern object looking for {...} without any nested {'s.
        Pattern MyPattern = Pattern.compile('\\{![^\\{!]*\\}');
        // Then instantiate a new Matcher object
        Matcher MyMatcher = MyPattern.matcher(strFirstNameSpec);

        while (MyMatcher.find()) {
            // get the fieldname without the {!}'s
            string strField = strFirstNameSpec.substring(MyMatcher.start() + chLToken.length(), MyMatcher.end()-chRToken.length());
            setStrField.add(strField.trim());
        }

        return setStrField;
    }

    /*******************************************************************************************************
	* @description Given an Account name format, returns the salutation demarcated by an outer {!} specified in the string.
    * @param strAcctNameFormat is a string of the Account name format currently set in the org.
    * @return String.
    */
    private static String strSalutationFromStrNameSpec(String strAcctNameFormat) {
  		String regexPattern = '(?:^|\\W)Salutation(?:$|\\W)';
      	Pattern MyPattern = Pattern.compile(regexPattern);
		Matcher MyMatcher = MyPattern.matcher(strAcctNameFormat);

        if (MyMatcher.find()) {
			return strAcctNameFormat.subString(MyMatcher.start()-1, MyMatcher.end());
		} else {
			return '';
        }

    }

    /*******************************************************************************************************
	* @description Given an Account name format, return the FirstName demarcated by an outer {!} specified in the string.
    * @param strAcctNameFormat is a string of the Account name format currently set in the org.
    * @return String.
    */
	private static String strFNameSpecFromStrNameSpec(String strAcctNameFormat) {
        //Checks {!FirstName}
        String regexPattern = '(?:^|\\W)FirstName(?:$|\\W)';
        Pattern MyPattern = Pattern.compile(regexPattern);
		Matcher MyMatcher = MyPattern.matcher(strAcctNameFormat);

        //Checks {!{FirstName}}
        String regexPatternDoubleToken = '\\{![^\\}]*\\{!.*\\}[^\\{!]*\\}';
        Pattern MyPatternDoubleTokenCheck = Pattern.compile(regexPatternDoubleToken);
        Matcher MyMatcherDoubleTokenCheck = MyPatternDoubleTokenCheck.matcher(strAcctNameFormat);

        //Set setFNSpec if it finds {!{FirstName}}
        if (MyMatcherDoubleTokenCheck.find()) {
            setFNSpec = true;
        }

		if (MyMatcher.find()) {
			return strAcctNameFormat.subString(MyMatcher.start()-1, MyMatcher.end());
		} else {
			return '';
        }
	}

    /*******************************************************************************************************
    * @description Given a NameSpec and a list of Contacts (assumed from a single household),
    * return the formated Account name.
    * This can be used for any of the household strings (name, formal greeting, informal greeting).
    * @param ns the NameSpec class
    * @param cons is the list of Contacts
    * return String.
    */
	private static String buildAccountName(Contact[] cons, NameSpec ns) {
		Set<String> processedLastNames = new Set<String>();
		String[] finalAccountName = new String[0];
        String strSalutation = '';
        Integer conSize = cons.size();
        Boolean isNoLastnames = ns.strFullNameSpec.toUpperCase().indexOf(chLToken + 'LASTNAME' + chRToken) == -1;
		Boolean isLastNameOnlyFormat = !isNoLastnames && ns.setStrFieldsInNameSpec().size() == 1;
		Map<Id, List<Contact>> mapLastFirstName = new Map<Id, List<Contact>>();


        for (Integer i = 0, next = 0; i < conSize; i = next) {
            String strLName = cons[i].LastName;
            next = i + 1;

			if (isLastNameOnlyFormat && processedLastNames.contains(strLName)) {
				continue;
			}

			//Adds the lastName
			processedLastNames.add(strLName);

            //Retrieves Salutation
            List<String> listSalutation = new List<String>();
            strSalutation = strConFspec(cons[i], ns.strSalutation);

			//Retrieves value of FirstName
			String strFName = strConFspec(cons[i], ns.strFirstNameSpec);

            //Retrieves additional Salutations/FirstNames if there are multiple Contact with same last name OR
            //if Contacts do not have same last name && the Account name format is not set to process {!LastName}.
			List<String> listFName = new List<String>();

            for (; next < conSize && (isNoLastnames || cons[next].LastName == strLname); next++) {

                String nextSalutation = strConFspec(cons[next], ns.strSalutation);
               	if (nextSalutation != '') {
                    listSalutation.add(nextSalutation);
                    listSalutation.sort();
               	}


                String nextFName = strConFspec(cons[next], ns.strFirstNameSpec);
               	if (nextFName != '') {
					listFName.add(nextFname);
                    listFName.sort();
				}

                //This is critical if the current Account name format is not set to process {!LastName}, then
                //all Contacts inserted will enter this loop and will need to stop the iteration of next so
                //that the next Contact will enter the outer loop.
                if (isNoLastnames) {
                    break;
                }
			}

            //Put together the Account name
			String name = processName(cons, strLname, strFName, strSalutation, listFName,
                                      listSalutation, ns, conSize, i, next);

            if (String.isNotBlank(name)) {
            	finalAccountName.add(name);
            }
		}

		return ns.namePrefix + stringAccountName(finalAccountName, ns) + ns.nameSuffix;
	}

    /*******************************************************************************************************
    * @description This method is reponsbile for concatenating all additional Salutations, FirstNames, and LastName
    * into a string to return the final Account name.
    * @param cons is the list of Contacts in the current trigger context.
    * @param strLName is the string for the current LastName that is in process.
    * @param strFName is the string for the current FirstName that is in process.
    * @param strSalutation is the string for the current strSalutation that is in process.
    * @param listFName is the list of string for the additional Contacts' FirtNames.
    * @param listSalutation is the list of string for the additional Contacts' Salutations.
    * @param ns is the NameSpec class.
    * @param conSize is an integer that holds the number of Contacts.
    * @param i is an integer that holds the current iteration.
    * @param next is an integer that holds the next iteration.
    * @param cons is the list of Contacts
    * return String.
    */
    private static String processName( Contact[] cons, String strLName, String strFName, String strSalutation,
                                      String[] listFName, String[] listSalutation, NameSpec ns, Integer conSize,
                                      Integer i, Integer next)
    {

        //Strings up the Salutations together
        for (Integer h = 0; h < listSalutation.size(); h++) {

        	if (h == listSalutation.size()-1) {
                if (strSalutation == NULL || strSalutation == '') {
                   	strSalutation = listSalutation[h];
                } else {
                    strSalutation += ns.strAnd + listSalutation[h];
                }
            } else {
              strSalutation += ', '+ listSalutation[h];
           	}
      	}

       	//Strings up the FNames together
		for (Integer k = 0; k <listFName.size(); k++) {

            if (k == listFName.size()-1) {
            	if (strFName == NULL || strFName == '') {
                	strFName = ' ' + listFName[k];
                } else {
                    strFName += ns.strAnd + listFName[k];
                }
			} else {
				strFName += ', ' + listFName[k];
			}
		}

        //Handles processing strFullNameSpec
        String acctName = strConFspec(cons[i], ns.strFullNameSpec);
		acctName = acctName.replace('FirstNameSpec', strFname);

        if (strFname == '') {
			acctName = acctName.trim();
		}

        return acctName;
    }

    /*******************************************************************************************************
    * @description Given a single Contact and a NameSpec string, returns the formatted string filling
    * in fields in the NameSpec from the Contact.
    * @param con the Contact in the current process.
	* @param strFspec is the string Account name format. ie. {!Salutation} {!FirstName}
    * return String
    */
    private static String strConFspec(Contact con, String strFspec) {
        String str = strFspec;

        // First, instantiate a new Pattern object looking for {...} without any nested {'s.
        Pattern MyPattern = Pattern.compile('\\{![^\\{!]*\\}');
        // Then instantiate a new Matcher object
        Matcher MyMatcher = MyPattern.matcher(strFspec);


        while (MyMatcher.find()) {
            //Get the fieldname without the {}'s, ie. {!LastName} -> LastName
            String strField = strFspec.substring(MyMatcher.start() + chLToken.length(), MyMatcher.end()-chRToken.length());

            //Separate cross object references, ie. (LastName)
            List<String> splitField = (strField.split('\\.',0));

            //Remove the field name itself to only include parent object references. ie.  {!LastName} -> LastName
            String fieldName = splitField[splitField.size()-1].trim();
            splitField.remove(splitField.size()-1);

            //Use the correct sObject
            sObject thisObj;
            if (!splitField.isEmpty()) {
                thisObj = con.getsObject(splitField[0]);
                splitField.remove(0);
            } else {
                thisObj = con;
            }

            //Traverse parent relationships until the last one
            for (string parentObj : splitField) {
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
                str = str.replace(strField + ' ', '');
                // eat potential leading space
                str = str.replace(' ' + strField, '');
            }

            //Replaces the string format with the actual value of FN/LN/Salutation
            str = str.replace(strField, val == null ? '' : val);

        }

        return str;
    }

    /*******************************************************************************************************
    * @description Concatenate string out of individual formatted names.
    * @param ns the NameSpec class
    * @param finalAccountName is the list of strings of the Account name.
    * return String, concatented string where names are separated by comma except
    * the last string is linked with the namespec's AND delimiter
    */
	private static String stringAccountName(String[] finalAccountName, NameSpec ns) {
		String name = '';
		String delimeter = '';
		Integer size = finalAccountName.size();

		for (Integer i = 0; i < size; i ++) {
			if (i > 0 && i == size - 1) {
				delimeter = ns.strAnd;
			} else if (i > 0) {
				delimeter = ', ';
			}
			name += delimeter + finalAccountName[i];
		}

		return name;
	}
}