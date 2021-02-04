({
  renderIcon: function(component) {
    var prefix = "slds-";
    var size = component.get("v.size");
    var name = component.get("v.name");
    var classname = component.get("v.class");
    var category = component.get("v.category");

    var containerClassName = [
        prefix+"icon__container",
        prefix+"icon-"+category+"-"+name,
        classname
        ].join(' ');
        
    component.set("v.containerClass", containerClassName);
  }
})