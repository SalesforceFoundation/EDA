({
  saveSettings : function(component) {
    var typeCheckboxes = component.find("checkboxIds");
    if (typeCheckboxes != null) {
      var selectedTypes = "";
      for(var i = 0; i <= typeCheckboxes.length; i += 1) {
        var checkbox = typeCheckboxes[i];
        if(typeof checkbox !== 'undefined') {
          var checkboxVal = checkbox.get("v.value");
          if(checkboxVal === true) {
            var checkboxText = checkbox.get("v.text");
            selectedTypes += checkboxText + '; ';
          }
        }
      }
      var setting = component.get("v.setting");
      setting = selectedTypes;
      component.set("v.setting", setting);
    }
  }
})