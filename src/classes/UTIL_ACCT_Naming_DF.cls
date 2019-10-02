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
public class UTIL_ACCT_Naming_DF {
    /*******************************************************************************************************
    * @description The user defined Administrative Account record type.
    */
    private static ID userDefinedAdminRecordTypeId = Util_Describe.getAdminAccRecTypeID();
    private static ID defaultRecTypeId = UTIL_CustomSettingsFacade.getSettings().Account_Processor__c;
	private static ID hhAccountRecordTypeId = UTIL_Describe.getHhAccRecTypeID();
	private static ID adminAccountRecordTypeId = UTIL_Describe.getAdminAccRecTypeID();

	//TODO: updateAdminAccountsName();
	/*public static list<Account> updateAdminAccountsName(List<Contact> listContactsChangedLastName) {
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
                acc.Name = updateName(mapAccIdToCon.get(acc.Id));
                listAccToUpdate.add(acc);
            }
        }

        return listAccToUpdate;
    }*/

	//listAccsToRename() replaces updateHHAccountsName()
    //TODO: Need to determine how to consolidate this method to just call updateNmae()
	//TODO: Need to replace updateHHAccountsName() from ACCT_INdividualAccounts_TDTM
	public static void updateHHAccountsName(Set<Id> accIdsToRename) {
    	List<Account> listAccsToRename = new List<Account>();

		listAccsToRename = queryContacts(accIdsToRename);
        //Loop through listAccsToRename and modify the name accordingly
		if (listAccsToRename.size() > 0) {
			for (Account acc : listAccsToRename) {
            	acc.Name = updateName(acc.Contacts);
        	}
		}
        //TODO: We will need to work on DMLWrapper enhancements to check if a certain record is already in DMLwrapper
        //For now, we use direct DML statement to avoid duplicate id issue
        update listAccsToRename;
    }
	private static List<Account> queryContacts(Set<Id> accIdsToRename) {
		List<Account> returnedContacts = new List<Account>();

		//Build dynamic query string
        String strSoql = 'SELECT id, RecordTypeId, ';
        strSoql += '(SELECT Id, AccountId,' +
                'Account.RecordTypeID, ' +
                'Account.Primary_Contact__c, Account.Name,' +
                'firstname, lastname, OwnerId, Salutation,' +
                'MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, ' +
                'OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, ';

        if (ADDR_Addresses_UTIL.isStateCountryPicklistsEnabled) {
			strSoql += 'MailingCountryCode, MailingStateCode, OtherCountryCode, OtherStateCode, ';
		}

        strSoql += 'Phone, Fax FROM Contacts WHERE Exclude_from_Household_Name__c != true)';
        strSoql += 'FROM Account WHERE Id IN :accIdsToRename';

        //Re-query to get correct Account values (and all the other fields we will look at)
        returnedContacts = database.query(strSoql);

		return returnedContacts;
	}
	//This replaced strNameAdmAccountForContact && strNameHHAccountForContact && strNameAccountForContact:
	//TODO: Need to check ACCT_IndividualAccounts_TDTM and replace the methods it is calling
	//TODO: updateHHAccountsName --> Need to incorporate this into updateName() to make it generic and update ACCT_IndividualAccounts_TDTM that's referencing this method.
	public static String updateName(Contact[] cons) {
		String accountNamingFormat;
		String finalAccountName;

        accountNamingFormat = checkAccountFormat();

		System.debug('updateName accountNamingFormat -->' + accountNamingFormat);

		NameSpec ns;
		if (accountNamingFormat != NULL) {
			ns = new NameSpec(accountNamingFormat);
			System.debug('updateName ns -->' + ns);
			return buildAccountName(cons, ns);
		} else {
			finalAccountName = defaultAccountName(cons, accountNamingFormat);
			System.debug('updateName finalAccountName -->' + finalAccountName);

		}
		return finalAccountName;
	}

	public static String checkAccountFormat () {
		String accountNamingFormat;
		System.debug('checkAccountType defaultRecTypeId -->' + defaultRecTypeId);

		if (defaultRecTypeId == hhAccountRecordTypeId) {
			System.debug('checkAccountType hhAccountType -->');
			if (accountNamingFormat == Label.acctNamingOther) {
				accountNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Other_Name_Setting__c;
			}
		} else if (defaultRecTypeId == adminAccountRecordTypeId) {
			System.debug('checkAccountType adminAccountRecordTypeId -->');
			if (accountNamingFormat == Label.acctNamingOther) {
				accountNamingFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Other_Name_Setting__c;
			}
		}

		System.debug('checkAccountType finalAcctNamingFOrmat -->' + accountNamingFormat);
		return accountNamingFormat;
	}

