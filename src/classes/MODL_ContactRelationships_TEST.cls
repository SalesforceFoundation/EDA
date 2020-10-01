@isTest
public with sharing class MODL_ContactRelationships_TEST {
    /**************************************************************************************************************************
    * @description Test method to verify that addRelationship() appends additional Relationship records to an existing list of 
    * records for a Contact Relationships model.
    **************************************************************************************************************************/
    @isTest 
    private static void addRelationshipWithExisting(){
        List<MODL_ContactRelationships> conRelsModelsList = MODL_ContactRelationships_TEST.getContactRelationshipsModelList(5);

        for (MODL_ContactRelationships conRelsMod : conRelsModelsList){
            for (Integer i = 0; i < 2; i++){
                Id relatedConFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, relatedConFakeId, 'Brother');
                conRelsMod.addRelationship(rel);
            }
        }

        Test.startTest();
        for (MODL_ContactRelationships conRelsMod : conRelsModelsList){
            for (Integer i = 0; i < 5; i++){
                Id relatedConFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, relatedConFakeId, 'Aunt');
                conRelsMod.addRelationship(rel);
            }
                    
            System.assertEquals(7, conRelsMod.relationshipList.size(), 'Contact Relationships model should have 5 new Relationship records added to existing 2 records.');
            System.assertEquals(7, conRelsMod.relationshipByTypeByRelatedContactId.keySet().size(), 'There should be 7 total related contact mappings for Contact Relationships model.');

            for (Id relConId : conRelsMod.relationshipByTypeByRelatedContactId.keySet()){
                for (String relType : conRelsMod.relationshipByTypeByRelatedContactId.get(relConId).keySet()){
                    System.assertEquals(true, (relType == 'Brother' || relType == 'Aunt'), 'Relationship types in Contact Relationships model should be Brother or Aunt only.');
                }
            }
        
        }
        Test.stopTest();
    }

    /**************************************************************************************************************************
    * @description Test method to verify that addRelationship() adds new Relationship records to an empty list of 
    * records for a Contact Relationships model.
    **************************************************************************************************************************/
    @isTest 
    private static void addRelationshipWithoutExisting(){
        List<MODL_ContactRelationships> conRelsModelsList = MODL_ContactRelationships_TEST.getContactRelationshipsModelList(5);

        Test.startTest();
        for (MODL_ContactRelationships conRelsMod : conRelsModelsList){

            for (Integer i = 0; i < 5; i++){
                Id relatedConFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
                Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(conRelsMod.contactId, relatedConFakeId, 'Aunt');
                conRelsMod.addRelationship(rel);
            }
                    
            System.assertEquals(5, conRelsMod.relationshipList.size(), 'Contact Relationships model should be associated with 5 new Relationship records.');
        }
        Test.stopTest();
    }

    @isTest 
    private static void getRelatedContactIdSetTrue(){

    }

    @isTest 
    private static void getRelatedContactIdSetTrue(){
        
    }

    @isTest 
    private static void getRelationshipTrue(){
        
    }

    @isTest 
    private static void getRelationshipTrue(){
        
    }

    @isTest 
    private static void isEmptyTrue(){

    }

    @isTest 
    private static void isEmptyFalse(){
        
    }
    /**************************************************************************************************************************
    * @description Helper method to generate a list of Contact Relationships models.
    * @param contactsCount The number of Contacts to associate with Contact Relationships models.
    * @return A list of MODL_ContactRelationships.
    **************************************************************************************************************************/ 
    private static List<MODL_ContactRelationships> getContactRelationshipsModelList(Integer contactsCount){
        List<MODL_ContactRelationships> conRelsModelsList = new List<MODL_ContactRelationships>();
        List<Contact> contactsList = UTIL_UnitTestData_TEST.getMultipleTestContacts(contactsCount);
        
        for (Contact con : contactsList){
            Id conFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);
            con.Id = conFakeId;

            MODL_ContactRelationships conRelsModel = new MODL_ContactRelationships(conFakeId);
            conRelsModelsList.add(conRelsModel);
        }

        return conRelsModelsList;
    }

    /**
     * createRelationshipsForContact description
     * @param  relationshipsCount relationshipsCount description
     * @param  contactRelsModel   contactRelsModel description
     * @return                    return description
     */
    // private static Map<Id, List<Relationship__c>> createRelationshipsForContact(Integer relationshipsCount, MODL_ContactRelationships contactRelsModel){
    //     Map<Id, List<Relationship__c>> relationshipsListByContactId = new Map<Id, List<Relationship__c>>();
    //     List<Relationship__c> relsToAddList = new List<Relationship__c>();

    //     Id relatedConFakeId = UTIL_UnitTestData_TEST.getFakeId(Contact.SObjectType);

    //     for (Integer i = 0; i < relationshipsCount; i++){
    //         Relationship__c rel = UTIL_UnitTestData_TEST.getRelationship(contactRelsModel.contactId, relatedConFakeId, 'Aunt');
    //         relsToAddList.add(rel);
    //     }

    //     relationshipsListByContactId.put(contactRelsModel.contactId, relsToAddList);
        
    //     return relationshipsListByContactId;
    // }
}
