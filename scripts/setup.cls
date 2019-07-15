public static void qaSetup() {
  enableCourseConnections();
}

public static void enableCourseConnections() {

    Schema.DescribeSObjectResult r = Schema.SObjectType.%%%NAMESPACE%%%Course_Enrollment__c;
  Map<String,Schema.RecordTypeInfo> rtInfosByName = r.getRecordTypeInfosByName();

  %%%NAMESPACE%%%Hierarchy_Settings__c settings = %%%NAMESPACE%%%Hierarchy_Settings__c.getOrgDefaults();

  settings.put('%%%NAMESPACE%%%Enable_Course_Connections__c', true);
  settings.put('%%%NAMESPACE%%%Validate_Program_Plan_for_Nested_PR__c', true);
  settings.put('%%%NAMESPACE%%%Affl_ProgEnroll_Set_Role__c', true);
  settings.put('%%%NAMESPACE%%%Affl_ProgEnroll_Copy_End_Date__c', true);
  settings.put('%%%NAMESPACE%%%Affl_ProgEnroll_Copy_Start_Date__c', true);
  settings.put('%%%NAMESPACE%%%Student_RecType__c', rtInfosByName.get('Student').getRecordTypeId());
  settings.put('%%%NAMESPACE%%%Faculty_RecType__c', rtInfosByName.get('Faculty').getRecordTypeId());

  upsert settings;
}