	public static String defaultAccountName(Contact[] cons, String accountNamingFormat) {
		Set<String> householdLastNames = new Set<String>();
        String hhAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Account_Naming_Format__c;
		String adminAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Account_Naming_Format__c;
		String finalAccountName;

		System.debug('defaultAccountName Method -->' + accountNamingFormat);

		for (Contact con : cons) {
			System.debug('defaultAccountName Loop1 -->');

            if (defaultRecTypeId == hhAccountRecordTypeId) {
				System.debug('defaultAccountName HHAccount -->');
				householdLastNames.add(con.LastName);
				System.debug('defaultAccountName HHAccount -->' + householdLastNames);
			} else if (defaultRecTypeId == adminAccountRecordTypeId) {
				System.debug('defaultAccountName adminAcct -->');
				finalAccountName = con.LastName + ' ' + System.label.DefaultAdminName;
				System.debug('defaultAccountName adminAcct -->' + finalAccountName);
				break;
			} else {
				System.debug('defaultAccountName nonHHAdminAcct -->');
				finalAccountName = con.LastName + ' ' + System.label.DefaultAccountName;
				break;
			}
        }
        if (householdLastNames.size() > 0) {
            String name = '';
			String strAnd = ' ' + Label.defaultNamingConnector + ' ';
        	Integer counter = 0;
			System.debug('defaultAccountName householdLastNames Check -->');
        	for (String lastName : householdLastNames) {
				System.debug('defaultAccountName householdLastNames Loop -->');
            	name += lastName;
            	counter++;
				System.debug('defaultAccountName name -->' + name);
				System.debug('defaultAccountName counter -->' + counter);
            	if (counter < householdLastNames.size()) {
 					System.debug('defaultAccountName countercheck-->');
                	name += strAnd;
					System.debug('defaultAccountName name-->' + name);
            	}
        	}
			if (accountNamingFormat == hhAccNamingFormat) {
				System.debug('defaultAccountName accountNamingFormat==HH -->');
				finalAccountName =  name + ' ' + System.label.DefaultHouseholdName;
				System.debug('defaultAccountName finalAccountName -->' + finalAccountName);
    		}
        }
		return finalAccountName;
	}

	private static String chLToken = '{!';
    private static String chRToken = '}';

	private class NameSpec {
		private String namePrefix { get; set; }
        private String nameSuffix { get; set; }
        private String strFirstNameSpec { get; set; }
        private String strFullNameSpec { get; set; }
        private String strAnd { get; set; }
        private string strAcctNameFormat { get; set; }

		//accountNamingFormat should return  Household_Account_Naming_Format__c
		private NameSpec(String accountNamingFormat) {
            String hhAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Account_Naming_Format__c;
			String adminAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Account_Naming_Format__c;
			//strNameSpec should return value ie. {!LastName} Family OR {!LastName} {!FirstName} Family
			//String strNameSpec = String.valueOf()

            //TODO: Fix the acctNamingFormat null result
			String strNameSpec;
			if (accountNamingFormat != NULL) {
				if (accountNamingFormat == hhAccNamingFormat) {
					strNameSpec = String.valueOf(hhAccNamingFormat);
				} else if (accountNamingFormat == adminAccNamingFormat) {
					strNameSpec = String.valueOf(adminAccNamingFormat);
				}
				parseNameSpec(strNameSpec);
			}
		}
		//Returns strFullNameSpec && strFirstNameSpec  - the AccountNameFormat Value ie. {!LastName} Family vs. {!LastNAme} Household
 		private void parseNameSpec(String strNameSpec) {
			namePrefix = '';
            nameSuffix = '';
            strFirstNameSpec = '';
            strFullNameSpec = '';

			if (strNameSpec == NULL) {
				return;
			}

			Integer indexFirstParenthesis = strNameSpec.indexOf(chLToken); //Should return 0
			Integer indexAfterLastParenthesis = strNameSpec.indexOf(chRToken); //Should return more than 0

			//Retrieving the Prefix
			if (indexFirstParenthesis > 0) {
				namePrefix = strNameSpec.left(indexFirstParenthesis);
				strAcctNameFormat = strNameSpec.subString(indexFirstParenthesis);
			}
			//Retrieving the Suffix
			if (indexAfterLastParenthesis > 0) {
				while (indexAfterLastParenthesis < strNameSpec.length()-1 && strNameSpec.subString(indexAfterLastParenthesis+1, indexAfterLastParenthesis+2) != ' ') {
					indexAfterLastParenthesis++;
				}
				nameSuffix = strNameSpec.subString(indexAfterLastParenthesis+1); //Retrieves the suffix ie. Family/Household
				strAcctNameFormat = strNameSpec.left(indexAfterLastParenthesis+1); //Retrieves just the format without the suffix ie. {!LastName}
			}
			//Retrieve FirstNameSpec
			String strFirstName = strFNameSpecFromStrNameSpec(strAcctNameFormat); //Returns the format of the FirstName ie. {!FirstName}
			Integer indexOfLeft = strFirstName.indexOf(chLToken); // -1 for {!LastName} Family scenario
			Integer indexOfRight = strFirstName.lastIndexOf(chRToken); // -1 for {!LastName} Family scenario
			if (indexOfLeft >= 0 && indexOfRight > 0) {
				strFullNameSpec = strNameSpec.replace(strFirstName, 'FirstNameSpec'); //Return {!LastName} FirstNameSpec or FirstNameSpec
				strFirstNameSpec = strFirstName.subString(indexOfLeft + chLToken.length(), indexOfRight);
			} else {
				strFullNameSpec = strAcctNameFormat;
			}
		}
		public set<string> setStrFieldsInNameSpec() {
            System.debug('setStrFieldsInNameSpec Method in NameSpec -->');
            set<string> setStrField = new set<string>();
            if (strFirstNameSpec != null)
                setStrField.addAll(setStrFieldFromStrFSpec(strFirstNameSpec)); //Returns {FirstName}

            if (strFullNameSpec != null)
                setStrField.addAll(setStrFieldFromStrFSpec(strFullNameSpec));  //Returns {FirstName, Lastname} if HHNAmeFormat == {!LastName} {!(FirstName)}
            setStrField.add('LastName');
            return setStrField;
        }

	}

