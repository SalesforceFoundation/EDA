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
* @description Test Class for the TDTM_Manager class
*/
@isTest
private class TDTM_Manager_TEST {

	/***
		Test the token equals and hashCode methods in the TDTM Token
	***/
	@isTest
	public static void verifyEquality() {

		insertTestDefaults();

		// Instantiate the TDTM Trigger Handler Manager
		TDTM_Manager manager = new TDTM_Manager('hed');
		Set<TDTM_Global_API.TdtmToken> defaultTokenSet = manager.packageTokens;

		// Set up references to existing trigger handlers already in the database. This
		// is testing that even though the references are different in memory they are still
		// equal.
        Map<Id,Trigger_Handler__c> existingDBHandlers = new Map<Id,Trigger_Handler__c>([SELECT Id, Active__c , Asynchronous__c , Class__c , Load_Order__c , Object__c , Trigger_Action__c
	        , User_Managed__c, Owned_by_Namespace__c, Filter_Field__c, Filter_Value__c, Usernames_to_Exclude__c
			FROM Trigger_Handler__c ORDER BY Load_Order__c]);
        Set<TDTM_Global_API.TdtmToken> existingDBtokens = manager.getTokenSet(existingDBHandlers);

        // Check Hash Code
		System.assertEquals(defaultTokenSet.hashCode(), existingDBtokens.hashCode() );

		// Check direct comparisons
		System.assertEquals(defaultTokenSet, existingDBtokens);
	}

	/* This test is installing the actual defaults to the database and checking the value of TDTM_Config.getTdtmConfig() */
	@isTest
	public static void verifyDefaultsConfig() {
        // Install Default EDA TDTM Configuration
        List<TDTM_Global_API.TdtmToken> defaultTokens = TDTM_Global_API.getDefaultTdtmConfig();
        TDTM_Global_API.setTdtmConfig(defaultTokens, 'hed');

        // Verify there are items in the DB
		System.assertEquals(false , TDTM_Config.isEmpty() );

		// Need to clear the cache for the test
		TDTM_Config.tdtmTokensCache = null;

        // This should pull items from the database.
		List<TDTM_Global_API.TdtmToken> tdtmConfig = TDTM_Config.getTdtmConfig();
		Set<TDTM_Global_API.TdtmToken> tdtmConfigSet = new Set<TDTM_Global_API.TdtmToken>(tdtmConfig);

		// Instantiate the TDTM Trigger Handler Manager
		TDTM_Manager manager = new TDTM_Manager('hed');
		Set<TDTM_Global_API.TdtmToken> defaultTokenSet = manager.packageTokens;

		// Make sure items in DB count match
		System.assertEquals(defaultTokenSet.size(), tdtmConfigSet.size() );
	}

	@isTest
	public static void newHandlers() {
		TDTM_Manager manager = new TDTM_Manager('hed');
		// Verifying there is nothing in the DB.
		System.assertEquals(manager.packageTokens.size(), 0);

        Set<TDTM_Global_API.TdtmToken> defaults = getBasicDefaults();

		Test.startTest();
		manager.updateDefaultTdtmConfig(defaults);
		Test.stopTest();

		// There are three defaults
		System.assertEquals(3, getDbHanders().values().size() );
	}

	@isTest
	public static void newHandlersNullName() {
		// Setup new configuration
        Set<TDTM_Global_API.TdtmToken> noNameConfig = new Set<TDTM_Global_API.TdtmToken>();
        noNameConfig.add(new TDTM_Global_API.TdtmToken('AFFL_Affiliations_TDTM', 'Contact', 'AfterInsert;AfterUpdate', 2, true, false, null, null, false, null, null));
        noNameConfig.add(new TDTM_Global_API.TdtmToken('REL_Relationships_Cm_TDTM', 'CampaignMember', 'AfterInsert;AfterUpdate;AfterDelete', 5.2, true, false, null, null, false, null, null));
        noNameConfig.add(new TDTM_Global_API.TdtmToken('REL_Relationships_Con_TDTM', 'Contact', 'AfterInsert;AfterDelete', 1, true, false, null, null, false, null, null));

		TDTM_Manager manager = new TDTM_Manager(null);
		Test.startTest();
		manager.updateDefaultTdtmConfig(noNameConfig);
		Test.stopTest();

		// There are three defaults
		System.assertEquals(3, getDbHanders().values().size() );
	}

