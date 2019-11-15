public class CCON_AffiliationBackfill_BATCH implements Database.Batchable<SObject>{
	
    public Database.Querylocator start(Database.BatchableContext bc) {
        Id studentCCRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        System.debug('CCON_BATCH METHOD-->'); 
        String query = 'SELECT Id, Program_Enrollment__c ' + 
                        'FROM Course_Enrollment__c ' + 
            			'WHERE Affiliation__c = NULL AND Program_Enrollment__c != NULL AND RecordTypeId = :studentCCRecordTypeId'; 
        System.debug('CCON_BATCH -->' + query); 
        return Database.getQueryLocator(query);  
    }
    
    public void execute(Database.BatchableContext bc, List<Course_Enrollment__c> returnCourseEnrollments){
        List<Id> pEnrollmentID = new List<Id>(); 
        List<Course_Enrollment__c> courseEnrollmentsToUpdate = new List<Course_Enrollment__c>(); 
        
        if (returnCourseEnrollments.size () > 0) {
            
            for (Integer i = 0; i < returnCourseEnrollments.size(); i++) {
                Course_Enrollment__c enroll = returnCourseEnrollments[i];
                if (enroll.Program_Enrollment__c != NULL) {
                    pEnrollmentID.add(enroll.Program_Enrollment__c); 
                }
            }
            
            if (pEnrollmentID.size () > 0) {
                List<Program_Enrollment__c> queryPE = [SELECT Id, Affiliation__c, Account__c
                                                  FROM Program_Enrollment__c 
                                                  WHERE Id = :pEnrollmentID]; 
                Map<Id, Program_Enrollment__c> pEnrollmentsMap = new Map<Id, Program_Enrollment__c>(queryPE); 
                
                for (Course_Enrollment__c courseEnroll : returnCourseEnrollments) {
                    courseEnroll.Affiliation__c = pEnrollmentsMap.get(courseEnroll.Program_Enrollment__c).Affiliation__c;
                    courseEnroll.Affiliation__c = pEnrollmentsMap.get(courseEnroll.Program_Enrollment__c).Account__c;
                    courseEnrollmentsToUpdate.add(courseEnroll); 
                }
                
            }
        }
        
        if (courseEnrollmentsToUpdate.size() > 0) {
            System.debug('CCON_BATCH B4Update ->' + courseEnrollmentsToUpdate); 
            update courseEnrollmentsToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext bc) {}
}