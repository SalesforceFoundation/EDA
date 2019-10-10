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
    public static String hhNameFormat = UTIL_CustomSettingsFacade.getSettings().Household_Account_Naming_Format__c;
    public static String aaNameFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Account_Naming_Format__c;

	public static List<Account> updateAdminAccountsName(List<Contact> listContactsChangedLastName) {
        List<Account> listAccToUpdate = new List<Account>();
        Map<Id, List<Contact>> mapAccIdToCon = new Map<Id, List<Contact>>();

        System.debug('updateAdminAccountsName Method -->' + listContactsChangedLastName);
        for (Contact con : listContactsChangedLastName) {
            if (mapAccIdToCon.containsKey(con.AccountId)) {
                mapAccIdToCon.get(con.AccountId).add(con);
            } else {
                mapAccIdToCon.put(con.AccountId, new List<Contact> {con});
            }

        }
		System.debug('updateAdminAccountsName mapAccIdToCon -->' + mapAccIdToCon);

        for (Account acc: [SELECT Id, Name, RecordTypeId,
                           (SELECT Id, LastName, Salutation, FirstName FROM Contacts WHERE AccountId IN :mapAccIdToCon.keySet())
                           FROM Account WHERE Id IN: mapAccIdToCon.keySet()])
        {
            System.debug('updateAdminAccountsName Account Loop -->' + acc);
            if (acc.RecordTypeId == userDefinedAdminRecordTypeId) {
                System.debug('updateAdminAccountsName Account LoopConCheck -->' + acc.Contacts);
                acc.Name = UTIL_ACCT_Naming_DF.updateName(acc.Contacts);
                System.debug('updateAdminAccountsName Account LoopConCheckAfter -->' + acc.Contacts);
                listAccToUpdate.add(acc);
                System.debug('updateAdminAccountsName listAccToUpdate -->'+ listAccToUpdate);
            }
        }

		System.debug('updateAdminAccountsName listAccToUpdate -->'+ listAccToUpdate);
        return listAccToUpdate;
    }

	public static void updateHHAccountsName(Set<Id> accIdsToRename) {
        System.debug('updateHHAccountsName Method -->' + accIdsToRename);
    	List<Account> listAccsToRename = new List<Account>();

		listAccsToRename = queryContacts(accIdsToRename);
        System.debug('updateHHAccountsName listAccsToRename -->' + listAccsToRename);

        //Loop through listAccsToRename and modify the name accordingly
		if (listAccsToRename.size() > 0) {
			for (Account acc : listAccsToRename) {
                System.debug('updateHHAccountsName acc -->' + acc.Contacts);
            	acc.Name = UTIL_ACCT_Naming_DF.updateName(acc.Contacts);
                System.debug('updateHHAccountsName acc.Name -->' + acc.Name);
        	}
		}

        //For now, we use direct DML statement to avoid duplicate id issue
        System.debug('updateHHAccountsName listAccsToRename -->' + listAccsToRename);
        update listAccsToRename;
    }
	private static List<Account> queryContacts(Set<Id> accIdsToRename) {
		List<Account> returnedContacts = new List<Account>();
		System.debug('queryContacts Method -->' + accIdsToRename);

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

        if (defaultRecTypeId == hhAccountRecordTypeId) {
            strSoql += 'Phone, Fax FROM Contacts WHERE Exclude_from_Household_Name__c != true)';
        }

        strSoql += 'FROM Account WHERE Id IN :accIdsToRename';
        System.debug('queryContacts strSoql -->' + strSoql);

        //Re-query to get correct Account values (and all the other fields we will look at)
        returnedContacts = database.query(strSoql);
        System.debug('queryContacts returnedContacts -->' + returnedContacts);

		return returnedContacts;
	}

	public static String updateName(Contact[] cons) {
		String accountNamingFormat;
		String finalAccountName;

        System.debug('updateName contactCheck -->' + cons);

        accountNamingFormat = checkAccountFormat();

		System.debug('updateName accountNamingFormat -->' + accountNamingFormat);

		NameSpec ns;
		if (accountNamingFormat != NULL) {
			ns = new NameSpec(accountNamingFormat);
			System.debug('updateName ns -->' + ns);
			finalAccountName = buildAccountName(cons, ns);
            System.debug('finalAccountName -->' + finalAccountName);
		} else {
			finalAccountName = defaultAccountName(cons, accountNamingFormat);
			System.debug('updateName finalAccountName -->' + finalAccountName);

		}
        System.debug('finalAccountName -->' + finalAccountName);
		return finalAccountName;
	}

	public static String checkAccountFormat () {
		String accountNamingFormat;
		System.debug('checkAccountType defaultRecTypeId -->' + defaultRecTypeId);
        System.debug('checkAccountFormatType hhNameFormat -->' + hhNameFormat);

		if (defaultRecTypeId == hhAccountRecordTypeId) {
			System.debug('checkAccountType hhAccountType -->');

			accountNamingFormat = hhNameFormat;
            if (accountNamingFormat == Label.acctNamingOther) {
                accountNamingFormat = UTIL_CustomSettingsFacade.getSettings().Household_Other_Name_Setting__c;
            }

            System.debug('checkAccountType accountNamingFormat -->' + accountNamingFormat);
		} else if (defaultRecTypeId == adminAccountRecordTypeId) {

            System.debug('checkAccountType adminAccountRecordTypeId -->');
			accountNamingFormat = aaNameFormat;
            if (accountNamingFormat == Label.acctNamingOther) {
                accountNamingFormat = UTIL_CustomSettingsFacade.getSettings().Admin_Other_Name_Setting__c;
            }

            System.debug('checkAccountType accountNamingFormat -->' + accountNamingFormat);
		}

		System.debug('checkAccountType finalAcctNamingFOrmat -->' + accountNamingFormat);
		return accountNamingFormat;
	}

	public static String defaultAccountName(Contact[] cons, String accountNamingFormat) {
		Set<String> householdLastNames = new Set<String>();
		String finalAccountName;

		System.debug('defaultAccountName Method -->' + cons);

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
			if (accountNamingFormat == hhNameFormat) {
				System.debug('defaultAccountName accountNamingFormat==HH -->');
				finalAccountName =  name + ' ' + System.label.DefaultHouseholdName;
				System.debug('defaultAccountName finalAccountName -->' + finalAccountName);
    		}
        }
        System.debug('defaultAccountName finalAccountName -->' + finalAccountName);
		return finalAccountName;
	}

	private static String chLToken = '{!';
    private static String chRToken = '}';
    public static Boolean setFNSpec = false;

	private class NameSpec {
		private String namePrefix { get; set; }
        private String nameSuffix { get; set; }
        private String strFirstNameSpec { get; set; }
        private String strFullNameSpec { get; set; }
        private String strAnd { get; set; }
        private string strAcctNameFormat { get; set; }
        private String strSalutation {get; set; }

		//accountNamingFormat should return  Household_Account_Naming_Format__c
		private NameSpec(String accountNamingFormat) {
            System.debug('NameSpec Method -->' + accountNamingFormat);
			//strNameSpec should return value ie. {!LastName} Family OR {!LastName} {!FirstName} Family
			//String strNameSpec = String.valueOf()

            String strNameSpec;
			if (accountNamingFormat != NULL) {
                System.debug('NameSpec accountNamingFormatNotBlank --->');
                strNameSpec = String.valueOf(accountNamingFormat);
				parseNameSpec(strNameSpec);
			}
		}
		//Returns strFullNameSpec && strFirstNameSpec  - the AccountNameFormat Value ie. {!LastName} Family vs. {!LastNAme} Household
 		private void parseNameSpec(String strNameSpec) {
            System.debug('parseNameSpec Method -->' + strNameSpec);
			namePrefix = '';
            nameSuffix = '';
            strFirstNameSpec = '';
            strFullNameSpec = '';
			strAnd = ' ' + Label.defaultNamingConnector + ' ';

			if (strNameSpec == NULL) {
				return;
			}
			// {!{!FirstName}} {!LastName} Family
			Integer indexFirstParenthesis = strNameSpec.indexOf(chLToken); //Should return 0
            System.debug('parseNameSpec indexFirstParenthesis -->' + indexFirstParenthesis);
            System.debug('parseNameSpec strNameSpec -->'+ strNameSpec);
            System.debug('parseNameSpec chRToken -->'+ chRToken);
			Integer indexAfterLastParenthesis = strNameSpec.lastIndexOf(chRToken); //Should return more than 0.
            System.debug('parseNameSpec indexAfterLastParenthesis -->' + indexAfterLastParenthesis);

			//Retrieving the Prefix
			if (indexFirstParenthesis > 0) {
				namePrefix = strNameSpec.left(indexFirstParenthesis);
				strAcctNameFormat = strNameSpec.subString(indexFirstParenthesis);
                System.debug('NameSpec strAcctNameFormat namePrefix  -->' + namePrefix);
                System.debug('NameSpec strAcctNameFormat inPrefix  -->' + strAcctNameFormat);
			}

			//Retrieving the Suffix
			if (indexAfterLastParenthesis > 0) {
				while (indexAfterLastParenthesis < strNameSpec.length()-1 && strNameSpec.subString(indexAfterLastParenthesis+1, indexAfterLastParenthesis+2) != ' ') {
					indexAfterLastParenthesis++;
				}
				nameSuffix = strNameSpec.subString(indexAfterLastParenthesis+1); //Retrieves the suffix ie. Family/Household
				strAcctNameFormat = strNameSpec.left(indexAfterLastParenthesis+1); //Retrieves just the format without the suffix ie. {!LastName}
                System.debug('NameSpec strAcctNameFormat in Suffix -->' + nameSuffix);
                System.debug('NameSpec strAcctNameFormat -->' + strAcctNameFormat);
			}

			System.debug('NameSpec strAcctNameFormat -->' + strAcctNameFormat);

            //Retrieve FirstNameSpec
			String strFirstName = strFNameSpecFromStrNameSpec(strAcctNameFormat); //Returns the format of the FirstName ie. {!FirstName}
            System.debug('NameSpec strFirstName -->' + strFirstName);

            //Retrieving Salutation
            strSalutation = strSalutationFromStrNameSpec(strAcctNameFormat);
            System.debug('NameSpec strSalutation -->' + strSalutation);

            Integer indexOfLeft = strFirstName.indexOf(chLToken); // -1 for {!LastName} Family scenario
			Integer indexOfRight = strFirstName.lastIndexOf(chRToken); // -1 for {!LastName} Family scenario
            System.debug('NameSpec indexOfLeft -->' + indexOfLeft);//0
            System.debug('NameSpec indexOfRight -->' + indexOfRight);//14

            if (indexOfLeft >= 0 && indexOfRight > 0) {
                System.debug('NameSpec strNameSpec check beforesettingstrFullNameSpec --> ' + strNameSpec);
                System.debug('NameSpec strFirstName -->' + strFirstName);
               	if (strSalutation == NULL || strSalutation == '') {
                    strFullNameSpec = strAcctNameFormat.replace(strFirstName, 'FirstNameSpec'); //Return {!LastName} FirstNameSpec or FirstNameSpec
                } else {
                    strFullNameSpec = strAcctNameFormat;
                }
                System.debug('NameSpec strFullNameSpec string -->' + strFullNameSpec);
                //Do a check if it's {!{!FirstName}} vs {!FirstName}
                System.debug('setFNSpec Check -->'  + setFNSpec);
                if (setFNSpec) {
                	strFirstNameSpec = strFirstName.subString(indexOfLeft + chLToken.length(), indexOfRight);
                } else {
                   	strFirstNameSpec =  strFirstName;
                }
                System.debug('NameSpec strFirstNameSpec string -->' + strFirstNameSpec);
			} else {
                System.debug('NameSpec strFullNameSpec stringELSE -->' + strFullNameSpec);
				strFullNameSpec = strAcctNameFormat;
                System.debug('NameSpec strFullNameSpec stringELSE -->' + strFullNameSpec);
			}
		}
		public set<string> setStrFieldsInNameSpec() {
            System.debug('setStrFieldsInNameSpec Method in NameSpec -->');
            set<string> setStrField = new set<string>();
            if (strFirstNameSpec != null) {
                setStrField.addAll(setStrFieldFromStrFSpec(strFirstNameSpec)); //Returns {FirstName}
            }

            if (strFullNameSpec != null){
               	setStrField.addAll(setStrFieldFromStrFSpec(strFullNameSpec));  //Returns {FirstName, Lastname} if HHNAmeFormat == {!LastName} {!(FirstName)}
            }

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

    private static String strSalutationFromStrNameSpec(String strAcctNameFormat) {
  		String regexPattern = '(?:^|\\W)Salutation(?:$|\\W)';
      	Pattern MyPattern = Pattern.compile(regexPattern);
        System.debug('strFNameSpecFromStrNameSpec MyPattern -->' + MyPattern);
		Matcher MyMatcher = MyPattern.matcher(strAcctNameFormat);
		System.debug('MyMatcher1 -->' + MyMatcher);

        if (MyMatcher.find()) {
            System.debug('strFNameSpecFromStrNameSpec FindCheck -->');
			return strAcctNameFormat.subString(MyMatcher.start()-1, MyMatcher.end());
		} else {
            System.debug('strFNameSpecFromStrNameSpec FindCheckFail -->');
			return '';
        }

    }

	//Returns just the {!FirstName} format if it contains additional format
	private static String strFNameSpecFromStrNameSpec(String strAcctNameFormat) {
        System.debug('strFNameSpecFromStrNameSpec Method -->' + strAcctNameFormat); //{!FirstName} {!LastName} {!{!FirstName}} {!LastName}
        String regex1 = '\\{![^\\}]*\\{!.*\\}[^\\{!]*\\}';
        String regex2 = '^\\{![^\\}]*[^\\{!]*\\}';

        String regexPattern = '(?:^|\\W)FirstName(?:$|\\W)';
        Pattern MyPattern = Pattern.compile(regexPattern);

        System.debug('strFNameSpecFromStrNameSpec MyPattern -->' + MyPattern);

		Matcher MyMatcher = MyPattern.matcher(strAcctNameFormat);
		System.debug('MyMatcher1 -->' + MyMatcher);

        Pattern MyPatternCheck = Pattern.compile(regex1);
        Matcher MyMatcher2 = MyPatternCheck.matcher(strAcctNameFormat);

        if (MyMatcher2.find()) {
            setFNSpec = true;
        }

		if (MyMatcher.find()) {
            System.debug('strFNameSpecFromStrNameSpec FindCheck -->');
			return strAcctNameFormat.subString(MyMatcher.start()-1, MyMatcher.end());
		} else {
            System.debug('strFNameSpecFromStrNameSpec FindCheckFail -->');
			return '';
        }
	}

	private static String buildAccountName(Contact[] cons, NameSpec ns) {
		Set<String> processedLastNames = new Set<String>();
		String[] finalAccountName = new String[0];
        String strSalutation = '';
        Integer conSize = cons.size();
        Boolean isNoLastnames = ns.strFullNameSpec.toUpperCase().indexOf(chLToken + 'LASTNAME' + chRToken) == -1; //{!LastName}
		Boolean isLastNameOnlyFormat = !isNoLastnames && ns.setStrFieldsInNameSpec().size() == 1;
		Map<Id, List<Contact>> mapLastFirstName = new Map<Id, List<Contact>>();

        //cons.sort(); //This sorts it alphabetical.
        System.debug('checkContactRecord -->' + cons);
        System.debug('conSize -->' + conSize);
        System.debug('isNoLastnames -->' + isNoLastnames);
        System.debug('isLastNameOnlyFormat -->' + isLastNameOnlyFormat);
		//strFirstNameSpec ==> {!FirstName}
		//strFullNameSpec ==> {!LastName} (FirstNameSpec)

        for (Integer i = 0, next = 0; i < conSize; i = next) {
            System.debug('buildAcc iCheck -->' + i);
        	System.debug('buildAcc next -->' + next);
        	System.debug('buildAcc iConSizeCheck -->' + (i<conSize));
            System.debug('buildAcc inextCheck -->' + (i==next));

            String strLName = cons[i].LastName;
            next = i + 1;
            System.debug('strLName -->' + strLName);
            System.debug('next -->' + next);

			if (isLastNameOnlyFormat && processedLastNames.contains(strLName)) {
				continue;
			}

			//Adds the lastName
			processedLastNames.add(strLName);
            System.debug('processedLastNames -->' + processedLastNames);

            //Retrieves Salutation
            System.debug('buildAcctName strSalutation -->' + ns.strSalutation); //ns.strSalutation == {!Salutation}
            List<String> listSalutation = new List<String>();
            strSalutation = strConFspec(cons[i], ns.strSalutation, true);
            System.debug('buildAcctName strSalutation -->' + strSalutation); //ie. "Mr."


            //strSalutation = processSalutation(cons, listSalutation, strSalutation, ns, next, conSize);
            System.debug('strSalutationAfter -->' + strSalutation);
            System.debug('buildAccountName strFirstNameSpec -->' + ns.strFirstNameSpec); //ns.strFirstNameSpec == {!FirstName}

			//Retrieves value of FirstName
			String strFName = strConFspec(cons[i], ns.strFirstNameSpec, false);
            System.debug('buildAccountName strFName -->' + strFName); //returns value FirstName ie. "0Test0"

            //Retrieves additional Salutation/FNs if there are multiple
			List<String> listFName = new List<String>();
            System.debug('buildacctname next -->' + next);
            System.debug('buildacctname conSize -->' + conSize);
            //System.debug('buildAcct logic -->' + (isNoLastnames || cons[next].LastName == strLname));

            for (; next < conSize && (isNoLastnames || cons[next].LastName == strLname); next++) {
                System.debug('buildacctname nextIn Loop -->' + next);
                System.debug('strFName forloop -->' + strFName);
                System.debug('buildAccountName FNcons Check -->' + cons);


                //if (strSalutation != NULL || strSalutation != '') {
                    System.debug('InsideInnerSLloop -->');
                   	String nextSalutation = strConFspec(cons[next], ns.strSalutation, true);
                	System.debug('InsideSalutation nextSalutation -->' + nextSalutation);
                	if (nextSalutation != '') {
                    	System.debug('InsideSalutation nextSalutation -->' + nextSalutation);
                    	listSalutation.add(nextSalutation);
                    	System.debug('InsideSalutation listSalutation -->' + listSalutation);//Returns Mr.
                	}
                //}

                //if (strFName != NULL || strFName != '') {
                    System.debug('InsideInnerFNloop -->');
                    String nextFName = strConFspec(cons[next], ns.strFirstNameSpec, false);
                	System.debug('nextFName  -->' + nextFName);
                	if (nextFName != '') {
						listFName.add(nextFname);
                    	System.debug('listFName  -->' + listFName);
					}
                //}

				System.debug('buildacctname nextIn LoopB4Ends -->' + next);
                if (isNoLastnames) {
                    break;
                }
			}
            System.debug('FinallistFNameB4 -->' + listFName); //Shows additional first names
                   System.debug('buildAccBEFOREPprocess iCheck -->' + i);
        	System.debug('buildAccBEFOREPprocess next -->' + next);
        	System.debug('buildAccBEFOREPprocess iConSizeCheck -->' + (i<conSize));
            System.debug('buildAccBEFOREPprocess inextCheck -->' + (i==next));

            //Processing the stringing up
			String name = processName(cons, strLname, strFName, strSalutation, listFName,listSalutation, ns, conSize,
                                      		i, next, isNoLastnames);

            System.debug('Namecheck -->' + name);

            System.debug('finalAccountNameB4 -->' + finalAccountName);
            if (String.isNotBlank(name)) {
                 System.debug('nameStringCheck -->' + name);
               finalAccountName.add(name);
                System.debug('nameStringCheckAfter -->' + finalAccountName);
            }

            System.debug('finalAccountName -->' + finalAccountName);

            System.debug('buildAccEND iCheck -->' + i);
        	System.debug('buildAccEND next -->' + next);
        	System.debug('buildAccEND iConSizeCheck -->' + (i<conSize));
            System.debug('buildAccEND inextCheck -->' + (i==next));

		}

        System.debug('buildAcctName prefix -->' + ns.namePrefix);
        System.debug('buildAcctName suffix -->' + ns.nameSuffix);
        System.debug('strSalutationAfter -->' + strSalutation);
		//return ns.namePrefix + strSalutation + stringAccountName(finalAccountName, ns) + ns.nameSuffix;
		return ns.namePrefix + stringAccountName(finalAccountName, ns) + ns.nameSuffix;
	}

    /*private static String processSalutation(Contact[] cons, String[] listSalutation, String strSalutation,
                                          NameSpec ns, Integer next, Integer conSize) {

        //Processing more than 1 Salutation
        if (strSalutation != NULL || strSalutation != '') {
            for (; next < conSize; next ++) {
                Boolean salutationCheck = true;
                String nextSalutation = strConFspec(cons[next], ns.strSalutation, true);
                System.debug('InsideSalutation nextSalutation -->' + nextSalutation);
                if (nextSalutation != '') {
                    System.debug('InsideSalutation nextSalutation -->' + nextSalutation);
                    listSalutation.add(nextSalutation);
                    System.debug('InsideSalutation listSalutation -->' + listSalutation);
                }
            }
        }

        //Strings up the Salutations together
        for (Integer h = 0; h < listSalutation.size(); h++) {
            System.debug('InsideSalutation Stringingup -->');
        	if (h == listSalutation.size()-1) {
            	System.debug('strSalutation Add AND-->' + strSalutation);
                if (strSalutation == NULL || strSalutation == '') {
                	System.debug('strSalutationIsNull -->' + strSalutation);
                   	strSalutation = listSalutation[h];
                    System.debug('strSalutationIsNull -->' + strSalutation);
                } else {
                    System.debug('strSalutationELSE -->' + strSalutation);
                    strSalutation += ns.strAnd + listSalutation[h];
                    System.debug('strSalutationAdd AND-->'+ strSalutation);
                }

            } else {
              System.debug('strSalutation Add Comma -->'+ strSalutation);
              strSalutation += ', '+ listSalutation[h];
              System.debug('strSalutation Add Comma -->'+ strSalutation);
           	}
      	}
        System.debug('strSalutationfinal -->' + strSalutation);
        return strSalutation;
    }*/

    private static String processName( Contact[] cons, String strLName, String strFName, String strSalutation, String[] listFName, String[] listSalutation,
                                      NameSpec ns, Integer conSize, Integer i, Integer next, Boolean isNoLastnames) {

            System.debug('strLname return -->' + strLName); //0Contact_forTests0
            System.debug('strFName return -->' + strFName);//0Test0 Firstname value
            System.debug('listFName -->' + listFName);
			 System.debug('buildAccPROCESSbegin iCheck -->' + i);
        	System.debug('buildAccPROCESSbegin next -->' + next);
        	System.debug('buildAccPROCESSbegin iConSizeCheck -->' + (i<conSize));
            System.debug('buildAccPROCESSbegin inextCheck -->' + (i==next));
            //Strings up the Salutations together
        for (Integer h = 0; h < listSalutation.size(); h++) {
            System.debug('InsideSalutation Stringingup -->');
        	if (h == listSalutation.size()-1) {
            	System.debug('strSalutation Add AND-->' + strSalutation);
                if (strSalutation == NULL || strSalutation == '') {
                	System.debug('strSalutationIsNull -->' + strSalutation);
                   	strSalutation = listSalutation[h];
                    System.debug('strSalutationIsNull -->' + strSalutation);
                } else {
                    System.debug('strSalutationELSE -->' + strSalutation);
                    strSalutation += ns.strAnd + listSalutation[h];
                    System.debug('strSalutationAdd AND-->'+ strSalutation);
                }

            } else {
              System.debug('strSalutation Add Comma -->'+ strSalutation);
              strSalutation += ', '+ listSalutation[h];
              System.debug('strSalutation Add Comma -->'+ strSalutation);
           	}
      	}

            //Strings up the FNames together
			for (Integer k = 0; k <listFName.size(); k++) {
                System.debug('strFName 2ndLoop --->');
				if (k == listFName.size()-1) {
                    System.debug('strFName Add -->');
                    if (strFName == NULL || strFName == '') {
                        System.debug('strFName Add isBlank -->' + strFName);
                        strFName = ' ' + listFName[k];
                        System.debug('strFName Add isBlank -->' + strFName);
                    } else {
                        System.debug('strFName Add NotBlank -->' + strFName);
                        strFName += ns.strAnd + listFName[k];
                    	System.debug('strFName Add NotBlank -->' + strFName);
                    }
				} else {
                    System.debug('strFName ElseIfB4 -->' + strFName);
					strFName += ', ' + listFName[k];
                    System.debug('strFName ElseIfAfter -->' + strFName);
				}
			}
            System.debug('FinalStrFName -->' + strFName);

            //Handles processing LastNames
            System.debug('processName strFullNameSpec -->' + ns.strFullNameSpec);  //ns.strFullNameSpec => {!Salutation} {!FirstName}
            //Boolean processLN = false;
        	String acctName = strConFspec(cons[i], ns.strFullNameSpec, false); //passes {!Salutation} {!FirstName}
            System.debug('lastName return -->'+ acctName);      //Mr. 0Test0
			acctName = acctName.replace('FirstNameSpec', strFname);
            System.debug('lastName afterReplace -->'+ acctName); //ie. Mr. 0Test0

            if (strFname == '') {
                System.debug('firstNameCheck check -->'+ acctName);
				acctName = acctName.trim();
                System.debug('lastname trim -->'+ acctName);
			}

            System.debug('BuildAccount lastName -->'+ acctName);

            System.debug('buildAccPROCESS iCheck -->' + i);
        	System.debug('buildAccPROCESS next -->' + next);
        	System.debug('buildAccPROCESS iConSizeCheck -->' + (i<conSize));
            System.debug('buildAccPROCESS inextCheck -->' + (i==next));
            return acctName;
    }

    private static String strConFspec(Contact con, string strFspec, Boolean salutationCheck) {
        System.debug('strConFspec Method -->'+ strFspec); //strFSpec == {!Salutation}
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
            String strField = strFspec.substring(MyMatcher.start() + chLToken.length(), MyMatcher.end()-chRToken.length());
            System.debug('strConFspec strField -->' + strField);  //returns just "LastName" instead of {!LastName}

            //separate cross object references, i.e. account.name
            List<String> splitField = (strField.split('\\.',0));
            //splitField.sort(); //Testing if this will alphabetize the LName
            System.debug('strConFspec splitField -->' + splitField); // returns (LastName)

            //remove the field name itself to only include parent object references
            String fieldName = splitField[splitField.size()-1].trim();
            System.debug('strConFspec fieldName -->' + fieldName); //returns LastName //removes the the () and returns just the value
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

            String val; //Assigns the actual value of the Salutation/FN/LN to the String val.

            if (thisObj != null) {
                System.debug('strConFspec thisObIsNotBlank -->' + thisObj);
                val = String.valueOf(thisObj.get(fieldName)); //fieldName == {!Salutation}
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
                str = str.replace(strField + ' ', ''); //Replaced {!Salutation} {!FirstName} with just {!FirstName}
                System.debug('strConFspec strAfter -->' + str);
                System.debug('strConFspec strB42-->' + str);
                // eat potential leading space
                str = str.replace(' ' + strField, '');
                System.debug('strConFspec strAfter2-->' + str); //just returns {!FirstName}
            }

            System.debug('strCheck Value -->' + str); //ie. {!Salutation}
            System.debug('valCheck Value -->' + val); //ie. "Mr."
            System.debug('strFieldCheck Value -->' + strField); //ie. {!Salutation}
            str = str.replace(strField, val == null ? '' : val);
            System.debug('strCheck ValueAfter -->' + str);

            System.debug('strConFspec strFinal-->' + str); //returns "Pens" OR // "Thomas (FirstNameSpec)"
        }
        System.debug('strConFspec str -->' + str); //Mr. 0Test0
        return str;
    }

	private static String stringAccountName(String[] finalAccountName, NameSpec ns) {
        System.debug('stringAccountName Method -->');
		String name = '';
		String delimeter = '';
		Integer size = finalAccountName.size();
        System.debug('stringAccountName finalAccountName -->' + finalAccountName);

		for (Integer i = 0; i < size; i ++) {
            System.debug('stringAccountName firstloop -->');
			if (i > 0 && i == size - 1) {
                System.debug('stringAccountName if -->');
				delimeter = ns.strAnd;
			} else if (i > 0) {
                System.debug('stringAccountName elseIf -->');
				delimeter = ', ';
			}
            System.debug('stringAccountName nameB4 -->' + name);
			name += delimeter + finalAccountName[i];
            System.debug('stringAccountName nameAfter -->' + name);
		}
        System.debug('stringAccountName accountNameFinal -->' + name);
		return name;
	}
}