	// Test the deletion of a trigger handler
	@isTest
	public static void removeHandlers() {
		// Persist defaults to the DB
		TDTM_Manager tmpManager = new TDTM_Manager('hed');

        Set<TDTM_Global_API.TdtmToken> defaults = getBasicDefaults();
		tmpManager.updateDefaultTdtmConfig( defaults );

		// Setup new defaults with one missing to test removal from default.
		defaults.remove( new TDTM_Global_API.TdtmToken('AFFL_Affiliations_TDTM', 'Contact', 'AfterInsert', 1, true, false, null, null, false, 'hed', null) ); // Remove a single item

		// Instantiate new manager for test.
		TDTM_Manager removeManager = new TDTM_Manager('hed');

		Test.startTest();
		// Note: updateDefaultTdtmConfig will empty defaults
		removeManager.updateDefaultTdtmConfig( defaults );
		Test.stopTest();

		// There are 3 defaults originally and we delete one via configuration
		System.assertEquals(2, getDbHanders().values().size() );
	}

	// Testing the update of Trigger handlers also verifying user Managed Handlers are left alone
	@isTest
	public static void updatingDefaultHandlers() {

		// Add user managed trigger
		Trigger_Handler__c myHandler = new Trigger_Handler__c(
				Active__c = false, Asynchronous__c = false, Class__c = 'ACCT_IndividualAccounts_TDTM', Load_Order__c = 3, Object__c = 'Contact', Filter_Field__c = 'Gender__c', Filter_Value__c = 'Male', Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', User_Managed__c = true
		);
		insert myHandler;

		insertTestDefaults();

		// Setup new configuration
        Set<TDTM_Global_API.TdtmToken> newConfig = new Set<TDTM_Global_API.TdtmToken>();
        // Update load order and trigger action
        newConfig.add(new TDTM_Global_API.TdtmToken('AFFL_Affiliations_TDTM', 'Contact', 'AfterInsert;AfterUpdate', 2.2, true, false, null, null, false, 'hed', null));
        // Update load order and trigger action
        newConfig.add(new TDTM_Global_API.TdtmToken('REL_Relationships_Cm_TDTM', 'CampaignMember', 'AfterInsert;AfterUpdate;AfterDelete', 5, true, false, null, null, false, 'hed', null));
        // We'll leave this alone
        newConfig.add(new TDTM_Global_API.TdtmToken('REL_Relationships_Con_TDTM', 'Contact', 'AfterInsert;AfterDelete', 1, true, false, null, null, false, 'hed', null));


		// Instantiate new manager for test.
		TDTM_Manager updateManager = new TDTM_Manager('hed');

		Test.startTest();
		// Note: updateDefaultTdtmConfig will empty defaults
		updateManager.updateDefaultTdtmConfig( newConfig );
		Test.stopTest();

		for( Trigger_Handler__c h : getDbHanders().values() ){
			// Verify Change
			if(h.Class__c == 'AFFL_Affiliations_TDTM'){
				System.assertEquals(h.Trigger_Action__c, 'AfterInsert;AfterUpdate' );
				System.assertEquals(h.Load_Order__c, 2.2 );
				System.assertEquals(h.Owned_by_Namespace__c, 'hed' );
			}
			// Verify Change
			if(h.Class__c == 'REL_Relationships_Cm_TDTM'){
				System.assertEquals(h.Load_Order__c, 5);
				System.assertEquals(h.Owned_by_Namespace__c, 'hed');
				System.assertEquals(h.Trigger_Action__c, 'AfterInsert;AfterUpdate;AfterDelete');
			}
			// Verify NO Change
			if(h.Class__c == 'REL_Relationships_Con_TDTM'){
				System.assertEquals(h.Trigger_Action__c, 'AfterInsert;AfterDelete' );
				System.assertEquals(h.Load_Order__c, 1 );
				System.assertEquals(h.Owned_by_Namespace__c, 'hed' );
			}
			// Verify NO Change
			if(h.Class__c == 'ACCT_IndividualAccounts_TDTM'){
				System.assertEquals(h.Trigger_Action__c, 'AfterInsert;AfterUpdate;AfterDelete' );
				System.assertEquals(h.Load_Order__c, 3 );
				System.assertEquals(h.Active__c, false );
				System.assertEquals(h.User_Managed__c, true );
				System.assertEquals(h.Filter_Field__c, 'Gender__c');
				System.assertEquals(h.Filter_Value__c, 'Male' );
			}
		}
	}

