/*
    Copyright (c) 2020, Salesforce.org
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
* @date 2020
* @group Relationships
* @group-content ../../ApexDocContent/Relationships.htm
* @description Model for Reciprocal Relationship Mappings.
*/
public with sharing class MODL_ReciprocalRelationshipMapping {

    // relationshipName of type String representing the type of relationship this applies to
    // isActive of type Boolean representing if the mapping is active
    // femaleRelationshipType of type String representing the female type for the reciprocal relationship
    // maleRelationshipType of type String representing the male type for the reciprocal relationship
    // neutralRelationshipType of type String representing the neutral type for the reciprocal relationship


    public String relationshipName { get; private set; }
    public Boolean isActive { get; private set; }
    public String femaleRelationshipType { get; private set; }
    public String maleRelationshipType { get; private set; }
    public String neutralRelationshipType { get; private set; }

    public MODL_ReciprocalRelationshipMapping(Relationship_c relationshipLookup) {
        // Takes in a Relationship_Lookup__c
        // ❓Assign variables to matching values in Relationship_Lookup__c
        this.relationshipName = '';
        this.isActive = false;
        this.femaleRelationshipType = '';
        this.maleRelationshipType = '';
        this.neutralRelationshipType = '';         
    }

    public Boolean hasFemaleValue() {
        return this.femaleRelationshipType != null;
    }

    public Boolean hasMaleValue() {
        return this.maleRelationshipType != null;
    }
}