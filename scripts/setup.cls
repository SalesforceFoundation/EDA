public static void qaSetup() {
    configQACustomSettings();
}

//Wrapper class to config QA custom settings
private static void configQACustomSettings() {
    %%%NAMESPACE%%%Hierarchy_Settings__c orgSettings = UTIL_CustomSettingsFacade.getSettings();
    enableCourseConnections(orgSettings);
    enableSpecifyRoleForCreatedAffiliations(orgSettings);
    enableCopyAffiliationStartDateFromProgramEnrollment(orgSettings);
    enableCopyAffiliationEndDateFromProgramEnrollment(orgSettings);  
    upsert orgSettings;
}

//Enable course connections
private static void enableCourseConnections(%%%NAMESPACE%%%Hierarchy_Settings__c settings) {
    Schema.DescribeSObjectResult r = Schema.SObjectType.%%%NAMESPACE%%%Course_Enrollment__c;
    Map<String,Schema.RecordTypeInfo> rtInfosByName = r.getRecordTypeInfosByName();
    settings.put('%%%NAMESPACE%%%Enable_Course_Connections__c', true);
    settings.put('%%%NAMESPACE%%%Student_RecType__c', rtInfosByName.get('Student').getRecordTypeId());
    settings.put('%%%NAMESPACE%%%Faculty_RecType__c', rtInfosByName.get('Faculty').getRecordTypeId());
}

//Enable Specify Role For Created Affiliations
private static void enableSpecifyRoleForCreatedAffiliations(%%%NAMESPACE%%%Hierarchy_Settings__c settings) {   
    if (settings.%%%NAMESPACE%%%Affl_ProgEnroll_Set_Role__c == null 
        || settings.%%%NAMESPACE%%%Enable_New_Preferred_Phone_Sync__c != true) {
        settings.%%%NAMESPACE%%%Affl_ProgEnroll_Set_Role__c = true;
    }
}

//Enable Copy Affiliation Start Date From Program Enrollment
private static void enableCopyAffiliationStartDateFromProgramEnrollment(%%%NAMESPACE%%%Hierarchy_Settings__c settings) {
    if (settings.%%%NAMESPACE%%%Affl_ProgEnroll_Copy_Start_Date__c == null 
        || settings.%%%NAMESPACE%%%Affl_ProgEnroll_Copy_Start_Date__c != true) {
        settings.%%%NAMESPACE%%%Affl_ProgEnroll_Copy_Start_Date__c = true;
    }
}

//Enable Copy Affiliation End Date From Program Enrollment
private static void enableCopyAffiliationEndDateFromProgramEnrollment(%%%NAMESPACE%%%Hierarchy_Settings__c settings) {
    if (settings.%%%NAMESPACE%%%Affl_ProgEnroll_Copy_End_Date__c == null 
        || settings.%%%NAMESPACE%%%Affl_ProgEnroll_Copy_End_Date__c != true) {
        settings.%%%NAMESPACE%%%Affl_ProgEnroll_Copy_End_Date__c = true;
    }
}