	// Test to make sure a user can override a default and add their own
	@isTest
	public static void userHandlers() {

		insertTestDefaults();

        // Simulate a user modifying a standard Trigger making it user managed
        Trigger_Handler__c mod = [SELECT Id, Owned_by_Namespace__c, Load_Order__c, Trigger_Action__c, User_Managed__c FROM Trigger_Handler__c WHERE Class__c = 'REL_Relationships_Cm_TDTM' LIMIT 1];
        mod.Load_Order__c = 0.1;
        mod.Trigger_Action__c = 'AfterInsert';
        mod.User_Managed__c = true;
        update mod;

		// Simulate a user adding their own handler
		// Exclude Owned_by_Namespace__c and User_Managed__c
		Trigger_Handler__c newHandler = new Trigger_Handler__c(
			Active__c = true,
			Asynchronous__c = false,
			Class__c = 'Contact_Update',
			Load_Order__c = 0.2,
			Object__c = 'Contact',
			Trigger_Action__c = 'BeforeInsert;BeforeUpdate'
		);
		insert newHandler;

		// Setup new configuration
        Set<TDTM_Global_API.TdtmToken> newConfig = new Set<TDTM_Global_API.TdtmToken>();
        // Update load order and trigger action
        newConfig.add(new TDTM_Global_API.TdtmToken('AFFL_Affiliations_TDTM', 'Contact', 'AfterInsert;AfterUpdate', 2, true, false, null, null, false, 'hed', null));
        // Update load order and trigger action
        newConfig.add(new TDTM_Global_API.TdtmToken('REL_Relationships_Cm_TDTM', 'CampaignMember', 'AfterInsert;AfterUpdate;AfterDelete', 2, true, false, null, null, false, 'hed', null));
        // We'll leave this alone
        newConfig.add(new TDTM_Global_API.TdtmToken('REL_Relationships_Con_TDTM', 'Contact', 'AfterInsert;AfterDelete', 1, true, false, null, null, false, 'hed', null));

		// Instantiate new manager for test.
		TDTM_Manager updateManager = new TDTM_Manager('hed');

		Test.startTest();
		// Note: updateDefaultTdtmConfig will empty defaults
		updateManager.updateDefaultTdtmConfig( newConfig );
		Test.stopTest();

		//Make sure all are present and no additional items were created
		System.assertEquals( 4, getDbHanders().size());

		for( Trigger_Handler__c h : getDbHanders().values() ){
			// Verify Change
			if(h.Class__c == 'AFFL_Affiliations_TDTM'){
				System.assertEquals(h.Trigger_Action__c, 'AfterInsert;AfterUpdate' );
				System.assertEquals(h.Load_Order__c, 2 );
			}
			// Verify USER overrides are NOT changed
			if(h.Class__c == 'REL_Relationships_Cm_TDTM'){
				System.assertEquals(h.User_Managed__c, true );
				System.assertEquals(h.Load_Order__c, 0.1 );
				System.assertEquals(h.Trigger_Action__c, 'AfterInsert');
			}
			// Verify NO Change
			if(h.Class__c == 'REL_Relationships_Con_TDTM'){
				System.assertEquals(h.Trigger_Action__c, 'AfterInsert;AfterDelete' );
				System.assertEquals(h.Load_Order__c, 1 );
			}
			// Verify NO Change
			if(h.Class__c == 'Contact_Update'){
				System.assertEquals(h.Trigger_Action__c, 'BeforeInsert;BeforeUpdate' );
				System.assertEquals(h.Load_Order__c, 0.2 );
			}
		}
	}

