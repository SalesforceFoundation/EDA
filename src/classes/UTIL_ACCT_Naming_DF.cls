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

    private static String hhAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Account_Naming_Format__c;

    private static String adminAccNamingFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Account_Naming_Format__c;

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
	//This replaced strNameAdmAccountForContact && strNameHHAccountForContact : 
	//KD TO DO :  Need to check ACCT_IndividualAccounts_TDTM and replace the methods it is calling
	//KD TO DO :  strNameAccountForContact --> Need to incorporate this in here to add to the "genericness"
	public static String updateName(Contact[] cons) {
		String accountNamingFormat;
		String finalAccountName;
		accountNamingFormat = checkAccountType();

		if (accountNamingFormat != NULL) {
			//return buildAccountName(cons, accountNamingFormat);
		} else {
			finalAccountName = defaultAccountName(cons, accountNamingFormat);

		}
		return finalAccountName;
	}

	public static String checkAccountType () {
		String accountNamingFormat;

		if (defaultRecTypeId == hhAccNamingFormat) {
			accountNamingFormat = hhAccNamingFormat;
			if (accountNamingFormat == Label.acctNamingOther) {
				accountNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Other_Name_Setting__c;
			}
		} else if (defaultRecTypeId == adminAccNamingFormat) {
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
			if (accountNamingFormat == adminAccNamingFormat) {
				finalAccountName = con.LastName + ' ' + System.label.DefaultAdminName;
				break;
			} else {
				householdLastNames.add(con.LastName);
			}
        }
        if (householdLastNames.size() > 0) {
            String name = '';
        	Integer counter = 0;

        	for (String lastName : householdLastNames) {
            	name += lastName;
            	counter++;
            	if (counter < householdLastNames.size()) {
                	name += ' ' + Label.defaultNamingConnector + ' ';
            	}
        	}
			if (accountNamingFormat == hhAccNamingFormat) {
				finalAccountName =  name + ' ' + System.label.DefaultHouseholdName;
    		}
        }
		return finalAccountName;
	}
}