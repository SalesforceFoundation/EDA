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
	private static ID hhAccountRecordTypeId = UTIL_CustomSettingsFacade.getSettings().Household_Addresses_RecType__c;
	private static ID adminAccountRecordTypeId = UTIL_CustomSettingsFacade.getSettings().Administrative_Account_Record_Type__c;

    private static String hhAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Account_Naming_Format__c;

    private static String adminAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Account_Naming_Format__c;

	//1. KD TO DO: updateAdminAccountsNmae();


    //KD TO DO: Need to replace this from ACCT_INdividualAccounts_TDTM and make this method more generic.
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
	//KD TO DO :  Need to check ACCT_IndividualAccounts_TDTM and replace the methods it is calling
	//KD TO DO : updateHHAccountsName --> Need to incorporate this into updateName() to make it generic and update ACCT_IndividualAccounts_TDTM that's referencing this method.
	public static String updateName(Contact[] cons) {
		String accountNamingFormat;
		String finalAccountName;
		accountNamingFormat = checkAccountType();

		if (accountNamingFormat != NULL) {
			return buildAccountName(cons, accountNamingFormat);
		} else {
			finalAccountName = defaultAccountName(cons, accountNamingFormat);

		}
		return finalAccountName;
	}

	public static String checkAccountType () {
		String accountNamingFormat;

		if (defaultRecTypeId == hhAccountRecordTypeId) {
			accountNamingFormat = hhAccNamingFormat;
			if (accountNamingFormat == Label.acctNamingOther) {
				accountNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Other_Name_Setting__c;
			}
		} else if (defaultRecTypeId == adminAccountRecordTypeId) {
			accountNamingFormat = adminAccNamingFormat;
			if (accountNamingFormat == Label.acctNamingOther) {
				accountNamingFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Other_Name_Setting__c;
			}
		}
		return accountNamingFormat;
	}

	public static String defaultAccountName(Contact[] cons, String accountNamingFormat) {
		Set<String> householdLastNames = new Set<String>();
		String finalAccountName;

		for (Contact con : cons) {
			if (accountNamingFormat == hhAccNamingFormat) {
				householdLastNames.add(con.LastName);
			} else if (accountNamingFormat == adminAccNamingFormat) {
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
			if (accountNamingFormat == hhAccNamingFormat) {
				finalAccountName =  name + ' ' + System.label.DefaultHouseholdName;
    		}
        }
		return finalAccountName;
	}

	private static String chLToken = '{!';
    private static String chRToken = '}';

	private class NameSpec {
		private String namePrefix = new String();
        private String nameSuffix = new String();
        private String strFirstNameSpec { get; set; }
        private String strFullNameSpec { get; set; }
        private String strAnd { get; set; }
        //private string strOverrun { get; set; }
        //private integer cMaxUseOverrun { get; set; }
        private string strAcctNameFormat { get; set; }

		//accountNamingFormat should return  Household_Account_Naming_Format__c
		private NameSpec(String accountNamingFormat) {
			//strNameSpec should return value ie. {!LastName} Family OR {!LastName} {!FirstName} Family
			String strNameSpec = NULL;
			if (accountNamingFormat != NULL) {
				if (accountNamingFormat == hhAccNamingFormat) {
					strNameSpec = String.valueOf(hhAccNamingFormat);
				} else if (accountNamingFormat == adminAccNamingFormat) {
					strNameSpec = String.valueOf(adminAccNamingFormat);
				}
			}
		}

		private void parseNameSpec(String strNameSpec) {
			namePrefix = '';
            nameSuffix = '';
            strFirstNameSpec = '';
            strFullNameSpec = '';

			if (accountNamingFormat == NULL) {
				return;
			}

			Integer indexFirstParenthesis = accountNamingFormat.indexOf(chLToken); //Should return 0
			Integer indexAfterLastParenthesis = accountNamingFormat.indexOf(chRToken); //Should return more than 0

			//Retrieving the Prefix
			if (indexFirstParenthesis > 0) {
				namePrefix = accountNamingFormat.left(chLToken);
				strAcctNameFormat = accountNamingFormat.subString(chLToken);
			}
			//Retrieving the Suffix
			if (indexAfterLastParenthesis > 0) {
				while (indexAfterLastParenthesis < accountNamingFormat.length()-1 && accountNamingFormat.subString(indexAfterLastParenthesis+1, indexAfterLastParenthesis+2) != ' ') {
					indexAfterLastParenthesis++;
				}
				nameSuffix = indexAfterLastParenthesis.subString(indexAfterLastParenthesis+1); //Retrieves the suffix ie. Family/Household
				strAcctNameFormat = accountNamingFormat.left(indexAfterLastParenthesis+1); //Retrieves just the format without the suffix ie. {!LastName}
			}
			//Retrieve FirstNameSpec
			String strFirstName = strFNameSpecFromStrNameSpec(strAcctNameFormat);
			Integer indexOfLeft = strFirstName.indexOf(chLToken); // -1 for {!LastName} Family scenario
			Integer indexOfRight = strFirstName.lastIndextOf(chRToken); // -1 for {!LastName} Family scenario
			if (indexOfLeft >= 0 && indexOfRight > 0) {
				strFirstNameSpec = accountNamingFormat.replace(strFirstName, 'FirstNameSpec');
				strFullNameSpec = strFirstName.subString(indexOfLeft + chLToken.length(), indexOfRight);
			} else {
				strFirstNameSpec = strAcctNameFormat;
			}
		}
		public set<string> setStrFieldsInNameSpec() {
            System.debug('setStrFieldsInNameSpec Method in NameSpec -->');
            set<string> setStrField = new set<string>();
            if (strFirstNameSpec != null)
                setStrField.addAll(setStrFieldFromStrFSpec(strFirstNameSpec));
            if (strFullNameSpec != null)
                setStrField.addAll(setStrFieldFromStrFSpec(strFullNameSpec));
            setStrField.add('LastName');
            return setStrField;
        }

	}
	private static String strFNameSpecFromStrNameSpec(String strAcctNameFormat) {
		Pattern MyPattern = Pattern.compile('\\{![^\\}]*\\{!.*\\}[^\\{!]*\\}');
		Matcher MyMatcher = MyPattern.matcher(strAcctNameFormat);

		if (MyMatcher.find()) {
			return strAcctNameFormat.subString(MyMatcher.start(), MyMatcher.end());
		} else {
			return '';
		}
	}
}