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
 * @description A Class to setup of the default TDTM configuration for processing on package 
 * installs. Global to allow packages with dependencies on HEDA to easily process their own Trigger 
 * handlers.
 */
public class TDTM_Manager {

	public String namespace {get;set;}
	public Map<Id,Trigger_Handler__c> currentHandlers;
	public Set<TDTM_Global_API.TdtmToken> currentTokens;

    private List<Trigger_Handler__c> toDelete = new List<Trigger_Handler__c>();
    private List<Trigger_Handler__c> toUpsert = new List<Trigger_Handler__c>();
    
    /*******************************************************************************************************
    * @description Constructor. Sets namespace, currentHandlers, and currentTokens default properties.
    * @parameter nm A String representing the namespace to query from.
    *********************************************************************************************************/
	public TDTM_Manager(String nm) {  
		this.namespace = nm;
		this.currentHandlers = new Map<Id,Trigger_Handler__c>([SELECT Id, Active__c,  Asynchronous__c,  Object__c,  Load_Order__c,  Class__c,  Trigger_Action__c,  User_Managed__c, Owned_by_Namespace__c FROM Trigger_Handler__c WHERE Owned_by_Namespace__c =: this.namespace ORDER BY Load_Order__c ]);

		this.currentTokens = getTokenSet(this.currentHandlers);
	}

    /*******************************************************************************************************
    * @description Update the existing Trigger Handlers in the database. Will also delete Handlers not 
    * included in the default configuration.
    * @parameter newTokenSet A set of TDTM Tokens that represent a new configuration to compare to existing
    * @return void
    *********************************************************************************************************/
	public void updateDefaultTdtmConfig(Set<TDTM_Global_API.TdtmToken> newTokenSet) {

		// Check for changes
		if(newTokenSet != this.currentTokens) {

			for( TDTM_Global_API.TdtmToken existingToken : this.currentTokens ){

				// If the configuration does not include the item it changed
				if(!newTokenSet.contains(existingToken)) {

			        // Using Class and Target Object fields we check if the new set contains a matching token
					TDTM_Global_API.TdtmToken match = existingToken.getmatch( newTokenSet );

					// Explicitly skip over User Managed tokens
			        if(existingToken.userManaged && match != null ) {
			        	// Skip if User Managed
			        	newTokenSet.remove(match);
			        
			        // Check if the match is different, if so we'll update the current token
			        } else if( !existingToken.userManaged && match != null && !existingToken.equals(match) ) {
						
						// Update current handler value
						this.toUpsert.add( mergeToken(currentHandlers.get(existingToken.handlerId), match ) );
						// mark processed if updated
						newTokenSet.remove(match);

					// Removed from default config
					} else if ( !existingToken.userManaged && match == null ) {
						
						// Remove from existing list and setup for deletion
						this.toDelete.add(currentHandlers.get(existingToken.handlerId));
					}
				}

				// mark processed if not updated or deleted. This skips
				newTokenSet.remove(existingToken);
			}
			
			// Check for new items to add since these didn't match against existing items
			if(newTokenSet.size() > 0) {
				for( TDTM_Global_API.TdtmToken newToken: newTokenSet ){
					this.toUpsert.add( mergeToken(new Trigger_Handler__c() ,newToken ) );
				}
			}
		}
		
		if(this.toUpsert.size()>0) {
			upsert this.toUpsert;		

			// Update class properties because we have updates.
			this.currentHandlers = new Map<Id,Trigger_Handler__c>(this.toUpsert);
			this.currentTokens = this.getTokenSet(this.currentHandlers);
		} 

		if(this.toDelete.size()>0) {
			delete this.toDelete;
		}
	}


    /*******************************************************************************************************
    * @description Create an Set of TDTM Tokens
    * @parameter hs A Map of TDTM trigger handlers representing a new default configuration.
    * @return A set of TDTM Tokens from the Trigger handlers that were passed in.
    *********************************************************************************************************/
	public Set<TDTM_Global_API.TdtmToken> getTokenSet(Map<Id,Trigger_Handler__c> hs) {
        Set<TDTM_Global_API.TdtmToken> ts = new Set<TDTM_Global_API.TdtmToken>();

		for( Trigger_Handler__c h: hs.values() ) {

			TDTM_Global_API.TdtmToken newToken = new TDTM_Global_API.TdtmToken( h.Class__c, h.Object__c, h.Trigger_Action__c, h.Load_Order__c, h.Active__c, h.Asynchronous__c, null, null, h.User_Managed__c, h.Owned_by_Namespace__c);
		
			// Conditionally set Id
			if(h.Id != null) {
				newToken.handlerId = h.Id;
			}
			ts.add(newToken );
		}

		return ts;
	} 

	/***
		Merge token data into Trigger Handler. Has a special case to check if the token does not contain an ID. If not, it is a new handler so it adds "classname" and "targetObject" properties.
	***/
	private Trigger_Handler__c mergeToken(Trigger_Handler__c h, TDTM_Global_API.TdtmToken t) {
        h.Trigger_Action__c = t.actions;
        h.Active__c = t.active;
        h.Load_Order__c = t.loadOrder;
        h.Asynchronous__c = t.async;
        h.User_Managed__c = t.userManaged;
        h.Owned_by_Namespace__c = t.ownedByNamespace;

        if(t.handlerId == null) {
			h.Class__c = t.className;  
			h.Object__c = t.targetObject;
        }
        return h;
	}
}