	//Test to make sure setTDTMConfig can clear the cache after being called
	@isTest
	public static void clearTokenCaches() {

		//Build the token for the new handler
		TDTM_Global_API.TdtmToken newHandlerToken = new TDTM_Global_API.TdtmToken('Contact_Update', 'Contact', 'BeforeInsert;BeforeUpdate', 0.2, true, false, null, null, false, '', null);


        //Populate the cache with default TDTM Tokens
        List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getTdtmConfig();

        //Verify that the cached tokens do not contains new token
        Boolean hasNewHandler = false;
        for(TDTM_Global_API.TdtmToken token : tokens) {
            if(token.targetObject == newHandlerToken.targetObject && token.className == newHandlerToken.className) {
                hasNewHandler = true;
            }
        }
        system.assertEquals(false,hasNewHandler);

        //call the setTdtmConfig to clear the cache and add new trigger handler
		Test.startTest();
		TDTM_Global_API.setTdtmConfig(new List<TDTM_Global_API.TdtmToken>{newHandlerToken});
		Test.stopTest();

		//now verify the old token get cleared
		system.assertEquals(new List<TDTM_Global_API.TdtmToken>(), tokens);

		//get token again and verify the new handler is included
		tokens = TDTM_Global_API.getTdtmConfig();
        hasNewHandler = false;
		for(TDTM_Global_API.TdtmToken token : tokens) {
			if(token.targetObject == newHandlerToken.targetObject && token.className == newHandlerToken.className) {
				hasNewHandler = true;
			}
		}
		system.assertEquals(true,hasNewHandler);
	}

	//Test to make sure we can save Filter Field and Filter Value for default config
	@isTest
	public static void updateDefaultFilterFieldFilterValue() {
		//get default tokens
		List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getDefaultTdtmConfig();

		//Change the Filter Field and Filter Value
		for(TDTM_Global_API.TdtmToken token : tokens) {
			if(token.className == 'REL_Relationships_Con_TDTM') {
				token.filterField = 'Gender__c';
				token.filterValue = 'Male';
			}
		}

		//use setTdtmConfig to save the filter in the DB
		Test.startTest();
		TDTM_Global_API.setTdtmConfig(tokens, 'hed');
		Test.stopTest();

		//verify the filter is saved in DB
		List<Trigger_Handler__c> handlers = [select Id from Trigger_Handler__c where Class__c = 'REL_Relationships_Con_TDTM' and Filter_Field__c = 'Gender__c' and Filter_Value__c = 'Male' ];
		system.assertEquals(1, handlers.size());

	}

	//Test to make sure we can save Filter Field and Filter Value for user's config
	@isTest
	public static void updateUserHandlerFilterFieldFilterValue() {

		//Build Token for User's Trigger Handler
		TDTM_Global_API.TdtmToken newHandlerToken = new TDTM_Global_API.TdtmToken('Contact_Update', 'Contact', 'BeforeInsert;BeforeUpdate', 0.2, true, false, null, null, false, '', null);

		//Save the token into the DB
		TDTM_Global_API.setTdtmConfig(new List<TDTM_Global_API.TdtmToken>{newHandlerToken});

		//Verify that Filter is not in the DB
		Trigger_Handler__c handler = [select Filter_Field__c, Filter_Value__c from Trigger_Handler__c where Class__c = 'Contact_Update'];
		system.assertEquals(null, handler.Filter_Field__c);
		system.assertEquals(null, handler.Filter_Value__c);

		//Get token and add Filter Field and Filter Value
		List<TDTM_Global_API.TdtmToken> tokens = TDTM_Global_API.getTdtmConfig();
		for(TDTM_Global_API.TdtmToken token : tokens) {
			if(token.className == 'Contact_Update') {
				token.filterField = 'Gender__c';
				token.filterValue = 'Male';
			}
		}

		//set Filter field and Filter value
		Test.startTest();
		TDTM_Global_API.setTdtmConfig(tokens);
		Test.stopTest();

		//verify that the Filter is saved in DB
		handler = [select Filter_Field__c, Filter_Value__c from Trigger_Handler__c where Class__c = 'Contact_Update'];
		system.assertEquals('Gender__c', handler.Filter_Field__c);
		system.assertEquals('Male', handler.Filter_Value__c);

	}