	//Returns the a clean String {FirstName} OR {LastName}
    private static Set<string> setStrFieldFromStrFSpec(String strFSpec) {
        set<string> setStrField = new set<string>();
		System.debug('setStrFieldFromStrFSpec method -->');
        // First, instantiate a new Pattern object looking for {...} without any nested {'s.
        Pattern MyPattern = Pattern.compile('\\{![^\\{!]*\\}');
        System.debug('setStrFieldFromStrFSpec MyPattern -->' + MyPattern);
        // Then instantiate a new Matcher object
        Matcher MyMatcher = MyPattern.matcher(strFSpec);
        System.debug('setStrFieldFromStrFSpec MyMatcher -->' + MyMatcher);

        while (MyMatcher.find()) {
            // get the fieldname without the {}'s
           	System.debug('setStrFieldFromStrFSpec MyMatcherCheck -->' + MyMatcher);
            string strField = strFSpec.substring(MyMatcher.start() + chLToken.length(), MyMatcher.end()-chRToken.length());
            System.debug('setStrFieldFromStrFSpec strField -->' + strField); // Returns just "FirstName/LastName" instead of "{!FirstName}/{!LastName}"
            System.debug('setStrFieldFromStrFSpec strFieldTrim -->' + strField.trim());
            setStrField.add(strField.trim()); //Returns {FirstName} OR {LastName} without !
            System.debug('setStrFieldFromStrFSpec setStrField -->' + setStrField);
        }
        return setStrField;
    }
	//Returns just the {!FirstName} format if it contains additional format
	private static String strFNameSpecFromStrNameSpec(String strAcctNameFormat) {
		Pattern MyPattern = Pattern.compile('\\{![^\\}]*\\{!.*\\}[^\\{!]*\\}');
		Matcher MyMatcher = MyPattern.matcher(strAcctNameFormat);

		if (MyMatcher.find()) {
			return strAcctNameFormat.subString(MyMatcher.start(), MyMatcher.end());
		} else {
			return '';
		}
	}

