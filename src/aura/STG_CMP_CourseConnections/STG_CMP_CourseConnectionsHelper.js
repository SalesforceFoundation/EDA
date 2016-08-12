({
  init : function(component, event) {
    this.getCourseConnectionRecordTypes(component);
  },

  onStudentSelectChange : function(component) {
    var selectedVal = component.find("studentRecordTypesDropDown").get("v.value");
    component.set("v.hierarchySettings.Default_Enrolled_Student_RecordType_Id__c", selectedVal);
  },

  onFacultySelectChange : function(component) {
    var selectedVal = component.find("facultyRecordTypesDropDown").get("v.value");
    component.set("v.hierarchySettings.Default_Faculty_RecordType_Id__c", selectedVal);
  },

  getCourseConnectionRecordTypes : function(component) {
      var action = component.get("c.getRecTypesMapByName");
      action.setParams({ objectName : 'Course_Enrollment__c' });
      var recordTypes = [];

      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              for (var key in response.getReturnValue()) {
                  recordTypes.push({name: key, id: response.getReturnValue()[key]});
              }
              component.set("v.courseConnectionRecordTypes", recordTypes);
          }
          else if (state === "ERROR") {
              var errors = response.getError();
              if (errors) {
                  if (errors[0] && errors[0].message) {
                      console.log("Error message: " +
                               errors[0].message);
                  }
              } else {
                  console.log("Unknown error");
              }
          }
      });
      $A.enqueueAction(action);
  }
})