	private static Set<TDTM_Global_API.TdtmToken> getBasicDefaults() {
        Set<TDTM_Global_API.TdtmToken> h = new Set<TDTM_Global_API.TdtmToken>();
        h.add(new TDTM_Global_API.TdtmToken('AFFL_Affiliations_TDTM', 'Contact', 'AfterInsert', 1, true, false, null, null, false, 'hed', null));
        h.add(new TDTM_Global_API.TdtmToken('REL_Relationships_Cm_TDTM', 'CampaignMember', 'AfterInsert;AfterUpdate', 1.1, true, false, null, null, false, 'hed', null));
        h.add(new TDTM_Global_API.TdtmToken('REL_Relationships_Con_TDTM', 'Contact', 'AfterInsert;AfterDelete', 1.2, true, false, null, null, false, 'hed', null));
    	return h;
	}

	private static void insertTestDefaults() {
        List<TDTM_Global_API.TdtmToken> tl = new List<TDTM_Global_API.TdtmToken>( getBasicDefaults() );
    	TDTM_Global_API.setTdtmConfig(tl);
	}

	private static Map<Id,Trigger_Handler__c> getDbHanders() {
        return new Map<Id,Trigger_Handler__c>([SELECT Id, Active__c , Asynchronous__c , Class__c , Load_Order__c , Object__c , Trigger_Action__c , Filter_Field__c, Filter_Value__c, User_Managed__c, Owned_by_Namespace__c
        	FROM Trigger_Handler__c ORDER BY Load_Order__c]);
	}

	//Test to make sure trigger handler is skipped if usernames_to_excluded contains current username
	@isTest
	public static void excludeUsernamesSingleUser() {
		UTIL_CustomSettings_API.getSettingsForTests(
				new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

		//Get current user's username
		String currUserName = UserInfo.getUserName();

		//Populate the Usernames_to_Exclude__c value of the trigger handler
		Trigger_Handler__c handler = new Trigger_Handler__c(
				Active__c = true, Asynchronous__c = false, Class__c = 'ACCT_IndividualAccounts_TDTM', Load_Order__c = 3, Object__c = 'Contact', Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Usernames_to_Exclude__c = currUserName);
		insert handler;

		Contact con = UTIL_UnitTestData_API.getContact();

		Test.startTest();
		insert con;
		Test.stopTest();

		//verify that the Admin account is not created for current user
		Contact assertCon = [SELECT Id, AccountId from Contact WHERE Id = :con.Id];
		system.assertEquals(null, assertCon.AccountId);

	}

	//Test to make sure trigger handler is skipped if usernames_to_excluded contains multiple certain usernames
	@isTest
	public static void excludeUsernamesMultipleUser() {
		UTIL_CustomSettings_API.getSettingsForTests(
				new Hierarchy_Settings__c(Account_Processor__c = UTIL_Describe_API.getAdminAccRecTypeID()));

		//Get current user's username
		String currUserName = UserInfo.getUserName();
		User testUserDisabled = UTIL_UnitTestData_API.createNewUserForTests('excludedUser@gmail.com');
		User testUserEnabled = UTIL_UnitTestData_API.createNewUserForTests('notExcludedUser@gmail.com');
		String strUsernames = currUserName + ';' + testUserDisabled.Username;

		//Populate the Usernames_to_Exclude__c value of the trigger handler
		Trigger_Handler__c handler = new Trigger_Handler__c(
				Active__c = true, Asynchronous__c = false, Class__c = 'ACCT_IndividualAccounts_TDTM', Load_Order__c = 3, Object__c = 'Contact', Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', Usernames_to_Exclude__c = strUsernames);
		insert handler;

		Contact con = UTIL_UnitTestData_API.getContact();
		Contact con2 = UTIL_UnitTestData_API.getContact();
		Contact con3 = UTIL_UnitTestData_API.getContact();

		Test.startTest();
		insert con;
		System.runAs(testUserDisabled) {
			insert con2;
		}
		System.runAs(testUserEnabled) {
			insert con3;
		}
		Test.stopTest();

		//verify that the Admin account is not created for current user
		Contact assertCon = [SELECT Id, AccountId from Contact WHERE Id = :con.Id];
		system.assertEquals(null, assertCon.AccountId);
		Contact assertCon2 = [SELECT Id, AccountId from Contact WHERE Id = :con2.Id];
		system.assertEquals(null, assertCon2.AccountId);
		Contact assertCon3 = [SELECT Id, AccountId from Contact WHERE Id = :con3.Id];
		system.assertNotEquals(null, assertCon3.AccountId);

	}


}