	private static String buildAccountName(Contact[] cons, NameSpec ns) {
		Integer conSize = cons.size();
		Boolean isNoLastnames = ns.strFullNameSpec.toUpperCase().indexOf(chLToken + 'LASTNAME' + chRToken) == -1;
		Boolean isLastNameOnlyFormat = !isNoLastnames && ns.setStrFieldsInNameSpec().size() == 1;
		Set<String> processedLastNames = new Set<String>();
		String[] finalAccountName = new String[0];
		//strFirstNameSpec ==> {!FirstName}
		//strFullNameSpec ==> {!LastName} (FirstNameSpec)
		for (Integer i = 0, next = 0; i < conSize; i = next) {
			String strLName = cons[i].LastName;
			next = i + 1;

			if (isLastNameOnlyFormat && processedLastNames.contains(strLname)) {
				continue;
			}
			//Adds the lastName
			processedLastNames.add(strLName);

			//TODO: potentially break this into it's own method  - all about firstnames
			//Retrieves value of FirstName
			String strFName = strConFspec(cons[i], ns.strFirstNameSpec);
			//TODO: Need to sort strFName so that it is in order
			//Retrieves additional FName if there's more than 1
			List<String> listFName = new List<String>();
			for (; next < conSize && (isNoLastnames || cons[next].LastName == strLname); next ++) {
				String nextFName = strConFspec(cons[next], ns.strFirstNameSpec);
				if (nextFName != '') {
					listFName.add(nextFname);
				}
			}
			//Strings up the FNames together
			for (Integer k = 0; k <listFName.size(); k++) {
				if (k == listFName.size()-1) {
					strFName += ns.strAnd + listFName[k];
				} else {
					strFName += ', ' + listFName[k];
				}

			}

			//TODO: potentially break this into it's own method - all about lastnames
			String lastName = strConFspec(cons[i], ns.strFullNameSpec);
			lastName = lastName.replace('FirstNameSpec', strFname);
			if (strFname == '') {
				lastName = lastName.trim();
			}
			finalAccountName.add(lastName);
		}
		return ns.namePrefix + stringAccountName(finalAccountName, ns) + ns.nameSuffix;
	}
    private static string strConFspec(Contact con, string strFspec) {
        System.debug('strConFspec Method -->'+ strFspec);
        string str = strFspec;

        // First, instantiate a new Pattern object looking for {...} without any nested {'s.
        Pattern MyPattern = Pattern.compile('\\{![^\\{!]*\\}');
        // Then instantiate a new Matcher object
        Matcher MyMatcher = MyPattern.matcher(strFspec);
        System.debug('strConFspec MyPattern -->'+ MyPattern);
        System.debug('strConFspec MyMatcher -->' + MyMatcher);

        while (MyMatcher.find()) {
            System.debug('strConFspec MyMatcherCheck -->' + MyMatcher);
            // get the fieldname without the {}'s
            string strField = strFspec.substring(MyMatcher.start() + chLToken.length(), MyMatcher.end()-chRToken.length());
            System.debug('strConFspec strField -->' + strField);  //returns just "LastName" instead of {!LastName}

            //separate cross object references, i.e. account.name
            list<string> splitField = (strField.split('\\.',0));
            System.debug('strConFspec splitField -->' + splitField); // returns (LastName)

            //remove the field name itself to only include parent object references
            string fieldName = splitField[splitField.size()-1].trim();
            System.debug('strConFspec fieldName -->' + fieldName); //returns LastName
            splitField.remove(splitField.size()-1);
            System.debug('strConFspec splitField -->' + splitField); //returns nothing ()

            //use the correct sObject
            sObject thisObj;
            if (!splitField.isEmpty()) {
                System.debug('strConFspec splitField Check-->' + splitField);
                thisObj = con.getsObject(splitField[0]);
                System.debug('strConFspec thisObj-->' + thisObj);
                splitField.remove(0);
                System.debug('strConFspec splitField-->' + splitField);
            } else {
                System.debug('strConFspec splitFieldIsEmpty -->' + splitField);
                thisObj = con;
                System.debug('strConFspec thisObj -->' + thisObj); //returns the Contact record
            }

            //traverse parent relationships until the last one
            for (string parentObj : splitField) {
                System.debug('strConFspec parentObj -->' + parentObj);
                if (thisObj != null) {
                    System.debug('strConFspec thisObIsNotBlank -->' + thisObj);
                    thisObj = thisObj.getsObject(parentObj);
                    System.debug('strConFspec thisObj -->' + thisObj);
                }
            }

            string val;
            if (thisObj != null) {
                System.debug('strConFspec thisObIsNotBlank -->' + thisObj);
                val = string.valueOf(thisObj.get(fieldName));
                System.debug('strConFspec val -->' + val); //returns just the last name value "Pens"
            }

            System.debug('strConFspec strField -->' + strField);
            // add back the {}'s for string substitution
            strField = chLToken + strField + chRToken;
            System.debug('strConFspec strField -->' + strField); //returns {!LastName}
            if (val == null) {
                System.debug('strConFspec valIsBlank -->' + val);
                // eat potential trailing space
                System.debug('strConFspec strB4 -->' + str);
                str = str.replace(strField + ' ', '');
                System.debug('strConFspec strAfter -->' + str);
                System.debug('strConFspec strB42-->' + str);
                // eat potential leading space
                str = str.replace(' ' + strField, '');
                System.debug('strConFspec strAfter2-->' + str);
            }
            str = str.replace(strField, val == null ? '' : val);
            System.debug('strConFspec strFinal-->' + str); //returns "Pens" OR // "Thomas (FirstNameSpec)"
        }
        return str;
    }
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